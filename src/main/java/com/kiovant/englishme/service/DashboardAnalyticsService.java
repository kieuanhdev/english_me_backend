package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DashboardAnalytics;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import com.kiovant.englishme.repository.StudySessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserTestSessionRepository;
import com.kiovant.englishme.repository.XpHistoryRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class DashboardAnalyticsService {

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("MM-dd");
    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final UserRepository userRepository;
    private final StudySessionRepository studySessionRepository;
    private final ExerciseSessionRepository exerciseSessionRepository;
    private final UserTestSessionRepository userTestSessionRepository;
    private final XpHistoryRepository xpHistoryRepository;

    public DashboardAnalyticsService(
            UserRepository userRepository,
            StudySessionRepository studySessionRepository,
            ExerciseSessionRepository exerciseSessionRepository,
            UserTestSessionRepository userTestSessionRepository,
            XpHistoryRepository xpHistoryRepository
    ) {
        this.userRepository = userRepository;
        this.studySessionRepository = studySessionRepository;
        this.exerciseSessionRepository = exerciseSessionRepository;
        this.userTestSessionRepository = userTestSessionRepository;
        this.xpHistoryRepository = xpHistoryRepository;
    }

    public DashboardAnalytics build() {
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();

        return new DashboardAnalytics(
                buildKpi(today, todayStart),
                buildNewUsersSeries(today, 14),
                buildCefrDistribution(),
                buildXpBySource7d()
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

    private List<DashboardAnalytics.NamedCount> buildXpBySource7d() {
        LocalDateTime weekStart = LocalDate.now().minusDays(6).atStartOfDay();
        long study = studySessionRepository.countSince(weekStart) * 2L;
        long exercise = exerciseSessionRepository.countSince(weekStart) * 5L;
        long test = userTestSessionRepository.countSince(weekStart) * 10L;
        return List.of(
                new DashboardAnalytics.NamedCount("Study", study),
                new DashboardAnalytics.NamedCount("Exercise", exercise),
                new DashboardAnalytics.NamedCount("Test", test)
        );
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
