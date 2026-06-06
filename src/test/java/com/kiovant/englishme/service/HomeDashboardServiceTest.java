package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.HomeDashboardResponse;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.entity.UserSkillXp;
import com.kiovant.englishme.repository.FlashcardProgressRepository;
import com.kiovant.englishme.repository.GrammarTopicRepository;
import com.kiovant.englishme.repository.UserDailyGoalRepository;
import com.kiovant.englishme.repository.UserLessonProgressRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserSkillXpRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Pageable;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Test tính cá nhân hóa Home dashboard:
 *   P2 — gợi ý nhắm kỹ năng yếu nhất (đọc user_skill_xp).
 *   P3 — "Tiếp tục học" theo tiến độ thật (bài in_progress, retry nếu chưa đạt điểm).
 *   P5 — Word of Day theo gap (thẻ flashcard yếu nhất) + đếm thẻ cần ôn.
 *
 * Pure logic — mock toàn bộ repository, không cần DB/Firebase.
 */
class HomeDashboardServiceTest {

    private UserRepository userRepository;
    private XpHistoryRepository xpHistoryRepository;
    private WordOfDayService wordOfDayService;
    private GrammarTopicRepository grammarTopicRepository;
    private UserDailyGoalRepository userDailyGoalRepository;
    private UserSkillXpRepository userSkillXpRepository;
    private UserLessonProgressRepository userLessonProgressRepository;
    private FlashcardProgressRepository flashcardProgressRepository;
    private HomeDashboardService service;

    private final UUID userId = UUID.randomUUID();
    private final String uid = "firebase-uid-1";

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        xpHistoryRepository = mock(XpHistoryRepository.class);
        wordOfDayService = mock(WordOfDayService.class);
        grammarTopicRepository = mock(GrammarTopicRepository.class);
        userDailyGoalRepository = mock(UserDailyGoalRepository.class);
        userSkillXpRepository = mock(UserSkillXpRepository.class);
        userLessonProgressRepository = mock(UserLessonProgressRepository.class);
        flashcardProgressRepository = mock(FlashcardProgressRepository.class);

        service = new HomeDashboardService(
                userRepository, xpHistoryRepository, wordOfDayService,
                grammarTopicRepository, userDailyGoalRepository, userSkillXpRepository,
                userLessonProgressRepository, flashcardProgressRepository);

        User user = new User();
        user.setId(userId);
        user.setFullName("Test");
        user.setCefrLevel("A1");
        user.setTotalXp(190);
        user.setCurrentStreak(3);
        user.setLongestStreak(5);
        when(userRepository.findByFirebaseUid(uid)).thenReturn(Optional.of(user));

