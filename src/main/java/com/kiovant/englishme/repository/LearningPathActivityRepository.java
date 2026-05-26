package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningPathActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LearningPathActivityRepository extends JpaRepository<LearningPathActivity, String> {
    List<LearningPathActivity> findByPathIdOrderByDisplayOrderAsc(String pathId);

    long countByPathId(String pathId);

    Optional<LearningPathActivity> findFirstByLessonId(String lessonId);
}
