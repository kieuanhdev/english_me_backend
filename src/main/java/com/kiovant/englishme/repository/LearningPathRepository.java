package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningPath;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LearningPathRepository extends JpaRepository<LearningPath, String> {
    List<LearningPath> findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(String levelCode);
}
