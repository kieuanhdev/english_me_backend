package com.kiovant.englishme.dto;

import java.util.List;

public record LearningHubResponse(
        String currentLevel,
        String selectedLevel,
        String nextRecommendedSkill,
        DailyGoal dailyGoal,
        List<LevelSummary> levels,
        List<SkillTrackSummary> skillTracks,
        List<UnitSummary> units,
        List<SupportTrackSummary> supportTracks
) {
    public record DailyGoal(
            int targetXp,
            int earnedXp,
            int completedActivities
    ) {}

    public record LevelSummary(
            String code,
            String title,
            String description,
            double progress,
            String status,
            boolean locked
    ) {}

    public record SkillTrackSummary(
            String type,
            String title,
            String description,
            String icon,
            String accentColor,
            double progress,
            int totalLessons,
            int completedLessons,
            String nextLessonId,
            boolean enabled
    ) {}

    public record UnitSummary(
            String id,
            String level,
            String title,
            String subtitle,
            int lessonCount,
            int completedLessonCount,
            String status,
            List<String> skillCoverage
    ) {}

    public record SupportTrackSummary(
            String type,
            String title,
            String description,
            String route,
            double progress,
            boolean enabled
    ) {}
}
