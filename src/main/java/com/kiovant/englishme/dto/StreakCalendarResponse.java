package com.kiovant.englishme.dto;

import java.util.List;

public record StreakCalendarResponse(
        String month,
        Integer currentStreak,
        Integer longestStreak,
        List<String> streakDays
) {}
