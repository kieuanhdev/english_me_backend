package com.kiovant.englishme.dto;

import java.util.List;

public record RecommendationsResponse(
        List<Recommendation> recommendations
) {
    public record Recommendation(
            String type,
            String title,
            String subtitle,
            String level,
            String skill,
            String lessonId,
            int priority
    ) {}
}
