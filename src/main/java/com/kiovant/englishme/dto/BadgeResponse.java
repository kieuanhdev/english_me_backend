package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record BadgeResponse(
        UUID id,
        String name,
        String description,
        String iconUrl,
        String conditionType,
        LocalDateTime earnedAt
) {}
