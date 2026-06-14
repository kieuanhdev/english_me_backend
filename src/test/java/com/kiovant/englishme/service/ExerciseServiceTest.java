package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AnswerSubmit;
import com.kiovant.englishme.dto.ExerciseCompleteResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.ExerciseQuestion;
import com.kiovant.englishme.entity.ExerciseSession;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.ExerciseAnswerRepository;
import com.kiovant.englishme.repository.ExerciseQuestionRepository;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Unit test cho ExerciseService — chấm điểm: câu không trả lời tính là SAI,
 * câu trùng/ngoài session bị bỏ qua, accuracy làm tròn 1 chữ số thập phân.
 */
class ExerciseServiceTest {

    private static final String UID = "uid-1";

    private UserRepository userRepository;
    private ExerciseQuestionRepository questionRepository;
    private ExerciseSessionRepository sessionRepository;
    private ExerciseAnswerRepository answerRepository;
    private XpService xpService;
    private XpRuleService xpRuleService;
    private ExerciseService service;

    private User user;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        questionRepository = mock(ExerciseQuestionRepository.class);
        sessionRepository = mock(ExerciseSessionRepository.class);
        answerRepository = mock(ExerciseAnswerRepository.class);
        xpService = mock(XpService.class);
        xpRuleService = mock(XpRuleService.class);
        service = new ExerciseService(userRepository, questionRepository,
                sessionRepository, answerRepository, xpService, xpRuleService);

        user = new User();
        user.setId(UUID.randomUUID());
        user.setFirebaseUid(UID);
        when(userRepository.findByFirebaseUid(UID)).thenReturn(Optional.of(user));
        when(sessionRepository.save(any(ExerciseSession.class))).thenAnswer(inv -> inv.getArgument(0));
        when(answerRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(xpRuleService.computeAccuracyBased(eq("exercise"), anyInt(), anyInt())).thenReturn(10);
        when(xpService.grant(any(), anyInt(), anyString(), anyString(), anyString(), any()))
                .thenReturn(new XpGrantResult(10, 110L, 10, false, false, List.of()));
    }

    private ExerciseQuestion question(String correct) {
        ExerciseQuestion q = new ExerciseQuestion();
        q.setId(UUID.randomUUID());
        q.setCategory("vocabulary");
        q.setCorrectAnswer(correct);
        return q;
    }

    /** Session active với danh sách câu hỏi cho trước; mock cả lookup theo (id, uid). */
    private ExerciseSession sessionWith(List<ExerciseQuestion> questions) {
        ExerciseSession s = new ExerciseSession();
        s.setId(UUID.randomUUID());
        s.setUser(user);
        s.setCategory("vocabulary");
        s.setStatus("active");
        s.setQuestionIds(new ArrayList<>(questions.stream().map(ExerciseQuestion::getId).toList()));
        when(sessionRepository.findByIdAndUser_FirebaseUid(s.getId(), UID)).thenReturn(Optional.of(s));
        when(questionRepository.findAllById(s.getQuestionIds())).thenReturn(questions);
        return s;
    }

    // ── createSession ─────────────────────────────────────────────────────

