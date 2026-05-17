package com.kiovant.englishme.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record UserDetailDto(
        // Profile
        UUID id,
        String firebaseUid,
        String email,
        String fullName,
        String avatarUrl,
        String cefrLevel,
        Boolean isOnboarded,
        Boolean accountLocked,
        LocalDateTime createdAt,
        LocalDate lastActiveDate,
        LocalDateTime deletedAt,

        // Stats tổng hợp
        int totalXp,
        int currentStreak,
        int longestStreak,
        long studySessions,
        long exerciseSessions,
        long testSessions,
        long pronunciationAttempts,

        // Badges đã đạt
        List<BadgeRow> badges,

        // Biểu đồ XP 30 ngày — danh sách điểm (date, xp)
        List<XpPoint> xpHistory,

        // Streak calendar 90 ngày — list ngày có hoạt động (LocalDate iso)
        List<String> activeDays,

        // 50 hoạt động gần nhất (merge từ study/exercise/test/pronunciation)
        List<ActivityRow> activities,

        // Desk + số flashcard
        List<DeskRow> desks
) {
    public record BadgeRow(
            UUID badgeId,
            String name,
            String description,
            String iconUrl,
            String conditionType,
            LocalDateTime earnedAt
    ) {}

    public record XpPoint(
            String date,   // yyyy-MM-dd
            long xp
    ) {}

    public record ActivityRow(
            String type,           // "study" | "exercise" | "test" | "pronunciation"
            String summary,        // mô tả ngắn
            LocalDateTime at,
            String status,         // tuỳ loại
            UUID refId             // id của session/attempt
    ) {}

    public record DeskRow(
            UUID deskId,
            String cefrLevel,
            String title,
            long flashcardCount,
            LocalDateTime createdAt
    ) {}
}
