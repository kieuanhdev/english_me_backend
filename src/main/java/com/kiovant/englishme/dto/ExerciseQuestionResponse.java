package com.kiovant.englishme.dto;

import java.util.Map;

public record ExerciseQuestionResponse(
        String id,
        String type,
        String category,
        String difficulty,
        String question,
        Map<String, String> options,
        String correctAnswer,
        String explanation,
        String hint,
        String passage,
        String audioUrl
) {
}
