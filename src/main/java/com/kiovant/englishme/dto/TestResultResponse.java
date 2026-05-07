package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record TestResultResponse(
        UUID sessionId,
        String resultLevel,
        int score,
        int totalQuestions,
        List<AnswerReview> review
) {
    public record AnswerReview(
            UUID questionId,
            String question,
            String selectedAnswer,
            String correctAnswer,
            boolean isCorrect,
            String explanation
    ) {}
}
