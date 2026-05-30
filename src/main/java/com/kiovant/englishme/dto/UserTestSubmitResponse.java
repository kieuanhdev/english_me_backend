package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record UserTestSubmitResponse(
        UUID sessionId,
        String topic,
        String level,
        int total,
        int correct,
        int incorrect,
        int accuracyPercent,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        int timeTakenSeconds,
        String cefrSuggestion,
        List<XpGrantResult.Bonus> bonuses
) {
}
