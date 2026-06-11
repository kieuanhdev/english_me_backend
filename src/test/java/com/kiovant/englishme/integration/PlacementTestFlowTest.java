package com.kiovant.englishme.integration;

import com.kiovant.englishme.dto.AnswerQuestionRequest;
import com.kiovant.englishme.dto.AnswerQuestionResponse;
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

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration test end-to-end cho Trụ 3 — Placement Test thích ứng CEFR.
 *
 * Chạy với:
 *  - H2 in-memory (profile "test"), tắt Flyway, Hibernate create-drop
 *  - ApplicationContext thật → JPA + transaction + service đầy đủ
 *  - Seed dữ liệu trực tiếp qua repository (4 câu/cấp A1–B2, skill_category lowercase)
 *
 * Kịch bản:
 *  1. Tạo user demo
 *  2. startTest -> nhận sessionId + 16 câu hỏi A1–B2 + notice
 *  3. answerQuestion — đúng A1+A2, sai B1+B2 (weighted R = 12/40 = 0.30 -> A2)
 *  4. completeTest -> resultLevel = A2 theo Weighted Difficulty Scoring (§A.1)
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

        // Seed 4 câu/cấp A1–B2 (mỗi cấp = 2 grammar + 2 vocabulary), skill_category LOWERCASE.
        for (String level : new String[]{"A1", "A2", "B1", "B2"}) {
            seedQuestion(level, "grammar", "A");
            seedQuestion(level, "grammar", "B");
            seedQuestion(level, "vocabulary", "A");
            seedQuestion(level, "vocabulary", "B");
        }
    }

    private void seedQuestion(String level, String skill, String correct) {
        Question q = new Question();
        q.setCefrLevel(level);
        q.setSkillCategory(skill);
        q.setQuestion("Sample " + level + "/" + skill);
        Map<String, String> options = new LinkedHashMap<>();
        options.put("A", "alpha");
        options.put("B", "bravo");
        options.put("C", "charlie");
        options.put("D", "delta");
        q.setOptions(options);
        q.setCorrectAnswer(correct);
        q.setExplanation("Because.");
        questionRepository.save(q);
    }

    @Test
    @DisplayName("Full flow: start -> answer x N -> complete trả CEFR theo weighted scoring")
    void fullPlacementTestFlowReturnsWeightedCefr() {
        // 1. Start — đề rút từ pool A1–B2 (16 câu nếu pool đủ) + notice cap B2.
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        assertNotNull(start.sessionId());
        assertEquals(start.questions().size(), start.totalQuestions());
        assertTrue(start.totalQuestions() >= 4, "Phải có ít nhất 4 câu hỏi");
        assertNotNull(start.notice());
        assertTrue(start.notice().contains("B2"), "notice phải nêu rõ giới hạn B2");

        // 2. Answer — đúng A1+A2, sai B1+B2. Weighted: earned = w(A1)*nA1 + w(A2)*nA2.
        int answered = 0;
        for (var qDto : start.questions()) {
            Question q = questionRepository.findById(qDto.id()).orElseThrow();
            boolean answerCorrect = "A1".equals(q.getCefrLevel()) || "A2".equals(q.getCefrLevel());
            String selected = answerCorrect
                    ? q.getCorrectAnswer()
                    : ("A".equals(q.getCorrectAnswer()) ? "B" : "A");
            AnswerQuestionResponse ans = placementTestService.answerQuestion(
                    user.getFirebaseUid(),
                    start.sessionId(),
                    new AnswerQuestionRequest(q.getId(), selected)
            );
            answered++;
            assertEquals(answered, ans.answeredCount());
            assertEquals(start.totalQuestions(), ans.totalQuestions());
        }

        // 3. Complete — pool đủ A1–B2 (4/cấp): R = (1*4 + 2*4)/40 = 0.30 -> A2 (cap B2 không kích hoạt).
        TestResultResponse result = placementTestService.completeTest(user.getFirebaseUid(), start.sessionId());
        assertNotNull(result);
        assertEquals(start.totalQuestions(), result.totalQuestions());
        assertEquals("A2", result.resultLevel(),
                "Đúng A1+A2, sai B1+B2 -> R=0.30 -> band A2 theo weighted scoring");
        assertFalse(result.canGoHigherThanB2());

        // 4. User được set cefrLevel + isOnboarded
        User reloaded = userRepository.findById(user.getId()).orElseThrow();
        assertEquals("A2", reloaded.getCefrLevel());
        assertEquals(Boolean.TRUE, reloaded.getIsOnboarded());
    }

    @Test
    @DisplayName("Trả lời lại câu đã trả lời -> IllegalStateException")
    void duplicateAnswerIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        var q = start.questions().get(0);

        placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(q.id(), "A"));
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(q.id(), "B"))
        );
    }

    @Test
    @DisplayName("Complete xong rồi answer tiếp -> IllegalStateException")
    void answerAfterCompleteIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());

        // Trả lời hết
        for (var qDto : start.questions()) {
            placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(qDto.id(), "A"));
        }
        placementTestService.completeTest(user.getFirebaseUid(), start.sessionId());

        var firstQuestion = start.questions().get(0);
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(user.getFirebaseUid(), start.sessionId(), new AnswerQuestionRequest(firstQuestion.id(), "B"))
        );
    }

    @Test
    @DisplayName("User B đụng session của user A -> not found (chống IDOR)")
    void foreignUserCannotTouchSession() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        var q = start.questions().get(0);

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
