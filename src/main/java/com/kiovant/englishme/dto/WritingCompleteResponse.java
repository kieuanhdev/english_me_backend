package com.kiovant.englishme.dto;

import java.util.List;

/** Kết quả phiên luyện Viết: số lượt + XP đã cộng (skill = writing). */
public record WritingCompleteResponse(
        int turns,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        List<XpGrantResult.Bonus> bonuses
) {
}
