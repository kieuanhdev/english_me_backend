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
}
