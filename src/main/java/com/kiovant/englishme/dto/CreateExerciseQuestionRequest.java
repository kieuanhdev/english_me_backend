package com.kiovant.englishme.dto;

public record CreateExerciseQuestionRequest(
        String category,
        String difficulty,
        String level,
        String question,
        String optionsJson,
        String correctAnswer,
        String explanation,
        String hint
) {
}
