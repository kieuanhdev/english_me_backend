package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminBannerRow(
        UUID id,
        String title,
        String imageUrl,
        String actionUrl,
        LocalDateTime startAt,
        LocalDateTime endAt,
        Integer sortOrder,
        Boolean isActive
) {
}
