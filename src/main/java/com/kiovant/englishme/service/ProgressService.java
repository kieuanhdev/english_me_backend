package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DailyGoalResponse;
import com.kiovant.englishme.dto.ProgressResponse;
import com.kiovant.englishme.dto.SkillScore;
import com.kiovant.englishme.dto.StreakCalendarResponse;
import com.kiovant.englishme.dto.WeekSummary;
import com.kiovant.englishme.dto.XpHistoryItem;
import com.kiovant.englishme.dto.XpLedgerItem;
import com.kiovant.englishme.dto.XpLedgerPage;
import com.kiovant.englishme.entity.Badge;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserBadge;
import com.kiovant.englishme.entity.UserDailyGoal;
import com.kiovant.englishme.entity.XpHistory;
import com.kiovant.englishme.entity.XpLedger;
import com.kiovant.englishme.repository.BadgeRepository;
import com.kiovant.englishme.repository.UserBadgeRepository;
import com.kiovant.englishme.repository.UserDailyGoalRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import com.kiovant.englishme.repository.XpLedgerRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class ProgressService {

    private static final DateTimeFormatter MONTH_FMT = DateTimeFormatter.ofPattern("yyyy-MM");
    /** Mục tiêu XP/ngày mặc định — khớp UserDailyGoal.targetXp default (=30). */
    private static final int DEFAULT_DAILY_XP_GOAL = 30;
    /** Các mức mục tiêu XP/ngày user được chọn (Nhẹ / Vừa / Chăm / Cường độ cao). */
    private static final List<Integer> ALLOWED_DAILY_GOALS = List.of(20, 30, 50, 80);

    private final UserRepository userRepository;
    private final XpHistoryRepository xpHistoryRepository;
    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final XpLedgerRepository xpLedgerRepository;
    private final UserDailyGoalRepository userDailyGoalRepository;

    public ProgressService(UserRepository userRepository,
                           XpHistoryRepository xpHistoryRepository,
                           BadgeRepository badgeRepository,
                           UserBadgeRepository userBadgeRepository,
                           XpLedgerRepository xpLedgerRepository,
                           UserDailyGoalRepository userDailyGoalRepository) {
        this.userRepository = userRepository;
        this.xpHistoryRepository = xpHistoryRepository;
        this.badgeRepository = badgeRepository;
        this.userBadgeRepository = userBadgeRepository;
        this.xpLedgerRepository = xpLedgerRepository;
        this.userDailyGoalRepository = userDailyGoalRepository;
    }

    @Transactional(readOnly = true)
    public ProgressResponse getProgress(String firebaseUid) {
        User user = loadUser(firebaseUid);

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        int weekXp = xpHistoryRepository.sumXpBetween(user.getId(), weekStart, today);
        int activeDays = xpHistoryRepository.countActiveDaysBetween(user.getId(), weekStart, today);

        // MVP: skill scores derive from totalXp split — placeholder values
        // Tracking per-skill XP is not in scope yet; expose flat distribution
        int total = user.getTotalXp() != null ? user.getTotalXp() : 0;
        List<SkillScore> skills = List.of(
                new SkillScore("vocabulary", total),
                new SkillScore("grammar", total),
                new SkillScore("pronunciation", total),
                new SkillScore("listening", 0)
        );

        WeekSummary week = new WeekSummary(weekXp, activeDays, 0);

        // Mục tiêu XP hôm nay — cùng nguồn với Home dashboard (user_daily_goals.targetXp),
        // chưa có row hôm nay → default 30.
        int xpGoal = userDailyGoalRepository.findByUserIdAndGoalDate(user.getId(), today)
                .map(g -> g.getTargetXp() == null ? DEFAULT_DAILY_XP_GOAL : g.getTargetXp().intValue())
                .orElse(DEFAULT_DAILY_XP_GOAL);

        return new ProgressResponse(
                user.getTotalXp(),
                user.getCurrentStreak(),
                user.getLongestStreak(),
                user.getCefrLevel(),
                xpGoal,
                skills,
                week
        );
    }

    /** Trạng thái mục tiêu XP hôm nay (target + đã kiếm + danh sách preset). */
    @Transactional(readOnly = true)
    public DailyGoalResponse getDailyGoal(String firebaseUid) {
        User user = loadUser(firebaseUid);
        UserDailyGoal goal = userDailyGoalRepository
                .findByUserIdAndGoalDate(user.getId(), LocalDate.now())
                .orElse(null);
        int target = goal == null || goal.getTargetXp() == null
                ? DEFAULT_DAILY_XP_GOAL : goal.getTargetXp();
        int earned = goal == null || goal.getEarnedXp() == null
                ? 0 : goal.getEarnedXp();
        return new DailyGoalResponse(target, earned, earned >= target, ALLOWED_DAILY_GOALS);
    }

    /**
     * User tự đặt mục tiêu XP cho ngày HÔM NAY. Chỉ chấp nhận giá trị trong preset.
     *
     * <p>Lưu ý idempotency bonus: target chỉ ảnh hưởng tới ngày hiện tại. Nếu user đã
     * nhận daily_goal_bonus hôm nay (daily_bonus_granted=true) rồi mới nâng target, sẽ
     * KHÔNG cấp lại bonus dù chưa đạt target mới — đúng quy ước "1 bonus/ngày".
     */
    @Transactional
    public DailyGoalResponse updateDailyGoal(String firebaseUid, Integer targetXp) {
        if (targetXp == null || !ALLOWED_DAILY_GOALS.contains(targetXp)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "targetXp phải thuộc " + ALLOWED_DAILY_GOALS);
        }
        User user = loadUser(firebaseUid);
        LocalDate today = LocalDate.now();
        UserDailyGoal goal = userDailyGoalRepository
                .findByUserIdAndGoalDate(user.getId(), today)
                .orElseGet(() -> {
                    UserDailyGoal g = new UserDailyGoal();
                    g.setUserId(user.getId());
                    g.setGoalDate(today);
                    return g;
                });
        goal.setTargetXp(targetXp.shortValue());
        userDailyGoalRepository.save(goal);

        int earned = goal.getEarnedXp() == null ? 0 : goal.getEarnedXp();
        return new DailyGoalResponse(targetXp, earned, earned >= targetXp, ALLOWED_DAILY_GOALS);
    }

    @Transactional(readOnly = true)
    public List<XpHistoryItem> getXpHistory(String firebaseUid, int days) {
        User user = loadUser(firebaseUid);
        int safeDays = Math.min(Math.max(days, 1), 365);

        LocalDate today = LocalDate.now();
        LocalDate from = today.minusDays(safeDays - 1L);

        Map<LocalDate, Integer> byDate = new HashMap<>();
        for (XpHistory row : xpHistoryRepository.findByUser_IdAndActivityDateBetweenOrderByActivityDateAsc(user.getId(), from, today)) {
            byDate.put(row.getActivityDate(), row.getXp());
        }

        List<XpHistoryItem> result = new java.util.ArrayList<>(safeDays);
        for (int i = 0; i < safeDays; i++) {
            LocalDate d = from.plusDays(i);
            result.add(new XpHistoryItem(d, byDate.getOrDefault(d, 0)));
        }
        return result;
    }

    @Transactional(readOnly = true)
    public StreakCalendarResponse getStreakCalendar(String firebaseUid, String month) {
        User user = loadUser(firebaseUid);
        YearMonth ym = parseMonth(month);
        LocalDate from = ym.atDay(1);
        LocalDate to = ym.atEndOfMonth();

        List<String> streakDays = xpHistoryRepository
                .findByUser_IdAndActivityDateBetweenOrderByActivityDateAsc(user.getId(), from, to)
                .stream()
                .filter(x -> x.getXp() != null && x.getXp() > 0)
                .map(x -> x.getActivityDate().toString())
                .toList();

        return new StreakCalendarResponse(
                ym.format(MONTH_FMT),
                user.getCurrentStreak(),
                user.getLongestStreak(),
                streakDays
        );
    }

    /**
     * Lịch sử transaction XP (per-row của xp_ledger), cursor pagination giảm dần theo id.
     *
     * @param cursor id của row cuối cùng trang trước (null nếu trang đầu).
     * @param limit  số row tối đa (clamp [1, 100], default 20).
     */
    @Transactional(readOnly = true)
    public XpLedgerPage getXpLedger(String firebaseUid, String cursor, int limit) {
        User user = loadUser(firebaseUid);
        int safeLimit = Math.min(Math.max(limit, 1), 100);

        List<XpLedger> rows;
        if (cursor == null || cursor.isBlank()) {
            rows = xpLedgerRepository.findFirstPage(user.getId(), PageRequest.of(0, safeLimit));
        } else {
            Long cursorId;
            try {
                cursorId = Long.parseLong(cursor.trim());
            } catch (NumberFormatException ex) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "cursor must be a numeric ledger id");
            }
            rows = xpLedgerRepository.findByUserIdBeforeCursor(user.getId(), cursorId, PageRequest.of(0, safeLimit));
        }

        List<XpLedgerItem> items = rows.stream()
                .map(r -> new XpLedgerItem(
                        r.getId(),
                        r.getAmount(),
                        r.getSourceType(),
                        r.getSourceId(),
                        r.getOccurredAt()))
                .toList();
        String nextCursor = items.size() < safeLimit ? null
                : String.valueOf(items.get(items.size() - 1).id());
        return new XpLedgerPage(items, nextCursor);
    }

    /**
     * Cap nhat XP, streak, lich su sau moi hoat dong (study/exercise/test).
     * Goi tu cac service khac sau khi user hoan tat 1 activity.
     */
    @Transactional
    public void recordActivity(UUID userId, int xpEarned) {
        if (xpEarned < 0) {
            xpEarned = 0;
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        LocalDate today = LocalDate.now();

        // Cap nhat xp_history
        Optional<XpHistory> existing = xpHistoryRepository.findByUser_IdAndActivityDate(user.getId(), today);
        XpHistory row = existing.orElseGet(() -> {
            XpHistory x = new XpHistory();
            x.setUser(user);
            x.setActivityDate(today);
            x.setXp(0);
            return x;
        });
        row.setXp((row.getXp() == null ? 0 : row.getXp()) + xpEarned);
        xpHistoryRepository.save(row);

        // Cap nhat tong XP
        int newTotal = (user.getTotalXp() == null ? 0 : user.getTotalXp()) + xpEarned;
        user.setTotalXp(newTotal);

        // Cap nhat streak
        LocalDate last = user.getLastActiveDate();
        int currentStreak;
        if (last == null) {
            currentStreak = 1;
        } else if (last.equals(today)) {
            currentStreak = user.getCurrentStreak() == null ? 1 : Math.max(user.getCurrentStreak(), 1);
        } else if (last.equals(today.minusDays(1))) {
            currentStreak = (user.getCurrentStreak() == null ? 0 : user.getCurrentStreak()) + 1;
        } else {
            currentStreak = 1;
        }
        user.setCurrentStreak(currentStreak);

        int longest = user.getLongestStreak() == null ? 0 : user.getLongestStreak();
        if (currentStreak > longest) {
            user.setLongestStreak(currentStreak);
        }
        user.setLastActiveDate(today);

        userRepository.save(user);

        // Cap badges
        evaluateBadges(user);
    }

    private void evaluateBadges(User user) {
        if (user.getCurrentStreak() != null && user.getCurrentStreak() >= 7) {
            awardBadge(user, "streak_7");
        }
        if (user.getCurrentStreak() != null && user.getCurrentStreak() >= 30) {
            awardBadge(user, "streak_30");
        }
        if (user.getTotalXp() != null && user.getTotalXp() >= 1000) {
            awardBadge(user, "xp_1000");
        }
    }

    private void awardBadge(User user, String conditionType) {
        Optional<Badge> badge = badgeRepository.findByConditionType(conditionType);
        if (badge.isEmpty()) {
            return;
        }
        if (userBadgeRepository.existsByUser_IdAndBadge_Id(user.getId(), badge.get().getId())) {
            return;
        }
        UserBadge ub = new UserBadge();
        ub.setUser(user);
        ub.setBadge(badge.get());
        userBadgeRepository.save(ub);
    }

    private YearMonth parseMonth(String month) {
        if (month == null || month.isBlank()) {
            return YearMonth.now();
        }
        try {
            return YearMonth.parse(month.trim(), MONTH_FMT);
        } catch (DateTimeParseException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "month must be in yyyy-MM format");
        }
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
