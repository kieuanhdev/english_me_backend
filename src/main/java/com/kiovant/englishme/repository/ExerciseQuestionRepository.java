package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.ExerciseQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ExerciseQuestionRepository extends JpaRepository<ExerciseQuestion, UUID> {

    @Query(value = "SELECT * FROM exercise_question WHERE category = :category ORDER BY random() LIMIT :size", nativeQuery = true)
    List<ExerciseQuestion> findRandomByCategory(String category, int size);

    @Query(value = "SELECT * FROM exercise_question WHERE category = :category AND level = :level ORDER BY random() LIMIT :size", nativeQuery = true)
    List<ExerciseQuestion> findRandomByCategoryAndLevel(String category, String level, int size);

    /**
     * Admin search. {@code levelUpper} đã được uppercase và {@code keywordPattern}
     * đã được lowercase + bọc '%...%' ở caller — query không gọi UPPER/LOWER trên param
     * để tránh lỗi "function lower(bytea) does not exist" khi PostgreSQL bind NULL.
     */
    @Query("""
            SELECT q FROM ExerciseQuestion q
            WHERE (:category IS NULL OR q.category = :category)
              AND (:difficulty IS NULL OR q.difficulty = :difficulty)
              AND (:levelUpper IS NULL OR UPPER(q.level) = :levelUpper)
              AND (:keywordPattern IS NULL OR LOWER(q.question) LIKE :keywordPattern)
            ORDER BY q.category ASC, q.difficulty ASC, q.id ASC
            """)
    List<ExerciseQuestion> searchQuestions(@Param("category") String category,
                                           @Param("difficulty") String difficulty,
                                           @Param("levelUpper") String levelUpper,
                                           @Param("keywordPattern") String keywordPattern);
}
