package com.kiovant.englishme.dto;

public record UpdateBadgeRequest(
        String name,
        String description,
        String iconUrl,
        String conditionType,
        Integer conditionValue,
        Boolean isActive
) {
}
