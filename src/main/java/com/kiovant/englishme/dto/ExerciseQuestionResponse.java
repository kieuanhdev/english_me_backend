package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record ExerciseQuestionResponse(
        UUID id,
        String category,
        String difficulty,
        String question,
        List<String> options,
        String hint,
        String level
) {
}
