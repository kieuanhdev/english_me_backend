package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GrammarTopicRepository extends JpaRepository<GrammarTopic, UUID> {
    Optional<GrammarTopic> findByCategoryAndLevel(String category, String level);

    List<GrammarTopic> findAllByOrderBySortOrderAscCategoryAscLevelAsc();

    @Query("""
            select t.id as topicId, count(l.id) as lessonCount
            from GrammarTopic t
            left join GrammarLesson l on l.topic = t
            group by t.id
            """)
    List<TopicLessonCountView> countLessonsByTopic();

    interface TopicLessonCountView {
        UUID getTopicId();

        long getLessonCount();
    }
}
