package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningLesson;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LearningLessonRepository extends JpaRepository<LearningLesson, String> {
    List<LearningLesson> findByLevelCodeAndSkillCodeAndIsActiveTrueOrderByIdAsc(String levelCode, String skillCode);

    long countByLevelCodeAndSkillCode(String levelCode, String skillCode);
}
