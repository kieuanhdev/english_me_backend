package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationExercise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PronunciationExerciseRepository extends JpaRepository<PronunciationExercise, UUID> {
    List<PronunciationExercise> findAllByOrderByDifficultyAsc();
}
