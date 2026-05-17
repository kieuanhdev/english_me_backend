package com.kiovant.englishme.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.AdminGrammarExerciseRow;
import com.kiovant.englishme.dto.AdminGrammarLessonDetail;
import com.kiovant.englishme.dto.AdminGrammarLessonRow;
import com.kiovant.englishme.dto.AdminGrammarTopicRow;
import com.kiovant.englishme.dto.CreateGrammarExerciseRequest;
import com.kiovant.englishme.dto.CreateGrammarLessonRequest;
import com.kiovant.englishme.dto.CreateGrammarTopicRequest;
import com.kiovant.englishme.dto.GrammarImportResult;
import com.kiovant.englishme.dto.UpdateGrammarExerciseRequest;
import com.kiovant.englishme.dto.UpdateGrammarLessonRequest;
import com.kiovant.englishme.dto.UpdateGrammarTopicRequest;
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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminGrammarService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final Set<String> ALLOWED_EXERCISE_TYPES = Set.of(
            "multiple_choice", "fill_blank", "rearrange", "translate", "match", "true_false", "free_text"
    );

    private final GrammarTopicRepository topicRepository;
    private final GrammarLessonRepository lessonRepository;
    private final GrammarExerciseRepository exerciseRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AdminGrammarService(GrammarTopicRepository topicRepository,
                               GrammarLessonRepository lessonRepository,
                               GrammarExerciseRepository exerciseRepository) {
        this.topicRepository = topicRepository;
        this.lessonRepository = lessonRepository;
        this.exerciseRepository = exerciseRepository;
    }

    // ── Topics ──────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminGrammarTopicRow> listTopics(String level, String keyword) {
        Map<UUID, Long> counts = new HashMap<>();
        topicRepository.countLessonsByTopic().forEach(v -> counts.put(v.getTopicId(), v.getLessonCount()));
        return topicRepository.searchTopics(
                        blankToNull(level),
                        blankToNull(keyword))
                .stream()
                .map(t -> new AdminGrammarTopicRow(
                        t.getId(),
                        t.getSlug(),
                        t.getCategory(),
                        t.getLevel(),
                        t.getTitle(),
                        t.getSortOrder(),
                        counts.getOrDefault(t.getId(), 0L)))
                .toList();
    }

    @Transactional(readOnly = true)
    public GrammarTopic getTopicOrThrow(UUID id) {
        return topicRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar topic not found"));
    }

    @Transactional
    public GrammarTopic createTopic(CreateGrammarTopicRequest req) {
        validateTopicPayload(req.slug(), req.category(), req.level(), req.title());
        String slug = req.slug().trim().toLowerCase(Locale.ROOT);
        if (topicRepository.existsBySlug(slug)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Slug đã tồn tại.");
        }
        if (topicRepository.existsByCategoryAndLevel(req.category().trim(), normalizeLevel(req.level()))) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Đã có chủ đề cho cùng danh mục + trình độ này.");
        }
        GrammarTopic topic = new GrammarTopic();
        topic.setSlug(slug);
        topic.setCategory(req.category().trim());
        topic.setLevel(normalizeLevel(req.level()));
        topic.setTitle(req.title().trim());
        topic.setSortOrder(req.sortOrder() == null
                ? (topicRepository.maxSortOrder() == null ? 1 : topicRepository.maxSortOrder() + 1)
                : req.sortOrder());
        return topicRepository.save(topic);
    }

    @Transactional
    public GrammarTopic updateTopic(UUID id, UpdateGrammarTopicRequest req) {
        validateTopicPayload(req.slug(), req.category(), req.level(), req.title());
        GrammarTopic topic = getTopicOrThrow(id);
        String slug = req.slug().trim().toLowerCase(Locale.ROOT);
        if (!slug.equals(topic.getSlug()) && topicRepository.existsBySlug(slug)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Slug đã tồn tại.");
        }
        String newCategory = req.category().trim();
        String newLevel = normalizeLevel(req.level());
        if ((!newCategory.equals(topic.getCategory()) || !newLevel.equals(topic.getLevel()))
                && topicRepository.existsByCategoryAndLevel(newCategory, newLevel)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Đã có chủ đề cho cùng danh mục + trình độ này.");
        }
        topic.setSlug(slug);
        topic.setCategory(newCategory);
        topic.setLevel(newLevel);
        topic.setTitle(req.title().trim());
        if (req.sortOrder() != null) topic.setSortOrder(req.sortOrder());
        return topicRepository.save(topic);
    }

    @Transactional
    public void deleteTopic(UUID id) {
        GrammarTopic topic = getTopicOrThrow(id);
        topicRepository.delete(topic);
    }

    // ── Lessons ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminGrammarLessonRow> listLessonsByTopic(UUID topicId) {
        GrammarTopic topic = getTopicOrThrow(topicId);
        Map<UUID, Long> counts = new HashMap<>();
        lessonRepository.countExercisesByLessonForTopic(topic)
                .forEach(v -> counts.put(v.getLessonId(), v.getExerciseCount()));
        return lessonRepository.findByTopicOrderBySortOrderAscTitleAsc(topic).stream()
                .map(l -> new AdminGrammarLessonRow(
                        l.getId(),
                        l.getSourceId(),
                        l.getTitle(),
                        l.getSortOrder(),
                        counts.getOrDefault(l.getId(), 0L)))
                .toList();
    }

    @Transactional(readOnly = true)
    public GrammarLesson getLessonOrThrow(UUID id) {
        return lessonRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar lesson not found"));
    }

    @Transactional
    public GrammarLesson createLesson(UUID topicId, CreateGrammarLessonRequest req) {
        GrammarTopic topic = getTopicOrThrow(topicId);
        validateLessonPayload(req.sourceId(), req.title());
        String sourceId = req.sourceId().trim();
        if (lessonRepository.existsBySourceId(sourceId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Source ID đã tồn tại.");
        }
        GrammarLesson lesson = new GrammarLesson();
        lesson.setTopic(topic);
        lesson.setSourceId(sourceId);
        lesson.setTitle(req.title().trim());
        lesson.setSortOrder(req.sortOrder() == null
                ? (lessonRepository.maxSortOrderByTopic(topic) == null
                ? 1 : lessonRepository.maxSortOrderByTopic(topic) + 1)
                : req.sortOrder());
        lesson.setExplanationVi(blankToNull(req.explanationVi()));
        lesson.setWhenToUseVi(blankToNull(req.whenToUseVi()));
        lesson.setTipsVi(blankToNull(req.tipsVi()));
        lesson.setFormulas(parseJsonArrayOfMaps(req.formulasJson(), "formulas"));
        lesson.setKeyWords(parseJsonArrayOfStrings(req.keyWordsJson(), "keyWords"));
        lesson.setExamples(parseJsonArrayOfMaps(req.examplesJson(), "examples"));
        lesson.setCommonMistakes(parseJsonArrayOfMaps(req.commonMistakesJson(), "commonMistakes"));
        return lessonRepository.save(lesson);
    }

    @Transactional
    public GrammarLesson updateLesson(UUID id, UpdateGrammarLessonRequest req) {
        validateLessonPayload(req.sourceId(), req.title());
        GrammarLesson lesson = getLessonOrThrow(id);
        String sourceId = req.sourceId().trim();
        if (!sourceId.equals(lesson.getSourceId()) && lessonRepository.existsBySourceId(sourceId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Source ID đã tồn tại.");
        }
        lesson.setSourceId(sourceId);
        lesson.setTitle(req.title().trim());
        if (req.sortOrder() != null) lesson.setSortOrder(req.sortOrder());
        lesson.setExplanationVi(blankToNull(req.explanationVi()));
        lesson.setWhenToUseVi(blankToNull(req.whenToUseVi()));
        lesson.setTipsVi(blankToNull(req.tipsVi()));
        lesson.setFormulas(parseJsonArrayOfMaps(req.formulasJson(), "formulas"));
        lesson.setKeyWords(parseJsonArrayOfStrings(req.keyWordsJson(), "keyWords"));
        lesson.setExamples(parseJsonArrayOfMaps(req.examplesJson(), "examples"));
        lesson.setCommonMistakes(parseJsonArrayOfMaps(req.commonMistakesJson(), "commonMistakes"));
        return lessonRepository.save(lesson);
    }

    @Transactional
    public void deleteLesson(UUID id) {
        GrammarLesson lesson = getLessonOrThrow(id);
        lessonRepository.delete(lesson);
    }

    @Transactional(readOnly = true)
    public AdminGrammarLessonDetail getLessonDetail(UUID id) {
        GrammarLesson lesson = getLessonOrThrow(id);
        List<AdminGrammarExerciseRow> exercises = exerciseRepository
                .findByLessonOrderByExerciseOrderAsc(lesson).stream()
                .map(e -> new AdminGrammarExerciseRow(
                        e.getId(),
                        e.getExerciseOrder(),
                        e.getExerciseType(),
                        toJsonPretty(e.getContent())))
                .toList();
        return new AdminGrammarLessonDetail(
                lesson.getId(),
                lesson.getTopic().getId(),
                lesson.getTopic().getTitle(),
                lesson.getSourceId(),
                lesson.getTitle(),
                lesson.getSortOrder(),
                lesson.getExplanationVi(),
                lesson.getWhenToUseVi(),
                lesson.getTipsVi(),
                toJsonPretty(lesson.getFormulas()),
                toJsonPretty(lesson.getKeyWords()),
                toJsonPretty(lesson.getExamples()),
                toJsonPretty(lesson.getCommonMistakes()),
                exercises);
    }

    // ── Exercises ───────────────────────────────────────────────────────────

    @Transactional
    public GrammarExercise createExercise(UUID lessonId, CreateGrammarExerciseRequest req) {
        GrammarLesson lesson = getLessonOrThrow(lessonId);
        Map<String, Object> content = parseJsonObject(req.contentJson(), "content");
        if (content == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nội dung bài tập (JSON) không được trống.");
        }
        String type = normalizeExerciseType(req.exerciseType());
        GrammarExercise exercise = new GrammarExercise();
        exercise.setLesson(lesson);
        exercise.setExerciseOrder(req.exerciseOrder() == null
                ? (exerciseRepository.maxOrderByLesson(lesson) == null
                ? 1 : exerciseRepository.maxOrderByLesson(lesson) + 1)
                : req.exerciseOrder());
        exercise.setExerciseType(type);
        exercise.setContent(content);
        return exerciseRepository.save(exercise);
    }

    @Transactional
    public GrammarExercise updateExercise(UUID id, UpdateGrammarExerciseRequest req) {
        GrammarExercise exercise = exerciseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar exercise not found"));
        Map<String, Object> content = parseJsonObject(req.contentJson(), "content");
        if (content == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Nội dung bài tập (JSON) không được trống.");
        }
        if (req.exerciseOrder() != null) exercise.setExerciseOrder(req.exerciseOrder());
        exercise.setExerciseType(normalizeExerciseType(req.exerciseType()));
        exercise.setContent(content);
        return exerciseRepository.save(exercise);
    }

    @Transactional
    public UUID deleteExercise(UUID id) {
        GrammarExercise exercise = exerciseRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar exercise not found"));
        UUID lessonId = exercise.getLesson().getId();
        exerciseRepository.delete(exercise);
        return lessonId;
    }

    // ── Bulk import (JSON) ──────────────────────────────────────────────────

    /**
     * Import grammar nhanh từ JSON. Hỗ trợ payload dạng:
     * {
     *   "topics": [
     *     {
     *       "slug": "...", "category": "...", "level": "A1", "title": "...", "sortOrder": 1,
     *       "lessons": [
     *         {
     *           "sourceId": "...", "title": "...", "sortOrder": 1,
     *           "explanationVi": "...", "whenToUseVi": "...", "tipsVi": "...",
     *           "formulas": [{...}], "keyWords": ["..."], "examples": [{...}], "commonMistakes": [{...}],
     *           "exercises": [
     *             {"exerciseOrder": 1, "exerciseType": "fill_blank", "content": {...}}
     *           ]
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    @Transactional
    public GrammarImportResult importGrammar(String jsonPayload) {
        if (jsonPayload == null || jsonPayload.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "JSON payload trống.");
        }
        JsonNode root;
        try {
            root = objectMapper.readTree(jsonPayload);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "JSON không hợp lệ: " + ex.getMessage());
        }
        JsonNode topicsNode = root.isArray() ? root : root.path("topics");
        if (!topicsNode.isArray()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Payload phải là mảng topics hoặc object { \"topics\": [...] }.");
        }

        int totalTopics = 0, topicsInserted = 0, topicsSkipped = 0;
        int totalLessons = 0, lessonsInserted = 0, lessonsSkipped = 0;
        int totalExercises = 0, exercisesInserted = 0;
        List<String> errors = new ArrayList<>();

        for (JsonNode topicNode : topicsNode) {
            totalTopics++;
            try {
                String slug = textOrNull(topicNode, "slug");
                String category = textOrNull(topicNode, "category");
                String level = textOrNull(topicNode, "level");
                String title = textOrNull(topicNode, "title");
                if (slug == null || category == null || level == null || title == null) {
                    throw new IllegalArgumentException("Thiếu trường bắt buộc (slug/category/level/title).");
                }
                Integer sortOrder = topicNode.has("sortOrder") && topicNode.get("sortOrder").isInt()
                        ? topicNode.get("sortOrder").asInt() : null;

                GrammarTopic topic = topicRepository.findBySlug(slug.trim().toLowerCase(Locale.ROOT))
                        .orElse(null);
                if (topic == null) {
                    topic = createTopic(new CreateGrammarTopicRequest(slug, category, level, title, sortOrder));
                    topicsInserted++;
                } else {
                    topicsSkipped++;
                }

                JsonNode lessons = topicNode.path("lessons");
                if (lessons.isArray()) {
                    for (JsonNode lessonNode : lessons) {
                        totalLessons++;
                        try {
                            String sourceId = textOrNull(lessonNode, "sourceId");
                            String lessonTitle = textOrNull(lessonNode, "title");
                            if (sourceId == null || lessonTitle == null) {
                                throw new IllegalArgumentException("Lesson thiếu sourceId/title.");
                            }
                            if (lessonRepository.existsBySourceId(sourceId.trim())) {
                                lessonsSkipped++;
                                continue;
                            }
                            CreateGrammarLessonRequest lessonReq = new CreateGrammarLessonRequest(
                                    sourceId,
                                    lessonTitle,
                                    lessonNode.has("sortOrder") && lessonNode.get("sortOrder").isInt()
                                            ? lessonNode.get("sortOrder").asInt() : null,
                                    textOrNull(lessonNode, "explanationVi"),
                                    textOrNull(lessonNode, "whenToUseVi"),
                                    textOrNull(lessonNode, "tipsVi"),
                                    nodeToJsonString(lessonNode.get("formulas")),
                                    nodeToJsonString(lessonNode.get("keyWords")),
                                    nodeToJsonString(lessonNode.get("examples")),
                                    nodeToJsonString(lessonNode.get("commonMistakes"))
                            );
                            GrammarLesson newLesson = createLesson(topic.getId(), lessonReq);
                            lessonsInserted++;

                            JsonNode exercises = lessonNode.path("exercises");
                            if (exercises.isArray()) {
                                for (JsonNode exNode : exercises) {
                                    totalExercises++;
                                    try {
                                        String contentJson = nodeToJsonString(exNode.get("content"));
                                        if (contentJson == null || contentJson.isBlank()) {
                                            throw new IllegalArgumentException("Exercise thiếu content.");
                                        }
                                        Integer exOrder = exNode.has("exerciseOrder") && exNode.get("exerciseOrder").isInt()
                                                ? exNode.get("exerciseOrder").asInt() : null;
                                        createExercise(newLesson.getId(), new CreateGrammarExerciseRequest(
                                                exOrder,
                                                textOrNull(exNode, "exerciseType"),
                                                contentJson));
                                        exercisesInserted++;
                                    } catch (Exception inner) {
                                        errors.add("Exercise lỗi (lesson " + sourceId + "): " + inner.getMessage());
                                    }
                                }
                            }
                        } catch (Exception inner) {
                            errors.add("Lesson lỗi: " + inner.getMessage());
                        }
                    }
                }
            } catch (Exception outer) {
                errors.add("Topic lỗi: " + outer.getMessage());
            }
        }

        return new GrammarImportResult(
                totalTopics, topicsInserted, topicsSkipped,
                totalLessons, lessonsInserted, lessonsSkipped,
                totalExercises, exercisesInserted,
                errors);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private void validateTopicPayload(String slug, String category, String level, String title) {
        if (slug == null || slug.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Slug bắt buộc.");
        }
        if (!slug.matches("[a-z0-9][a-z0-9_-]{0,118}")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Slug chỉ chứa chữ thường, số, dấu '-' hoặc '_' (bắt đầu bằng chữ/số).");
        }
        if (category == null || category.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Danh mục bắt buộc.");
        }
        if (level == null || level.isBlank() || !ALLOWED_LEVELS.contains(level.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Trình độ phải thuộc A1–C2.");
        }
        if (title == null || title.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tiêu đề bắt buộc.");
        }
    }

    private void validateLessonPayload(String sourceId, String title) {
        if (sourceId == null || sourceId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Source ID bắt buộc.");
        }
        if (sourceId.length() > 120) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Source ID tối đa 120 ký tự.");
        }
        if (title == null || title.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tiêu đề bắt buộc.");
        }
    }

    private static String normalizeLevel(String level) {
        return level.trim().toUpperCase(Locale.ROOT);
    }

    private static String normalizeExerciseType(String type) {
        if (type == null || type.isBlank()) return null;
        String norm = type.trim().toLowerCase(Locale.ROOT);
        return ALLOWED_EXERCISE_TYPES.contains(norm) ? norm : norm;
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private List<Map<String, Object>> parseJsonArrayOfMaps(String json, String field) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Trường '" + field + "' phải là mảng object JSON: " + ex.getMessage());
        }
    }

    private List<String> parseJsonArrayOfStrings(String json, String field) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Trường '" + field + "' phải là mảng chuỗi JSON: " + ex.getMessage());
        }
    }

    private Map<String, Object> parseJsonObject(String json, String field) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Trường '" + field + "' phải là object JSON: " + ex.getMessage());
        }
    }

    private String toJsonPretty(Object value) {
        if (value == null) return null;
        try {
            return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(value);
        } catch (Exception ex) {
            return value.toString();
        }
    }

    private String nodeToJsonString(JsonNode node) {
        if (node == null || node.isNull()) return null;
        try {
            return objectMapper.writeValueAsString(node);
        } catch (Exception ex) {
            return null;
        }
    }

    private static String textOrNull(JsonNode node, String field) {
        JsonNode v = node.get(field);
        if (v == null || v.isNull()) return null;
        String s = v.asText();
        return s == null || s.isBlank() ? null : s;
    }
}
