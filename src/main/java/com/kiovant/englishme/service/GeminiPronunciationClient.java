package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.List;
import java.util.Map;

/**
 * Chấm phát âm bằng Google Gemini (đa phương thức): gửi FILE AUDIO + câu mẫu,
 * model nghe và ước lượng điểm phát âm từng từ. Khác STT — không chuyển audio
 * thành text rồi so chữ (cách đó bị autocorrect làm sai điểm), mà nghe trực tiếp.
 *
 * Kích hoạt khi `englishme.ai.pronunciation.provider = gemini`.
 * Thiếu key / lỗi -> fallback MockPronunciationClient để demo vẫn chạy.
 *
 * Trả JSON đúng shape mà {@link PronunciationScoringMapper} parse
 * (text_score.word_score_list[].quality_score ...), nên service/mapper không đổi.
 */
@Component
@Primary
@ConditionalOnProperty(
        prefix = "englishme.ai.pronunciation",
        name = "provider",
        havingValue = "gemini"
)
public class GeminiPronunciationClient implements CloudPronunciationClient {

    private static final Logger log = LoggerFactory.getLogger(GeminiPronunciationClient.class);

    private static final String CONFIG_KEY = "GEMINI_API_KEY";
    private static final String GEMINI_URL =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    private final AppConfigService appConfigService;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final MockPronunciationClient fallback;

    public GeminiPronunciationClient(
            AppConfigService appConfigService,
            ObjectMapper objectMapper,
            MockPronunciationClient fallback
    ) {
        this.appConfigService = appConfigService;
        this.objectMapper = objectMapper;
        this.fallback = fallback;
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    }

    @Override
    public JsonNode assess(byte[] audioBytes, String referenceText, String language) {
        String apiKey = appConfigService.getValue(CONFIG_KEY);
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("GEMINI_API_KEY chưa cấu hình — fallback mock");
            return fallback.assess(audioBytes, referenceText, language);
        }
        try {
            JsonNode geminiJson = callGemini(apiKey.trim(), audioBytes, referenceText);
            return toScoringShape(geminiJson, referenceText);
        } catch (Exception ex) {
            log.error("Gemini pronunciation lỗi, fallback mock: {}", ex.getMessage());
            return fallback.assess(audioBytes, referenceText, language);
        }
    }

    private JsonNode callGemini(String apiKey, byte[] audioBytes, String referenceText) throws Exception {
        String base64Audio = Base64.getEncoder().encodeToString(audioBytes);

        String prompt = """
                Bạn là giám khảo chấm phát âm tiếng Anh. Người học đọc to câu mẫu, file audio đính kèm là giọng họ.
                Nghe audio và chấm phát âm SO VỚI câu mẫu. Chú ý âm sai, thiếu từ, trọng âm, độ trôi chảy.
                Chỉ trả JSON hợp lệ, KHÔNG markdown, KHÔNG giải thích. Cấu trúc bắt buộc:
                {
                  "overall": <0-100 điểm tổng>,
                  "pronunciation": <0-100 độ chính xác âm>,
                  "fluency": <0-100 độ trôi chảy>,
                  "words": [
                    { "word": "<từ trong câu mẫu, viết thường>", "score": <0-100 điểm từ này> }
                  ]
                }
                Quy tắc: words liệt kê đúng thứ tự câu mẫu. Từ phát âm sai/thiếu cho điểm thấp.
                Câu mẫu: "%s"
                """.formatted(referenceText);

        Map<String, Object> body = Map.of(
                "contents", List.of(Map.of(
                        "parts", List.of(
                                Map.of("text", prompt),
                                Map.of("inline_data", Map.of(
                                        "mime_type", "audio/mp4",
                                        "data", base64Audio
                                ))
                        )
                )),
                "generationConfig", Map.of(
                        "temperature", 0,
                        "responseMimeType", "application/json"
                )
        );

        URI uri = URI.create(GEMINI_URL + "?key=" + apiKey);
        HttpRequest request = HttpRequest.newBuilder()
                .uri(uri)
                .timeout(Duration.ofSeconds(30))
                .header("Content-Type", "application/json; charset=utf-8")
                .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body), StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response =
                httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("Gemini HTTP " + response.statusCode() + ": " + response.body());
        }

        JsonNode root = objectMapper.readTree(response.body());
        String content = root.path("candidates").path(0)
                .path("content").path("parts").path(0).path("text").asText("");
        if (content.isBlank()) {
            throw new IllegalStateException("Gemini trả nội dung rỗng");
        }
        return objectMapper.readTree(content);
    }

    /** Đổi JSON Gemini -> shape Speechace mà PronunciationScoringMapper đang parse. */
    private JsonNode toScoringShape(JsonNode gemini, String referenceText) {
        int overall = clamp(gemini.path("overall").asInt(0));
        int pronScore = clamp(gemini.path("pronunciation").asInt(overall));
        int fluencyScore = clamp(gemini.path("fluency").asInt(overall));

        ArrayNode wordList = objectMapper.createArrayNode();
        double time = 0.1;
        for (JsonNode w : gemini.path("words")) {
            String token = w.path("word").asText("").trim().toLowerCase();
            if (token.isEmpty()) {
                continue;
            }
            int wordScore = clamp(w.path("score").asInt(overall));
            double end = time + 0.4;
            ObjectNode wordNode = objectMapper.createObjectNode();
            wordNode.put("word", token);
            wordNode.put("quality_score", wordScore);
            wordNode.put("start", Math.round(time * 100.0) / 100.0);
            wordNode.put("end", Math.round(end * 100.0) / 100.0);
            wordList.add(wordNode);
            time = end + 0.05;
        }

        ObjectNode pronunciation = objectMapper.createObjectNode();
        pronunciation.put("score", pronScore);
        ObjectNode fluency = objectMapper.createObjectNode();
        fluency.put("score", fluencyScore);
        ObjectNode textScore = objectMapper.createObjectNode();
        textScore.put("quality_score", overall);
        textScore.set("pronunciation", pronunciation);
        textScore.set("fluency", fluency);
        textScore.set("word_score_list", wordList);
        ObjectNode root = objectMapper.createObjectNode();
        root.set("text_score", textScore);
        return root;
    }

    private static int clamp(int v) {
        return Math.min(Math.max(v, 0), 100);
    }

    @Override
    public String providerName() {
        String apiKey = appConfigService.getValue(CONFIG_KEY);
        if (apiKey == null || apiKey.isBlank()) {
            return fallback.providerName();
        }
        return "gemini";
    }
}
