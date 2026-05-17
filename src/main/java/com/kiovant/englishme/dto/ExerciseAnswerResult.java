package com.kiovant.englishme.dto;

import java.util.UUID;

public record ExerciseAnswerResult(
        UUID questionId,
        String selectedAnswer,
        String correctAnswer,
        boolean isCorrect,
        String explanation
) {
}
