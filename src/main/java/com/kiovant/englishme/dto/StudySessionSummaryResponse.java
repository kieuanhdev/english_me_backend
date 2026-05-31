package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record StudySessionSummaryResponse(
        UUID sessionId,
        UUID deskId,
        String status,
        Integer totalCards,
        Integer masteredCards,
        Integer hardCards,
        Integer againCards,
        Integer xpEarned,
        Integer newWordsLearned,
        LocalDateTime startedAt,
        LocalDateTime completedAt,
        // XP của user sau khi grant (chỉ cộng khi phiên hoàn thành) — để FE cập nhật
        // ProfileController + streak + bonus 1 lần ở màn tổng kết.
        Long totalXp,
        Boolean streakUpdated,
        List<XpGrantResult.Bonus> bonuses
) {
}
