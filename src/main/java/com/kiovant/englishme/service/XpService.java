package com.kiovant.englishme.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserDailyGoal;
import com.kiovant.englishme.entity.XpHistory;
import com.kiovant.englishme.entity.XpLedger;
import com.kiovant.englishme.repository.UserDailyGoalRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserSkillXpRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import com.kiovant.englishme.repository.XpLedgerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Clock;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Cộng XP idempotent + tự động cập nhật total_xp, streak, daily goal.
 *
 * Mọi endpoint cộng XP CHỈ nên đi qua XpService.grant(...). Không update users.total_xp
 * ở chỗ khác — invariant `users.total_xp == SUM(xp_ledger.amount)` phụ thuộc vào điều này.
 *
 * Idempotency key format: `{sourceType}:{sourceId}:{bucket}` — xem XP_SYSTEM_SPEC §3.1.
 */
@Service
public class XpService {

    private static final Logger log = LoggerFactory.getLogger(XpService.class);

    /** Fallback nếu xp_rules thiếu row 'daily_goal_bonus' (vd. trước khi V22 chạy). */
    private static final int DAILY_GOAL_BONUS_FALLBACK = 5;

    /**
     * Quy ước sourceType -> skill cho per-skill XP tracking (V47).
     * test & daily_goal_bonus KHÔNG có trong map (đa kỹ năng / thưởng) -> không cộng skill.
     */
    private static final Map<String, String> SOURCE_TYPE_TO_SKILL = Map.of(
            "sm2_review", "vocabulary",
            "pronunciation", "pronunciation",
            "lesson", "grammar",
            "exercise", "grammar"
    );

    private final UserRepository userRepository;
    private final XpLedgerRepository ledgerRepository;
    private final UserDailyGoalRepository dailyGoalRepository;
    private final XpHistoryRepository xpHistoryRepository;
    private final UserSkillXpRepository skillXpRepository;
    private final XpRuleService xpRuleService;
    private final BadgeService badgeService;
    private final ObjectMapper objectMapper;
    private final Clock clock;

    public XpService(UserRepository userRepository,
                     XpLedgerRepository ledgerRepository,
                     UserDailyGoalRepository dailyGoalRepository,
                     XpHistoryRepository xpHistoryRepository,
                     UserSkillXpRepository skillXpRepository,
                     XpRuleService xpRuleService,
                     BadgeService badgeService,
                     ObjectMapper objectMapper,
                     Clock clock) {
        this.userRepository = userRepository;
        this.ledgerRepository = ledgerRepository;
        this.dailyGoalRepository = dailyGoalRepository;
        this.xpHistoryRepository = xpHistoryRepository;
        this.skillXpRepository = skillXpRepository;
        this.xpRuleService = xpRuleService;
        this.badgeService = badgeService;
        this.objectMapper = objectMapper;
        this.clock = clock;
    }

