package com.kiovant.englishme.dto;

import java.util.List;

public record LessonCompleteResponse(
        String lessonId,
        boolean completed,
        int score,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        double levelProgress,
        double skillProgress,
        String nextLessonId,
        boolean streakUpdated,
        List<XpGrantResult.Bonus> bonuses
) {}
