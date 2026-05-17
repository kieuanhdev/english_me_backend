package com.kiovant.englishme.dto;

import java.util.List;

public record PronunciationAnalytics(
        long totalAttempts,
        Double averageScore,
        List<ScoreBucket> scoreBuckets,
        List<WeakWord> weakestWords,
        List<IssueType> topIssues,
        List<ProviderStat> providers
) {
    public record ScoreBucket(String label, long count) {}
    public record WeakWord(String word, long attempts, Double avgScore) {}
    public record IssueType(String issueType, long count) {}
    public record ProviderStat(String provider, long attempts, Double avgOverall, Double avgAccuracy, Double avgFluency) {}
}
