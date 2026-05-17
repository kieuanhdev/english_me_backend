package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.DashboardAnalytics;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.StudySessionRepository;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.repository.UserTestSessionRepository;
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

    private final UserRepository userRepository;
    private final DeskRepository deskRepository;
    private final FlashcardRepository flashcardRepository;
    private final StudySessionRepository studySessionRepository;
    private final ExerciseSessionRepository exerciseSessionRepository;
    private final UserTestSessionRepository userTestSessionRepository;
    private final PronunciationAttemptRepository pronunciationAttemptRepository;
    private final XpHistoryRepository xpHistoryRepository;

    public DashboardAnalyticsService(
            UserRepository userRepository,
            DeskRepository deskRepository,
            FlashcardRepository flashcardRepository,
            StudySessionRepository studySessionRepository,
            ExerciseSessionRepository exerciseSessionRepository,
            UserTestSessionRepository userTestSessionRepository,
            PronunciationAttemptRepository pronunciationAttemptRepository,
            XpHistoryRepository xpHistoryRepository
    ) {
        this.userRepository = userRepository;
        this.deskRepository = deskRepository;
        this.flashcardRepository = flashcardRepository;
        this.studySessionRepository = studySessionRepository;
        this.exerciseSessionRepository = exerciseSessionRepository;
        this.userTestSessionRepository = userTestSessionRepository;
        this.pronunciationAttemptRepository = pronunciationAttemptRepository;
        this.xpHistoryRepository = xpHistoryRepository;
    }

    public DashboardAnalytics build() {
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime weekStart = today.minusDays(6).atStartOfDay();
        LocalDateTime monthStart = today.minusDays(29).atStartOfDay();

        return new DashboardAnalytics(
                buildKpi(today, todayStart, weekStart, monthStart),
                buildSeries(today, 14, this::countNewUsersOnDate),
                buildSeries(today, 14, this::countActiveUsersOnDate),
                buildCefrDistribution(),
                buildContentDistribution(todayStart),
                buildXpBySource7d(),
                buildHeatmap(monthStart),
                buildTopStreak(),
                buildTopXp(),
                buildTopWords(),
                buildTopPronunciationMisses(),
                buildInactiveUsers(today),
                buildSystemHealth()
        );
    }

    private DashboardAnalytics.KpiSummary buildKpi(LocalDate today, LocalDateTime todayStart, LocalDateTime weekStart, LocalDateTime monthStart) {
        long totalUsers = userRepository.count();
        long newUsersToday = userRepository.countCreatedSince(todayStart);
        long studyToday = studySessionRepository.countSince(todayStart);
        long exerciseToday = exerciseSessionRepository.countSince(todayStart);
        long testToday = userTestSessionRepository.countSince(todayStart);
        long pronunciationActive = pronunciationAttemptRepository.countDistinctUsersSince(todayStart);

        long dau = Math.max(xpHistoryRepository.countActiveUsersBetween(today, today), pronunciationActive);
        long wau = xpHistoryRepository.countActiveUsersBetween(today.minusDays(6), today);
        long mau = xpHistoryRepository.countActiveUsersBetween(today.minusDays(29), today);

        double retention7d = totalUsers == 0 ? 0.0 : (wau * 100.0) / totalUsers;
        double retention30d = totalUsers == 0 ? 0.0 : (mau * 100.0) / totalUsers;

        long xpToday = xpHistoryRepository.sumXpOnDate(today);
        Double avgStreakRaw = userRepository.averageCurrentStreak();
        double avgStreak = avgStreakRaw == null ? 0.0 : avgStreakRaw;

        return new DashboardAnalytics.KpiSummary(
                totalUsers,
                newUsersToday,
                dau,
                dau,
                wau,
                mau,
                round1(retention7d),
                round1(retention30d),
                studyToday + exerciseToday + testToday,
                xpToday,
                round1(avgStreak)
        );
    }

    private DashboardAnalytics.TimeSeries buildSeries(LocalDate today, int days, java.util.function.Function<LocalDate, Long> producer) {
        List<String> labels = new ArrayList<>(days);
        List<Long> values = new ArrayList<>(days);
        for (int i = days - 1; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            labels.add(d.format(DAY_FMT));
            values.add(producer.apply(d));
        }
        return new DashboardAnalytics.TimeSeries(labels, values);
    }

    private long countNewUsersOnDate(LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.plusDays(1).atStartOfDay();
        return userRepository.countCreatedBetween(start, end);
    }

    private long countActiveUsersOnDate(LocalDate date) {
        return xpHistoryRepository.countActiveUsersBetween(date, date);
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

    private List<DashboardAnalytics.NamedCount> buildContentDistribution(LocalDateTime todayStart) {
        LocalDateTime since = todayStart.minusDays(29);
        long study = studySessionRepository.countSince(since);
        long exercise = exerciseSessionRepository.countSince(since);
        long test = userTestSessionRepository.countSince(since);
        long pronunciation = pronunciationAttemptRepository.countSince(since);
        return List.of(
                new DashboardAnalytics.NamedCount("Vocabulary (Study)", study),
                new DashboardAnalytics.NamedCount("Exercise", exercise),
                new DashboardAnalytics.NamedCount("Test", test),
                new DashboardAnalytics.NamedCount("Pronunciation", pronunciation)
        );
    }

    private List<DashboardAnalytics.NamedCount> buildXpBySource7d() {
        LocalDate today = LocalDate.now();
        LocalDateTime weekStart = today.minusDays(6).atStartOfDay();
        long study = studySessionRepository.countSince(weekStart) * 2L;
        long exercise = exerciseSessionRepository.countSince(weekStart) * 5L;
        long test = userTestSessionRepository.countSince(weekStart) * 10L;
        return List.of(
                new DashboardAnalytics.NamedCount("Study", study),
                new DashboardAnalytics.NamedCount("Exercise", exercise),
                new DashboardAnalytics.NamedCount("Test", test)
        );
    }

    private int[][] buildHeatmap(LocalDateTime since) {
        int[][] grid = new int[7][24];
        try {
            List<Object[]> rows = studySessionRepository.heatmapSince(since);
            for (Object[] row : rows) {
                int dow = ((Number) row[0]).intValue();
                int hour = ((Number) row[1]).intValue();
                long count = ((Number) row[2]).longValue();
                if (dow >= 0 && dow < 7 && hour >= 0 && hour < 24) {
                    grid[dow][hour] = (int) Math.min(count, Integer.MAX_VALUE);
                }
            }
        } catch (Exception ignored) {
            // Native query may fail on non-Postgres; trả về grid rỗng.
        }
        return grid;
    }

    private List<DashboardAnalytics.TopUserRow> buildTopStreak() {
        return userRepository.findTopByStreak(PageRequest.of(0, 10)).stream()
                .map(u -> new DashboardAnalytics.TopUserRow(
                        u.getId() == null ? "" : u.getId().toString(),
                        safe(u.getFullName()),
                        safe(u.getEmail()),
                        safe(u.getCefrLevel()),
                        u.getCurrentStreak() == null ? 0L : u.getCurrentStreak().longValue()
                ))
                .toList();
    }

    private List<DashboardAnalytics.TopUserRow> buildTopXp() {
        return userRepository.findTopByXp(PageRequest.of(0, 10)).stream()
                .map(u -> new DashboardAnalytics.TopUserRow(
                        u.getId() == null ? "" : u.getId().toString(),
                        safe(u.getFullName()),
                        safe(u.getEmail()),
                        safe(u.getCefrLevel()),
                        u.getTotalXp() == null ? 0L : u.getTotalXp().longValue()
                ))
                .toList();
    }

    private List<DashboardAnalytics.TopFlashcardRow> buildTopWords() {
        List<DashboardAnalytics.TopFlashcardRow> result = new ArrayList<>();
        try {
            var all = flashcardRepository.findAll(PageRequest.of(0, 10));
            for (var f : all) {
                result.add(new DashboardAnalytics.TopFlashcardRow(
                        safe(f.getWord()),
                        safe(f.getCefr()),
                        0L
                ));
            }
        } catch (Exception ignored) { }
        return result;
    }

    private List<DashboardAnalytics.TopPronunciationMissRow> buildTopPronunciationMisses() {
        List<Object[]> rows = pronunciationAttemptRepository.findTopMissedWords(PageRequest.of(0, 10));
        List<DashboardAnalytics.TopPronunciationMissRow> result = new ArrayList<>(rows.size());
        for (Object[] row : rows) {
            String text = row[0] == null ? "" : row[0].toString();
            double avg = row[1] == null ? 0.0 : ((Number) row[1]).doubleValue();
            long attempts = row[2] == null ? 0L : ((Number) row[2]).longValue();
            result.add(new DashboardAnalytics.TopPronunciationMissRow(text, round1(avg), attempts));
        }
        return result;
    }

    private List<DashboardAnalytics.InactiveUserRow> buildInactiveUsers(LocalDate today) {
        LocalDate threshold = today.minusDays(7);
        List<User> users = userRepository.findInactiveUsers(threshold, PageRequest.of(0, 10));
        List<DashboardAnalytics.InactiveUserRow> result = new ArrayList<>(users.size());
        for (User u : users) {
            result.add(new DashboardAnalytics.InactiveUserRow(
                    u.getId() == null ? "" : u.getId().toString(),
                    safe(u.getFullName()),
                    safe(u.getEmail()),
                    u.getCurrentStreak() == null ? 0 : u.getCurrentStreak(),
                    u.getLastActiveDate() == null ? "—" : u.getLastActiveDate().toString()
            ));
        }
        return result;
    }

    private DashboardAnalytics.SystemHealth buildSystemHealth() {
        return new DashboardAnalytics.SystemHealth(
                "OK",
                "OK",
                "OK",
                0L,
                0,
                0L
        );
    }

    private static String safe(String s) {
        return s == null ? "" : s;
    }

    private static double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
