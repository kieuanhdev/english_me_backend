package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminBadgeUserRow(
        UUID userId,
        String fullName,
        String email,
        Integer totalXp,
        Integer currentStreak,
        LocalDateTime earnedAt
) {
}
