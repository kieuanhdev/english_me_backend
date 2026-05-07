package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.GrammarLesson;
import com.kiovant.englishme.entity.GrammarTopic;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GrammarLessonRepository extends JpaRepository<GrammarLesson, UUID> {
    Optional<GrammarLesson> findBySourceId(String sourceId);

    List<GrammarLesson> findByTopicOrderBySortOrderAscTitleAsc(GrammarTopic topic);
}
