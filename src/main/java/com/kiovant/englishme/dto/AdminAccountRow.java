package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminAccountRow(
        UUID id,
        String email,
        String fullName,
        String role,
        boolean isActive,
        LocalDateTime lastLoginAt,
        LocalDateTime createdAt
) {
}
