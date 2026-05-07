package com.kiovant.englishme.dto;

import java.util.UUID;

public record AnswerQuestionResponse(
        UUID questionId,
        String selectedAnswer,
        String correctAnswer,
        boolean isCorrect,
        String explanation,
        int answeredCount,
        int totalQuestions
) {}
