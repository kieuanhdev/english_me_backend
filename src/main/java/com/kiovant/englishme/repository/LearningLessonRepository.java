package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LearningLessonRepository extends JpaRepository<LearningLesson, String> {
    List<LearningLesson> findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(String levelCode, String skillCode);

    long countByLevelCodeAndSkillCode(String levelCode, String skillCode);

    /**
     * Admin: list lessons với filter optional level/skill/keyword.
     * Truyền null/blank cho field nào để bỏ qua filter đó.
     */
    @Query("""
            SELECT l FROM LearningLesson l
            WHERE (:level IS NULL OR l.levelCode = :level)
              AND (:skill IS NULL OR l.skillCode = :skill)
              AND (:keyword IS NULL
                   OR LOWER(l.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(l.id)    LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY l.levelCode ASC, l.skillCode ASC, l.id ASC
            """)
    List<LearningLesson> adminSearch(@Param("level") String level,
                                     @Param("skill") String skill,
                                     @Param("keyword") String keyword);
}
