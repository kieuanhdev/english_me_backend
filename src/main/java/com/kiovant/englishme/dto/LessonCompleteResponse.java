package com.kiovant.englishme.dto;

public record LessonCompleteResponse(
        String lessonId,
        boolean completed,
        int score,
        int xpEarned,
        double levelProgress,
        double skillProgress,
        String nextLessonId,
        boolean streakUpdated
) {}
