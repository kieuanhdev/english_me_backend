package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LearningLessonRepository extends JpaRepository<LearningLesson, String> {
    List<LearningLesson> findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(String levelCode, String skillCode);

    long countByLevelCodeAndSkillCode(String levelCode, String skillCode);

    /** Lesson của 1 Unit, sắp theo lesson_order (luồng giáo trình). */
    List<LearningLesson> findByUnitIdAndIsActiveTrueOrderByLessonOrderAsc(String unitId);

    long countByUnitIdAndIsActiveTrue(String unitId);

    /** Tất cả lesson active thuộc các Unit cho trước (dùng rút đề checkpoint theo level). */
    List<LearningLesson> findByUnitIdInAndIsActiveTrue(List<String> unitIds);

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
