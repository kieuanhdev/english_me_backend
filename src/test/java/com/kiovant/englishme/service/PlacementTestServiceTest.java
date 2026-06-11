package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AnswerQuestionRequest;
import com.kiovant.englishme.dto.AnswerQuestionResponse;
import com.kiovant.englishme.dto.StartTestResponse;
import com.kiovant.englishme.dto.TestResultResponse;
import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.entity.TestAnswer;
import com.kiovant.englishme.entity.TestSession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.QuestionRepository;
import com.kiovant.englishme.repository.TestAnswerRepository;
import com.kiovant.englishme.repository.TestSessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho PlacementTestService — Trụ 3 (Placement Test thích ứng CEFR).
 *
 * Cover flow: start -> answer -> complete + suy luận CEFR theo % đúng từng level.
 */
class PlacementTestServiceTest {

    private QuestionRepository questionRepository;
    private TestSessionRepository testSessionRepository;
    private TestAnswerRepository testAnswerRepository;
    private UserRepository userRepository;
    private UserService userService;
    private PlacementTestService service;

    private User user;

    @BeforeEach
    void setUp() {
        questionRepository = mock(QuestionRepository.class);
        testSessionRepository = mock(TestSessionRepository.class);
        testAnswerRepository = mock(TestAnswerRepository.class);
        userRepository = mock(UserRepository.class);
        userService = mock(UserService.class);
        service = new PlacementTestService(
                questionRepository,
                testSessionRepository,
                testAnswerRepository,
                userRepository,
                userService
        );

        user = new User();
        user.setId(UUID.randomUUID());
        user.setFirebaseUid("uid-1");
        when(userRepository.findByFirebaseUid("uid-1")).thenReturn(Optional.of(user));
        doNothing().when(userService).requireAccountNotLocked(any());
    }

    private Question buildQuestion(String level, String skill, String correct) {
        Question q = new Question();
        q.setId(UUID.randomUUID());
        q.setCefrLevel(level);
        q.setSkillCategory(skill);
        q.setQuestion("Q-" + UUID.randomUUID());
        q.setOptions(Map.of("A", "a", "B", "b", "C", "c", "D", "d"));
        q.setCorrectAnswer(correct);
        q.setExplanation("explain");
        return q;
    }

    @Test
    @DisplayName("startTest tạo session IN_PROGRESS, trả 16 câu A1–B2 + notice cap B2")
    void startTestCreatesInProgressSession() {
        // Service rút 2 grammar + 2 vocabulary mỗi cấp A1–B2 (skill_category LOWERCASE, khớp V18).
        for (String level : List.of("A1", "A2", "B1", "B2")) {
            when(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "grammar", 2))
                    .thenReturn(List.of(buildQuestion(level, "grammar", "A"), buildQuestion(level, "grammar", "B")));
            when(questionRepository.findRandomByCefrLevelAndSkillCategory(level, "vocabulary", 2))
                    .thenReturn(List.of(buildQuestion(level, "vocabulary", "A"), buildQuestion(level, "vocabulary", "B")));
        }
        when(questionRepository.findRandomByCefrLevel(anyString(), anyInt())).thenReturn(List.of());
        when(testSessionRepository.save(any(TestSession.class))).thenAnswer(inv -> inv.getArgument(0));

        StartTestResponse response = service.startTest("uid-1");

        assertNotNull(response);
        assertEquals(16, response.questions().size());
        assertEquals(16, response.totalQuestions());
        assertNotNull(response.notice());
        assertTrue(response.notice().contains("B2"), "notice phải nêu rõ giới hạn B2");

