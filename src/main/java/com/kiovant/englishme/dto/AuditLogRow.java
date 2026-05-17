package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AuditLogRow(
        UUID id,
        String adminEmail,
        String action,
        String requestUri,
        String entityType,
        String entityId,
        Integer statusCode,
        String ipAddress,
        LocalDateTime createdAt
) {
}
