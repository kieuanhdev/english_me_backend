package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record ExerciseCompleteResponse(
        UUID sessionId,
        String category,
        int totalQuestions,
        int correct,
        int incorrect,
        int accuracyPercent,
        int xpEarned,
        List<ExerciseAnswerResult> results
) {
}
