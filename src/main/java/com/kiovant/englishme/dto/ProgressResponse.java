package com.kiovant.englishme.dto;

import java.util.List;

public record ProgressResponse(
        Integer totalXp,
        Integer currentStreak,
        Integer longestStreak,
        String cefrLevel,
        Integer xpGoal,
        List<SkillScore> skills,
        WeekSummary weekSummary
) {}
