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

    // ── CAT (Computerized Adaptive Testing) ─────────────────────────────────
    // Pool câu placement (chỉ grammar + vocabulary) loại trừ câu đã hỏi.
    // Service tự tính |b_i - θ| trên kết quả → không cần ORDER BY ở SQL.
    @Query("SELECT q FROM Question q WHERE q.skillCategory IN ('grammar', 'vocabulary') "
            + "AND q.id NOT IN :askedIds")
    List<Question> findForCat(@Param("askedIds") List<UUID> askedIds);

    // Biến thể cho lần đầu (askedIds rỗng) — tránh SQL "NOT IN ()" lỗi.
    @Query("SELECT q FROM Question q WHERE q.skillCategory IN ('grammar', 'vocabulary')")
    List<Question> findAllForCat();
}
