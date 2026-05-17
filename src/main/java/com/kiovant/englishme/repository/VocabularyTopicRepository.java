package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.VocabularyTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface VocabularyTopicRepository extends JpaRepository<VocabularyTopic, UUID> {

    List<VocabularyTopic> findAllByOrderBySortOrderAsc();

    @Query("SELECT COUNT(w) FROM VocabularyWord w WHERE w.topic.id = :topicId")
    long countWordsByTopicId(@Param("topicId") UUID topicId);

    @Query("""
            SELECT t FROM VocabularyTopic t
            WHERE (:level IS NULL OR :level = '' OR LOWER(t.level) = LOWER(:level))
              AND (:keyword IS NULL OR :keyword = ''
                   OR LOWER(t.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(t.nameEn) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY t.sortOrder ASC
            """)
    List<VocabularyTopic> searchTopics(@Param("level") String level, @Param("keyword") String keyword);

    @Query("SELECT COALESCE(MAX(t.sortOrder), 0) FROM VocabularyTopic t")
    Integer maxSortOrder();
}
