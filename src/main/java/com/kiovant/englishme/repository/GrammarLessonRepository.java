package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarLesson;
import com.kiovant.englishme.entity.GrammarTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GrammarLessonRepository extends JpaRepository<GrammarLesson, UUID> {
    Optional<GrammarLesson> findBySourceId(String sourceId);

    boolean existsBySourceId(String sourceId);

    List<GrammarLesson> findByTopicOrderBySortOrderAscTitleAsc(GrammarTopic topic);

    @Query("select coalesce(max(l.sortOrder), 0) from GrammarLesson l where l.topic = :topic")
    Integer maxSortOrderByTopic(@Param("topic") GrammarTopic topic);

    @Query("""
            select l.id as lessonId, count(e.id) as exerciseCount
            from GrammarLesson l
            left join GrammarExercise e on e.lesson = l
            where l.topic = :topic
            group by l.id
            """)
    List<LessonExerciseCountView> countExercisesByLessonForTopic(@Param("topic") GrammarTopic topic);

    long countByTopic(GrammarTopic topic);

    interface LessonExerciseCountView {
        UUID getLessonId();

        long getExerciseCount();
    }
}
