package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.GrammarPracticeItem;
import com.kiovant.englishme.entity.GrammarLesson;
import com.kiovant.englishme.repository.GrammarLessonRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Sinh thêm câu luyện tập CÙNG DẠNG LỖI với câu người học vừa làm sai.
 *
 * Luồng: FE gửi {lessonId, exerciseType, wrongContent (câu vừa sai)} -> service lấy lý thuyết
 * bài học + câu sai làm ngữ cảnh -> LLM sinh {count} câu MỚI cùng loại, cùng kiểu lỗi để luyện.
 *
 * Tái dùng {@link LlmClient} (OpenAI-compatible, cấu hình runtime) như các service AI khác.
 * Chưa cấu hình key / lỗi / parse fail -> trả list rỗng (FE báo thử lại). Không bao giờ ném 5xx
 * vì lý do AI: AI là tính năng phụ trợ, hỏng thì degrade chứ không chặn người học đọc lý thuyết.
 */
@Service
public class GrammarPracticeService {

    private static final Logger log = LoggerFactory.getLogger(GrammarPracticeService.class);

    private static final int MAX_COUNT = 5;
    private static final int DEFAULT_COUNT = 3;
    private static final double DEFAULT_TEMPERATURE = 0.8;
    private static final int DEFAULT_MAX_TOKENS = 1400;

    private static final List<String> SUPPORTED_TYPES =
            List.of("multiple_choice", "fill_blank", "error_correction");

    private final LlmClient llmClient;
    private final AppConfigService appConfigService;
    private final GrammarLessonRepository grammarLessonRepository;
    private final ObjectMapper objectMapper;

    public GrammarPracticeService(
            LlmClient llmClient,
            AppConfigService appConfigService,
            GrammarLessonRepository grammarLessonRepository,
            ObjectMapper objectMapper
    ) {
        this.llmClient = llmClient;
        this.appConfigService = appConfigService;
        this.grammarLessonRepository = grammarLessonRepository;
        this.objectMapper = objectMapper;
    }

    public List<GrammarPracticeItem> generateSimilar(
            String lessonId, String exerciseType, Map<String, Object> wrongContent, int count) {

        String type = normalizeType(exerciseType);
        int n = (count <= 0 || count > MAX_COUNT) ? DEFAULT_COUNT : count;

        GrammarLesson lesson = grammarLessonRepository.findById(parseUuid(lessonId))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Grammar lesson not found"));

        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — không gen được câu luyện ngữ pháp");
            return List.of();
        }

