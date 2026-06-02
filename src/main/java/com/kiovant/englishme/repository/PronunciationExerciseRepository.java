package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface PronunciationExerciseRepository extends JpaRepository<PronunciationExercise, UUID> {
    List<PronunciationExercise> findAllByOrderByDifficultyAsc();

    /**
     * Bài luyện âm cho người học: chỉ lấy các level <= level người học (truyền qua :levels),
     * kèm lọc theo level cụ thể (nếu chọn) và keyword. Sắp theo level rồi text.
     */
    @Query("""
            SELECT e FROM PronunciationExercise e
            WHERE (e.level IS NULL OR UPPER(e.level) IN :levels)
              AND (:level = '' OR UPPER(COALESCE(e.level, '')) = UPPER(:level))
              AND (:keyword = '' OR LOWER(e.text) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY e.level ASC, e.text ASC
            """)
    List<PronunciationExercise> findForLearner(@Param("levels") List<String> levels,
                                               @Param("level") String level,
                                               @Param("keyword") String keyword);

    @Query("""
            SELECT e FROM PronunciationExercise e
            WHERE (:level = '' OR LOWER(COALESCE(e.level, '')) = LOWER(:level))
              AND (:difficulty = '' OR LOWER(e.difficulty) = LOWER(:difficulty))
              AND (:keyword = '' OR LOWER(e.text) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY e.difficulty ASC, e.text ASC
            """)
    List<PronunciationExercise> searchForAdmin(@Param("level") String level,
                                               @Param("difficulty") String difficulty,
                                               @Param("keyword") String keyword);
}
