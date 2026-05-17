package com.kiovant.englishme.dto;

import java.util.List;

public record ProgressResponse(
        Integer totalXp,
        Integer currentStreak,
        Integer longestStreak,
        String cefrLevel,
        List<SkillScore> skills,
        WeekSummary weekSummary
) {}
