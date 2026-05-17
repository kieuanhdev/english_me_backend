package com.kiovant.englishme.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.AdminTestBankQuestionRow;
import com.kiovant.englishme.dto.CreateTestBankQuestionRequest;
import com.kiovant.englishme.dto.TestBankImportResult;
import com.kiovant.englishme.dto.TestBankStats;
import com.kiovant.englishme.dto.UpdateTestBankQuestionRequest;
import com.kiovant.englishme.entity.Question;
import com.kiovant.englishme.repository.QuestionRepository;
import com.kiovant.englishme.repository.TestAnswerRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.UUID;

@Service
public class AdminTestBankService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final Set<String> ALLOWED_SKILLS =
            Set.of("grammar", "vocabulary", "reading", "listening");
    private static final Set<String> ALLOWED_ANSWERS = Set.of("A", "B", "C", "D");

    private final QuestionRepository questionRepository;
    private final TestAnswerRepository testAnswerRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AdminTestBankService(QuestionRepository questionRepository,
                                TestAnswerRepository testAnswerRepository) {
        this.questionRepository = questionRepository;
        this.testAnswerRepository = testAnswerRepository;
    }

    // ── Question CRUD ───────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminTestBankQuestionRow> listQuestions(String level, String skill, String keyword) {
        List<Question> questions = questionRepository.searchQuestions(
                blankToNull(level),
                blankToNull(skill),
                blankToNull(keyword));
        if (questions.isEmpty()) return List.of();

        Map<UUID, long[]> stats = loadQuestionStats(questions.stream().map(Question::getId).toList());
        List<AdminTestBankQuestionRow> rows = new ArrayList<>(questions.size());
        for (Question q : questions) {
            long[] st = stats.getOrDefault(q.getId(), new long[]{0L, 0L});
            long attempts = st[0];
            long correct = st[1];
            Double avg = attempts == 0 ? null : Math.round((correct * 10000.0 / attempts)) / 100.0;
            rows.add(new AdminTestBankQuestionRow(
                    q.getId(),
                    q.getCefrLevel(),
                    q.getSkillCategory(),
                    q.getQuestion(),
                    toJsonInline(q.getOptions()),
                    q.getCorrectAnswer(),
                    q.getExplanation(),
                    q.getAudioUrl(),
                    q.getPassage(),
                    attempts,
                    correct,
                    avg));
        }
        return rows;
    }

    @Transactional(readOnly = true)
    public Question getQuestionOrThrow(UUID id) {
        return questionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Test bank question not found"));
    }

    @Transactional
    public Question createQuestion(CreateTestBankQuestionRequest req) {
        validatePayload(req.cefrLevel(), req.skillCategory(), req.question(), req.optionsJson(), req.correctAnswer());
        Question q = new Question();
        applyFields(q, req.cefrLevel(), req.skillCategory(), req.question(), req.optionsJson(),
                req.correctAnswer(), req.explanation(), req.audioUrl(), req.passage());
        return questionRepository.save(q);
    }

    @Transactional
    public Question updateQuestion(UUID id, UpdateTestBankQuestionRequest req) {
        validatePayload(req.cefrLevel(), req.skillCategory(), req.question(), req.optionsJson(), req.correctAnswer());
        Question q = getQuestionOrThrow(id);
        applyFields(q, req.cefrLevel(), req.skillCategory(), req.question(), req.optionsJson(),
                req.correctAnswer(), req.explanation(), req.audioUrl(), req.passage());
        return questionRepository.save(q);
    }

    @Transactional
    public void deleteQuestion(UUID id) {
        Question q = getQuestionOrThrow(id);
        questionRepository.delete(q);
    }

    // ── Bulk import (JSON) ──────────────────────────────────────────────────

    /**
     * Hỗ trợ payload dạng:
     *   [{...}, {...}]
     *   { "questions": [...] }
     * Mỗi item: cefr_level, skill_category, question, options (object A/B/C/D),
     *           correct_answer, explanation, audio_url, passage.
     * Bỏ qua câu duplicate theo cặp (cefr_level, skill_category, question) sau khi normalize.
     */
    @Transactional
    public TestBankImportResult importQuestions(String jsonPayload) {
        if (jsonPayload == null || jsonPayload.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "JSON payload trống.");
        }
        JsonNode root;
        try {
            root = objectMapper.readTree(jsonPayload);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "JSON không hợp lệ: " + ex.getMessage());
        }
        JsonNode arr = root.isArray() ? root : root.path("questions");
        if (!arr.isArray()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Payload phải là mảng hoặc object { \"questions\": [...] }.");
        }

        int total = 0, inserted = 0, skipped = 0;
        List<String> errors = new ArrayList<>();
        Set<String> seenKey = new HashSet<>();

        for (JsonNode node : arr) {
            total++;
            try {
                String cefrLevel = firstNonBlank(
                        textOrNull(node, "cefrLevel"),
                        textOrNull(node, "cefr_level"));
                String skillCategory = firstNonBlank(
                        textOrNull(node, "skillCategory"),
                        textOrNull(node, "skill_category"));
                String question = textOrNull(node, "question");
                String correctAnswer = firstNonBlank(
                        textOrNull(node, "correctAnswer"),
                        textOrNull(node, "correct_answer"));
                String explanation = firstNonBlank(textOrNull(node, "explanation"));
                String audioUrl = firstNonBlank(
                        textOrNull(node, "audioUrl"),
                        textOrNull(node, "audio_url"));
                String passage = firstNonBlank(textOrNull(node, "passage"));

                JsonNode optionsNode = node.get("options");
                String optionsJson = optionsNode == null || optionsNode.isNull()
                        ? null : objectMapper.writeValueAsString(optionsNode);

                if (cefrLevel == null || skillCategory == null || question == null
                        || correctAnswer == null || optionsJson == null) {
                    throw new IllegalArgumentException(
                            "Thiếu trường bắt buộc (cefr_level/skill_category/question/options/correct_answer).");
                }

                String dedupeKey = cefrLevel.trim().toUpperCase(Locale.ROOT)
                        + "##" + skillCategory.trim().toLowerCase(Locale.ROOT)
                        + "##" + question.trim().toLowerCase(Locale.ROOT);
                if (!seenKey.add(dedupeKey)
                        || questionRepository.existsByCefrLevelAndSkillCategoryAndQuestion(
                                cefrLevel.trim().toUpperCase(Locale.ROOT),
                                skillCategory.trim().toLowerCase(Locale.ROOT),
                                question.trim())) {
                    skipped++;
                    continue;
                }

                createQuestion(new CreateTestBankQuestionRequest(
                        cefrLevel, skillCategory, question, optionsJson, correctAnswer,
                        explanation, audioUrl, passage));
                inserted++;
            } catch (Exception ex) {
                errors.add("Dòng " + total + ": " + ex.getMessage());
            }
        }
        return new TestBankImportResult(total, inserted, skipped, errors);
    }

    // ── Export CSV ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public String exportQuestionsAsCsv(String level, String skill, String keyword) {
        List<Question> questions = questionRepository.searchQuestions(
                blankToNull(level),
                blankToNull(skill),
                blankToNull(keyword));
        StringBuilder sb = new StringBuilder();
        sb.append("cefr_level,skill_category,question,options,correct_answer,explanation,audio_url,passage\n");
        for (Question q : questions) {
            sb.append(csv(q.getCefrLevel())).append(',')
              .append(csv(q.getSkillCategory())).append(',')
              .append(csv(q.getQuestion())).append(',')
              .append(csv(toJsonInline(q.getOptions()))).append(',')
              .append(csv(q.getCorrectAnswer())).append(',')
              .append(csv(q.getExplanation())).append(',')
              .append(csv(q.getAudioUrl())).append(',')
              .append(csv(q.getPassage())).append('\n');
        }
        return sb.toString();
    }

    // ── Stats ──────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public TestBankStats getStats() {
        long totalQuestions = questionRepository.count();

        Map<String, Long> questionCountByLevel = new TreeMap<>();
        for (Object[] row : questionRepository.countByCefrLevel()) {
            questionCountByLevel.put((String) row[0], ((Number) row[1]).longValue());
        }

        Map<String, long[]> attemptStatsByLevel = new HashMap<>();
        for (Object[] row : testAnswerRepository.aggregateStatsByCefrLevel()) {
            String lvl = (String) row[0];
            long attempts = ((Number) row[1]).longValue();
            long correct = row[2] == null ? 0L : ((Number) row[2]).longValue();
            attemptStatsByLevel.put(lvl, new long[]{attempts, correct});
        }

        List<TestBankStats.LevelStat> byLevel = new ArrayList<>();
        long totalAttempts = 0, totalCorrect = 0;
        for (Map.Entry<String, Long> e : questionCountByLevel.entrySet()) {
            String lvl = e.getKey();
            long[] st = attemptStatsByLevel.getOrDefault(lvl, new long[]{0L, 0L});
            long attempts = st[0];
            long correct = st[1];
            totalAttempts += attempts;
            totalCorrect += correct;
            Double accuracy = attempts == 0 ? null : Math.round((correct * 10000.0 / attempts)) / 100.0;
            byLevel.add(new TestBankStats.LevelStat(lvl, e.getValue(), attempts, correct, accuracy));
        }
        Double overallAccuracy = totalAttempts == 0
                ? null : Math.round((totalCorrect * 10000.0 / totalAttempts)) / 100.0;

        List<TestBankStats.SkillStat> bySkill = new ArrayList<>();
        for (Object[] row : questionRepository.countBySkillCategory()) {
            bySkill.add(new TestBankStats.SkillStat((String) row[0], ((Number) row[1]).longValue()));
        }

        List<TestBankStats.DifficultyBucket> buckets = buildDifficultyBuckets();

        return new TestBankStats(totalQuestions, totalAttempts, totalCorrect, overallAccuracy,
                byLevel, bySkill, buckets);
    }

    private List<TestBankStats.DifficultyBucket> buildDifficultyBuckets() {
        // Lấy stats cho TOÀN BỘ câu hỏi để tính tỉ lệ; câu chưa có attempt → bucket "Chưa có dữ liệu".
        List<UUID> allIds = questionRepository.findAll().stream().map(Question::getId).toList();
        if (allIds.isEmpty()) {
            return List.of(
                    new TestBankStats.DifficultyBucket("Quá khó (<30%)", 0),
                    new TestBankStats.DifficultyBucket("Bình thường", 0),
                    new TestBankStats.DifficultyBucket("Quá dễ (>95%)", 0),
                    new TestBankStats.DifficultyBucket("Chưa có dữ liệu", 0));
        }
        Map<UUID, long[]> stats = loadQuestionStats(allIds);
        long tooHard = 0, normal = 0, tooEasy = 0, noData = 0;
        for (UUID id : allIds) {
            long[] st = stats.get(id);
            if (st == null || st[0] == 0) {
                noData++;
                continue;
            }
            double acc = st[1] * 100.0 / st[0];
            if (acc < 30) tooHard++;
            else if (acc > 95) tooEasy++;
            else normal++;
        }
        Map<String, Long> map = new LinkedHashMap<>();
        map.put("Quá khó (<30%)", tooHard);
        map.put("Bình thường", normal);
        map.put("Quá dễ (>95%)", tooEasy);
        map.put("Chưa có dữ liệu", noData);
        List<TestBankStats.DifficultyBucket> list = new ArrayList<>();
        for (Map.Entry<String, Long> e : map.entrySet()) {
            list.add(new TestBankStats.DifficultyBucket(e.getKey(), e.getValue()));
        }
        return list;
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private Map<UUID, long[]> loadQuestionStats(List<UUID> questionIds) {
        if (questionIds.isEmpty()) return Collections.emptyMap();
        Map<UUID, long[]> result = new HashMap<>();
        for (Object[] row : testAnswerRepository.aggregateStatsByQuestionIds(questionIds)) {
            UUID qid = (UUID) row[0];
            long attempts = ((Number) row[1]).longValue();
            long correct = row[2] == null ? 0L : ((Number) row[2]).longValue();
            result.put(qid, new long[]{attempts, correct});
        }
        return result;
    }

    private void validatePayload(String level, String skill, String question,
                                 String optionsJson, String correctAnswer) {
        if (level == null || !ALLOWED_LEVELS.contains(level.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "CEFR level phải thuộc A1–C2.");
        }
        if (skill == null || !ALLOWED_SKILLS.contains(skill.trim().toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Skill category phải là 'grammar' | 'vocabulary' | 'reading' | 'listening'.");
        }
        if (question == null || question.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Câu hỏi không được trống.");
        }
        if (correctAnswer == null || correctAnswer.isBlank()
                || !ALLOWED_ANSWERS.contains(correctAnswer.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Đáp án đúng phải là 'A' | 'B' | 'C' | 'D'.");
        }
        Map<String, String> options = parseOptions(optionsJson);
        if (options.size() < 2) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Options cần ít nhất 2 lựa chọn.");
        }
        if (!options.containsKey(correctAnswer.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Đáp án đúng phải khớp 1 trong các khóa options (A/B/C/D).");
        }
    }

    private void applyFields(Question q, String level, String skill, String question,
                             String optionsJson, String correctAnswer, String explanation,
                             String audioUrl, String passage) {
        q.setCefrLevel(level.trim().toUpperCase(Locale.ROOT));
        q.setSkillCategory(skill.trim().toLowerCase(Locale.ROOT));
        q.setQuestion(question.trim());
        q.setOptions(parseOptions(optionsJson));
        q.setCorrectAnswer(correctAnswer.trim().toUpperCase(Locale.ROOT));
        q.setExplanation(blankToNull(explanation));
        q.setAudioUrl(blankToNull(audioUrl));
        q.setPassage(blankToNull(passage));
    }

    private Map<String, String> parseOptions(String optionsJson) {
        if (optionsJson == null || optionsJson.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Options không được trống.");
        }
        try {
            Map<String, String> raw = objectMapper.readValue(
                    optionsJson, new TypeReference<Map<String, String>>() {});
            Map<String, String> cleaned = new LinkedHashMap<>();
            for (Map.Entry<String, String> e : raw.entrySet()) {
                if (e.getKey() == null || e.getValue() == null) continue;
                String key = e.getKey().trim().toUpperCase(Locale.ROOT);
                String value = e.getValue().trim();
                if (key.isEmpty() || value.isEmpty()) continue;
                if (!ALLOWED_ANSWERS.contains(key)) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Khóa option phải là A/B/C/D, nhận được: " + key);
                }
                cleaned.put(key, value);
            }
            return cleaned;
        } catch (ResponseStatusException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Options phải là object JSON {\"A\":\"...\",\"B\":\"...\"} : " + ex.getMessage());
        }
    }

    private String toJsonInline(Object value) {
        if (value == null) return null;
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception ex) {
            return value.toString();
        }
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String firstNonBlank(String... values) {
        for (String s : values) {
            if (s != null && !s.isBlank()) return s;
        }
        return null;
    }

    private static String textOrNull(JsonNode node, String field) {
        JsonNode v = node.get(field);
        if (v == null || v.isNull()) return null;
        String s = v.asText();
        return s == null || s.isBlank() ? null : s;
    }

    private static String csv(String value) {
        if (value == null) return "";
        String escaped = value.replace("\"", "\"\"");
        return "\"" + escaped + "\"";
    }
}
