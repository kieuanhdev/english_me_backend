package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GrammarTopicRepository extends JpaRepository<GrammarTopic, UUID> {
    Optional<GrammarTopic> findBySlug(String slug);

    boolean existsBySlug(String slug);

    boolean existsByCategoryAndLevel(String category, String level);

    List<GrammarTopic> findAllByOrderBySortOrderAscCategoryAscLevelAsc();

    @Query("""
            select t.id as topicId, count(l.id) as lessonCount
            from GrammarTopic t
            left join GrammarLesson l on l.topic = t
            group by t.id
            """)
    List<TopicLessonCountView> countLessonsByTopic();

    @Query("""
            select t from GrammarTopic t
            where (:level is null or :level = '' or lower(t.level) = lower(:level))
              and (:keyword is null or :keyword = ''
                   or lower(t.title) like lower(concat('%', :keyword, '%'))
                   or lower(t.category) like lower(concat('%', :keyword, '%'))
                   or lower(t.slug) like lower(concat('%', :keyword, '%')))
            order by t.sortOrder asc, t.category asc, t.level asc
            """)
    List<GrammarTopic> searchTopics(@Param("level") String level, @Param("keyword") String keyword);

    @Query("select coalesce(max(t.sortOrder), 0) from GrammarTopic t")
    Integer maxSortOrder();

    interface TopicLessonCountView {
        UUID getTopicId();

        long getLessonCount();
    }
}
