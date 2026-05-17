package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record StudySessionSummaryResponse(
        UUID sessionId,
        UUID deskId,
        String status,
        Integer totalCards,
        Integer masteredCards,
        Integer hardCards,
        Integer againCards,
        Integer xpEarned,
        Integer newWordsLearned,
        LocalDateTime startedAt,
        LocalDateTime completedAt
) {
}
