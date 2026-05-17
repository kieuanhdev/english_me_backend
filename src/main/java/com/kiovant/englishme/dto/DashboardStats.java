package com.kiovant.englishme.dto;

public record DashboardStats(
        long totalUsers,
        long activeToday,
        long newUsersToday,
        long totalDesks,
        long totalFlashcards,
        long totalPronunciationAttempts
) {}
