package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserLessonProgress;
import com.kiovant.englishme.entity.UserLessonProgressId;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface UserLessonProgressRepository extends JpaRepository<UserLessonProgress, UserLessonProgressId> {
    List<UserLessonProgress> findByUserIdAndPathId(UUID userId, String pathId);

    /** Số bài user đã hoàn thành — cho badge 'first_lesson' (>= 1). */
    long countByUserIdAndStatus(UUID userId, String status);

    List<UserLessonProgress> findByUserIdAndLessonIdIn(UUID userId, List<String> lessonIds);

    /**
     * Bài học của user theo trạng thái, JOIN learning_lessons để lấy title + level + order.
     * Dùng cho "Tiếp tục học" cá nhân hóa.
     *
     * <p>Cột projection: lesson_id, title, level_code, last_score, required_score, lesson_order.
     */
    @Query(value = """
            SELECT p.lesson_id      AS lesson_id,
                   l.title          AS title,
                   l.level_code     AS level_code,
                   p.last_score     AS last_score,
                   l.required_score_to_pass AS required_score,
                   l.lesson_order   AS lesson_order
            FROM user_lesson_progress p
            JOIN learning_lessons l ON l.id = p.lesson_id
            WHERE p.user_id = :userId
              AND p.status = :status
              AND l.is_active = true
            ORDER BY l.level_code ASC, l.lesson_order ASC
            """, nativeQuery = true)
    List<Object[]> findByStatusWithLesson(@Param("userId") UUID userId,
                                          @Param("status") String status,
                                          Pageable pageable);
}
