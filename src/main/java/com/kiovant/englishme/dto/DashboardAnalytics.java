package com.kiovant.englishme.dto;

import java.util.List;

public record DashboardAnalytics(
        KpiSummary kpi,
        TimeSeries newUsersSeries,
        List<NamedCount> cefrDistribution,
        List<NamedCount> xpBySource7d
) {

    public record KpiSummary(
            long totalUsers,
            long newUsersToday,
            long dau,
            long wau,
            long mau,
            double retention7d,
            long xpAwardedToday
    ) {}

    public record TimeSeries(List<String> labels, List<Long> values) {}

    public record NamedCount(String label, long value) {}
}
