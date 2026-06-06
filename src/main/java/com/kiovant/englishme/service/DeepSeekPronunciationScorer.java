package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationErrorDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Chấm phát âm dựa trên transcript (text người dùng nói được từ STT) so với câu mẫu.
 *
 * - Dùng DeepSeek chat API để so sánh ngữ nghĩa + từng từ, trả điểm và gợi ý.
 * - Khi thiếu API key hoặc DeepSeek lỗi: fallback chấm bằng Levenshtein theo từ
 *   để app vẫn hoạt động khi demo.
 */
@Service
public class DeepSeekPronunciationScorer {

    private static final Logger log = LoggerFactory.getLogger(DeepSeekPronunciationScorer.class);

    private static final int DEFAULT_MAX_TOKENS = 800;

    static final String DEFAULT_PROMPT = """
            Bạn là giám khảo chấm phát âm tiếng Anh. Người học đọc một câu mẫu, hệ thống nhận dạng giọng nói
            đã chuyển thành văn bản. Hãy so sánh văn bản người học nói được với câu mẫu và chấm điểm.
            Chỉ trả về JSON hợp lệ, KHÔNG kèm giải thích, KHÔNG markdown. Cấu trúc bắt buộc:
            {
              "score": <0-100 điểm tổng>,
              "accuracy": <0-100 độ chính xác từ ngữ>,
              "fluency": <0-100 độ trôi chảy ước lượng>,
              "completeness": <0-100 tỉ lệ đọc đủ câu>,
              "overallComment": "<nhận xét tổng quát bằng tiếng Việt, 1-2 câu>",
              "errors": [
                { "word": "<từ sai trong câu mẫu>", "position": <chỉ số từ, bắt đầu 0>,
                  "expected": "<từ mẫu>", "actual": "<từ người học nói, rỗng nếu thiếu>",
                  "suggestion": "<gợi ý luyện bằng tiếng Việt>" }
              ]
            }
            Quy tắc: nếu người học nói đúng hết thì errors là mảng rỗng. Điểm phản ánh mức khớp với câu mẫu.""";

    private final LlmClient llmClient;
    private final AppConfigService appConfigService;
    private final ObjectMapper objectMapper;

    public DeepSeekPronunciationScorer(LlmClient llmClient, AppConfigService appConfigService, ObjectMapper objectMapper) {
        this.llmClient = llmClient;
        this.appConfigService = appConfigService;
        this.objectMapper = objectMapper;
    }

