package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.entity.GrammarExercise;
import com.kiovant.englishme.entity.GrammarLesson;
import com.kiovant.englishme.entity.GrammarTopic;
import com.kiovant.englishme.repository.GrammarExerciseRepository;
import com.kiovant.englishme.repository.GrammarLessonRepository;
import com.kiovant.englishme.repository.GrammarTopicRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Comparator;
import java.util.Map;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class GrammarService {

    private final GrammarTopicRepository grammarTopicRepository;
    private final GrammarLessonRepository grammarLessonRepository;
    private final GrammarExerciseRepository grammarExerciseRepository;

    public GrammarService(
            GrammarTopicRepository grammarTopicRepository,
            GrammarLessonRepository grammarLessonRepository,
            GrammarExerciseRepository grammarExerciseRepository
    ) {
        this.grammarTopicRepository = grammarTopicRepository;
        this.grammarLessonRepository = grammarLessonRepository;
        this.grammarExerciseRepository = grammarExerciseRepository;
    }

    @Transactional(readOnly = true)
    public List<GrammarTopicResponse> getTopics() {
        Map<UUID, Long> lessonCountByTopic = grammarTopicRepository.countLessonsByTopic()
                .stream()
                .collect(Collectors.toMap(
                        GrammarTopicRepository.TopicLessonCountView::getTopicId,
                        GrammarTopicRepository.TopicLessonCountView::getLessonCount
                ));

        return grammarTopicRepository.findAllByOrderBySortOrderAscCategoryAscLevelAsc()
                .stream()
                .map(topic -> toTopicResponse(topic, lessonCountByTopic.getOrDefault(topic.getId(), 0L)))
                .toList();
    }

    private static final List<String> CEFR_ORDER = List.of("A1", "A2", "B1", "B2", "C1", "C2");

    @Transactional(readOnly = true)
    public List<GrammarLevelGroupResponse> getTopicsGroupedByLevel() {
        Map<String, List<GrammarTopicResponse>> byLevel = getTopics()
                .stream()
                .filter(t -> t.level() != null && !t.level().isBlank())
                .collect(Collectors.groupingBy(
                        t -> t.level().trim().toUpperCase(),
                        java.util.LinkedHashMap::new,
                        Collectors.toList()
                ));

        return byLevel.entrySet()
                .stream()
                .sorted(Comparator.comparingInt(e -> {
                    int idx = CEFR_ORDER.indexOf(e.getKey());
                    return idx < 0 ? Integer.MAX_VALUE : idx;
                }))
                .map(e -> new GrammarLevelGroupResponse(e.getKey(), e.getValue()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<GrammarLessonListItemResponse> getLessonsByTopicId(String topicId) {
        GrammarTopic topic = grammarTopicRepository.findById(parseUuid(topicId, "topicId"))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar topic not found"));

        return grammarLessonRepository.findByTopicOrderBySortOrderAscTitleAsc(topic)
                .stream()
                .map(this::toLessonListItem)
                .toList();
    }

    @Transactional(readOnly = true)
    public GrammarLessonDetailResponse getLessonDetail(String lessonId) {
        GrammarLesson lesson = grammarLessonRepository.findById(parseUuid(lessonId, "lessonId"))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar lesson not found"));

        List<GrammarExerciseResponse> exercises = grammarExerciseRepository.findByLessonOrderByExerciseOrderAsc(lesson)
                .stream()
                .map(this::toExerciseResponse)
                .toList();

        return new GrammarLessonDetailResponse(
                lesson.getId(),
                lesson.getTopic().getId(),
                lesson.getSourceId(),
                lesson.getTitle(),
                lesson.getSortOrder(),
                lesson.getExplanationVi(),
                lesson.getWhenToUseVi(),
                lesson.getTipsVi(),
                lesson.getFormulas(),
                lesson.getKeyWords(),
                lesson.getExamples(),
                lesson.getCommonMistakes(),
                exercises
        );
    }

    private GrammarTopicResponse toTopicResponse(GrammarTopic topic, long lessonCount) {
        return new GrammarTopicResponse(
                topic.getId(),
                topic.getSlug(),
                topic.getCategory(),
                topic.getLevel(),
                topic.getTitle(),
                topic.getSortOrder(),
                lessonCount
        );
    }

    private GrammarLessonListItemResponse toLessonListItem(GrammarLesson lesson) {
        return new GrammarLessonListItemResponse(
                lesson.getId(),
                lesson.getSourceId(),
                lesson.getTitle(),
                lesson.getSortOrder()
        );
    }

    private GrammarExerciseResponse toExerciseResponse(GrammarExercise exercise) {
        return new GrammarExerciseResponse(
                exercise.getId(),
                exercise.getExerciseOrder(),
                exercise.getExerciseType(),
                exercise.getContent()
        );
    }

    private UUID parseUuid(String raw, String fieldName) {
        try {
            return UUID.fromString(raw);
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, fieldName + " must be a valid UUID");
        }
    }
}
