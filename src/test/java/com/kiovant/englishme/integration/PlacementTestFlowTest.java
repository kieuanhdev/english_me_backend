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
 *  - Seed dữ liệu trực tiếp qua repository (4 A1 + 4 A2)
 *
 * Kịch bản:
 *  1. Tạo user demo
 *  2. startTest -> nhận sessionId + 8 câu hỏi
 *  3. answerQuestion 8 lần — pha trộn đúng/sai để CEFR = A1
 *  4. completeTest -> resultLevel = A1, score chính xác
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

        // Seed 4 A1 + 4 A2 (mỗi level = 2 Grammar + 2 Vocabulary)
        seedQuestion("A1", "Grammar", "A");
        seedQuestion("A1", "Grammar", "B");
        seedQuestion("A1", "Vocabulary", "A");
        seedQuestion("A1", "Vocabulary", "B");
        seedQuestion("A2", "Grammar", "A");
        seedQuestion("A2", "Grammar", "B");
        seedQuestion("A2", "Vocabulary", "A");
        seedQuestion("A2", "Vocabulary", "B");
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
    @DisplayName("Full flow: start -> answer x N -> complete trả kết quả CEFR đúng")
    void fullPlacementTestFlowReturnsCefrA1() {
        // 1. Start
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        assertNotNull(start.sessionId());
        assertEquals(start.questions().size(), start.totalQuestions());
        assertTrue(start.totalQuestions() >= 4, "Phải có ít nhất 4 câu hỏi");

        // 2. Answer từng câu — đúng cho A1, sai cho A2 (để resultLevel = A1)
        int answered = 0;
        for (var qDto : start.questions()) {
            Question q = questionRepository.findById(qDto.id()).orElseThrow();
            String selected;
            if ("A1".equals(q.getCefrLevel())) {
                selected = q.getCorrectAnswer(); // đúng
            } else {
                // chọn 1 đáp án khác correct
                selected = "A".equals(q.getCorrectAnswer()) ? "B" : "A";
            }
            AnswerQuestionResponse ans = placementTestService.answerQuestion(
                    start.sessionId(),
                    new AnswerQuestionRequest(q.getId(), selected)
            );
            answered++;
            assertEquals(answered, ans.answeredCount());
            assertEquals(start.totalQuestions(), ans.totalQuestions());
        }

        // 3. Complete
        TestResultResponse result = placementTestService.completeTest(start.sessionId());
        assertNotNull(result);
        assertEquals(start.totalQuestions(), result.totalQuestions());
        assertEquals("A1", result.resultLevel(),
                "User đúng 100% A1, 0% A2 -> phải pass A1 và không pass A2");

        // 4. User được set cefrLevel + isOnboarded
        User reloaded = userRepository.findById(user.getId()).orElseThrow();
        assertEquals("A1", reloaded.getCefrLevel());
        assertEquals(Boolean.TRUE, reloaded.getIsOnboarded());
    }

    @Test
    @DisplayName("Trả lời lại câu đã trả lời -> IllegalStateException")
    void duplicateAnswerIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());
        var q = start.questions().get(0);

        placementTestService.answerQuestion(start.sessionId(), new AnswerQuestionRequest(q.id(), "A"));
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(start.sessionId(), new AnswerQuestionRequest(q.id(), "B"))
        );
    }

    @Test
    @DisplayName("Complete xong rồi answer tiếp -> IllegalStateException")
    void answerAfterCompleteIsRejected() {
        StartTestResponse start = placementTestService.startTest(user.getFirebaseUid());

        // Trả lời hết
        for (var qDto : start.questions()) {
            placementTestService.answerQuestion(start.sessionId(), new AnswerQuestionRequest(qDto.id(), "A"));
        }
        placementTestService.completeTest(start.sessionId());

        var firstQuestion = start.questions().get(0);
        assertThrows(IllegalStateException.class, () ->
                placementTestService.answerQuestion(start.sessionId(), new AnswerQuestionRequest(firstQuestion.id(), "B"))
        );
    }
}