        // Mặc định: không có bài dở, không có thẻ due, lesson progress rỗng.
        when(userLessonProgressRepository.findByStatusWithLesson(eq(userId), eq("in_progress"), any(Pageable.class)))
                .thenReturn(List.of());
        when(flashcardProgressRepository.findWeakestDueFlashcards(eq(userId), any(), any(Pageable.class)))
                .thenReturn(List.of());
        when(flashcardProgressRepository.countAllDueProgress(eq(userId), any())).thenReturn(0L);
        when(xpHistoryRepository.findByUser_IdAndActivityDate(any(), any())).thenReturn(Optional.empty());
        when(xpHistoryRepository.sumXpBetween(any(), any(), any())).thenReturn(0);
        when(xpHistoryRepository.countActiveDaysBetween(any(), any(), any())).thenReturn(0);
        when(userDailyGoalRepository.findByUserIdAndGoalDate(any(), any())).thenReturn(Optional.empty());
        when(grammarTopicRepository.findAllByOrderBySortOrderAscCategoryAscLevelAsc()).thenReturn(List.of());
    }

    private UserSkillXp skill(String name, int xp) {
        UserSkillXp s = new UserSkillXp();
        s.setUserId(userId);
        s.setSkill(name);
        s.setXp(xp);
        return s;
    }

    // ── P2: Recommendation theo kỹ năng yếu ────────────────────────────────

    @Test
    @DisplayName("P2: pronunciation yếu nhất (share thấp) -> gợi ý pronunciation lên đầu + có reason")
    void weakestSkillRecommendationGoesFirst() {
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of(
                skill("vocabulary", 100),
                skill("grammar", 80),
                skill("pronunciation", 10)   // share = 10/190 ≈ 5% < 25% -> yếu nhất
        ));

        HomeDashboardResponse res = service.getDashboard(uid);
        List<HomeDashboardResponse.Recommendation> recs = res.recommendations();

        assertFalse(recs.isEmpty());
        assertEquals("pronunciation", recs.get(0).type(), "gợi ý kỹ năng yếu nhất phải đứng đầu");
        assertNotNull(recs.get(0).reason(), "phải có lý do cá nhân hóa");
        assertTrue(recs.get(0).reason().contains("phát âm"), "reason nhắc đúng kỹ năng");
    }

    @Test
    @DisplayName("P2: user mới (chưa có skill XP) -> giữ catalog gốc, không reason")
    void newUserKeepsDefaultCatalog() {
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of());

        HomeDashboardResponse res = service.getDashboard(uid);
        List<HomeDashboardResponse.Recommendation> recs = res.recommendations();

        assertFalse(recs.isEmpty());
        assertNull(recs.get(0).reason(), "user mới không có reason cá nhân hóa");
    }

    @Test
    @DisplayName("P2: các skill cân bằng (không skill nào < 25%) -> không reorder, không reason")
    void balancedSkillsNoPersonalization() {
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of(
                skill("vocabulary", 60),
                skill("grammar", 70),
                skill("pronunciation", 60)   // share thấp nhất ≈ 31% > 25%
        ));

        HomeDashboardResponse res = service.getDashboard(uid);
        assertNull(res.recommendations().get(0).reason());
    }

    // ── P3: Continue Learning theo tiến độ ──────────────────────────────────

    @Test
    @DisplayName("P3: bài in_progress điểm chưa đạt -> actionType=retry, title 'Làm lại'")
    void inProgressLowScoreYieldsRetry() {
        // projection: lesson_id, title, level_code, last_score, required_score, lesson_order
        Object[] row = {"a1.listening.1", "Chào hỏi", "A1", 55, 70, 1};
        when(userLessonProgressRepository.findByStatusWithLesson(eq(userId), eq("in_progress"), any(Pageable.class)))
                .thenReturn(List.<Object[]>of(row));
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of());

        HomeDashboardResponse.ContinueLearning cl = service.getDashboard(uid).continueLearning();

        assertEquals("lesson", cl.type());
        assertEquals("retry", cl.actionType());
        assertEquals("a1.listening.1", cl.lessonId());
        assertTrue(cl.title().startsWith("Làm lại"));
        assertEquals(55, cl.progress());
    }

    @Test
    @DisplayName("P3: bài in_progress điểm đạt/chưa chấm -> actionType=continue, title 'Tiếp tục'")
    void inProgressPassedYieldsContinue() {
        Object[] row = {"a1.listening.2", "Số đếm", "A1", 80, 70, 2};
        when(userLessonProgressRepository.findByStatusWithLesson(eq(userId), eq("in_progress"), any(Pageable.class)))
                .thenReturn(List.<Object[]>of(row));
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of());

        HomeDashboardResponse.ContinueLearning cl = service.getDashboard(uid).continueLearning();

        assertEquals("continue", cl.actionType());
        assertTrue(cl.title().startsWith("Tiếp tục"));
    }

    // ── P5: Word of Day theo gap + due cards ────────────────────────────────

    @Test
    @DisplayName("P5: có thẻ yếu -> Word of Day lấy từ thẻ đó (không dùng từ-theo-level)")
    void weakFlashcardBecomesWordOfDay() {
        Flashcard f = new Flashcard();
        f.setId(UUID.randomUUID());
        f.setWord("ubiquitous");
        f.setIpa("/juːˈbɪkwɪtəs/");
        f.setCefr("C1");
        when(flashcardProgressRepository.findWeakestDueFlashcards(eq(userId), any(), any(Pageable.class)))
                .thenReturn(List.of(f));
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of());

        HomeDashboardResponse.WordOfDay wod = service.getDashboard(uid).wordOfDay();

        assertNotNull(wod);
        assertEquals("ubiquitous", wod.word());
        verify(wordOfDayService, never()).getWordOfDay(any());
    }

    @Test
    @DisplayName("P5: dueCardCount phản ánh số thẻ tới hạn ôn")
    void dueCardCountSurfaced() {
        when(flashcardProgressRepository.countAllDueProgress(eq(userId), any())).thenReturn(7L);
        when(userSkillXpRepository.findByUserId(userId)).thenReturn(List.of());

        HomeDashboardResponse.DailyStats stats = service.getDashboard(uid).dailyStats();

        assertEquals(7L, stats.dueCardCount());
    }
}
