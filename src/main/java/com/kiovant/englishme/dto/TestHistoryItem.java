package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record TestHistoryItem(
        UUID sessionId,
        String topic,
        String level,
        String status,
        Integer total,
        Integer correct,
        Integer accuracyPercent,
        Integer xpEarned,
        Integer timeTakenSeconds,
        String cefrSuggestion,
        LocalDateTime createdAt,
        LocalDateTime completedAt
) {
}
