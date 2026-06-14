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

    /**
     * Adaptive: câu trong {@code category} mà user TỪNG trả lời SAI và CHƯA bao giờ
     * trả lời đúng — tức điểm yếu thật của user. Câu nào còn sai nhiều ưu tiên trước.
     * Dùng để mở đầu buổi luyện bằng chính lỗi của user thay vì câu random.
     */
    @Query(value = """
            SELECT q.* FROM exercise_question q
            JOIN exercise_answer a ON a.question_id = q.id
            JOIN exercise_session s ON s.id = a.session_id
            WHERE q.category = :category AND s.user_id = :userId
            GROUP BY q.id
            HAVING SUM(CASE WHEN a.is_correct THEN 1 ELSE 0 END) = 0
            ORDER BY COUNT(*) DESC, random()
            LIMIT :size
            """, nativeQuery = true)
    List<ExerciseQuestion> findWeakByCategory(UUID userId, String category, int size);

    /** Random câu trong {@code category} nhưng loại trừ các id đã chọn (để fill sau weak). */
    @Query(value = """
            SELECT * FROM exercise_question
            WHERE category = :category AND id NOT IN (:excludeIds)
            ORDER BY random() LIMIT :size
            """, nativeQuery = true)
    List<ExerciseQuestion> findRandomByCategoryExcluding(String category, List<UUID> excludeIds, int size);

    /**
     * Admin search. {@code levelUpper} đã được uppercase và {@code keywordPattern}
     * đã được lowercase + escape wildcard (\% \_ \\) + bọc '%...%' ở caller — query
     * không gọi UPPER/LOWER trên param để tránh lỗi "function lower(bytea) does not
     * exist" khi PostgreSQL bind NULL. ESCAPE '\' khớp với escape ở caller.
     */
    @Query("""
            SELECT q FROM ExerciseQuestion q
            WHERE (:category IS NULL OR q.category = :category)
              AND (:difficulty IS NULL OR q.difficulty = :difficulty)
              AND (:levelUpper IS NULL OR UPPER(q.level) = :levelUpper)
              AND (:keywordPattern IS NULL OR LOWER(q.question) LIKE :keywordPattern ESCAPE '\\')
            ORDER BY q.category ASC, q.difficulty ASC, q.id ASC
            """)
    List<ExerciseQuestion> searchQuestions(@Param("category") String category,
                                           @Param("difficulty") String difficulty,
                                           @Param("levelUpper") String levelUpper,
                                           @Param("keywordPattern") String keywordPattern);
}
