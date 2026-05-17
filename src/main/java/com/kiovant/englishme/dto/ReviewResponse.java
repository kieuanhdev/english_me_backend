package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record ReviewResponse(
        UUID flashcardId,
        Integer repetitions,
        Double easinessFactor,
        Integer intervalDays,
        LocalDateTime nextReviewAt,
        Integer xpEarned,
        Integer sessionXp,
        Integer reviewedCount,
        Integer totalCards
) {
}
