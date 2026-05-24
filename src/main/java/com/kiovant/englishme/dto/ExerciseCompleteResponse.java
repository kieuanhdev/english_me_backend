package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record ExerciseCompleteResponse(
        UUID sessionId,
        String category,
        int totalQuestions,
        int correct,
        int incorrect,
        double accuracyPercent,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        List<ExerciseAnswerResult> results
) {
}
