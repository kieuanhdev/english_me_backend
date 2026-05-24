package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLessonActivity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LearningLessonActivityRepository extends JpaRepository<LearningLessonActivity, String> {
    List<LearningLessonActivity> findByLessonIdOrderByDisplayOrderAsc(String lessonId);
}
