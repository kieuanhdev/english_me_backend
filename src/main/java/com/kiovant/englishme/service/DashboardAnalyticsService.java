package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DashboardAnalytics;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class DashboardAnalyticsService {

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("MM-dd");
    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final int TOP_LEARNERS_LIMIT = 10;

    private final UserRepository userRepository;
    private final XpHistoryRepository xpHistoryRepository;

    public DashboardAnalyticsService(
            UserRepository userRepository,
            XpHistoryRepository xpHistoryRepository
    ) {
        this.userRepository = userRepository;
        this.xpHistoryRepository = xpHistoryRepository;
    }

    public DashboardAnalytics build() {
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();

        return new DashboardAnalytics(
                buildKpi(today, todayStart),
                buildNewUsersSeries(today, 14),
                buildCefrDistribution(),
                buildXpDailySeries(today, 7),
                buildTopLearners()
        );
    }

    private DashboardAnalytics.KpiSummary buildKpi(LocalDate today, LocalDateTime todayStart) {
        long totalUsers = userRepository.count();
        long newUsersToday = userRepository.countCreatedSince(todayStart);

        long dau = xpHistoryRepository.countActiveUsersBetween(today, today);
        long wau = xpHistoryRepository.countActiveUsersBetween(today.minusDays(6), today);
        long mau = xpHistoryRepository.countActiveUsersBetween(today.minusDays(29), today);

        double retention7d = totalUsers == 0 ? 0.0 : (wau * 100.0) / totalUsers;
        long xpToday = xpHistoryRepository.sumXpOnDate(today);

        return new DashboardAnalytics.KpiSummary(
                totalUsers, newUsersToday, dau, wau, mau, round1(retention7d), xpToday);
    }

    private DashboardAnalytics.TimeSeries buildNewUsersSeries(LocalDate today, int days) {
        List<String> labels = new ArrayList<>(days);
        List<Long> values = new ArrayList<>(days);
        for (int i = days - 1; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            LocalDateTime start = d.atStartOfDay();
            LocalDateTime end = d.plusDays(1).atStartOfDay();
            labels.add(d.format(DAY_FMT));
            values.add(userRepository.countCreatedBetween(start, end));
        }
        return new DashboardAnalytics.TimeSeries(labels, values);
    }

    private List<DashboardAnalytics.NamedCount> buildCefrDistribution() {
        Map<String, Long> map = new LinkedHashMap<>();
        for (String level : CEFR_ORDER) map.put(level, 0L);
        map.put("Unknown", 0L);
        for (Object[] row : userRepository.countByCefrLevel()) {
            String level = row[0] == null ? "Unknown" : String.valueOf(row[0]).toUpperCase();
            long count = ((Number) row[1]).longValue();
            map.merge(map.containsKey(level) ? level : "Unknown", count, Long::sum);
        }
        List<DashboardAnalytics.NamedCount> result = new ArrayList<>(map.size());
        map.forEach((k, v) -> result.add(new DashboardAnalytics.NamedCount(k, v)));
        return result;
    }

    /** XP thực thu mỗi ngày trong {@code days} ngày gần nhất, đọc trực tiếp từ xp_history. */
    private DashboardAnalytics.TimeSeries buildXpDailySeries(LocalDate today, int days) {
        LocalDate from = today.minusDays(days - 1L);
        Map<LocalDate, Long> byDate = new HashMap<>();
        for (Object[] row : xpHistoryRepository.sumXpByDateBetween(from, today)) {
            byDate.put((LocalDate) row[0], ((Number) row[1]).longValue());
        }
        List<String> labels = new ArrayList<>(days);
        List<Long> values = new ArrayList<>(days);
        for (int i = days - 1; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            labels.add(d.format(DAY_FMT));
            values.add(byDate.getOrDefault(d, 0L));
        }
        return new DashboardAnalytics.TimeSeries(labels, values);
    }

    private List<DashboardAnalytics.TopLearner> buildTopLearners() {
        List<Object[]> rows = userRepository.findTopLearners(PageRequest.of(0, TOP_LEARNERS_LIMIT));
        List<DashboardAnalytics.TopLearner> result = new ArrayList<>(rows.size());
        int rank = 1;
        for (Object[] row : rows) {
            String name = row[0] != null ? String.valueOf(row[0]) : String.valueOf(row[1]);
            String cefr = row[2] != null ? String.valueOf(row[2]).toUpperCase() : "—";
            long totalXp = row[3] != null ? ((Number) row[3]).longValue() : 0L;
            int streak = row[4] != null ? ((Number) row[4]).intValue() : 0;
            result.add(new DashboardAnalytics.TopLearner(rank++, name, cefr, totalXp, streak));
        }
        return result;
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
