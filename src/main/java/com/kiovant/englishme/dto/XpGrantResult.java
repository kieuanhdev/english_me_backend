package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Kết quả của 1 lần cộng XP qua XpService.grant().
 *
 * - xpEarned: XP của lần này (0 nếu đã cộng từ trước hoặc rule không cho cộng).
 * - totalXp: total_xp mới của user (đã bao gồm cả bonus nếu có).
 * - dailyEarnedXp: earned_xp trong ngày hôm nay.
 * - streakUpdated: true nếu hôm nay là ngày đầu kiếm XP (current_streak vừa tăng).
 * - alreadyGranted: true nếu request này là retry (FE không bắt buộc đọc).
 * - bonuses: các bonus được cộng kèm (daily_goal_bonus, streak_bonus, ...).
 * - newBadges: badge VỪA mở khoá trong lần cộng XP này (rỗng nếu không có) —
 *   FE hiện popup ăn mừng ngay, không bắt user vào hồ sơ mới biết.
 */
public record XpGrantResult(
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        boolean alreadyGranted,
        List<Bonus> bonuses,
        List<BadgeAward> newBadges
) {
    public record Bonus(String type, int amount, String label) {}

    public record BadgeAward(String name, String description, String iconUrl) {}
}
