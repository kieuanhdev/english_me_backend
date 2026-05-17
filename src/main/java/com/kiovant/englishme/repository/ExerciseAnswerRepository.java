package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.ExerciseAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ExerciseAnswerRepository extends JpaRepository<ExerciseAnswer, UUID> {

    /** [questionId, attempts, correctAttempts] cho mọi câu hỏi đã được trả lời. */
    @Query("""
            SELECT a.question.id, COUNT(a),
                   SUM(CASE WHEN a.isCorrect = true THEN 1 ELSE 0 END)
            FROM ExerciseAnswer a
            WHERE a.question.id IN :questionIds
            GROUP BY a.question.id
            """)
    List<Object[]> aggregateStatsByQuestionIds(@Param("questionIds") List<UUID> questionIds);
}
