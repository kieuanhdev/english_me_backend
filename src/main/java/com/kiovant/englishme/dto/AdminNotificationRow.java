package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminNotificationRow(
        UUID id,
        String title,
        String body,
        String segmentType,
        String segmentValue,
        Integer targetCount,
        Integer successCount,
        Integer failureCount,
        String sentByEmail,
        LocalDateTime sentAt
) {
}
