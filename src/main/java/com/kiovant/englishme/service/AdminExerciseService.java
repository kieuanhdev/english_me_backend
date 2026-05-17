package com.kiovant.englishme.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.AdminExerciseQuestionRow;
import com.kiovant.englishme.dto.AdminExerciseSessionDetail;
import com.kiovant.englishme.dto.AdminExerciseSessionRow;
import com.kiovant.englishme.dto.CreateExerciseQuestionRequest;
import com.kiovant.englishme.dto.ExerciseImportResult;
import com.kiovant.englishme.dto.UpdateExerciseQuestionRequest;
import com.kiovant.englishme.entity.ExerciseAnswer;
import com.kiovant.englishme.entity.ExerciseQuestion;
import com.kiovant.englishme.entity.ExerciseSession;
import com.kiovant.englishme.repository.ExerciseAnswerRepository;
import com.kiovant.englishme.repository.ExerciseQuestionRepository;
import com.kiovant.englishme.repository.ExerciseSessionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminExerciseService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");
    private static final Set<String> ALLOWED_CATEGORIES = Set.of("vocabulary", "grammar");
    private static final Set<String> ALLOWED_DIFFICULTIES = Set.of("easy", "medium", "hard");

    private final ExerciseQuestionRepository questionRepository;
    private final ExerciseSessionRepository sessionRepository;
    private final ExerciseAnswerRepository answerRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AdminExerciseService(ExerciseQuestionRepository questionRepository,
                                ExerciseSessionRepository sessionRepository,
                                ExerciseAnswerRepository answerRepository) {
        this.questionRepository = questionRepository;
        this.sessionRepository = sessionRepository;
        this.answerRepository = answerRepository;
    }

    // ── Question CRUD ───────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminExerciseQuestionRow> listQuestions(String category, String difficulty, String level, String keyword) {
        List<ExerciseQuestion> questions = questionRepository.searchQuestions(
                blankToNull(category),
                blankToNull(difficulty),
                blankToNull(level),
                blankToNull(keyword));
        if (questions.isEmpty()) return List.of();

        Map<UUID, long[]> stats = loadQuestionStats(questions.stream().map(ExerciseQuestion::getId).toList());
        List<AdminExerciseQuestionRow> rows = new ArrayList<>(questions.size());
        for (ExerciseQuestion q : questions) {
            long[] st = stats.getOrDefault(q.getId(), new long[]{0L, 0L});
            long attempts = st[0];
            long correct = st[1];
            Double avg = attempts == 0 ? null : Math.round((correct * 10000.0 / attempts)) / 100.0;
            rows.add(new AdminExerciseQuestionRow(
                    q.getId(),
                    q.getCategory(),
                    q.getDifficulty(),
                    q.getLevel(),
                    q.getQuestion(),
                    toJsonInline(q.getOptions()),
                    q.getCorrectAnswer(),
                    attempts,
                    correct,
                    avg));
        }
        return rows;
    }

    @Transactional(readOnly = true)
    public ExerciseQuestion getQuestionOrThrow(UUID id) {
        return questionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise question not found"));
    }

    @Transactional
    public ExerciseQuestion createQuestion(CreateExerciseQuestionRequest req) {
        validateQuestionPayload(req.category(), req.difficulty(), req.level(),
                req.question(), req.optionsJson(), req.correctAnswer());
        ExerciseQuestion q = new ExerciseQuestion();
        applyQuestionFields(q, req.category(), req.difficulty(), req.level(),
                req.question(), req.optionsJson(), req.correctAnswer(), req.explanation(), req.hint());
        return questionRepository.save(q);
    }

    @Transactional
    public ExerciseQuestion updateQuestion(UUID id, UpdateExerciseQuestionRequest req) {
        validateQuestionPayload(req.category(), req.difficulty(), req.level(),
                req.question(), req.optionsJson(), req.correctAnswer());
        ExerciseQuestion q = getQuestionOrThrow(id);
        applyQuestionFields(q, req.category(), req.difficulty(), req.level(),
                req.question(), req.optionsJson(), req.correctAnswer(), req.explanation(), req.hint());
        return questionRepository.save(q);
    }

    @Transactional
    public void deleteQuestion(UUID id) {
        ExerciseQuestion q = getQuestionOrThrow(id);
        questionRepository.delete(q);
    }

    // ── Bulk import (JSON) ──────────────────────────────────────────────────

    /**
     * Hỗ trợ payload dạng:
     *   [{...}, {...}]
     *   { "questions": [...] }
     * Mỗi item: category, difficulty, question, options (array), correct_answer (correctAnswer),
     * explanation, hint, level. Bỏ qua câu duplicate theo cặp (category, question) sau khi normalize.
     */
    @Transactional
    public ExerciseImportResult importQuestions(String jsonPayload) {
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
                String category = textOrNull(node, "category");
                String difficulty = textOrNull(node, "difficulty");
                String level = firstNonBlank(textOrNull(node, "level"));
                String question = textOrNull(node, "question");
                String correctAnswer = firstNonBlank(
                        textOrNull(node, "correctAnswer"),
                        textOrNull(node, "correct_answer"));
                String explanation = firstNonBlank(textOrNull(node, "explanation"));
                String hint = firstNonBlank(textOrNull(node, "hint"));

                JsonNode optionsNode = node.get("options");
                String optionsJson = optionsNode == null || optionsNode.isNull()
                        ? null : objectMapper.writeValueAsString(optionsNode);

                if (category == null || difficulty == null || question == null
                        || correctAnswer == null || optionsJson == null) {
                    throw new IllegalArgumentException("Thiếu trường bắt buộc (category/difficulty/question/options/correctAnswer).");
                }

                String dedupeKey = (category.trim().toLowerCase(Locale.ROOT)
                        + "##" + question.trim().toLowerCase(Locale.ROOT));
                if (!seenKey.add(dedupeKey)) {
                    skipped++;
                    continue;
                }

                createQuestion(new CreateExerciseQuestionRequest(
                        category, difficulty, level, question, optionsJson,
                        correctAnswer, explanation, hint));
                inserted++;
            } catch (Exception ex) {
                errors.add("Dòng " + total + ": " + ex.getMessage());
            }
        }
        return new ExerciseImportResult(total, inserted, skipped, errors);
    }

    // ── Export CSV ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public String exportQuestionsAsCsv(String category, String difficulty, String level, String keyword) {
        List<ExerciseQuestion> questions = questionRepository.searchQuestions(
                blankToNull(category),
                blankToNull(difficulty),
                blankToNull(level),
                blankToNull(keyword));
        StringBuilder sb = new StringBuilder();
        sb.append("category,difficulty,level,question,options,correct_answer,explanation,hint\n");
        for (ExerciseQuestion q : questions) {
            sb.append(csv(q.getCategory())).append(',')
              .append(csv(q.getDifficulty())).append(',')
              .append(csv(q.getLevel())).append(',')
              .append(csv(q.getQuestion())).append(',')
              .append(csv(toJsonInline(q.getOptions()))).append(',')
              .append(csv(q.getCorrectAnswer())).append(',')
              .append(csv(q.getExplanation())).append(',')
              .append(csv(q.getHint())).append('\n');
        }
        return sb.toString();
    }

    // ── Sessions ────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public Page<AdminExerciseSessionRow> listSessions(String category, String status, UUID userId, int page, int size) {
        Page<ExerciseSession> sessions = sessionRepository.searchSessions(
                blankToNull(category),
                blankToNull(status),
                userId,
                PageRequest.of(Math.max(0, page), Math.max(1, Math.min(size, 100))));

        List<UUID> sessionIds = sessions.stream().map(ExerciseSession::getId).toList();
        Map<UUID, long[]> stats = sessionIds.isEmpty()
                ? Collections.emptyMap()
                : loadSessionAnswerStats(sessionIds);

        return sessions.map(s -> new AdminExerciseSessionRow(
                s.getId(),
                s.getUser() == null ? null : s.getUser().getId(),
                s.getUser() == null ? null : s.getUser().getEmail(),
                s.getUser() == null ? null : s.getUser().getFullName(),
                s.getCategory(),
                s.getStatus(),
                s.getQuestionIds() == null ? 0 : s.getQuestionIds().size(),
                stats.getOrDefault(s.getId(), new long[]{0L, 0L})[0],
                stats.getOrDefault(s.getId(), new long[]{0L, 0L})[1],
                s.getCreatedAt(),
                s.getCompletedAt()));
    }

    @Transactional(readOnly = true)
    public AdminExerciseSessionDetail getSessionDetail(UUID sessionId) {
        ExerciseSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Exercise session not found"));

        List<ExerciseAnswer> answers = answerRepository.findBySessionId(sessionId);
        long answered = answers.size();
        long correct = answers.stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();

        List<AdminExerciseSessionDetail.AnswerRow> answerRows = new ArrayList<>(answers.size());
        for (ExerciseAnswer a : answers) {
            ExerciseQuestion q = a.getQuestion();
            answerRows.add(new AdminExerciseSessionDetail.AnswerRow(
                    a.getId(),
                    q == null ? null : q.getId(),
                    q == null ? null : q.getQuestion(),
                    q == null ? null : toJsonInline(q.getOptions()),
                    q == null ? null : q.getCorrectAnswer(),
                    a.getSelectedAnswer(),
                    a.getIsCorrect(),
                    q == null ? null : q.getLevel(),
                    q == null ? null : q.getDifficulty()));
        }

        Long durationSec = null;
        if (session.getCreatedAt() != null && session.getCompletedAt() != null) {
            durationSec = Duration.between(session.getCreatedAt(), session.getCompletedAt()).toSeconds();
        }

        return new AdminExerciseSessionDetail(
                session.getId(),
                session.getUser() == null ? null : session.getUser().getId(),
                session.getUser() == null ? null : session.getUser().getEmail(),
                session.getUser() == null ? null : session.getUser().getFullName(),
                session.getCategory(),
                session.getStatus(),
                session.getCreatedAt(),
                session.getCompletedAt(),
                durationSec,
                session.getQuestionIds() == null ? 0 : session.getQuestionIds().size(),
                answered,
                correct,
                answerRows);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private Map<UUID, long[]> loadQuestionStats(List<UUID> questionIds) {
        if (questionIds.isEmpty()) return Collections.emptyMap();
        Map<UUID, long[]> result = new HashMap<>();
        for (Object[] row : answerRepository.aggregateStatsByQuestionIds(questionIds)) {
            UUID qid = (UUID) row[0];
            long attempts = ((Number) row[1]).longValue();
            long correct = row[2] == null ? 0L : ((Number) row[2]).longValue();
            result.put(qid, new long[]{attempts, correct});
        }
        return result;
    }

    private Map<UUID, long[]> loadSessionAnswerStats(List<UUID> sessionIds) {
        Map<UUID, long[]> map = new HashMap<>();
        for (UUID sid : sessionIds) {
            long total = answerRepository.countBySessionId(sid);
            long correct = answerRepository.countCorrectBySessionId(sid);
            map.put(sid, new long[]{total, correct});
        }
        return map;
    }

    private void validateQuestionPayload(String category, String difficulty, String level,
                                         String question, String optionsJson, String correctAnswer) {
        if (category == null || !ALLOWED_CATEGORIES.contains(category.trim().toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category phải là 'vocabulary' hoặc 'grammar'.");
        }
        if (difficulty == null || !ALLOWED_DIFFICULTIES.contains(difficulty.trim().toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Difficulty phải là 'easy' | 'medium' | 'hard'.");
        }
        if (level != null && !level.isBlank()
                && !ALLOWED_LEVELS.contains(level.trim().toUpperCase(Locale.ROOT))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Level phải thuộc A1–C2 (hoặc để trống).");
        }
        if (question == null || question.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Câu hỏi không được trống.");
        }
        if (correctAnswer == null || correctAnswer.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đáp án đúng không được trống.");
        }
        List<String> options = parseOptions(optionsJson);
        if (options.size() < 2) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Options cần ít nhất 2 lựa chọn.");
        }
        // Tránh sai đáp án: bắt buộc correctAnswer phải có trong options
        boolean match = options.stream().anyMatch(o -> o != null && o.equals(correctAnswer.trim()));
        if (!match) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Đáp án đúng phải khớp 1 trong các lựa chọn (kiểm tra khoảng trắng / dấu).");
        }
    }

    private void applyQuestionFields(ExerciseQuestion q, String category, String difficulty, String level,
                                     String question, String optionsJson, String correctAnswer,
                                     String explanation, String hint) {
        q.setCategory(category.trim().toLowerCase(Locale.ROOT));
        q.setDifficulty(difficulty.trim().toLowerCase(Locale.ROOT));
        q.setLevel(level == null || level.isBlank() ? null : level.trim().toUpperCase(Locale.ROOT));
        q.setQuestion(question.trim());
        q.setOptions(parseOptions(optionsJson));
        q.setCorrectAnswer(correctAnswer.trim());
        q.setExplanation(blankToNull(explanation));
        q.setHint(blankToNull(hint));
    }

    private List<String> parseOptions(String optionsJson) {
        if (optionsJson == null || optionsJson.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Options không được trống.");
        }
        try {
            List<String> raw = objectMapper.readValue(optionsJson, new TypeReference<List<String>>() {});
            List<String> cleaned = new ArrayList<>();
            for (String s : raw) {
                if (s != null && !s.isBlank()) cleaned.add(s.trim());
            }
            return cleaned;
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Options phải là mảng JSON các chuỗi: " + ex.getMessage());
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
