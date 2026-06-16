package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

/**
 * DTO cho luồng giáo trình (Unit → Lesson → Theory/Practice/Quiz).
 * Field name khớp ĐÚNG với FE curriculum_models.dart để FE chỉ cần đổi
 * MockCurriculumRepository → ApiCurriculumRepository là chạy.
 */
public final class CurriculumDtos {

    private CurriculumDtos() {}

    // GET /curriculum/levels/{level}/units  → LevelUnits.fromJson
    public record LevelUnits(
            String level,
            double levelProgress,
            int completedUnits,
            int totalUnits,
            boolean checkpointUnlocked,
            List<UnitSummary> units
    ) {}

    public record UnitSummary(
            String id,
            String level,
            String title,
            String subtitle,
            int order,
            String status,            // locked | available | in_progress | completed
            int lessonCount,
            int completedLessonCount,
            List<String> skillCoverage
    ) {}

    // GET /curriculum/units/{unitId}  → UnitDetail.fromJson
    public record UnitDetail(
            String id,
            String level,
            String title,
            String subtitle,
            String status,
            int completedLessonCount,
            int totalLessons,
            List<LessonListItem> lessons
    ) {}

    public record LessonListItem(
            String id,
            String title,
            String subtitle,
            String skill,
            int lessonOrder,
            String status,
            boolean theoryViewed,
            int bestScore,
            int xpReward,
            int durationMinutes
    ) {}

    // GET /curriculum/lessons/{lessonId}  → CurriculumLessonDetail.fromJson
    public record LessonDetail(
            String id,
            String unitId,
            String level,
            String skill,
            String title,
            String subtitle,
            int xpReward,
            int requiredScoreToPass,
            boolean theoryViewed,
            boolean practiceCompleted,         // đã làm xong luyện tập → vào thẳng quiz
            String status,                     // locked | available | in_progress | completed
            int bestScore,                     // điểm cao nhất đã đạt (0 nếu chưa nộp)
            int lastScore,                     // điểm lần nộp gần nhất
            double unitProgress,               // tiến độ unit hiện tại (0..1) — dựng lại summary
            boolean unitCompleted,             // unit đã hoàn thành toàn bộ chưa
            Map<String, Object> theory,        // nguyên theory_content JSONB
            List<Map<String, Object>> exercises, // phase=practice (payload + meta)
            List<Map<String, Object>> quiz       // phase=quiz
    ) {}

    // POST /curriculum/lessons/{lessonId}/complete  → LessonResult
    public record LessonResult(
            boolean passed,
            int score,
            int xpEarned,
            double unitProgress,
            boolean unitCompleted,
            String nextLessonId,
            long totalXp,
            int dailyEarnedXp,
            boolean streakUpdated,
            List<XpGrantResult.Bonus> bonuses,
            List<XpGrantResult.BadgeAward> newBadges  // badge vừa mở khoá → FE popup
    ) {}
}
