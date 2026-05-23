package com.kiovant.englishme.dto;

import java.util.List;

public record LevelDetailResponse(
        LevelInfo level,
        List<String> outcomes,
        List<LearningHubResponse.UnitSummary> units,
        List<LearningHubResponse.SkillTrackSummary> skillTracks
) {
    public record LevelInfo(
            String code,
            String title,
            String description,
            double progress,
            String status,
            boolean locked
    ) {}
}
