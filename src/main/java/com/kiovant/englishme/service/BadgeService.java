package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.Badge;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserBadge;
import com.kiovant.englishme.entity.UserLevel;
import com.kiovant.englishme.repository.BadgeRepository;
import com.kiovant.englishme.repository.UserBadgeRepository;
import com.kiovant.englishme.repository.UserLessonProgressRepository;
import com.kiovant.englishme.repository.UserLevelRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * Tự động cấp badge khi user đạt điều kiện (streak / tổng XP / qua CEFR level / bài đầu tiên).
 *
 * <p>Thiết kế phụ thuộc MỘT CHIỀU: BadgeService chỉ đọc dữ liệu (UserLevel,
 * UserLessonProgress, Badge) — KHÔNG inject XpService. Ngược lại {@link XpService#grant}
 * gọi {@link #awardEligible(User)} ở cuối, nên mọi lần cộng XP (kể cả level_bonus khi
 * lên level, streak cập nhật) đều kéo theo việc rà & cấp badge. Tránh vòng phụ thuộc.
 *
 * <p>Điều kiện chuẩn hóa ở V72: condition_type ∈ {streak, total_xp, cefr_level, first_lesson},
 * condition_value = ngưỡng số. cefr_level value là bậc 1..6 (A1..C2).
 */
@Service
public class BadgeService {

    private static final Logger log = LoggerFactory.getLogger(BadgeService.class);

    public static final String COND_STREAK = "streak";
    public static final String COND_TOTAL_XP = "total_xp";
    public static final String COND_CEFR_LEVEL = "cefr_level";
    public static final String COND_FIRST_LESSON = "first_lesson";

    /** Map bậc CEFR -> số, để so sánh "đạt level >= ngưỡng". */
    private static final Map<String, Integer> CEFR_RANK = Map.of(
            "A1", 1, "A2", 2, "B1", 3, "B2", 4, "C1", 5, "C2", 6
    );

    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final UserLevelRepository userLevelRepository;
    private final UserLessonProgressRepository lessonProgressRepository;

    public BadgeService(BadgeRepository badgeRepository,
                        UserBadgeRepository userBadgeRepository,
                        UserLevelRepository userLevelRepository,
                        UserLessonProgressRepository lessonProgressRepository) {
        this.badgeRepository = badgeRepository;
        this.userBadgeRepository = userBadgeRepository;
        this.userLevelRepository = userLevelRepository;
        this.lessonProgressRepository = lessonProgressRepository;
    }

    /**
     * Rà mọi badge đang bật, cấp những badge user vừa đủ điều kiện mà chưa có.
     * Chạy trong cùng transaction của caller (REQUIRED) — an toàn vì chỉ INSERT
     * user_badge mới, không động total_xp.
     *
     * @return danh sách badge VỪA cấp (mới) — rỗng nếu không có badge mới. FE
     *         dùng để hiện popup ăn mừng ngay khi mở khoá (trước đây chỉ trả số
     *         đếm → FE không biết badge nào để show).
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public List<Badge> awardEligible(User user) {
        if (user == null || user.getId() == null) {
            return List.of();
        }
        List<Badge> active = badgeRepository.findByIsActiveTrue();
        if (active.isEmpty()) {
            return List.of();
        }

        int currentStreak = user.getCurrentStreak() == null ? 0 : user.getCurrentStreak();
        int totalXp = user.getTotalXp() == null ? 0 : user.getTotalXp();
        // Tính sẵn 1 lần (lazy) để không query lặp cho mỗi badge cùng loại.
        Integer cefrRank = null;
        Long completedLessons = null;

        List<Badge> awarded = new java.util.ArrayList<>();
        for (Badge b : active) {
            String type = b.getConditionType();
            int threshold = b.getConditionValue() == null ? 0 : b.getConditionValue();
            boolean eligible;

            switch (type) {
                case COND_STREAK -> eligible = currentStreak >= threshold;
                case COND_TOTAL_XP -> eligible = totalXp >= threshold;
                case COND_CEFR_LEVEL -> {
                    if (cefrRank == null) {
                        cefrRank = resolveCefrRank(user);
                    }
                    eligible = cefrRank >= threshold;
                }
                case COND_FIRST_LESSON -> {
                    if (completedLessons == null) {
                        completedLessons = lessonProgressRepository
                                .countByUserIdAndStatus(user.getId(), "completed");
                    }
                    eligible = completedLessons >= 1;
                }
                default -> eligible = false; // loại lạ -> bỏ qua, không vỡ.
            }

            if (eligible && !userBadgeRepository.existsByUser_IdAndBadge_Id(user.getId(), b.getId())) {
                UserBadge ub = new UserBadge();
                ub.setUser(user);
                ub.setBadge(b);
                userBadgeRepository.save(ub);
                awarded.add(b);
                log.info("Badge '{}' awarded to user {}", b.getName(), user.getId());
            }
        }
        return awarded;
    }

    // ── Admin CRUD ───────────────────────────────────────────────────────────

    /** Các loại điều kiện hợp lệ cho admin chọn (dropdown). */
    public static final List<String> CONDITION_TYPES =
            List.of(COND_STREAK, COND_TOTAL_XP, COND_CEFR_LEVEL, COND_FIRST_LESSON);

    @Transactional(readOnly = true)
    public List<Badge> listAll() {
        return badgeRepository.findAllByOrderByConditionTypeAscConditionValueAsc();
    }

    /**
     * Tạo / cập nhật badge. {@code id} null -> tạo mới.
     * first_lesson không cần ngưỡng -> conditionValue ép null.
     */
    @Transactional
    public void save(java.util.UUID id, String name, String description, String iconUrl,
                     String conditionType, Integer conditionValue, boolean isActive) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Tên badge không được trống.");
        }
        if (!CONDITION_TYPES.contains(conditionType)) {
            throw new IllegalArgumentException("Loại điều kiện không hợp lệ: " + conditionType);
        }
        boolean needsValue = !COND_FIRST_LESSON.equals(conditionType);
        if (needsValue && (conditionValue == null || conditionValue <= 0)) {
            throw new IllegalArgumentException("Ngưỡng phải là số dương cho loại " + conditionType + ".");
        }

        Badge b = id == null ? new Badge() : badgeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy badge."));
        b.setName(name.trim());
        b.setDescription(description == null ? null : description.trim());
        b.setIconUrl(iconUrl == null || iconUrl.isBlank() ? null : iconUrl.trim());
        b.setConditionType(conditionType);
        b.setConditionValue(needsValue ? conditionValue : null);
        b.setIsActive(isActive);
        badgeRepository.save(b);
    }

    @Transactional
    public void delete(java.util.UUID id) {
        // user_badge FK -> badge (không cascade) nên gỡ lượt cấp trước.
        userBadgeRepository.deleteByBadge_Id(id);
        badgeRepository.deleteById(id);
    }

    /** Bậc CEFR của user: ưu tiên current_level (curriculum), fallback users.cefr_level. */
    private int resolveCefrRank(User user) {
        String level = userLevelRepository.findById(user.getId())
                .map(UserLevel::getCurrentLevel)
                .filter(s -> s != null && !s.isBlank())
                .orElse(user.getCefrLevel());
        if (level == null) {
            return 0;
        }
        return CEFR_RANK.getOrDefault(level.trim().toUpperCase(), 0);
    }
}
