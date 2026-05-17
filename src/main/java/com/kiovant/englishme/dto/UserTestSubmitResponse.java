package com.kiovant.englishme.dto;

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
        int timeTakenSeconds,
        String cefrSuggestion
) {
}
