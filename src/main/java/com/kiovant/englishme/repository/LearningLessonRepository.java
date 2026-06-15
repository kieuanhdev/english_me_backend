package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface LearningLessonRepository extends JpaRepository<LearningLesson, String> {
    List<LearningLesson> findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(String levelCode, String skillCode);

    long countByLevelCodeAndSkillCode(String levelCode, String skillCode);

    /** Lesson của 1 Unit, sắp theo lesson_order (luồng giáo trình). */
    List<LearningLesson> findByUnitIdAndIsActiveTrueOrderByLessonOrderAsc(String unitId);

    long countByUnitIdAndIsActiveTrue(String unitId);

    /** Tất cả lesson active thuộc các Unit cho trước (dùng rút đề checkpoint theo level). */
    List<LearningLesson> findByUnitIdInAndIsActiveTrue(List<String> unitIds);

    /**
     * Lesson user ĐÃ/ĐANG học ở một level — nguồn nội dung cho 4 kỹ năng (B) xoay
     * quanh bài giáo trình (A). JOIN user_lesson_progress để chỉ lấy bài đã chạm
     * tới (completed hoặc in_progress), bài học gần nhất xếp trước.
     */
    @Query("""
            SELECT l FROM LearningLesson l, UserLessonProgress p
            WHERE p.lessonId = l.id
              AND p.userId = :userId
              AND l.levelCode = :level
              AND l.isActive = true
              AND p.status IN ('completed', 'in_progress')
            ORDER BY p.completedAt DESC NULLS LAST, l.lessonOrder ASC
            """)
    List<LearningLesson> findStudiedByUserAndLevel(@Param("userId") UUID userId,
                                                   @Param("level") String level);

    /**
     * Admin: list lessons với filter optional level/skill/keyword.
     * Truyền null cho field nào để bỏ qua filter đó. Keyword đã được lowercase ở caller
     * (xem AdminLessonController) — query không gọi LOWER trên param để tránh
     * lỗi "function lower(bytea) does not exist" khi Postgres bind NULL.
     */
    @Query("""
            SELECT l FROM LearningLesson l
            WHERE (:level IS NULL OR l.levelCode = :level)
              AND (:skill IS NULL OR l.skillCode = :skill)
              AND (:keywordPattern IS NULL
                   OR LOWER(l.title) LIKE :keywordPattern
                   OR LOWER(l.id)    LIKE :keywordPattern)
            ORDER BY l.levelCode ASC, l.skillCode ASC, l.id ASC
            """)
    List<LearningLesson> adminSearch(@Param("level") String level,
                                     @Param("skill") String skill,
                                     @Param("keywordPattern") String keywordPattern);
}
