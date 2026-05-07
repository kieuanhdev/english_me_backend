package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarExercise;
import com.kiovant.englishme.entity.GrammarLesson;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface GrammarExerciseRepository extends JpaRepository<GrammarExercise, UUID> {
    List<GrammarExercise> findByLessonOrderByExerciseOrderAsc(GrammarLesson lesson);
}
