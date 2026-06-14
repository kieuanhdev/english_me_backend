package com.kiovant.englishme.service;

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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho XpService — idempotency, streak, daily goal, xp_history.
 *
 * Bug ở đây = sai XP/streak của MỌI user, vì vậy test chốt từng nhánh thời gian
 * bằng Clock đóng băng (TODAY = 2026-06-10).
 */
class XpServiceTest {

    private static final LocalDate TODAY = LocalDate.of(2026, 6, 10);
    private static final Clock FIXED_CLOCK =
            Clock.fixed(Instant.parse("2026-06-10T12:00:00Z"), ZoneOffset.UTC);

    private UserRepository userRepository;
    private XpLedgerRepository ledgerRepository;
    private UserDailyGoalRepository dailyGoalRepository;
    private XpHistoryRepository xpHistoryRepository;
    private UserSkillXpRepository skillXpRepository;
    private XpRuleService xpRuleService;
    private BadgeService badgeService;
    private XpService service;

    private User user;
    private UUID userId;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        ledgerRepository = mock(XpLedgerRepository.class);
        dailyGoalRepository = mock(UserDailyGoalRepository.class);
        xpHistoryRepository = mock(XpHistoryRepository.class);
        skillXpRepository = mock(UserSkillXpRepository.class);
        xpRuleService = mock(XpRuleService.class);
        badgeService = mock(BadgeService.class);
        service = new XpService(
                userRepository, ledgerRepository, dailyGoalRepository,
                xpHistoryRepository, skillXpRepository, xpRuleService,
                badgeService, new ObjectMapper(), FIXED_CLOCK);

        userId = UUID.randomUUID();
        user = new User();
        user.setId(userId);
        user.setTotalXp(100);
        user.setCurrentStreak(5);
        user.setLongestStreak(7);

