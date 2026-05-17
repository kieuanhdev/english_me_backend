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
    @DisplayName("startTest tạo session IN_PROGRESS và trả về danh sách câu hỏi")
    void startTestCreatesInProgressSession() {
        List<Question> a1Grammar = List.of(buildQuestion("A1", "Grammar", "A"), buildQuestion("A1", "Grammar", "B"));
        List<Question> a1Vocab = List.of(buildQuestion("A1", "Vocabulary", "A"), buildQuestion("A1", "Vocabulary", "B"));
        List<Question> a2Grammar = List.of(buildQuestion("A2", "Grammar", "A"), buildQuestion("A2", "Grammar", "B"));
        List<Question> a2Vocab = List.of(buildQuestion("A2", "Vocabulary", "A"), buildQuestion("A2", "Vocabulary", "B"));

        when(questionRepository.findRandomByCefrLevelAndSkillCategory("A1", "Grammar", 2)).thenReturn(a1Grammar);
        when(questionRepository.findRandomByCefrLevelAndSkillCategory("A1", "Vocabulary", 2)).thenReturn(a1Vocab);
        when(questionRepository.findRandomByCefrLevelAndSkillCategory("A2", "Grammar", 2)).thenReturn(a2Grammar);
        when(questionRepository.findRandomByCefrLevelAndSkillCategory("A2", "Vocabulary", 2)).thenReturn(a2Vocab);
        when(questionRepository.findRandomByCefrLevel(anyString(), anyInt())).thenReturn(List.of());
        when(testSessionRepository.save(any(TestSession.class))).thenAnswer(inv -> inv.getArgument(0));

        StartTestResponse response = service.startTest("uid-1");

        assertNotNull(response);
        assertEquals(8, response.questions().size());
        assertEquals(8, response.totalQuestions());

        verify(testSessionRepository).save(argThat(s ->
                s.getStatus() == TestSession.TestStatus.IN_PROGRESS
                        && s.getQuestionIds() != null
                        && s.getQuestionIds().size() == 8
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

        when(testSessionRepository.findById(any())).thenReturn(Optional.of(session));
        when(questionRepository.findById(q.getId())).thenReturn(Optional.of(q));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, q)).thenReturn(Optional.empty());
        when(testAnswerRepository.countByTestSession(session)).thenReturn(1L);

        AnswerQuestionResponse response = service.answerQuestion(
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

        when(testSessionRepository.findById(any())).thenReturn(Optional.of(session));

        assertThrows(IllegalStateException.class, () ->
                service.answerQuestion(UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"))
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
        when(testSessionRepository.findById(any())).thenReturn(Optional.of(session));
        when(questionRepository.findById(q.getId())).thenReturn(Optional.of(q));
        when(testAnswerRepository.findByTestSessionAndQuestion(session, q)).thenReturn(Optional.of(existing));

        assertThrows(IllegalStateException.class, () ->
                service.answerQuestion(UUID.randomUUID(), new AnswerQuestionRequest(q.getId(), "A"))
        );
        verify(testAnswerRepository, never()).save(any());
    }

    @Test
    @DisplayName("answerQuestion ném lỗi khi câu không thuộc session")
    void answerQuestionRejectsQuestionOutsideSession() {
        TestSession session = new TestSession();
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(UUID.randomUUID()));

        when(testSessionRepository.findById(any())).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                service.answerQuestion(UUID.randomUUID(), new AnswerQuestionRequest(UUID.randomUUID(), "A"))
        );
    }

    @Test
    @DisplayName("completeTest tính score + suy luận CEFR theo % đúng (>=50% qua level)")
    void completeTestComputesCefrLevel() {
        // Trả 4 câu A1 đúng 3/4 (>=50% -> qua A1)
        // Trả 4 câu A2 đúng 1/4 (<50% -> không qua A2)
        // -> resultLevel = A1
        Question a1q1 = buildQuestion("A1", "Grammar", "A");
        Question a1q2 = buildQuestion("A1", "Grammar", "A");
        Question a1q3 = buildQuestion("A1", "Vocabulary", "A");
        Question a1q4 = buildQuestion("A1", "Vocabulary", "A");
        Question a2q1 = buildQuestion("A2", "Grammar", "A");
        Question a2q2 = buildQuestion("A2", "Grammar", "A");
        Question a2q3 = buildQuestion("A2", "Vocabulary", "A");
        Question a2q4 = buildQuestion("A2", "Vocabulary", "A");
        List<Question> all = List.of(a1q1, a1q2, a1q3, a1q4, a2q1, a2q2, a2q3, a2q4);

        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(all.stream().map(Question::getId).toList());

        List<TestAnswer> answers = new ArrayList<>();
        answers.add(buildAnswer(session, a1q1, true));
        answers.add(buildAnswer(session, a1q2, true));
        answers.add(buildAnswer(session, a1q3, true));
        answers.add(buildAnswer(session, a1q4, false));
        answers.add(buildAnswer(session, a2q1, true));
        answers.add(buildAnswer(session, a2q2, false));
        answers.add(buildAnswer(session, a2q3, false));
        answers.add(buildAnswer(session, a2q4, false));

        when(testSessionRepository.findById(session.getId())).thenReturn(Optional.of(session));
        when(testAnswerRepository.findByTestSession(session)).thenReturn(answers);
        when(questionRepository.findAllById(session.getQuestionIds())).thenReturn(all);
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        TestResultResponse result = service.completeTest(session.getId());

        assertEquals("A1", result.resultLevel());
        assertEquals(4, result.score()); // 3 đúng A1 + 1 đúng A2
        assertEquals(8, result.totalQuestions());
        assertEquals(TestSession.TestStatus.COMPLETED, session.getStatus());
        assertNotNull(session.getCompletedAt());
    }

    @Test
    @DisplayName("completeTest gán cefrLevel cho user nếu user chưa có")
    void completeTestSetsUserCefrLevelIfMissing() {
        Question q = buildQuestion("A1", "Grammar", "A");
        TestSession session = new TestSession();
        session.setId(UUID.randomUUID());
        session.setUser(user);
        session.setStatus(TestSession.TestStatus.IN_PROGRESS);
        session.setQuestionIds(List.of(q.getId()));

        when(testSessionRepository.findById(session.getId())).thenReturn(Optional.of(session));
        when(testAnswerRepository.findByTestSession(session)).thenReturn(List.of(buildAnswer(session, q, true)));
        when(questionRepository.findAllById(any())).thenReturn(List.of(q));
        when(testSessionRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        assertNull(user.getCefrLevel());
        service.completeTest(session.getId());

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

        when(testSessionRepository.findById(session.getId())).thenReturn(Optional.of(session));

        assertThrows(IllegalStateException.class, () -> service.completeTest(session.getId()));
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