        try {
            String theory = buildTheoryContext(lesson);
            String wrong = buildWrongContext(wrongContent);

            String userPrompt = "Tiêu đề bài học: " + nullToEmpty(lesson.getTitle()) + "\n"
                    + "Lý thuyết bài học:\n" + theory + "\n\n"
                    + "Người học vừa làm SAI câu sau (cùng loại \"" + type + "\"):\n" + wrong + "\n\n"
                    + "Hãy tạo " + n + " câu MỚI loại \"" + type + "\" nhắm đúng kiểu lỗi này để luyện thêm.";

            double temp = appConfigService.getDoubleOr(AiConfigKeys.PRACTICE_TEMPERATURE, DEFAULT_TEMPERATURE);
            int maxTokens = appConfigService.getIntOr(AiConfigKeys.PRACTICE_MAX_TOKENS, DEFAULT_MAX_TOKENS);

            String content = llmClient.chatCompletion(
                    List.of(
                            Map.of("role", "system", "content", systemPrompt(type, n)),
                            Map.of("role", "user", "content", userPrompt)
                    ),
                    temp, maxTokens, true);

            return parse(content, type, n);
        } catch (Exception ex) {
            log.error("Gen câu luyện ngữ pháp lỗi: {}", ex.getMessage());
            return List.of();
        }
    }

    // ── Parse + validate theo từng loại ──────────────────────────────────────────

    private List<GrammarPracticeItem> parse(String content, String type, int wanted) {
        List<GrammarPracticeItem> out = new ArrayList<>();
        try {
            if (content == null || content.isBlank()) {
                return out;
            }
            JsonNode root = objectMapper.readTree(content);
            JsonNode items = root.path("items");
            if (!items.isArray()) {
                return out;
            }
            int idx = 0;
            for (JsonNode item : items) {
                Map<String, Object> validated = toContent(item, type);
                if (validated != null) {
                    out.add(new GrammarPracticeItem("gen-" + idx, type, validated));
                    idx++;
                }
                if (out.size() >= wanted) {
                    break;
                }
            }
        } catch (Exception ex) {
            log.error("Parse câu luyện ngữ pháp lỗi: {}", ex.getMessage());
        }
        return out;
    }

    /** Trả content hợp lệ cho FE render; null nếu câu không đạt schema -> bỏ qua. */
    private Map<String, Object> toContent(JsonNode item, String type) {
        return switch (type) {
            case "multiple_choice" -> toMultipleChoice(item);
            case "fill_blank" -> toFillBlank(item);
            case "error_correction" -> toErrorCorrection(item);
            default -> null;
        };
    }

    private Map<String, Object> toMultipleChoice(JsonNode item) {
        String question = item.path("question").asText("").trim();
        List<String> options = toStringList(item.path("options"));
        String answer = item.path("answer").asText("").trim();
        if (question.isEmpty() || options.size() < 2 || !options.contains(answer)) {
            return null;
        }
        Map<String, Object> c = new LinkedHashMap<>();
        c.put("type", "multiple_choice");
        c.put("question", question);
        c.put("options", options);
        c.put("answer", answer);
        c.put("explain_vi", item.path("explain_vi").asText("").trim());
        return c;
    }

    private Map<String, Object> toFillBlank(JsonNode item) {
        String sentence = item.path("sentence").asText("").trim();
        String answer = item.path("answer").asText("").trim();
        // FE tách chỗ trống bằng "___"; bắt buộc câu phải có placeholder.
        if (sentence.isEmpty() || !sentence.contains("___") || answer.isEmpty()) {
            return null;
        }
        Map<String, Object> c = new LinkedHashMap<>();
        c.put("type", "fill_blank");
        c.put("sentence", sentence);
        c.put("answer", answer);
        c.put("hints", toStringList(item.path("hints")));
        c.put("explain_vi", item.path("explain_vi").asText("").trim());
        return c;
    }

    private Map<String, Object> toErrorCorrection(JsonNode item) {
        List<String> segments = toStringList(item.path("segments"));
        String answer = item.path("answer").asText("").trim();
        // answer phải là một segment cụ thể (phần bị sai), nếu không FE không highlight đúng.
        if (segments.size() < 2 || !segments.contains(answer)) {
            return null;
        }
        Map<String, Object> c = new LinkedHashMap<>();
        c.put("type", "error_correction");
        c.put("instruction", item.path("instruction").asText("Tìm phần sai trong câu dưới đây:").trim());
        c.put("segments", segments);
        c.put("answer", answer);
        c.put("correction", item.path("correction").asText("").trim());
        c.put("explain_vi", item.path("explain_vi").asText("").trim());
        return c;
    }

    // ── Prompt ───────────────────────────────────────────────────────────────────

    static final String DEFAULT_PROMPT = """
            Bạn là giáo viên tiếng Anh tạo bài tập luyện tập cá nhân hóa cho người học Việt Nam.
            Người học vừa làm SAI một câu. Hãy tạo %1$d câu bài tập MỚI loại "%2$s" nhắm ĐÚNG kiểu lỗi
            mà người học vừa mắc, dựa trên lý thuyết bài học được cung cấp. Câu mới phải KHÁC câu đã sai
            (đổi từ vựng/ngữ cảnh) nhưng cùng điểm ngữ pháp và cùng bẫy lỗi.
            Chỉ trả về JSON hợp lệ, KHÔNG markdown, KHÔNG giải thích thừa.

            Cấu trúc theo từng loại "%2$s":

            - multiple_choice: mỗi item gồm
              {"question":"<câu hỏi, dùng ___ cho chỗ trống nếu cần>",
               "options":["...","...","...","..."], "answer":"<đúng 1 phần tử trong options>",
               "explain_vi":"<giải thích tiếng Việt vì sao đúng>"}

            - fill_blank: mỗi item gồm
              {"sentence":"<câu tiếng Anh có đúng MỘT chỗ trống ghi là ___>",
               "answer":"<từ/cụm điền vào>", "hints":["<gợi ý>","..."],
               "explain_vi":"<giải thích tiếng Việt>"}

            - error_correction: mỗi item gồm
              {"instruction":"Tìm phần sai trong câu dưới đây:",
               "segments":["<mảnh 1>","<mảnh 2>","..."],
               "answer":"<đúng MỘT phần tử trong segments — phần bị sai>",
               "correction":"<phần đúng thay thế>", "explain_vi":"<giải thích tiếng Việt>"}

            Bọc tất cả trong:
            {"items":[ <các item theo đúng loại "%2$s"> ]}""";

    private String systemPrompt(String type, int count) {
        String tpl = appConfigService.getOr(AiConfigKeys.PROMPT_GRAMMAR_PRACTICE, DEFAULT_PROMPT);
        try {
            return tpl.formatted(count, type);
        } catch (Exception ex) {
            log.warn("Prompt grammar practice sai placeholder, dùng default: {}", ex.getMessage());
            return DEFAULT_PROMPT.formatted(count, type);
        }
    }

    // ── Context builders ──────────────────────────────────────────────────────────

    private String buildTheoryContext(GrammarLesson lesson) {
        StringBuilder sb = new StringBuilder();
        appendIfPresent(sb, "Giải thích", lesson.getExplanationVi());
        appendIfPresent(sb, "Khi nào dùng", lesson.getWhenToUseVi());
        appendIfPresent(sb, "Mẹo", lesson.getTipsVi());

        List<Map<String, Object>> formulas = lesson.getFormulas();
        if (formulas != null && !formulas.isEmpty()) {
            sb.append("Công thức:\n");
            for (Map<String, Object> f : formulas) {
                sb.append("- ").append(f.get("label")).append(": ").append(f.get("structure")).append("\n");
            }
        }

        List<Map<String, Object>> examples = lesson.getExamples();
        if (examples != null && !examples.isEmpty()) {
            sb.append("Ví dụ:\n");
            for (Map<String, Object> e : examples) {
                sb.append("- ").append(e.get("en"));
                Object vi = e.get("vi");
                if (vi != null) {
                    sb.append(" — ").append(vi);
                }
                sb.append("\n");
            }
        }

        return sb.length() == 0 ? "(Không có lý thuyết chi tiết — dựa vào tiêu đề bài học.)" : sb.toString();
    }

    private static String buildWrongContext(Map<String, Object> wrong) {
        if (wrong == null || wrong.isEmpty()) {
            return "(Không có nội dung câu sai cụ thể — chỉ cần bám lý thuyết và loại bài tập.)";
        }
        // Liệt kê các trường hữu ích để AI thấy đúng kiểu lỗi, tránh dump nguyên JSON thô.
        StringBuilder sb = new StringBuilder();
        appendField(sb, "Câu hỏi", wrong.get("question"));
        appendField(sb, "Câu", wrong.get("sentence"));
        appendField(sb, "Lựa chọn", wrong.get("options"));
        appendField(sb, "Mảnh câu", wrong.get("segments"));
        appendField(sb, "Đáp án đúng", wrong.get("answer"));
        appendField(sb, "Phần sửa", wrong.get("correction"));
        appendField(sb, "Giải thích", wrong.get("explain_vi"));
        return sb.length() == 0 ? "(Không rõ nội dung câu sai.)" : sb.toString();
    }

    private static void appendField(StringBuilder sb, String label, Object value) {
        if (value != null && !String.valueOf(value).isBlank()) {
            sb.append(label).append(": ").append(value).append("\n");
        }
    }

    private static void appendIfPresent(StringBuilder sb, String label, String value) {
        if (value != null && !value.isBlank()) {
            sb.append(label).append(": ").append(value.trim()).append("\n");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────────

    private static List<String> toStringList(JsonNode arr) {
        List<String> out = new ArrayList<>();
        if (arr != null && arr.isArray()) {
            for (JsonNode n : arr) {
                String s = n.asText("").trim();
                if (!s.isEmpty()) {
                    out.add(s);
                }
            }
        }
        return out;
    }

    private static String normalizeType(String type) {
        String t = type == null ? "" : type.trim().toLowerCase();
        if (!SUPPORTED_TYPES.contains(t)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "exerciseType phải là một trong " + SUPPORTED_TYPES);
        }
        return t;
    }

    private static UUID parseUuid(String raw) {
        try {
            return UUID.fromString(raw);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "lessonId must be a valid UUID");
        }
    }

    private static String nullToEmpty(String s) {
        return s == null ? "" : s;
    }
}
