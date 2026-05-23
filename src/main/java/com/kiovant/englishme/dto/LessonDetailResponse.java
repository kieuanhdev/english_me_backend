package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

public record LessonDetailResponse(
        String id,
        String level,
        String skill,
        String unitId,
        String title,
        String subtitle,
        int durationMinutes,
        int xpReward,
        String status,
        Map<String, Object> content,
        List<Activity> activities
) {
    public record Activity(
            String id,
            String type,
            String question,
            List<Option> options,
            String correctOptionId,
            String explanationVi,
            String expectedText,
            Integer minScoreToPass,
            String prompt,
            List<String> rubric,
            String textAnswer
    ) {
        public record Option(
                String id,
                String text
        ) {}
    }
}