    public PronunciationAssessResponse score(String referenceText, String spokenText) {
        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — fallback Levenshtein");
            return fallbackScore(referenceText, spokenText);
        }
        try {
            return scoreWithLlm(referenceText, spokenText);
        } catch (Exception ex) {
            log.error("LLM scoring lỗi, fallback Levenshtein: {}", ex.getMessage());
            return fallbackScore(referenceText, spokenText);
        }
    }

    // ── LLM ────────────────────────────────────────────────────────────

    private PronunciationAssessResponse scoreWithLlm(String referenceText, String spokenText) {
        String systemPrompt = appConfigService.getOr(AiConfigKeys.PROMPT_PRONUN, DEFAULT_PROMPT);

        String userPrompt = "Câu mẫu: \"" + referenceText + "\"\n"
                + "Người học nói được: \"" + spokenText + "\"";

        int maxTokens = appConfigService.getIntOr(AiConfigKeys.PRONUN_MAX_TOKENS, DEFAULT_MAX_TOKENS);
        String content = llmClient.chatCompletion(
                List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", userPrompt)
                ),
                0, maxTokens, true);

        return parseLlmResponse(content, referenceText, spokenText);
    }

    private PronunciationAssessResponse parseLlmResponse(String content, String referenceText, String spokenText) {
        try {
            if (content == null || content.isBlank()) {
                throw new IllegalStateException("LLM trả nội dung rỗng");
            }
            JsonNode parsed = objectMapper.readTree(content);

            double score = clamp(parsed.path("score").asDouble(0));
            double accuracy = clamp(parsed.path("accuracy").asDouble(score));
            double fluency = clamp(parsed.path("fluency").asDouble(score));
            double completeness = clamp(parsed.path("completeness").asDouble(score));
            String comment = parsed.path("overallComment").asText("");

            List<PronunciationErrorDto> errors = new ArrayList<>();
            for (JsonNode err : parsed.path("errors")) {
                String word = err.path("word").asText("").trim();
                if (word.isEmpty()) {
                    continue;
                }
                errors.add(new PronunciationErrorDto(
                        word,
                        err.path("position").asInt(0),
                        err.path("expected").asText(word),
                        err.path("actual").asText(""),
                        err.path("suggestion").asText("Luyện lại từ \"" + word + "\".")
                ));
            }
            return new PronunciationAssessResponse(
                    score, accuracy, fluency, completeness, spokenText, errors,
                    comment.isBlank() ? null : comment
            );
        } catch (Exception ex) {
            log.error("Parse DeepSeek response lỗi, fallback: {}", ex.getMessage());
            return fallbackScore(referenceText, spokenText);
        }
    }

    // ── Fallback: Levenshtein theo từ ─────────────────────────────────────────

    private PronunciationAssessResponse fallbackScore(String referenceText, String spokenText) {
        List<String> ref = tokenize(referenceText);
        List<String> spoken = tokenize(spokenText);

        int distance = wordLevenshtein(ref, spoken);
        int maxLen = Math.max(ref.size(), spoken.size());
        double similarity = maxLen == 0 ? 1.0 : 1.0 - ((double) distance / maxLen);
        double accuracy = clamp(similarity * 100);

        long matched = ref.stream().filter(spoken::contains).count();
        double completeness = ref.isEmpty() ? 0 : clamp((double) matched / ref.size() * 100);
        double score = (accuracy * 0.7) + (completeness * 0.3);

        List<PronunciationErrorDto> errors = new ArrayList<>();
        for (int i = 0; i < ref.size(); i++) {
            String word = ref.get(i);
            if (!spoken.contains(word)) {
                errors.add(new PronunciationErrorDto(
                        word, i, word,
                        i < spoken.size() ? spoken.get(i) : "",
                        "Cần luyện lại từ \"" + word + "\". Đọc chậm, nhấn rõ trọng âm."
                ));
            }
        }
        String comment = buildComment(errors.size(), ref.size());
        return new PronunciationAssessResponse(score, accuracy, accuracy, completeness, spokenText, errors, comment);
    }

    private static List<String> tokenize(String text) {
        if (text == null) {
            return List.of();
        }
        List<String> out = new ArrayList<>();
        for (String w : text.toLowerCase().replaceAll("[^a-z0-9'\\s]", " ").split("\\s+")) {
            if (!w.isBlank()) {
                out.add(w);
            }
        }
        return out;
    }

    private static int wordLevenshtein(List<String> a, List<String> b) {
        if (a.isEmpty()) return b.size();
        if (b.isEmpty()) return a.size();
        int[] prev = new int[b.size() + 1];
        int[] curr = new int[b.size() + 1];
        for (int j = 0; j <= b.size(); j++) prev[j] = j;
        for (int i = 1; i <= a.size(); i++) {
            curr[0] = i;
            for (int j = 1; j <= b.size(); j++) {
                int cost = a.get(i - 1).equals(b.get(j - 1)) ? 0 : 1;
                curr[j] = Math.min(Math.min(prev[j] + 1, curr[j - 1] + 1), prev[j - 1] + cost);
            }
            int[] tmp = prev;
            prev = curr;
            curr = tmp;
        }
        return prev[b.size()];
    }

    private static String buildComment(int errorCount, int totalWords) {
        if (errorCount == 0) {
            return "Đọc rất khớp với câu mẫu. Tiếp tục luyện tập để duy trì phong độ.";
        }
        double rate = totalWords == 0 ? 0 : (double) errorCount / totalWords;
        if (rate <= 0.2) {
            return "Khá tốt. Cần cải thiện một vài từ nhỏ.";
        }
        if (rate <= 0.5) {
            return "Mức trung bình. Nên luyện lại các từ bị sai và đọc cả câu 2-3 lần.";
        }
        return "Cần luyện thêm. Chia câu thành đoạn ngắn và luyện từng đoạn.";
    }

    private static double clamp(double value) {
        return Math.min(Math.max(value, 0), 100);
    }
}