    @Test
    @DisplayName("createSession category lạ ('listening') -> 400")
    void createSessionRejectsInvalidCategory() {
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.createSession(UID, "listening", 10));
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    @Test
    @DisplayName("createSession pool thiếu câu (5 < 10) -> 404")
    void createSessionThrowsWhenNotEnoughQuestions() {
        // Không có câu yếu, random chỉ trả 5 câu -> dưới cap 10.
        when(questionRepository.findWeakByCategory(eq(user.getId()), eq("vocabulary"), anyInt()))
                .thenReturn(List.of());
        when(questionRepository.findRandomByCategoryExcluding(eq("vocabulary"), any(), anyInt()))
                .thenReturn(List.of(question("A"), question("B"), question("A"), question("B"), question("A")));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.createSession(UID, "vocabulary", 10));
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(sessionRepository, never()).save(any());
    }

    // ── createSession: adaptive selection ─────────────────────────────────

    @Test
    @DisplayName("Adaptive: ưu tiên câu YẾU (từng sai) tối đa 50%, fill phần còn lại bằng random mới")
    void createSessionPrioritisesWeakQuestions() {
        List<ExerciseQuestion> weak = List.of(question("A"), question("A"), question("A"));
        // cap=10 -> weakCap=5; chỉ có 3 câu yếu -> fill 7 câu random.
        when(questionRepository.findWeakByCategory(user.getId(), "vocabulary", 5)).thenReturn(weak);
        List<ExerciseQuestion> fill = new ArrayList<>();
        for (int i = 0; i < 7; i++) fill.add(question("B"));
        when(questionRepository.findRandomByCategoryExcluding(eq("vocabulary"), any(), eq(7))).thenReturn(fill);

        var res = service.createSession(UID, "vocabulary", 10);

        assertEquals(10, res.questions().size());
        // 3 câu đầu là câu yếu (giữ thứ tự weak-first).
        for (int i = 0; i < 3; i++) {
            assertEquals(weak.get(i).getId().toString(), res.questions().get(i).id());
        }
        verify(questionRepository).findWeakByCategory(user.getId(), "vocabulary", 5);
    }

    @Test
    @DisplayName("Adaptive: user mới (0 câu yếu) -> toàn bộ random, excludeIds dùng sentinel")
    void createSessionFallsBackToRandomForNewUser() {
        when(questionRepository.findWeakByCategory(eq(user.getId()), eq("vocabulary"), anyInt()))
                .thenReturn(List.of());
        List<ExerciseQuestion> fill = new ArrayList<>();
        for (int i = 0; i < 10; i++) fill.add(question("A"));
        when(questionRepository.findRandomByCategoryExcluding(eq("vocabulary"), any(), eq(10))).thenReturn(fill);

        var res = service.createSession(UID, "vocabulary", 10);

        assertEquals(10, res.questions().size());
        verify(questionRepository).findRandomByCategoryExcluding(eq("vocabulary"), any(), eq(10));
        verify(questionRepository, never()).findRandomByCategory(anyString(), anyInt());
    }

    // ── completeSession: chấm điểm ────────────────────────────────────────

    @Test
    @DisplayName("Câu KHÔNG trả lời tính là SAI: 10 câu trả lời đúng 2 -> accuracy 20.0 (trên 10, không phải trên 2)")
    void completeSessionCountsUnansweredAsWrong() {
        List<ExerciseQuestion> qs = new ArrayList<>();
        for (int i = 0; i < 10; i++) qs.add(question("A"));
        ExerciseSession session = sessionWith(qs);

        // Chỉ nộp 2 câu, cả 2 đúng.
        List<AnswerSubmit> answers = List.of(
                new AnswerSubmit(qs.get(0).getId(), "A"),
                new AnswerSubmit(qs.get(1).getId(), "A"));

        ExerciseCompleteResponse res = service.completeSession(UID, session.getId(), answers);

        assertEquals(10, res.totalQuestions());
        assertEquals(2, res.correct());
        assertEquals(8, res.incorrect());
        assertEquals(20.0, res.accuracyPercent(), 0.001);
        verify(xpRuleService).computeAccuracyBased("exercise", 2, 10);
    }

    @Test
    @DisplayName("Accuracy làm tròn 1 chữ số: 1/3 -> 33.3, 2/3 -> 66.7")
    void completeSessionAccuracyRounding() {
        List<ExerciseQuestion> qs = List.of(question("A"), question("A"), question("A"));
        ExerciseSession s1 = sessionWith(qs);
        ExerciseCompleteResponse oneOfThree = service.completeSession(UID, s1.getId(), List.of(
                new AnswerSubmit(qs.get(0).getId(), "A"),
                new AnswerSubmit(qs.get(1).getId(), "B"),
                new AnswerSubmit(qs.get(2).getId(), "B")));
        assertEquals(33.3, oneOfThree.accuracyPercent(), 0.001);

        ExerciseSession s2 = sessionWith(qs);
        ExerciseCompleteResponse twoOfThree = service.completeSession(UID, s2.getId(), List.of(
                new AnswerSubmit(qs.get(0).getId(), "A"),
                new AnswerSubmit(qs.get(1).getId(), "A"),
                new AnswerSubmit(qs.get(2).getId(), "B")));
        assertEquals(66.7, twoOfThree.accuracyPercent(), 0.001);
    }

    @Test
    @DisplayName("Đáp án TRÙNG questionId -> chỉ tính lần đầu")
    void completeSessionIgnoresDuplicateAnswers() {
        List<ExerciseQuestion> qs = List.of(question("A"), question("A"));
        ExerciseSession session = sessionWith(qs);

        ExerciseCompleteResponse res = service.completeSession(UID, session.getId(), List.of(
                new AnswerSubmit(qs.get(0).getId(), "A"),  // đúng, tính
                new AnswerSubmit(qs.get(0).getId(), "A"),  // trùng -> bỏ qua
                new AnswerSubmit(qs.get(1).getId(), "B"))); // sai

        assertEquals(1, res.correct());
        assertEquals(2, res.results().size(), "câu trùng không sinh result entry thứ 2");
    }

    @Test
    @DisplayName("questionId NGOÀI session -> bỏ qua, không chấm, không cộng điểm")
    void completeSessionSkipsForeignQuestion() {
        List<ExerciseQuestion> qs = List.of(question("A"));
        ExerciseSession session = sessionWith(qs);

        ExerciseCompleteResponse res = service.completeSession(UID, session.getId(), List.of(
                new AnswerSubmit(UUID.randomUUID(), "A"), // câu lạ -> skip
                new AnswerSubmit(qs.get(0).getId(), "A")));

        assertEquals(1, res.correct());
        assertEquals(1, res.results().size(), "câu ngoài session không được chấm");
    }

    @Test
    @DisplayName("Session đã completed -> 409, không chấm lại")
    void completeSessionTwiceConflicts() {
        ExerciseSession session = sessionWith(List.of(question("A")));
        session.setStatus("completed");

        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                () -> service.completeSession(UID, session.getId(), List.of()));
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(xpService, never()).grant(any(), anyInt(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("XP grant dùng idempotency key 'exercise:<sessionId>:submit'")
    void completeSessionGrantsXpWithSessionScopedKey() {
        List<ExerciseQuestion> qs = List.of(question("A"));
        ExerciseSession session = sessionWith(qs);

        service.completeSession(UID, session.getId(),
                List.of(new AnswerSubmit(qs.get(0).getId(), "A")));

        verify(xpService).grant(eq(user.getId()), eq(10), eq("exercise"),
                eq(session.getId().toString()),
                eq("exercise:" + session.getId() + ":submit"), any());
    }
}
