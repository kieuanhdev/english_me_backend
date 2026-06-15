package com.kiovant.englishme.dto;

import java.util.List;

/** Kết quả phiên dictation: thống kê + XP đã cộng (skill = listening). */
public record DictationCompleteResponse(
        int total,
        int correct,
        int incorrect,
        double accuracyPercent,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        List<XpGrantResult.Bonus> bonuses
) {
}
