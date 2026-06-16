package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record ReviewResponse(
        UUID flashcardId,
        Integer repetitions,
        Double easinessFactor,
        Integer intervalDays,
        LocalDateTime nextReviewAt,
        Integer xpEarned,
        Long totalXp,
        Integer dailyEarnedXp,
        Boolean streakUpdated,
        Integer sessionXp,
        Integer reviewedCount,
        Integer totalCards,
        List<XpGrantResult.Bonus> bonuses,
        List<XpGrantResult.BadgeAward> newBadges
) {
}
