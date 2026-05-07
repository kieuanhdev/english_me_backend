package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record UserSyncResponse(
        UUID id,
        String email,
        String fullName,
        String avatarUrl,
        String cefrLevel,
        Boolean isOnboarded,
        LocalDateTime createdAt
) {}
