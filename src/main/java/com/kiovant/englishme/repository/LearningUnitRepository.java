package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LearningUnit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LearningUnitRepository extends JpaRepository<LearningUnit, String> {
    List<LearningUnit> findByLevelCodeAndIsActiveTrueOrderByDisplayOrderAsc(String levelCode);
}
