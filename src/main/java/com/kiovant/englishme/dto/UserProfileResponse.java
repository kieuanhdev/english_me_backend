package com.kiovant.englishme.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record UserProfileResponse(
        UUID id,
        String email,
        String fullName,
        String avatarUrl,
        String cefrLevel,
        Boolean isOnboarded,
        Integer totalXp,
        Integer currentStreak,
        Integer longestStreak,
        LocalDate lastActiveDate,
        LocalDateTime createdAt,
        List<BadgeResponse> badges
) {}
