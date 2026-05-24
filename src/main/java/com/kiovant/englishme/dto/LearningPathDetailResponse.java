package com.kiovant.englishme.dto;

import java.util.List;

/** Response cho GET /api/learning/paths/{pathId} (spec mục 4.3). */
public record LearningPathDetailResponse(
        String id,
        String level,
        String title,
        String description,
        String status,
        double progress,
        int requiredScoreToPass,
        List<ActivitySummary> activities
) {
    public record ActivitySummary(
            String id,
            String pathId,
            String title,
            String subtitle,
            String skill,
            String type,
            String status,
            int order,
            int durationMinutes,
            int xpReward
    ) {}
}
