package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        String type,
        String title,
        String body,
        String actionRoute,
        boolean isRead,
        LocalDateTime createdAt
) {}
