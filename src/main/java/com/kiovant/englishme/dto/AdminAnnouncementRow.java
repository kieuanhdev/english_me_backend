package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminAnnouncementRow(
        UUID id,
        String title,
        String body,
        String severity,
        LocalDateTime startAt,
        LocalDateTime endAt,
        Boolean isActive,
        String createdByEmail
) {
}