        when(userRepository.findByIdForUpdate(userId)).thenReturn(Optional.of(user));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(dailyGoalRepository.findByUserIdAndGoalDate(eq(userId), any())).thenReturn(Optional.empty());
        when(dailyGoalRepository.save(any(UserDailyGoal.class))).thenAnswer(inv -> inv.getArgument(0));
        when(xpHistoryRepository.findByUser_IdAndActivityDate(eq(userId), any())).thenReturn(Optional.empty());
        when(xpHistoryRepository.save(any(XpHistory.class))).thenAnswer(inv -> inv.getArgument(0));
        when(xpRuleService.baseAmount(eq("daily_goal_bonus"), anyInt())).thenReturn(5);
    }

    private void stubInsertSucceeds() {
        when(ledgerRepository.insertIfAbsent(any(), anyInt(), anyString(), any(), anyString(), any()))
                .thenReturn(1);
    }

    @Test
    @DisplayName("grant lần 2 cùng idempotencyKey -> không cộng thêm, alreadyGranted=true")
    void grantCalledTwiceSameKeyGrantsOnce() {
        // Lần 2: insertIfAbsent trả 0 (ON CONFLICT DO NOTHING) -> đọc lại row cũ.
        when(ledgerRepository.insertIfAbsent(any(), anyInt(), anyString(), any(), anyString(), any()))
                .thenReturn(0);
        XpLedger existing = new XpLedger();
        existing.setAmount(10);
        when(ledgerRepository.findByUserIdAndIdempotencyKey(userId, "exercise:s1:submit"))
                .thenReturn(Optional.of(existing));

        XpGrantResult result = service.grant(userId, 10, "exercise", "s1", "exercise:s1:submit", null);

        assertTrue(result.alreadyGranted());
        assertEquals(10, result.xpEarned());
        assertEquals(100L, result.totalXp(), "totalXp giữ nguyên — không cộng lần 2");
        assertEquals(100, user.getTotalXp());
        verify(userRepository, never()).save(any());
        verify(xpHistoryRepository, never()).save(any());
    }

    @Test
    @DisplayName("grant amount <= 0 -> không insert ledger, xpEarned=0")
    void grantNonPositiveAmountIsNoOp() {
        XpGrantResult result = service.grant(userId, 0, "exercise", "s1", "k", null);

        assertEquals(0, result.xpEarned());
        verify(ledgerRepository, never()).insertIfAbsent(any(), anyInt(), anyString(), any(), anyString(), any());
    }

    @Test
    @DisplayName("Đạt daily target (25+10 >= 30) -> cộng thêm daily_goal_bonus")
    void grantReachingDailyTargetAddsGoalBonus() {
        stubInsertSucceeds();
        UserDailyGoal goal = new UserDailyGoal();
        goal.setUserId(userId);
        goal.setGoalDate(TODAY);
        goal.setTargetXp((short) 30);
        goal.setEarnedXp((short) 25);
        goal.setDailyBonusGranted(false);
        when(dailyGoalRepository.findByUserIdAndGoalDate(userId, TODAY)).thenReturn(Optional.of(goal));
        user.setLastActiveDate(TODAY); // đã hoạt động hôm nay -> không đụng nhánh streak

        XpGrantResult result = service.grant(userId, 10, "exercise", "s1", "exercise:s1:submit", null);

        assertEquals(10, result.xpEarned());
        assertEquals(1, result.bonuses().size());
        assertEquals("daily_goal_bonus", result.bonuses().get(0).type());
        assertEquals(5, result.bonuses().get(0).amount());
        assertEquals(115, user.getTotalXp(), "100 + 10 + bonus 5");
        assertEquals(Boolean.TRUE, goal.getDailyBonusGranted());
        // Bonus cũng đi qua ledger idempotent (key daily_goal_bonus:userId:date).
        verify(ledgerRepository).insertIfAbsent(eq(userId), eq(5), eq("daily_goal_bonus"),
                eq(TODAY.toString()), eq("daily_goal_bonus:" + userId + ":" + TODAY), any());
    }

    @Test
    @DisplayName("Streak: grant lần 2 trong cùng ngày -> KHÔNG tăng streak")
    void streakSameDayNoIncrement() {
        stubInsertSucceeds();
        user.setLastActiveDate(TODAY);
        user.setCurrentStreak(5);

        XpGrantResult result = service.grant(userId, 5, "exercise", "s1", "k1", null);

        assertEquals(5, user.getCurrentStreak());
        assertFalse(result.streakUpdated());
    }

    @Test
    @DisplayName("Streak: hôm qua có học -> hôm nay +1; vượt longest thì cập nhật longest")
    void streakConsecutiveDayIncrements() {
        stubInsertSucceeds();
        user.setLastActiveDate(TODAY.minusDays(1));
        user.setCurrentStreak(7);
        user.setLongestStreak(7);

        XpGrantResult result = service.grant(userId, 5, "exercise", "s1", "k1", null);

        assertEquals(8, user.getCurrentStreak());
        assertEquals(8, user.getLongestStreak());
        assertEquals(TODAY, user.getLastActiveDate());
        assertTrue(result.streakUpdated());
    }

    @Test
    @DisplayName("Streak: bỏ học 2+ ngày -> reset về 1, longest giữ nguyên")
    void streakGapTwoDaysResetsToOne() {
        stubInsertSucceeds();
        user.setLastActiveDate(TODAY.minusDays(2));
        user.setCurrentStreak(9);
        user.setLongestStreak(9);

        service.grant(userId, 5, "exercise", "s1", "k1", null);

        assertEquals(1, user.getCurrentStreak());
        assertEquals(9, user.getLongestStreak());
    }

    @Test
    @DisplayName("Streak: lần đầu kiếm XP (lastActiveDate null) -> streak=1, longest=1")
    void streakFirstActivitySetsOne() {
        stubInsertSucceeds();
        user.setLastActiveDate(null);
        user.setCurrentStreak(0);
        user.setLongestStreak(0);

        XpGrantResult result = service.grant(userId, 5, "exercise", "s1", "k1", null);

        assertEquals(1, user.getCurrentStreak());
        assertEquals(1, user.getLongestStreak());
        assertTrue(result.streakUpdated());
    }

    @Test
    @DisplayName("xp_history: grant nhiều lần cùng ngày -> cộng dồn vào MỘT row")
    void xpHistorySameDayAggregatesIntoOneRow() {
        stubInsertSucceeds();
        user.setLastActiveDate(TODAY);
        XpHistory existingRow = new XpHistory();
        existingRow.setUser(user);
        existingRow.setActivityDate(TODAY);
        existingRow.setXp(10);
        when(xpHistoryRepository.findByUser_IdAndActivityDate(userId, TODAY))
                .thenReturn(Optional.of(existingRow));

        service.grant(userId, 5, "exercise", "s1", "k1", null);

        ArgumentCaptor<XpHistory> captor = ArgumentCaptor.forClass(XpHistory.class);
        verify(xpHistoryRepository).save(captor.capture());
        assertEquals(15, captor.getValue().getXp(), "10 cũ + 5 mới, cùng row");
    }

    @Test
    @DisplayName("sourceType có map skill (exercise->grammar) -> upsert per-skill XP")
    void grantUpsertsSkillXpForMappedSourceType() {
        stubInsertSucceeds();
        user.setLastActiveDate(TODAY);

        service.grant(userId, 5, "exercise", "s1", "k1", Map.of());

        verify(skillXpRepository).upsertAdd(userId, "grammar", 5);
    }
}
