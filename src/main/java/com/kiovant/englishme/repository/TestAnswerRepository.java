package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.entity.TestAnswer;
import com.kiovant.englishme.entity.TestSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TestAnswerRepository extends JpaRepository<TestAnswer, UUID> {

    List<TestAnswer> findByTestSession(TestSession testSession);

    Optional<TestAnswer> findByTestSessionAndQuestion(TestSession testSession, Question question);

    long countByTestSession(TestSession testSession);

    /** [questionId, attempts, correctAttempts] cho mọi câu hỏi đã được trả lời trong test bank. */
    @Query("""
            SELECT a.question.id, COUNT(a),
                   SUM(CASE WHEN a.isCorrect = true THEN 1 ELSE 0 END)
            FROM TestAnswer a
            WHERE a.question.id IN :questionIds
            GROUP BY a.question.id
            """)
    List<Object[]> aggregateStatsByQuestionIds(@Param("questionIds") List<UUID> questionIds);

    /** [cefrLevel, attempts, correctAttempts] gộp theo CEFR level. */
    @Query("""
            SELECT a.question.cefrLevel, COUNT(a),
                   SUM(CASE WHEN a.isCorrect = true THEN 1 ELSE 0 END)
            FROM TestAnswer a
            GROUP BY a.question.cefrLevel
            ORDER BY a.question.cefrLevel ASC
            """)
    List<Object[]> aggregateStatsByCefrLevel();
}
