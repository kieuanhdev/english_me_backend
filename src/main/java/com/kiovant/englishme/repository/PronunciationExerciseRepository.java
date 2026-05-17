package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface PronunciationExerciseRepository extends JpaRepository<PronunciationExercise, UUID> {
    List<PronunciationExercise> findAllByOrderByDifficultyAsc();

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
