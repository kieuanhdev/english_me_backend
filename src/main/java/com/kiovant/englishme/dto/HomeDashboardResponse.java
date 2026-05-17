package com.kiovant.englishme.dto;

import java.util.List;

public record HomeDashboardResponse(
        HomeUserInfo user,
        DailyStats dailyStats,
        WordOfDay wordOfDay,
        ContinueLearning continueLearning,
        List<Recommendation> recommendations
) {

    public record HomeUserInfo(
            String fullName,
            String avatarUrl,
            String cefrLevel,
            Integer totalXp,
            Integer currentStreak,
            Integer longestStreak
    ) {}

    public record DailyStats(
            int xpToday,
            int xpWeek,
            int activeDaysThisWeek,
            Integer currentStreak
    ) {}

    public record WordOfDay(
            java.util.UUID id,
            String word,
            String pronunciation,
            String partOfSpeech,
            String definitionVi,
            String definitionEn,
            String exampleSentence,
            String exampleTranslation,
            String level
    ) {}

    public record ContinueLearning(
            String type,
            java.util.UUID topicId,
            String title,
            String level,
            String slug
    ) {}

    public record Recommendation(
            String type,
            String title,
            String description,
            String actionUrl
    ) {}
}