    /**
     * Cộng XP cho user theo (sourceType, sourceId, idempotencyKey).
     *
     * <p>Hành vi:
     * <ul>
     *   <li>Nếu (userId, idempotencyKey) đã tồn tại → KHÔNG cộng thêm, trả {@code alreadyGranted=true},
     *       {@code xpEarned = amount của row cũ}, {@code totalXp = current}.</li>
     *   <li>Nếu là lần đầu → insert ledger, cộng vào users.total_xp, cập nhật streak + daily goal,
     *       cộng daily_goal_bonus 5 XP nếu vừa đạt target.</li>
     *   <li>Nếu {@code amount <= 0} → trả ngay {@code xpEarned=0}, không insert ledger.</li>
     * </ul>
     *
     * @param userId        user.id (UUID).
     * @param amount        XP cộng. Phải > 0 mới có hiệu lực.
     * @param sourceType    'lesson' | 'test' | 'exercise' | 'sm2_review' | 'pronunciation' | ...
     * @param sourceId      ID nghiệp vụ: lessonId, sessionId, cardId, ...
     * @param idempotencyKey chuỗi duy nhất theo (user, hành động) — xem spec §3.1.
     * @param metadata      Thông tin bổ sung (score, previousBest, ...). Có thể null.
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public XpGrantResult grant(UUID userId,
                               int amount,
                               String sourceType,
                               String sourceId,
                               String idempotencyKey,
                               Map<String, Object> metadata) {
        if (amount <= 0) {
            return readOnlyResult(userId, 0, false, false);
        }
        // Row lock (FOR UPDATE): serialize các grant song song của cùng user —
        // total_xp/streak/xp_history/daily_goal đều là load-modify-save, không lock
        // thì 2 request cùng lúc sẽ lost-update lẫn nhau.
        User user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String metaJson = serializeMetadata(metadata);
        int inserted = ledgerRepository.insertIfAbsent(userId, amount, sourceType, sourceId, idempotencyKey, metaJson);

        if (inserted == 0) {
            // Đã từng cộng → đọc lại để trả về xpEarned cũ, KHÔNG cộng total_xp.
            XpLedger existing = ledgerRepository.findByUserIdAndIdempotencyKey(userId, idempotencyKey)
                    .orElseThrow(() -> new IllegalStateException("Ledger row missing after ON CONFLICT for " + idempotencyKey));
            int dailyEarned = readDailyEarned(userId);
            return new XpGrantResult(
                    existing.getAmount(),
                    user.getTotalXp() == null ? 0L : user.getTotalXp(),
                    dailyEarned,
                    false,
                    true,
                    List.of()
            );
        }

        // Lần đầu cộng: cộng dồn per-skill XP (nếu sourceType map ra skill). Idempotency
        // đã đảm bảo ở tầng ledger phía trên -> không double-count khi retry.
        String skill = SOURCE_TYPE_TO_SKILL.get(sourceType);
        if (skill != null) {
            skillXpRepository.upsertAdd(userId, skill, amount);
        }

        // Lần đầu cộng: cập nhật total_xp + streak + daily goal + xp_history (cộng dồn ngày).
        long newTotal = applyToUser(user, amount);
        boolean streakUpdated = updateStreak(user);
        userRepository.save(user);

        addToXpHistory(user, amount);
        DailyResult daily = applyDailyGoal(userId, amount, false);

        // Daily goal bonus: nếu vừa đạt target → cộng thêm XP (giá trị đọc từ xp_rules).
        List<XpGrantResult.Bonus> bonuses = new ArrayList<>();
        int dailyGoalBonusAmount = xpRuleService.baseAmount("daily_goal_bonus", DAILY_GOAL_BONUS_FALLBACK);
        if (daily.justReachedTarget() && dailyGoalBonusAmount > 0) {
            String bonusKey = "daily_goal_bonus:" + userId + ":" + LocalDate.now(clock);
            int bonusInserted = ledgerRepository.insertIfAbsent(
                    userId, dailyGoalBonusAmount, "daily_goal_bonus",
                    LocalDate.now(clock).toString(), bonusKey,
                    serializeMetadata(Map.of("targetXp", daily.targetXp()))
            );
            if (bonusInserted > 0) {
                newTotal = applyToUser(user, dailyGoalBonusAmount);
                userRepository.save(user);
                addToXpHistory(user, dailyGoalBonusAmount);

                DailyResult bonusDaily = applyDailyGoal(userId, dailyGoalBonusAmount, true);
                daily = new DailyResult(bonusDaily.earnedXp(), bonusDaily.targetXp(), false);

                bonuses.add(new XpGrantResult.Bonus(
                        "daily_goal_bonus",
                        dailyGoalBonusAmount,
                        "Đạt mục tiêu ngày (" + daily.targetXp() + " XP)"
                ));
            }
        }

        // Auto-award badge sau khi total_xp/streak đã chốt (cùng transaction). Lỗi cấp
        // badge KHÔNG được làm hỏng việc cộng XP -> nuốt exception, chỉ log.
        try {
            badgeService.awardEligible(user);
        } catch (Exception ex) {
            log.warn("awardEligible lỗi cho user {}: {}", userId, ex.getMessage());
        }

        return new XpGrantResult(amount, newTotal, daily.earnedXp(), streakUpdated, false, bonuses);
    }

    /**
     * Lấy total_xp hiện tại của user mà không cộng gì — dùng khi endpoint không grant XP
     * nhưng vẫn cần trả totalXp trong response (ví dụ submit lại lesson đã pass).
     */
    @Transactional(readOnly = true)
    public XpGrantResult readOnlyResult(UUID userId, int xpEarned, boolean streakUpdated, boolean alreadyGranted) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        int daily = readDailyEarned(userId);
        return new XpGrantResult(
                xpEarned,
                user.getTotalXp() == null ? 0L : user.getTotalXp(),
                daily,
                streakUpdated,
                alreadyGranted,
                List.of()
        );
    }

    /** Cộng amount vào users.total_xp, set last_xp_date = today, return total mới. */
    private long applyToUser(User user, int amount) {
        long current = user.getTotalXp() == null ? 0L : user.getTotalXp();
        long newTotal = current + amount;
        // total_xp là Integer trong entity; clamp về Integer range an toàn (XP thực tế không vượt 2^31).
        user.setTotalXp((int) Math.min(Integer.MAX_VALUE, newTotal));
        user.setLastXpDate(LocalDate.now(clock));
        return user.getTotalXp();
    }

    /** Cập nhật current_streak / longest_streak / last_active_date. Trả true nếu hôm nay là ngày đầu kiếm XP. */
    private boolean updateStreak(User user) {
        LocalDate today = LocalDate.now(clock);
        LocalDate last = user.getLastActiveDate();

        int newStreak;
        boolean firstOfDay;
        if (last == null) {
            newStreak = 1;
            firstOfDay = true;
        } else if (last.equals(today)) {
            newStreak = user.getCurrentStreak() == null ? 1 : Math.max(user.getCurrentStreak(), 1);
            firstOfDay = false;
        } else if (last.equals(today.minusDays(1))) {
            newStreak = (user.getCurrentStreak() == null ? 0 : user.getCurrentStreak()) + 1;
            firstOfDay = true;
        } else {
            newStreak = 1;
            firstOfDay = true;
        }
        user.setCurrentStreak(newStreak);
        int longest = user.getLongestStreak() == null ? 0 : user.getLongestStreak();
        if (newStreak > longest) user.setLongestStreak(newStreak);
        user.setLastActiveDate(today);
        return firstOfDay;
    }

    /**
     * Cập nhật user_daily_goals.earned_xp + completed_activities.
     *
     * @param isBonus true nếu đang cộng daily_goal_bonus (không tính là 1 "activity").
     * @return earned_xp sau update + có vừa đạt target lần đầu không.
     */
    private DailyResult applyDailyGoal(UUID userId, int amount, boolean isBonus) {
        LocalDate today = LocalDate.now(clock);
        UserDailyGoal goal = dailyGoalRepository.findByUserIdAndGoalDate(userId, today).orElseGet(() -> {
            UserDailyGoal g = new UserDailyGoal();
            g.setUserId(userId);
            g.setGoalDate(today);
            return g;
        });

        short prevEarned = goal.getEarnedXp() == null ? 0 : goal.getEarnedXp();
        short target = goal.getTargetXp() == null ? 30 : goal.getTargetXp();
        int newEarned = Math.min(Short.MAX_VALUE, prevEarned + amount);
        goal.setEarnedXp((short) newEarned);
        if (!isBonus) {
            short act = goal.getCompletedActivities() == null ? 0 : goal.getCompletedActivities();
            goal.setCompletedActivities((short) Math.min(Short.MAX_VALUE, act + 1));
        }

        boolean justReached = !Boolean.TRUE.equals(goal.getDailyBonusGranted())
                && prevEarned < target
                && newEarned >= target;
        if (justReached) {
            goal.setDailyBonusGranted(true);
        }
        dailyGoalRepository.save(goal);
        return new DailyResult(newEarned, target, justReached);
    }

    /** Cộng dồn vào xp_history (theo ngày) — phục vụ chart progress & streak calendar. */
    private void addToXpHistory(User user, int amount) {
        LocalDate today = LocalDate.now(clock);
        XpHistory row = xpHistoryRepository.findByUser_IdAndActivityDate(user.getId(), today).orElseGet(() -> {
            XpHistory x = new XpHistory();
            x.setUser(user);
            x.setActivityDate(today);
            x.setXp(0);
            return x;
        });
        row.setXp((row.getXp() == null ? 0 : row.getXp()) + amount);
        xpHistoryRepository.save(row);
    }

    private int readDailyEarned(UUID userId) {
        return dailyGoalRepository.findByUserIdAndGoalDate(userId, LocalDate.now(clock))
                .map(g -> g.getEarnedXp() == null ? 0 : g.getEarnedXp().intValue())
                .orElse(0);
    }

    private String serializeMetadata(Map<String, Object> metadata) {
        Map<String, Object> safe = metadata == null ? new HashMap<>() : metadata;
        try {
            return objectMapper.writeValueAsString(safe);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }

    /** Holder nội bộ cho applyDailyGoal. */
    private record DailyResult(int earnedXp, int targetXp, boolean justReachedTarget) {}
}
