package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AnswerQuestionRequest;
import com.kiovant.englishme.dto.CatAnswerResponse;
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
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho PlacementTestService — Trụ 3 (Placement Test thích ứng CEFR / CAT + IRT 1PL).
 *
 * Cover: start (1 câu), answer (update θ + chọn câu kế / isDone), complete (map θ → CEFR),
 * bảo mật IDOR, edge cases. Xem docs/placement-test-cat-upgrade.md.
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

    private Question buildQuestion(String level, String skill, String correct, double difficulty) {
        Question q = new Question();
        q.setId(UUID.randomUUID());
        q.setCefrLevel(level);
        q.setSkillCategory(skill);
        q.setQuestion("Q-" + UUID.randomUUID());
        q.setOptions(Map.of("A", "a", "B", "b", "C", "c", "D", "d"));
        q.setCorrectAnswer(correct);
        q.setExplanation("explain");
        q.setDifficulty(difficulty);
        return q;
    }

    /** Pool 1 câu mỗi level (A1..C1) — đủ để CAT chọn theo |b_i - θ|. */
    private List<Question> buildPool() {
        return new ArrayList<>(List.of(
                buildQuestion("A1", "grammar", "A", -2.0),
                buildQuestion("A2", "vocabulary", "A", -1.0),
                buildQuestion("B1", "grammar", "A", 0.0),
                buildQuestion("B2", "vocabulary", "A", 1.0),
                buildQuestion("C1", "grammar", "A", 2.0)
        ));
    }

    @Test
    @DisplayName("startTest tạo session IN_PROGRESS, θ=0, trả 1 câu đầu (gần B1) + notice A1–C1")
    void startTestCreatesSessionWithFirstQuestion() {
        when(questionRepository.findAllForCat()).thenReturn(buildPool());
        when(testSessionRepository.save(any(TestSession.class))).thenAnswer(inv -> inv.getArgument(0));

        StartTestResponse response = service.startTest("uid-1");

        assertNotNull(response);
        assertNotNull(response.firstQuestion());
        assertEquals("B1", response.firstQuestion().cefrLevel(), "θ=0 → câu gần b=0 nhất = B1");
        assertEquals(15, response.maxQuestions());
        assertNotNull(response.notice());

        verify(testSessionRepository).save(argThat(s ->
                s.getStatus() == TestSession.TestStatus.IN_PROGRESS
                        && s.getTheta() != null && s.getTheta() == 0.0
                        && s.getQuestionIds() != null && s.getQuestionIds().size() == 1
                        && s.getUser() == user
        ));
    }

    @Test
    @DisplayName("answerQuestion đúng: θ tăng + trả câu kế tiếp khó hơn, isDone=false")
    void answerCorrectIncreasesThetaAndReturnsNext() {
        Question b1 = buildQuestion("B1", "grammar", "B", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(0.0);
        session.setMaxQuestions(15);
        session.setQuestionIds(new ArrayList<>(List.of(b1.getId())));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(b1.getId())).thenReturn(Optional.of(b1));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, b1)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(1L);
        when(questionRepository.findAllById(anyList())).thenReturn(List.of(b1));
        when(questionRepository.findForCat(anyList())).thenReturn(List.of(
                buildQuestion("B2", "vocabulary", "A", 1.0)));
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        CatAnswerResponse response = service.answerQuestion(
                "uid-1", UUID.randomUUID(), new AnswerQuestionRequest(b1.getId(), "B"));

        assertTrue(response.isCorrect());
        assertFalse(response.isDone());
        assertNotNull(response.nextQuestion());
        assertEquals(1, response.answeredCount());
        assertTrue(session.getTheta() > 0.0, "trả lời đúng → θ tăng");
        assertEquals(2, session.getQuestionIds().size(), "câu kế tiếp được append vào session");
    }

    @Test
    @DisplayName("answerQuestion sai: θ giảm")
    void answerWrongDecreasesTheta() {
        Question b1 = buildQuestion("B1", "grammar", "B", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(0.0);
        session.setMaxQuestions(15);
        session.setQuestionIds(new ArrayList<>(List.of(b1.getId())));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(b1.getId())).thenReturn(Optional.of(b1));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, b1)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(1L);
        when(questionRepository.findAllById(anyList())).thenReturn(List.of(b1));
        when(questionRepository.findForCat(anyList())).thenReturn(List.of(
                buildQuestion("A2", "vocabulary", "A", -1.0)));
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        CatAnswerResponse response = service.answerQuestion(
                "uid-1", UUID.randomUUID(), new AnswerQuestionRequest(b1.getId(), "Z"));

        assertFalse(response.isCorrect());
        assertTrue(session.getTheta() < 0.0, "trả lời sai → θ giảm");
    }

    @Test
    @DisplayName("answerQuestion: đạt maxQuestions → isDone=true, nextQuestion=null")
    void answerReachingMaxIsDone() {
        Question q = buildQuestion("B1", "grammar", "A", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(0.5);
        session.setMaxQuestions(15);
        session.setQuestionIds(new ArrayList<>(List.of(q.getId())));

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(q.getId())).thenReturn(Optional.of(q));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, q)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(15L); // đã đủ
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        CatAnswerResponse response = service.answerQuestion(
                "uid-1", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"));

        assertTrue(response.isDone());
        assertNull(response.nextQuestion());
        verify(questionRepository, never()).findForCat(anyList());
    }

    @Test
    @DisplayName("completeTest: θ cao → C1; θ thấp → A1 (map θ → CEFR)")
    void completeTestMapsThetaToCefr() {
        // θ = 2.0 → C1
        assertEquals("C1", runComplete(2.0).resultLevel());
        // θ = 1.0 → B2
        assertEquals("B2", runComplete(1.0).resultLevel());
        // θ = 0.0 → B1
        assertEquals("B1", runComplete(0.0).resultLevel());
        // θ = -1.0 → A2
        assertEquals("A2", runComplete(-1.0).resultLevel());
        // θ = -2.0 → A1
        assertEquals("A1", runComplete(-2.0).resultLevel());
    }

    @Test
    @DisplayName("completeTest: θ kịch trần (≥2.2) → C1 + canGoHigherThanC1=true + finalTheta truyền về")
    void completeTestFlagsAboveC1() {
        TestResultResponse result = runComplete(2.5);
        assertEquals("C1", result.resultLevel());
        assertTrue(result.canGoHigherThanC1());
        assertFalse(result.aboveLevelMessage().isEmpty());
        assertEquals(2.5, result.finalTheta(), 1e-9);
    }

    @Test
    @DisplayName("completeTest gán cefrLevel cho user nếu chưa có; re-test chỉ nâng không hạ")
    void completeTestUserLevelLogic() {
        assertNull(user.getCefrLevel());
        runComplete(2.0); // C1
        assertEquals("C1", user.getCefrLevel());
        assertEquals(Boolean.TRUE, user.getIsOnboarded());

        // Re-test ra thấp hơn → giữ level cũ.
        runComplete(-2.0); // A1
        assertEquals("C1", user.getCefrLevel(), "không hạ level");
    }

    @Test
    @DisplayName("answerQuestion: user khác (uid lạ) → not found (chống IDOR)")
    void answerQuestionRejectsForeignUser() {
        Question q = buildQuestion("B1", "grammar", "A", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(q.getId()));
        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                service.answerQuestion("uid-2", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A")));
        verify(testAnswerRepository, never()).save(any());
    }

    @Test
    @DisplayName("answerQuestion ném lỗi khi session đã COMPLETED")
    void answerQuestionRejectsCompletedSession() {
        Question q = buildQuestion("B1", "grammar", "A", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.COMPLETED);
        session.setQuestionIds(List.of(q.getId()));
        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));

        assertThrows(IllegalStateException.class, () ->
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A")));
        verify(testAnswerRepository, never()).save(any());
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
                service.answerQuestion("uid-1", UUID.randomUUID(), new AnswerQuestionRequest(UUID.randomUUID(), "A")));
    }

    @Test
    @DisplayName("selectNextQuestion balance 3 skill: skill ít câu nhất được ưu tiên khi |b-θ| hoà")
    void selectNextQuestionBalancesAcrossThreeSkills() {
        // Câu đầu là grammar. Pool kế có cả grammar/vocabulary/reading cùng b=0 (|b-θ| hoà).
        Question firstGrammar = buildQuestion("B1", "grammar", "A", 0.0);
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(0.0);
        session.setMaxQuestions(15);
        session.setQuestionIds(new ArrayList<>(List.of(firstGrammar.getId())));

        Question poolVocab = buildQuestion("B1", "vocabulary", "A", 0.0);
        Question poolReading = buildQuestion("B1", "reading", "A", 0.0);
        Question poolGrammar = buildQuestion("B1", "grammar", "A", 0.0);

        when(testSessionRepository.findByIdAndUser_FirebaseUid(any(), eq("uid-1"))).thenReturn(Optional.of(session));
        when(questionRepository.findById(firstGrammar.getId())).thenReturn(Optional.of(firstGrammar));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, firstGrammar)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(1L);
        when(questionRepository.findAllById(anyList())).thenReturn(List.of(firstGrammar)); // đã hỏi: 1 grammar
        when(questionRepository.findForCat(anyList())).thenReturn(List.of(poolGrammar, poolVocab, poolReading));
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        CatAnswerResponse response = service.answerQuestion(
                "uid-1", UUID.randomUUID(), new AnswerQuestionRequest(firstGrammar.getId(), "A"));

        // grammar đã có 1, vocabulary/reading = 0 → ưu tiên 1 trong 2 cái 0, KHÔNG chọn grammar.
        assertNotNull(response.nextQuestion());
        assertNotEquals("grammar", response.nextQuestion().skillCategory(),
                "skill đã hỏi (grammar) không được ưu tiên khi có skill chưa hỏi cùng độ khó");
    }

    @Test
    @DisplayName("selfSelectLevel: level hợp lệ → set cefr + onboarded; level lạ → reject")
    void selfSelectLevelValidatesCefr() {
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        service.selfSelectLevel("uid-1", new com.kiovant.englishme.dto.SelfSelectLevelRequest("b1"));
        assertEquals("B1", user.getCefrLevel(), "lowercase được normalize");
        assertEquals(Boolean.TRUE, user.getIsOnboarded());

        assertThrows(IllegalArgumentException.class, () ->
                service.selfSelectLevel("uid-1", new com.kiovant.englishme.dto.SelfSelectLevelRequest("Z9")));
    }

    /** Dựng session có θ cho trước rồi chạy completeTest. */
    private TestResultResponse runComplete(double theta) {
        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setTheta(theta);
        session.setMaxQuestions(15);
        List<Question> questions = List.of(buildQuestion("B1", "grammar", "A", 0.0));
        session.setQuestionIds(questions.stream().map(Question::getId).toList());

        List<TestAnswer> answers = new ArrayList<>();
        TestAnswer a = new TestAnswer();
        a.setTestSession(session);
        a.setQuestion(questions.get(0));
        a.setSelectedAnswer("A");
        a.setIsCorrect(true);
        answers.add(a);

        when(testSessionRepository.findByIdAndUser_FirebaseUid(session.getId(), "uid-1")).thenReturn(Optional.of(session));
        when(testAnswerRepository.findByTestSession(session)).thenReturn(answers);
        when(questionRepository.findAllById(session.getQuestionIds())).thenReturn(questions);
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        return service.completeTest("uid-1", session.getId());
    }
}
