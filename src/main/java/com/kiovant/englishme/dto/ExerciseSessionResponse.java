package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record ExerciseSessionResponse(
        UUID sessionId,
        String category,
        int totalQuestions,
        List<ExerciseQuestionResponse> questions
) {
}
