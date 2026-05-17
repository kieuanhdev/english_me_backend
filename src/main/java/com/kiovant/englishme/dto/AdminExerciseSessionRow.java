package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminExerciseSessionRow(
        UUID id,
        UUID userId,
        String userEmail,
        String userFullName,
        String category,
        String status,
        int questionCount,
        long answeredCount,
        long correctCount,
        LocalDateTime createdAt,
        LocalDateTime completedAt
) {
}
