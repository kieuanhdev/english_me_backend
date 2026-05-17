package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarExercise;
import com.kiovant.englishme.entity.GrammarLesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface GrammarExerciseRepository extends JpaRepository<GrammarExercise, UUID> {
    List<GrammarExercise> findByLessonOrderByExerciseOrderAsc(GrammarLesson lesson);

    @Query("select coalesce(max(e.exerciseOrder), 0) from GrammarExercise e where e.lesson = :lesson")
    Integer maxOrderByLesson(@Param("lesson") GrammarLesson lesson);

    long countByLesson(GrammarLesson lesson);
}
