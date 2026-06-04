package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.NotificationResponse;
import com.kiovant.englishme.dto.UnreadCountResponse;
import com.kiovant.englishme.entity.Notification;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.FlashcardProgressRepository;
import com.kiovant.englishme.repository.NotificationRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Thông báo in-app (polling, không FCM). Bảng {@code notification} là source-of-truth.
 *
 * <p>Thông báo "derived" (REVIEW_DUE, STREAK_RISK, PLACEMENT_SUGGESTION) được sinh
 * LAZY mỗi lần đọc qua {@link #ensureFresh(User)} — không dùng scheduler. Mỗi thông báo
 * mang một {@code dedupKey} (UNIQUE theo user) nên chỉ tạo 1 lần trong cửa sổ tự nhiên
 * của nó; nhờ vậy trạng thái {@code isRead} sống sót qua các lần regenerate và không trùng.
 */
@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    /** Hằng số type (mirror enum-as-varchar của codebase). */
    public static final String TYPE_REVIEW_DUE = "REVIEW_DUE";
    public static final String TYPE_STREAK_RISK = "STREAK_RISK";
    public static final String TYPE_LESSON_UNLOCKED = "LESSON_UNLOCKED";
    public static final String TYPE_PLACEMENT_SUGGESTION = "PLACEMENT_SUGGESTION";
    public static final String TYPE_SYSTEM = "SYSTEM";

    private static final int MAX_LIMIT = 50;

    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;
    private final FlashcardProgressRepository flashcardProgressRepository;

    public NotificationService(UserRepository userRepository,
                               NotificationRepository notificationRepository,
                               FlashcardProgressRepository flashcardProgressRepository) {
        this.userRepository = userRepository;
        this.notificationRepository = notificationRepository;
        this.flashcardProgressRepository = flashcardProgressRepository;
    }

    @Transactional
    public List<NotificationResponse> list(String firebaseUid, boolean unreadOnly, int limit) {
        User user = loadUser(firebaseUid);
        ensureFresh(user);
        int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
        PageRequest page = PageRequest.of(0, safeLimit);
        List<Notification> rows = unreadOnly
                ? notificationRepository.findByUser_IdAndIsReadFalseOrderByCreatedAtDesc(user.getId(), page)
                : notificationRepository.findByUser_IdOrderByCreatedAtDesc(user.getId(), page);
        return rows.stream().map(this::toResponse).toList();
    }

    @Transactional
    public UnreadCountResponse unreadCount(String firebaseUid) {
        User user = loadUser(firebaseUid);
        ensureFresh(user);
        return new UnreadCountResponse(notificationRepository.countByUser_IdAndIsReadFalse(user.getId()));
    }

    @Transactional
    public void markRead(String firebaseUid, UUID id) {
        User user = loadUser(firebaseUid);
        Notification n = notificationRepository.findByIdAndUser_Id(id, user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found"));
        if (!Boolean.TRUE.equals(n.getIsRead())) {
            n.setIsRead(true);
            n.setReadAt(LocalDateTime.now());
            notificationRepository.save(n);
        }
    }

    @Transactional
    public void markAllRead(String firebaseUid) {
        User user = loadUser(firebaseUid);
        notificationRepository.markAllRead(user.getId(), LocalDateTime.now());
    }

    /**
     * Tạo thông báo nếu chưa tồn tại (theo dedupKey). Public để caller event-driven
     * tương lai (vd CurriculumService khi mở unit) tái dùng mà không lặp lại logic dedup.
     */
    @Transactional
    public void createIfAbsent(User user, String type, String title, String body,
                               String actionRoute, String dedupKey) {
        if (notificationRepository.existsByUser_IdAndDedupKey(user.getId(), dedupKey)) {
            return;
        }
        Notification n = new Notification();
        n.setUser(user);
        n.setType(type);
        n.setTitle(title);
        n.setBody(body);
        n.setActionRoute(actionRoute);
        n.setDedupKey(dedupKey);
        n.setIsRead(false);
        notificationRepository.save(n);
    }

    // ---------------------------------------------------------------------
    // Generator: sinh derived notification từ state hiện tại của user.
    // Mỗi rule bọc try/catch để một lỗi sinh không làm vỡ luồng đọc (demo reliability).
    // ---------------------------------------------------------------------
    private void ensureFresh(User user) {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        // 1) REVIEW_DUE — còn thẻ SM-2 đến hạn ôn (cross-desk). 1 thông báo/ngày.
        try {
            long due = flashcardProgressRepository.countAllDueProgress(user.getId(), now);
            if (due >= 1) {
                createIfAbsent(
                        user,
                        TYPE_REVIEW_DUE,
                        "Ôn tập từ vựng",
                        "Bạn có " + due + " thẻ cần ôn tập hôm nay.",
                        "/vocab",
                        "review_due:" + today
                );
            }
        } catch (Exception e) {
            log.warn("ensureFresh REVIEW_DUE failed for user {}: {}", user.getId(), e.getMessage());
        }

        // 2) STREAK_RISK — đang có streak nhưng hôm nay chưa kiếm XP. 1 thông báo/ngày.
        try {
            int streak = user.getCurrentStreak() == null ? 0 : user.getCurrentStreak();
            LocalDate lastXp = user.getLastXpDate();
            boolean earnedToday = today.equals(lastXp);
            if (streak > 0 && !earnedToday) {
                createIfAbsent(
                        user,
                        TYPE_STREAK_RISK,
                        "Giữ chuỗi học tập",
                        "Chuỗi " + streak + " ngày của bạn sắp mất! Học một chút để giữ streak.",
                        "/vocab",
                        "streak_risk:" + today
                );
            }
        } catch (Exception e) {
            log.warn("ensureFresh STREAK_RISK failed for user {}: {}", user.getId(), e.getMessage());
        }

        // 3) PLACEMENT_SUGGESTION — chưa làm placement test. Đúng 1 lần/user.
        try {
            if (!Boolean.TRUE.equals(user.getIsOnboarded())) {
                createIfAbsent(
                        user,
                        TYPE_PLACEMENT_SUGGESTION,
                        "Kiểm tra trình độ",
                        "Làm bài kiểm tra xếp lớp để nhận lộ trình học phù hợp với bạn.",
                        "/placement-test",
                        "placement"
                );
            }
        } catch (Exception e) {
            log.warn("ensureFresh PLACEMENT_SUGGESTION failed for user {}: {}", user.getId(), e.getMessage());
        }
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private NotificationResponse toResponse(Notification n) {
        return new NotificationResponse(
                n.getId(),
                n.getType(),
                n.getTitle(),
                n.getBody(),
                n.getActionRoute(),
                Boolean.TRUE.equals(n.getIsRead()),
                n.getCreatedAt()
        );
    }
}
