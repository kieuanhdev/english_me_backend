package com.kiovant.englishme.integration;

import com.kiovant.englishme.dto.AnswerQuestionRequest;
import com.kiovant.englishme.dto.CatAnswerResponse;
import com.kiovant.englishme.dto.QuestionDto;
import com.kiovant.englishme.dto.StartTestResponse;
import com.kiovant.englishme.dto.TestResultResponse;
import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.QuestionRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.PlacementTestService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration test end-to-end cho Trụ 3 — Placement Test thích ứng CEFR (CAT + IRT 1PL).
 *
 * Chạy với:
 *  - H2 in-memory (profile "test"), tắt Flyway, Hibernate create-drop
 *  - ApplicationContext thật → JPA + transaction + service đầy đủ
 *  - Seed pool đủ A1–C1 (mỗi cấp ≥ vài câu grammar + vocabulary, có difficulty)
 *
 * Kịch bản: start (1 câu) → vòng lặp answer cho tới isDone → complete map θ → CEFR.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class PlacementTestFlowTest {

    @Autowired
    private PlacementTestService placementTestService;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private UserRepository userRepository;

    private User user;

    private static final Map<String, Double> B = Map.of(
            "A1", -2.0, "A2", -1.0, "B1", 0.0, "B2", 1.0, "C1", 2.0);

    @BeforeEach
    void setUp() {
        user = new User();
        user.setFirebaseUid("uid-it-1");
        user.setEmail("it1@example.com");
        user.setFullName("IT User");
        user.setAccountLocked(false);
        user.setTotalXp(0);
        user.setCurrentStreak(0);
        user.setLongestStreak(0);
        userRepository.save(user);

        // Seed pool đủ cho CAT 15 câu: mỗi cấp A1–C1 = 4 grammar + 4 vocabulary + 4 reading.
        for (String level : new String[]{"A1", "A2", "B1", "B2", "C1"}) {
            for (int i = 0; i < 4; i++) {
                seedQuestion(level, "grammar", "A");
                seedQuestion(level, "vocabulary", "A");
                seedQuestion(level, "reading", "A");
            }
        }
    }

    private void seedQuestion(String level, String skill, String correct) {
        Question q = new Question();
        q.setCefrLevel(level);
        q.setSkillCategory(skill);
        q.setQuestion("Sample " + level + "/" + skill + "/" + UUID.randomUUID());
        Map<String, String> options = new LinkedHashMap<>();
        options.put("A", "alpha");
        options.put("B", "bravo");
        options.put("C", "charlie");
        options.put("D", "delta");
        q.setOptions(options);
        q.setCorrectAnswer(correct);
        q.setExplanation("Because.");
        if ("reading".equals(skill)) {
            q.setPassage("A short reading passage for " + level + ".");
        }
        q.setDifficulty(B.get(level));
        questionRepository.save(q);
    }

    @Test
    @DisplayName("Full CAT flow: start → answer cho tới isDone → complete; trả lời đúng hết → level cao (B2/C1)")
    void fullCatFlowConvergesHigh() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        assertNotNull(start.sessionId());
        assertNotNull(start.firstQuestion());
        assertEquals(15, start.maxQuestions());
        assertNotNull(start.notice());

        // Trả lời ĐÚNG mọi câu → θ leo lên → hội tụ B2/C1.
        QuestionDto current = start.firstQuestion();
        int answered = 0;
        TestResultResponse result = null;
        while (current != null) {
            Question q = questionRepository.findById(current.id()).orElseThrow();
            CatAnswerResponse ans = placementTestService.answerQuestion(
                    user.getFirebaseUid(),
                    start.sessionId(),
                    new AnswerQuestionRequest(q.getId(), q.getCorrectAnswer())
            );
            answered++;
            assertEquals(answered, ans.answeredCount());
            assertEquals(15, ans.maxQuestions());
            assertTrue(ans.isCorrect());
            if (ans.isDone()) {
                assertNull(ans.nextQuestion());
                break;
            }
            current = ans.nextQuestion();
        }
        assertEquals(15, answered, "CAT dừng đúng sau maxQuestions câu");

        result = placementTestService.completeTest(user.getFirebaseUid(), start.sessionId());
        assertNotNull(result);
        assertTrue(result.finalTheta() > 0.5, "trả lời đúng hết → θ cuối cao");
        assertTrue(result.resultLevel().equals("B2") || result.resultLevel().equals("C1"),
                "θ cao → B2 hoặc C1, nhận được: " + result.resultLevel());

        User reloaded = userRepository.findById(user.getId()).orElseThrow();
        assertEquals(result.resultLevel(), reloaded.getCefrLevel());
        assertEquals(Boolean.TRUE, reloaded.getIsOnboarded());
    }

    @Test
    @DisplayName("Trả lời SAI hết → θ tụt → level thấp (A1/A2)")
    void allWrongConvergesLow() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        QuestionDto current = start.firstQuestion();
        while (current != null) {
            Question q = questionRepository.findById(current.id()).orElseThrow();
            String wrong = "A".equals(q.getCorrectAnswer()) ? "B" : "A";
            CatAnswerResponse ans = placementTestService.answerQuestion(
                    user.getFirebaseUid(), start.sessionId(),
                    new AnswerQuestionRequest(q.getId(), wrong));
            if (ans.isDone()) break;
            current = ans.nextQuestion();
        }
        TestResultResponse result = placementTestService.completeTest(user.getFirebaseUid(), start.sessionId());
        assertTrue(result.finalTheta() < -0.5, "sai hết → θ cuối thấp");
        assertTrue(result.resultLevel().equals("A1") || result.resultLevel().equals("A2"),
                "θ thấp → A1 hoặc A2, nhận được: " + result.resultLevel());
    }

    @Test
    @DisplayName("Trả lời lại câu đã trả lời → IllegalStateException")
    void duplicateAnswerIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        var q = start.firstQuestion();

        placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(q.id(), "A"));
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(q.id(), "B"))
        );
    }

    @Test
    @DisplayName("Complete xong rồi answer tiếp → IllegalStateException")
    void answerAfterCompleteIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        QuestionDto current = start.firstQuestion();
        while (current != null) {
            Question q = questionRepository.findById(current.id()).orElseThrow();
            CatAnswerResponse ans = placementTestService.answerQuestion(
                    user.getFirebaseUid(), start.sessionId(),
                    new AnswerQuestionRequest(q.getId(), q.getCorrectAnswer()));
            if (ans.isDone()) break;
            current = ans.nextQuestion();
        }
        placementTestService.completeTest(user.getFirebaseUid(), start.sessionId());

        var firstQuestion = start.firstQuestion();
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(firstQuestion.id(), "B"))
        );
    }

    @Test
    @DisplayName("User B đụng session của user A → not found (chống IDOR)")
    void foreignUserCannotTouchSession() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        var q = start.firstQuestion();

        User other = new User();
        other.setFirebaseUid("uid-it-2");
        other.setEmail("it2@example.com");
        other.setFullName("IT User 2");
        other.setAccountLocked(false);
        other.setTotalXp(0);
        other.setCurrentStreak(0);
        other.setLongestStreak(0);
        userRepository.save(other);

        assertThrows(IllegalArgumentException.class, () ->
                placementTestService.answerQuestion(other.getFirebaseUid(), start.sessionId(),
                        new AnswerQuestionRequest(q.id(), "A")));
        assertThrows(IllegalArgumentException.class, () ->
                placementTestService.completeTest(other.getFirebaseUid(), start.sessionId()));
    }
}
