package com.kiovant.englishme.dto;

import java.util.List;

public record SkillLessonsResponse(
        String level,
        String skill,
        String title,
        String description,
        List<LessonSummary> lessons
) {
    public record LessonSummary(
            String id,
            String unitId,
            String title,
            String subtitle,
            String activityType,
            int durationMinutes,
            int xpReward,
            String status,
            int order
    ) {}
}
