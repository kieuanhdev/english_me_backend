package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.GeneratedQuestion;
import com.kiovant.englishme.entity.LearningLesson;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Sinh thêm câu hỏi trắc nghiệm luyện tập (AI) dựa vào lý thuyết của lesson.
 *
 * - Tái dùng DeepSeek chat API + key DEEPSEEK_API_KEY như các service AI khác.
 * - Chỉ tạo multiple_choice; FE chấm local (câu có sẵn correctOptionId).
 * - Thiếu key/lỗi -> trả list rỗng (FE báo người dùng thử lại).
 */
@Service
public class PracticeGenerationService {

    private static final Logger log = LoggerFactory.getLogger(PracticeGenerationService.class);

    private static final int MAX_COUNT = 10;
    private static final int MAX_EXISTING = 40;

    private final LlmClient llmClient;
    private final ObjectMapper objectMapper;

    public PracticeGenerationService(LlmClient llmClient, ObjectMapper objectMapper) {
        this.llmClient = llmClient;
        this.objectMapper = objectMapper;
    }

    public List<GeneratedQuestion> generate(LearningLesson lesson, List<String> existingQuestions, int count) {
        int n = (count <= 0 || count > MAX_COUNT) ? 5 : count;
        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — không gen được câu luyện tập");
            return List.of();
        }
        try {
            String theoryContext = buildTheoryContext(lesson);
            String existingList = buildExistingList(existingQuestions);

            String userPrompt = "Tiêu đề bài học: " + nullToEmpty(lesson.getTitle()) + "\n"
                    + "Lý thuyết bài học:\n" + theoryContext + "\n\n"
                    + "Các câu hỏi đã có (TRÁNH tạo trùng hoặc gần giống):\n" + existingList + "\n\n"
                    + "Hãy tạo " + n + " câu hỏi trắc nghiệm MỚI.";

            String content = llmClient.chatCompletion(
                    List.of(
                            Map.of("role", "system", "content", systemPrompt(n)),
                            Map.of("role", "user", "content", userPrompt)
                    ),
                    0.8, 1100, true);

            return parse(content, n);
        } catch (Exception ex) {
            log.error("Gen câu luyện tập lỗi: {}", ex.getMessage());
            return List.of();
        }
    }

    // ── Parse ──────────────────────────────────────────────────────────────────

    private List<GeneratedQuestion> parse(String content, int wanted) {
        List<GeneratedQuestion> out = new ArrayList<>();
        try {
            if (content == null || content.isBlank()) {
                return out;
            }
            JsonNode parsed = objectMapper.readTree(content);
            JsonNode questions = parsed.path("questions");
            if (!questions.isArray()) {
                return out;
            }
            int idx = 0;
            for (JsonNode q : questions) {
                GeneratedQuestion gq = toQuestion(q, idx);
                if (gq != null) {
                    out.add(gq);
                    idx++;
                }
                if (out.size() >= wanted) {
                    break;
                }
            }
        } catch (Exception ex) {
            log.error("Parse câu gen lỗi: {}", ex.getMessage());
        }
        return out;
    }

    private GeneratedQuestion toQuestion(JsonNode q, int idx) {
        String question = q.path("question").asText("").trim();
        if (question.isEmpty()) {
            return null;
        }
        List<Map<String, String>> options = new ArrayList<>();
        for (JsonNode opt : q.path("options")) {
            String id = opt.path("id").asText("").trim();
            String text = opt.path("text").asText("").trim();
            if (!id.isEmpty() && !text.isEmpty()) {
                Map<String, String> o = new LinkedHashMap<>();
                o.put("id", id);
                o.put("text", text);
                options.add(o);
            }
        }
        if (options.size() < 2) {
            return null;
        }
        String correctOptionId = q.path("correctOptionId").asText("").trim();
        boolean valid = options.stream().anyMatch(o -> o.get("id").equals(correctOptionId));
        if (!valid) {
            return null;
        }
        String difficulty = q.path("difficulty").asText("medium").trim();
        if (!List.of("easy", "medium", "hard").contains(difficulty)) {
            difficulty = "medium";
        }
        String explanation = q.path("explanationVi").asText("").trim();
        return new GeneratedQuestion(
                "gen-" + idx,
                "multiple_choice",
                "practice",
                difficulty,
                question,
                options,
                correctOptionId,
                explanation
        );
    }

    // ── Prompt + context ─────────────────────────────────────────────────────────

    private static String systemPrompt(int count) {
        return """
                Bạn là giáo viên tiếng Anh tạo câu hỏi trắc nghiệm ôn tập cho người học.
                Dựa HOÀN TOÀN vào nội dung lý thuyết bài học được cung cấp, tạo %d câu hỏi trắc nghiệm MỚI.
                Yêu cầu:
                - Mỗi câu là trắc nghiệm 4 lựa chọn (id: a, b, c, d), CHỈ 1 đáp án đúng.
                - Câu hỏi PHẢI khác với danh sách câu đã có (tránh lặp ý và cách hỏi).
                - Bám sát từ vựng/ngữ pháp/ví dụ trong lý thuyết. Độ khó vừa phải.
                - Câu hỏi có thể bằng tiếng Việt hoặc tiếng Anh; các lựa chọn dùng tiếng Anh khi hỏi về từ/ngữ pháp.
                - explanationVi: giải thích ngắn bằng tiếng Việt vì sao đáp án đúng.
                Chỉ trả về JSON hợp lệ, KHÔNG markdown, KHÔNG giải thích thừa. Cấu trúc bắt buộc:
                {
                  "questions": [
                    {
                      "question": "<nội dung câu hỏi>",
                      "options": [
                        {"id": "a", "text": "..."},
                        {"id": "b", "text": "..."},
                        {"id": "c", "text": "..."},
                        {"id": "d", "text": "..."}
                      ],
                      "correctOptionId": "a",
                      "explanationVi": "<giải thích tiếng Việt>",
                      "difficulty": "easy|medium|hard"
                    }
                  ]
                }""".formatted(count);
    }

    @SuppressWarnings("unchecked")
    private String buildTheoryContext(LearningLesson lesson) {
        Map<String, Object> theory = lesson.getTheoryContent();
        if (theory == null || theory.isEmpty()) {
            return "(Không có lý thuyết chi tiết — dựa vào tiêu đề bài học.)";
        }
        StringBuilder sb = new StringBuilder();

        Object objectives = theory.get("objectives");
        if (objectives instanceof List<?> list && !list.isEmpty()) {
            sb.append("Mục tiêu: ");
            sb.append(String.join("; ", list.stream().map(String::valueOf).toList()));
            sb.append("\n");
        }

        Object grammar = theory.get("grammarHtml");
        if (grammar != null && !String.valueOf(grammar).isBlank()) {
            sb.append("Ngữ pháp: ").append(stripHtml(String.valueOf(grammar))).append("\n");
        }

        Object vocab = theory.get("vocabBlock");
        if (vocab instanceof List<?> list && !list.isEmpty()) {
            sb.append("Từ vựng:\n");
            for (Object item : list) {
                if (item instanceof Map<?, ?> m) {
                    sb.append("- ").append(m.get("word"))
                            .append(" = ").append(m.get("meaningVi"));
                    Object ex = m.get("example");
                    if (ex != null && !String.valueOf(ex).isBlank()) {
                        sb.append(" (vd: ").append(ex).append(")");
                    }
                    sb.append("\n");
                }
            }
        }

        Object examples = theory.get("examples");
        if (examples instanceof List<?> list && !list.isEmpty()) {
            sb.append("Ví dụ:\n");
            for (Object item : list) {
                if (item instanceof Map<?, ?> m) {
                    sb.append("- ").append(m.get("en"));
                    Object vi = m.get("vi");
                    if (vi != null) {
                        sb.append(" — ").append(vi);
                    }
                    sb.append("\n");
                }
            }
        }

        Object tips = theory.get("tips");
        if (tips instanceof List<?> list && !list.isEmpty()) {
            sb.append("Mẹo: ").append(String.join("; ", list.stream().map(String::valueOf).toList()));
            sb.append("\n");
        }

        return sb.length() == 0 ? "(Không có lý thuyết chi tiết.)" : sb.toString();
    }

    private static String buildExistingList(List<String> existing) {
        if (existing == null || existing.isEmpty()) {
            return "(chưa có)";
        }
        List<String> trimmed = existing.size() > MAX_EXISTING
                ? existing.subList(0, MAX_EXISTING)
                : existing;
        StringBuilder sb = new StringBuilder();
        for (String s : trimmed) {
            if (s != null && !s.isBlank()) {
                sb.append("- ").append(s.trim()).append("\n");
            }
        }
        return sb.length() == 0 ? "(chưa có)" : sb.toString();
    }

    private static String stripHtml(String html) {
        return html.replaceAll("<[^>]+>", " ").replaceAll("\\s+", " ").trim();
    }

    private static String nullToEmpty(String s) {
        return s == null ? "" : s;
    }
}
