package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.UserDetailDto;
import com.kiovant.englishme.entity.Badge;
import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.ExerciseSession;
import com.kiovant.englishme.entity.PronunciationAttempt;
import com.kiovant.englishme.entity.StudySession;
import com.kiovant.englishme.entity.TestSession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserBadge;
import com.kiovant.englishme.repository.BadgeRepository;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import com.kiovant.englishme.repository.FlashcardProgressRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.StudySessionRepository;
import com.kiovant.englishme.repository.TestSessionRepository;
import com.kiovant.englishme.repository.UserBadgeRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminUserService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ISO_LOCAL_DATE;

    private final UserRepository userRepository;
    private final StudySessionRepository studySessionRepository;
    private final ExerciseSessionRepository exerciseSessionRepository;
    private final TestSessionRepository testSessionRepository;
    private final PronunciationAttemptRepository pronunciationAttemptRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final BadgeRepository badgeRepository;
    private final DeskRepository deskRepository;
    private final FlashcardRepository flashcardRepository;
    private final FlashcardProgressRepository flashcardProgressRepository;

    public AdminUserService(UserRepository userRepository,
                            StudySessionRepository studySessionRepository,
                            ExerciseSessionRepository exerciseSessionRepository,
                            TestSessionRepository testSessionRepository,
                            PronunciationAttemptRepository pronunciationAttemptRepository,
                            UserBadgeRepository userBadgeRepository,
                            BadgeRepository badgeRepository,
                            DeskRepository deskRepository,
                            FlashcardRepository flashcardRepository,
                            FlashcardProgressRepository flashcardProgressRepository) {
        this.userRepository = userRepository;
        this.studySessionRepository = studySessionRepository;
        this.exerciseSessionRepository = exerciseSessionRepository;
        this.testSessionRepository = testSessionRepository;
        this.pronunciationAttemptRepository = pronunciationAttemptRepository;
        this.userBadgeRepository = userBadgeRepository;
        this.badgeRepository = badgeRepository;
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
        this.flashcardProgressRepository = flashcardProgressRepository;
    }

    @Transactional(readOnly = true)
    public User getUserOrThrow(UUID id) {
        return userRepository.findById(id)
                .filter(u -> u.getDeletedAt() == null)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng."));
    }

    // ── Detail (profile + stats + badges + xp + streak + activity + desks) ────

    @Transactional(readOnly = true)
    public UserDetailDto getDetail(UUID userId) {
        User user = getUserOrThrow(userId);

        // Stats counters
        long studyCount = studySessionRepository.countByUser_Id(userId);
        long exerciseCount = exerciseSessionRepository.countByUser_Id(userId);
        long testCount = testSessionRepository.countByUser_Id(userId);
        long pronunciationCount = pronunciationAttemptRepository.countByUser_Id(userId);

        // Badges
        List<UserBadge> userBadges = userBadgeRepository.findByUser_Id(userId);
        List<UserDetailDto.BadgeRow> badges = userBadges.stream()
                .map(ub -> new UserDetailDto.BadgeRow(
                        ub.getBadge().getId(),
                        ub.getBadge().getName(),
                        ub.getBadge().getDescription(),
                        ub.getBadge().getIconUrl(),
                        ub.getBadge().getConditionType(),
                        ub.getEarnedAt()))
                .toList();

        // XP history 30 ngày (chỉ có nguồn timestamp đáng tin là StudySession.xpEarned)
        LocalDateTime since30 = LocalDate.now().minusDays(29).atStartOfDay();
        Map<String, Long> xpByDay = new HashMap<>();
        for (Object[] row : studySessionRepository.sumXpByDayForUser(userId, since30)) {
            String date = ((java.sql.Date) row[0]).toLocalDate().format(DATE_FMT);
            long xp = ((Number) row[1]).longValue();
            xpByDay.put(date, xp);
        }
        List<UserDetailDto.XpPoint> xpHistory = new ArrayList<>();
        for (int i = 29; i >= 0; i--) {
            String date = LocalDate.now().minusDays(i).format(DATE_FMT);
            xpHistory.add(new UserDetailDto.XpPoint(date, xpByDay.getOrDefault(date, 0L)));
        }

        // Streak calendar 90 ngày — ngày nào user có hoạt động
        LocalDateTime since90 = LocalDate.now().minusDays(89).atStartOfDay();
        List<String> activeDays = studySessionRepository.findActiveDaysForUser(userId, since90).stream()
                .map(d -> d.toLocalDate().format(DATE_FMT))
                .toList();

        // Activity feed — merge top 50 từ 4 nguồn rồi sort desc, lấy 50
        List<UserDetailDto.ActivityRow> merged = new ArrayList<>();
        for (StudySession s : studySessionRepository.findTop50ByUser_IdOrderByStartedAtDesc(userId)) {
            String summary = String.format(Locale.ROOT, "Study session — %d cards, %d XP",
                    s.getTotalCards() == null ? 0 : s.getTotalCards(),
                    s.getXpEarned() == null ? 0 : s.getXpEarned());
            merged.add(new UserDetailDto.ActivityRow("study", summary, s.getStartedAt(), s.getStatus(), s.getId()));
        }
        for (ExerciseSession e : exerciseSessionRepository.findTop50ByUser_IdOrderByCreatedAtDesc(userId)) {
            String summary = "Exercise — " + e.getCategory();
            merged.add(new UserDetailDto.ActivityRow("exercise", summary, e.getCreatedAt(), e.getStatus(), e.getId()));
        }
        for (TestSession t : testSessionRepository.findTop50ByUser_IdOrderByStartedAtDesc(userId)) {
            String summary = "Placement test"
                    + (t.getResultLevel() != null ? " → " + t.getResultLevel() : "")
                    + (t.getScore() != null ? " (score " + t.getScore() + ")" : "");
            merged.add(new UserDetailDto.ActivityRow("test", summary, t.getStartedAt(),
                    t.getStatus() == null ? null : t.getStatus().name(), t.getId()));
        }
        for (PronunciationAttempt p : pronunciationAttemptRepository.findTop50ByUser_IdOrderByCreatedAtDesc(userId)) {
            String summary = "Pronunciation — score " + p.getOverallScore()
                    + " (" + (p.getProvider() == null ? "?" : p.getProvider()) + ")";
            merged.add(new UserDetailDto.ActivityRow("pronunciation", summary, p.getCreatedAt(), null, p.getId()));
        }
        merged.sort(Comparator.comparing(
                UserDetailDto.ActivityRow::at,
                Comparator.nullsLast(Comparator.reverseOrder())));
        List<UserDetailDto.ActivityRow> activities = merged.size() > 50 ? merged.subList(0, 50) : merged;

        // Desks + số flashcard
        List<Desk> desks = deskRepository.findAllByOwner_IdOrderBySortOrderAsc(userId);
        Set<UUID> deskIds = new HashSet<>();
        desks.forEach(d -> deskIds.add(d.getId()));
        Map<UUID, Long> cardCounts = deskIds.isEmpty()
                ? Map.of() : flashcardRepository.countByDeskIdsAsMap(deskIds);
        List<UserDetailDto.DeskRow> deskRows = desks.stream()
                .map(d -> new UserDetailDto.DeskRow(
                        d.getId(),
                        d.getCefrLevel(),
                        d.getTitle(),
                        cardCounts.getOrDefault(d.getId(), 0L),
                        d.getCreatedAt()))
                .toList();

        return new UserDetailDto(
                user.getId(), user.getFirebaseUid(), user.getEmail(), user.getFullName(),
                user.getAvatarUrl(), user.getCefrLevel(), user.getIsOnboarded(), user.getAccountLocked(),
                user.getCreatedAt(), user.getLastActiveDate(), user.getDeletedAt(),
                user.getTotalXp() == null ? 0 : user.getTotalXp(),
                user.getCurrentStreak() == null ? 0 : user.getCurrentStreak(),
                user.getLongestStreak() == null ? 0 : user.getLongestStreak(),
                studyCount, exerciseCount, testCount, pronunciationCount,
                badges, xpHistory, activeDays, activities, deskRows);
    }

    // ── Actions ─────────────────────────────────────────────────────────────

    @Transactional
    public void grantXp(UUID userId, int amount) {
        if (amount <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Số XP phải lớn hơn 0.");
        }
        User user = getUserOrThrow(userId);
        user.setTotalXp((user.getTotalXp() == null ? 0 : user.getTotalXp()) + amount);
        userRepository.save(user);
    }

    @Transactional
    public void changeLevel(UUID userId, String newLevel) {
        if (newLevel == null || !ALLOWED_LEVELS.contains(newLevel.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "CEFR level phải thuộc A1–C2.");
        }
        User user = getUserOrThrow(userId);
        user.setCefrLevel(newLevel.trim().toUpperCase(Locale.ROOT));
        userRepository.save(user);
    }

    @Transactional
    public void awardBadge(UUID userId, UUID badgeId) {
        User user = getUserOrThrow(userId);
        Badge badge = badgeRepository.findById(badgeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy badge."));
        if (userBadgeRepository.existsByUser_IdAndBadge_Id(userId, badgeId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "User đã có badge này.");
        }
        UserBadge ub = new UserBadge();
        ub.setUser(user);
        ub.setBadge(badge);
        userBadgeRepository.save(ub);
    }

    /**
     * Xóa toàn bộ session/attempt/badge/progress và reset XP/streak. KHÔNG ĐỘNG vào desk/flashcard
     * (đó là content do user tạo, không phải progress).
     */
    @Transactional
    public void resetProgress(UUID userId) {
        User user = getUserOrThrow(userId);
        flashcardProgressRepository.deleteByUser_Id(userId);
        studySessionRepository.deleteByUser_Id(userId);
        exerciseSessionRepository.deleteByUser_Id(userId);
        testSessionRepository.deleteByUser_Id(userId);
        pronunciationAttemptRepository.deleteByUser_Id(userId);
        userBadgeRepository.deleteByUser_Id(userId);
        user.setTotalXp(0);
        user.setCurrentStreak(0);
        user.setLongestStreak(0);
        user.setLastActiveDate(null);
        userRepository.save(user);
    }

    @Transactional
    public void softDelete(UUID userId) {
        User user = getUserOrThrow(userId);
        user.setDeletedAt(LocalDateTime.now());
        user.setAccountLocked(true);
        userRepository.save(user);
    }

    // ── Export CSV ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public String exportUsersAsCsv(String cefrLevel, String status, String keyword) {
        // Tận dụng UserService specs đã có sẵn — gọi qua repository.findAll(spec) cũng được,
        // nhưng để tách dependency, ta lọc thủ công trên kết quả findAll.
        List<User> users = userRepository.findAll().stream()
                .filter(u -> u.getDeletedAt() == null)
                .filter(u -> cefrLevel == null || cefrLevel.isBlank()
                        || cefrLevel.equalsIgnoreCase(u.getCefrLevel()))
                .filter(u -> {
                    if (status == null || status.isBlank() || "all".equalsIgnoreCase(status)) return true;
                    boolean locked = "locked".equalsIgnoreCase(status);
                    return Boolean.valueOf(locked).equals(Boolean.TRUE.equals(u.getAccountLocked()));
                })
                .filter(u -> {
                    if (keyword == null || keyword.isBlank()) return true;
                    String kw = keyword.trim().toLowerCase(Locale.ROOT);
                    return (u.getFullName() != null && u.getFullName().toLowerCase(Locale.ROOT).contains(kw))
                            || (u.getEmail() != null && u.getEmail().toLowerCase(Locale.ROOT).contains(kw))
                            || (u.getFirebaseUid() != null && u.getFirebaseUid().toLowerCase(Locale.ROOT).contains(kw));
                })
                .sorted(Comparator.comparing(User::getCreatedAt,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();

        StringBuilder sb = new StringBuilder();
        sb.append("id,email,full_name,cefr_level,total_xp,current_streak,longest_streak,account_locked,last_active_date,created_at\n");
        for (User u : users) {
            sb.append(csv(u.getId() == null ? null : u.getId().toString())).append(',')
              .append(csv(u.getEmail())).append(',')
              .append(csv(u.getFullName())).append(',')
              .append(csv(u.getCefrLevel())).append(',')
              .append(csv(u.getTotalXp() == null ? "0" : u.getTotalXp().toString())).append(',')
              .append(csv(u.getCurrentStreak() == null ? "0" : u.getCurrentStreak().toString())).append(',')
              .append(csv(u.getLongestStreak() == null ? "0" : u.getLongestStreak().toString())).append(',')
              .append(csv(Boolean.TRUE.equals(u.getAccountLocked()) ? "locked" : "active")).append(',')
              .append(csv(u.getLastActiveDate() == null ? null : u.getLastActiveDate().toString())).append(',')
              .append(csv(u.getCreatedAt() == null ? null : u.getCreatedAt().toString())).append('\n');
        }
        return sb.toString();
    }

    @Transactional(readOnly = true)
    public List<Badge> listAllBadges() {
        return badgeRepository.findAll();
    }

    private static String csv(String value) {
        if (value == null) return "";
        String escaped = value.replace("\"", "\"\"");
        return "\"" + escaped + "\"";
    }
}
