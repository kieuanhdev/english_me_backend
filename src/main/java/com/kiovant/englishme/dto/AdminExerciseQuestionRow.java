package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminExerciseQuestionRow(
        UUID id,
        String category,
        String difficulty,
        String level,
        String question,
        String optionsJson,
        String correctAnswer,
        long attemptCount,
        long correctCount,
        Double avgAccuracy
) {
}
