package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record PronunciationAttemptHistoryItemResponse(
        UUID attemptId,
        UUID lessonItemId,
        String referenceText,
        int overallScore,
        int accuracyScore,
        int fluencyScore,
        String provider,
        LocalDateTime createdAt
) {
}
