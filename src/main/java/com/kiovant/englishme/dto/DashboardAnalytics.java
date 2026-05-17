package com.kiovant.englishme.dto;

import java.util.List;

public record DashboardAnalytics(
        KpiSummary kpi,
        TimeSeries newUsersSeries,
        TimeSeries activeUsersSeries,
        List<NamedCount> cefrDistribution,
        List<NamedCount> contentDistribution,
        List<NamedCount> xpBySource7d,
        int[][] activityHeatmap,
        List<TopUserRow> topStreak,
        List<TopUserRow> topXp,
        List<TopFlashcardRow> topWords,
        List<TopPronunciationMissRow> topPronunciationMisses,
        List<InactiveUserRow> inactiveUsers,
        SystemHealth health
) {

    public record KpiSummary(
            long totalUsers,
            long newUsersToday,
            long activeToday,
            long dau,
            long wau,
            long mau,
            double retention7d,
            double retention30d,
            long studySessionsToday,
            long xpAwardedToday,
            double averageStreak
    ) {}

    public record TimeSeries(List<String> labels, List<Long> values) {}

    public record NamedCount(String label, long value) {}

    public record TopUserRow(String userId, String fullName, String email, String cefrLevel, long value) {}

    public record TopFlashcardRow(String word, String cefr, long studyCount) {}

    public record TopPronunciationMissRow(String referenceText, double averageScore, long attempts) {}

    public record InactiveUserRow(String userId, String fullName, String email, int currentStreak, String lastActive) {}

    public record SystemHealth(
            String firebaseStatus,
            String pronunciationStatus,
            String chatStatus,
            long databaseSizeMb,
            int dbConnections,
            long audioDiskUsageMb
    ) {}
}
