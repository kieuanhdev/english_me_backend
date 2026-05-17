package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface QuestionRepository extends JpaRepository<Question, UUID> {

    boolean existsByCefrLevelAndSkillCategoryAndQuestion(String cefrLevel, String skillCategory, String question);

    // Lấy ngẫu nhiên N câu hỏi theo mức độ và kỹ năng
    @Query(value = "SELECT * FROM questions WHERE cefr_level = :level AND skill_category = :skill ORDER BY RANDOM() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomByCefrLevelAndSkillCategory(
            @Param("level") String level,
            @Param("skill") String skill,
            @Param("limit") int limit
    );

    // Lấy ngẫu nhiên N câu hỏi theo mức độ
    @Query(value = "SELECT * FROM questions WHERE cefr_level = :level ORDER BY RANDOM() LIMIT :limit", nativeQuery = true)
    List<Question> findRandomByCefrLevel(@Param("level") String level, @Param("limit") int limit);

    List<Question> findByCefrLevel(String cefrLevel);

    /**
     * Search/filter dùng cho admin test bank. Mọi tham số đều có thể null để bỏ điều kiện đó.
     */
    @Query("""
            SELECT q FROM Question q
            WHERE (:level IS NULL OR UPPER(q.cefrLevel) = UPPER(:level))
              AND (:skill IS NULL OR LOWER(q.skillCategory) = LOWER(:skill))
              AND (:keyword IS NULL OR LOWER(q.question) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY q.cefrLevel ASC, q.skillCategory ASC, q.id ASC
            """)
    List<Question> searchQuestions(@Param("level") String level,
                                   @Param("skill") String skill,
                                   @Param("keyword") String keyword);

    /** [cefrLevel, count] để hiển thị phân bố câu hỏi theo CEFR. */
    @Query("SELECT q.cefrLevel, COUNT(q) FROM Question q GROUP BY q.cefrLevel ORDER BY q.cefrLevel ASC")
    List<Object[]> countByCefrLevel();

    /** [skillCategory, count] để hiển thị phân bố theo kỹ năng. */
    @Query("SELECT LOWER(q.skillCategory), COUNT(q) FROM Question q GROUP BY LOWER(q.skillCategory) ORDER BY LOWER(q.skillCategory) ASC")
    List<Object[]> countBySkillCategory();
}
