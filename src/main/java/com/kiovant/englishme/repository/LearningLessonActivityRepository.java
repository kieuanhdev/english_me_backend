package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLessonActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface LearningLessonActivityRepository extends JpaRepository<LearningLessonActivity, String> {
    List<LearningLessonActivity> findByLessonIdOrderByDisplayOrderAsc(String lessonId);

    /**
     * Câu quiz (phase='quiz', tính mastery) của một tập lesson cho trước.
     * Service truyền vào lessonIds của cả level (lấy qua LearningLessonRepository)
     * rồi tự lọc dạng chấm tự động + random + giới hạn — đây là cách rút đề
     * Level Checkpoint Test (không cần ngân hàng câu hỏi riêng).
     */
    @Query("""
            SELECT a FROM LearningLessonActivity a
            WHERE a.phase = 'quiz' AND a.countsTowardMastery = true
              AND a.lessonId IN :lessonIds
            """)
    List<LearningLessonActivity> findQuizActivitiesByLessonIds(@Param("lessonIds") List<String> lessonIds);
}
