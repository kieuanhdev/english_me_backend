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
            Integer currentStreak,
            int xpGoal,
            long dueCardCount
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

    /**
     * "Tiếp tục học" cá nhân hóa theo tiến độ thật.
     *
     * @param type       "grammar" | "lesson" — nguồn nội dung.
     * @param topicId    id grammar topic (UUID) khi type=grammar; null khi type=lesson.
     * @param lessonId   id learning lesson (String) khi type=lesson; null khi type=grammar.
     * @param actionType "continue" (đang dở) | "retry" (điểm chưa đạt) | "start" (bài kế tiếp)
     *                   | "grammar" (fallback).
     * @param progress   % hoàn thành nếu biết (0–100), null nếu không áp dụng.
     */
    public record ContinueLearning(
            String type,
            java.util.UUID topicId,
            String lessonId,
            String title,
            String level,
            String slug,
            String actionType,
            Integer progress
    ) {}

    public record Recommendation(
            String type,
            String title,
            String description,
            String actionUrl,
            String reason
    ) {}
}
