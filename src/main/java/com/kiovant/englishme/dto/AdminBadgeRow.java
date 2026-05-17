package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminBadgeRow(
        UUID id,
        String name,
        String description,
        String iconUrl,
        String conditionType,
        Integer conditionValue,
        Boolean isActive,
        long awardedCount,
        LocalDateTime createdAt
) {
}
