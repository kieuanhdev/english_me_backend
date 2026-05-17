package com.kiovant.englishme.dto;

import java.util.List;

public record TestBankStats(
        long totalQuestions,
        long totalAttempts,
        long totalCorrect,
        Double overallAccuracy,
        List<LevelStat> byLevel,
        List<SkillStat> bySkill,
        List<DifficultyBucket> difficultyBuckets
) {
    public record LevelStat(
            String cefrLevel,
            long questionCount,
            long attempts,
            long correct,
            Double accuracy
    ) {}

    public record SkillStat(
            String skillCategory,
            long questionCount
    ) {}

    /** Phân nhóm câu hỏi theo độ khó dựa trên tỉ lệ đúng (proxy cho difficulty index). */
    public record DifficultyBucket(
            String label,         // "Quá khó (<30%)", "Bình thường", "Quá dễ (>95%)", "Chưa có dữ liệu"
            long questionCount
    ) {}
}
