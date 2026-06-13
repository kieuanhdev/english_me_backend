package com.kiovant.englishme.dto;

import java.util.UUID;

/**
 * Phản hồi sau mỗi câu trả lời trong CAT (Computerized Adaptive Testing).
 * Gồm feedback câu vừa làm + câu kế tiếp (hoặc isDone khi đã đủ maxQuestions).
 * Xem docs/placement-test-cat-upgrade.md.
 */
public record CatAnswerResponse(
        UUID questionId,
        String selectedAnswer,
        String correctAnswer,
        boolean isCorrect,
        String explanation,
        int answeredCount,
        int maxQuestions,
        boolean isDone,
        // null khi isDone == true (không còn câu kế tiếp).
        QuestionDto nextQuestion
) {}
