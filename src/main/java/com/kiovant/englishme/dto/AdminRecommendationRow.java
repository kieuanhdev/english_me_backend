package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminRecommendationRow(
        UUID id,
        String level,
        String type,
        String title,
        String description,
        String actionUrl,
        Integer sortOrder,
        Boolean isActive
) {
}
