package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminPronunciationAttemptRow(
        UUID attemptId,
        String userEmail,
        String userFullName,
        String firebaseUid,
        UUID exerciseId,
        String referenceText,
        int overallScore,
        int accuracyScore,
        int fluencyScore,
        String provider,
        LocalDateTime createdAt
) {
}