        verify(testSessionRepository).save(argThat(s ->
                s.getStatus() == TestSession.TestStatus.IN_PROGRESS
                        && s.getQuestionIds() != null
                        && s.getQuestionIds().size() == 16
                        && s.getUser() == user
        ));
    }

    @Test
    @DisplayName("answerQuestion lưu đáp án + cập nhật answeredCount")
    void answerQuestionPersistsAnswerAndCountsCorrectly() {
        Question q = buildQuestion("A1", "Grammar", "B");
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(new ArrayList<>(List.of(q.getId())));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(q.getId())).thenReturn(Optional.of(q));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, q)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(1L);

        AnswerQuestionResponse response = service.answerQuestion(
                "uid-1",
                UUID.randomUUID(),
                new AnswerQuestionRequest(q.getId(), "B")
        );

        assertTrue(response.isCorrect());
        assertEquals("B", response.selectedAnswer());
        assertEquals("B", response.correctAnswer());
        assertEquals(1, response.answeredCount());
        verify(testAnswerRepository).save(any(TestAnswer.class));
    }

    @Test
    @DisplayName("answerQuestion ném IllegalStateException khi session đã COMPLETED")
    void answerQuestionRejectsCompletedSession() {
        Question q = buildQuestion("A1", "Grammar", "A");
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.COMPLETED);
        session.setQuestionIds(List.of(q.getId()));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));

        assertThrows(IllegalStateException.class, () ->
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"))
        );
        verify(testAnswerRepository, never()).save(any());
    }

    @Test
    @DisplayName("answerQuestion ném lỗi khi câu đã trả lời rồi")
    void answerQuestionRejectsDuplicateAnswer() {
        Question q = buildQuestion("A1", "Grammar", "A");
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(q.getId()));

        TestAnswer existing = new TestAnswer();
        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(q.getId())).thenReturn(Optional.of(q));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, q)).thenReturn(Optional.of(existing));

        assertThrows(IllegalStateException.class, () ->
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"))
        );
        verify(testAnswerRepository, never()).save(any());
    }

    @Test
    @DisplayName("answerQuestion: user khác (uid lạ) đụng session -> not found (chống IDOR)")
    void answerQuestionRejectsForeignUser() {
        // Repo chỉ stub cho uid-1; uid-2 trả Optional.empty() (mặc định mock).
        Question q = buildQuestion("A1", "Grammar", "A");
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(q.getId()));
        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                service.answerQuestion("uid-2", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"))
        );
        verify(testAnswerRepository, never()).save(any());
    }

    @Test
    @DisplayName("completeTest: user khác (uid lạ) -> not found (chống IDOR)")
    void completeTestRejectsForeignUser() {
        assertThrows(IllegalArgumentException.class, () ->
                service.completeTest("uid-2", UUID.randomUUID())
        );
    }

    @Test
    @DisplayName("answerQuestion ném lỗi khi câu không thuộc session")
    void answerQuestionRejectsQuestionOutsideSession() {
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(UUID.randomUUID()));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(UUID.randomUUID(), "A"))
        );
    }

    /**
     * Dựng đề 16 câu (4/cấp A1–B2) với số câu ĐÚNG mỗi cấp cho trước, rồi chạy completeTest.
     * earned = Σ w·correct, max = Σ w·4 = 40. Dùng để kiểm chứng cutoff (§A.1/A.2).
     */
    private TestResultResponse runComplete(int a1, int a2, int b1, int b2) {
        Map<String, Integer> correctByLevel = Map.of("A1", a1, "A2", a2, "B1", b1, "B2", b2);
        List<Question> all = new ArrayList<>();
        List<TestAnswer> answers = new ArrayList<>();
        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        for (String level : List.of("A1", "A2", "B1", "B2")) {
            int correct = correctByLevel.get(level);
            for (int i = 0; i < 4; i++) {
                Question q = buildQuestion(level, i < 2 ? "grammar" : "vocabulary", "A");
                all.add(q);
                answers.add(buildAnswer(session, q, i < correct));
            }
        }
        session.setQuestionIds(all.stream().map(Question::getId).toList());

        when(testSessionRepository.findByIdAndUser_FirebaseUid(session.getId(), "uid-1")).thenReturn(Optional.of(session));
        when(testAnswerRepository.findByTestSession(session)).thenReturn(answers);
        when(questionRepository.findAllById(session.getQuestionIds())).thenReturn(all);
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        return service.completeTest("uid-1", session.getId());
    }

    @Test
    @DisplayName("Weighted scoring: A1 4/4, A2 4/4, B1 3/4, B2 2/4 -> R=29/40=0.725 -> B2")
    void completeTestWeightedScoringB2() {
        TestResultResponse result = runComplete(4, 4, 3, 2);
        assertEquals("B2", result.resultLevel());
        assertFalse(result.canGoHigherThanB2(), "R<0.90 nên không gợi ý cao hơn B2");
        assertEquals(13, result.score()); // 4+4+3+2
        assertEquals(16, result.totalQuestions());
    }

    @Test
    @DisplayName("Weighted scoring: A1 4/4, A2 4/4, B1 2/4, B2 1/4 -> R=22/40=0.55 -> B1")
    void completeTestWeightedScoringB1() {
        TestResultResponse result = runComplete(4, 4, 2, 1);
        assertEquals("B1", result.resultLevel());
        assertFalse(result.canGoHigherThanB2());
    }

    @Test
    @DisplayName("Weighted scoring: A1 4/4, A2 3/4, B1 1/4, B2 0/4 -> R=13/40=0.325 -> A2")
    void completeTestWeightedScoringA2() {
        TestResultResponse result = runComplete(4, 3, 1, 0);
        assertEquals("A2", result.resultLevel());
    }

    @Test
    @DisplayName("Đúng tuyệt đối 16/16 -> B2 + canGoHigherThanB2=true + có aboveLevelMessage")
    void completeTestPerfectScoreFlagsAboveB2() {
        TestResultResponse result = runComplete(4, 4, 4, 4);
        assertEquals("B2", result.resultLevel(), "cap cứng B2 dù làm đúng hết");
        assertTrue(result.canGoHigherThanB2(), "R=1.0 + B2 4/4 (smoothed 0.833) -> gợi ý cao hơn B2");
        assertNotNull(result.aboveLevelMessage());
        assertFalse(result.aboveLevelMessage().isEmpty());
    }

    @Test
    @DisplayName("B2 đúng 3/4 (smoothed 0.667 < 0.83) -> KHÔNG bật canGoHigherThanB2")
    void completeTestB2NotPerfectDoesNotFlag() {
        // A1 4/4, A2 4/4, B1 4/4, B2 3/4 -> earned=4+8+12+9=33, R=0.825 -> B2 nhưng <0.90
        TestResultResponse result = runComplete(4, 4, 4, 3);
        assertEquals("B2", result.resultLevel());
        assertFalse(result.canGoHigherThanB2(), "R=0.825<0.90 nên không bật");
    }

    @Test
    @DisplayName("completeTest: không có câu hợp lệ (maxScore==0) -> A1, chống chia 0")
    void completeTestEmptyAnswersFallsBackToA1() {
        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of());

        when(testSessionRepository.findByIdAndUser_FirebaseUid(session.getId(), "uid-1")).thenReturn(Optional.of(session));
        when(testAnswerRepository.findByTestSession(session)).thenReturn(List.of());
        when(questionRepository.findAllById(session.getQuestionIds())).thenReturn(List.of());
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        TestResultResponse result = service.completeTest("uid-1", session.getId());
        assertEquals("A1", result.resultLevel());
        assertEquals(TestSession.TestStatus.COMPLETED, session.getStatus());
    }

    @Test
    @DisplayName("completeTest gán cefrLevel cho user nếu user chưa có (lần đầu)")
    void completeTestSetsUserCefrLevelIfMissing() {
        // 4 câu A1 đúng, còn lại sai -> earned=4, max=40, R=0.1 -> A1.
        assertNull(user.getCefrLevel());
        TestResultResponse result = runComplete(4, 0, 0, 0);

        assertEquals("A1", result.resultLevel());
        assertEquals("A1", user.getCefrLevel());
        assertEquals(Boolean.TRUE, user.getIsOnboarded());
        verify(userRepository).save(user);
    }

    @Test
    @DisplayName("completeTest ném IllegalStateException khi session đã COMPLETED")
    void completeTestRejectsAlreadyCompletedSession() {
        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.COMPLETED);

        when(testSessionRepository.findByIdAndUser_FirebaseUid(session.getId(), "uid-1")).thenReturn(Optional.of(session));

        assertThrows(IllegalStateException.class, () -> service.completeTest("uid-1", session.getId()));
    }

    // ── Bổ sung FIX_PLAN Đợt 5: biên cutoff, re-test, selfSelect ──────────

    @Test
    @DisplayName("Biên cutoff CHÍNH XÁC: R=0.25 (earned=10/40) -> A2 (không phải A1, vì so sánh r < cutoff)")
    void cutoffBoundaryExactlyA2() {
        // 4 A1 đúng (4) + 3 A2 đúng (6) = 10/40 = 0.25 — đúng ngưỡng CUTOFF_A2.
        TestResultResponse result = runComplete(4, 3, 0, 0);
        assertEquals("A2", result.resultLevel(), "r=0.25 không < 0.25 -> rơi vào band A2");
    }

    @Test
    @DisplayName("Biên cutoff CHÍNH XÁC: R=0.45 (earned=18/40) -> B1")
    void cutoffBoundaryExactlyB1() {
        // 4+4*2+2*3 = 4+8+6 = 18/40 = 0.45 — đúng ngưỡng CUTOFF_B1.
        TestResultResponse result = runComplete(4, 4, 2, 0);
        assertEquals("B1", result.resultLevel());
    }

    @Test
    @DisplayName("Sát ngưỡng B2: earned=27 (0.675) -> B1; earned=28 (0.70) -> B2")
    void cutoffAroundB2() {
        // (3,4,4,1): 3+8+12+4 = 27/40 = 0.675 < 0.68 -> B1.
        assertEquals("B1", runComplete(3, 4, 4, 1).resultLevel());
        // (4,4,4,1): 4+8+12+4 = 28/40 = 0.70 >= 0.68 -> B2.
        assertEquals("B2", runComplete(4, 4, 4, 1).resultLevel());
    }

    @Test
    @DisplayName("Re-test ra level THẤP hơn -> user GIỮ level cũ (spec §6.4: chỉ nâng, không hạ)")
    void completeTestNeverDowngradesUserLevel() {
        user.setCefrLevel("B2");
        TestResultResponse result = runComplete(4, 0, 0, 0); // r=0.1 -> A1

        assertEquals("A1", result.resultLevel(), "kết quả bài thi vẫn báo A1");
        assertEquals("B2", user.getCefrLevel(), "nhưng level user không bị hạ");
    }

    @Test
    @DisplayName("Re-test ra level CAO hơn -> nâng level user")
    void completeTestUpgradesUserLevel() {
        user.setCefrLevel("A1");
        TestResultResponse result = runComplete(4, 4, 4, 1); // 0.70 -> B2

        assertEquals("B2", result.resultLevel());
        assertEquals("B2", user.getCefrLevel());
    }

    @Test
    @DisplayName("selfSelectLevel: level hợp lệ -> set cefr + onboarded; level lạ -> reject")
    void selfSelectLevelValidatesCefr() {
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        service.selfSelectLevel("uid-1", new com.kiovant.englishme.dto.SelfSelectLevelRequest("b1"));
        assertEquals("B1", user.getCefrLevel(), "lowercase được normalize");
        assertEquals(Boolean.TRUE, user.getIsOnboarded());

        assertThrows(IllegalArgumentException.class, () ->
                service.selfSelectLevel("uid-1", new com.kiovant.englishme.dto.SelfSelectLevelRequest("Z9")));
    }

    @Test
    @DisplayName("answerQuestion: question đã bị xóa khỏi DB -> lỗi rõ ràng, không NPE")
    void answerQuestionWithDeletedQuestionFailsCleanly() {
        UUID qid = UUID.randomUUID();
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(qid));
        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(qid)).thenReturn(Optional.empty());

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(qid, "A")));
        assertTrue(ex.getMessage().contains("Question not found"));
    }

    private TestAnswer buildAnswer(TestSession session, Question q, boolean correct) {
        TestAnswer a = new TestAnswer();
        a.setTestSession(session);
        a.setQuestion(q);
        a.setSelectedAnswer(correct ? q.getCorrectAnswer() : "Z");
        a.setIsCorrect(correct);
        return a;
    }
}
