package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.http.client.ClientHttpRequestFactoryBuilder;
import org.springframework.boot.http.client.ClientHttpRequestFactorySettings;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Client LLM dùng chung cho mọi chức năng AI (chat hội thoại, sinh câu hỏi, chấm text).
 *
 * Dùng chuẩn API OpenAI-compatible (/chat/completions) — phủ DeepSeek, OpenAI, Groq,
 * Together, OpenRouter... Provider/model/key/baseUrl đọc từ app_config lúc runtime,
 * nên admin đổi model không cần build lại.
 *
 * Config keys (app_config):
 *   LLM_BASE_URL — gốc API (vd https://api.deepseek.com). Tự nối "/chat/completions".
 *   LLM_API_KEY  — Bearer token.
 *   LLM_MODEL    — tên model (vd deepseek-chat, gpt-4o-mini).
 *
 * Mọi service AI nên hỏi {@link #isConfigured()} trước; chưa cấu hình -> tự fallback.
 */
@Service
public class LlmClient {

    private static final Logger log = LoggerFactory.getLogger(LlmClient.class);

    public static final String KEY_BASE_URL = "LLM_BASE_URL";
    public static final String KEY_API_KEY = "LLM_API_KEY";
    public static final String KEY_MODEL = "LLM_MODEL";

    private final AppConfigService appConfigService;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    public LlmClient(AppConfigService appConfigService, ObjectMapper objectMapper) {
        this.appConfigService = appConfigService;
        this.objectMapper = objectMapper;
        ClientHttpRequestFactorySettings settings = ClientHttpRequestFactorySettings.defaults()
                .withConnectTimeout(Duration.ofSeconds(5))
                .withReadTimeout(Duration.ofSeconds(30));
        this.restClient = RestClient.builder()
                .requestFactory(ClientHttpRequestFactoryBuilder.detect().build(settings))
                .build();
    }

    /** Đã đủ key + base url + model chưa. Service dùng để quyết fallback. */
    public boolean isConfigured() {
        return notBlank(appConfigService.getValue(KEY_API_KEY))
                && notBlank(appConfigService.getValue(KEY_BASE_URL))
                && notBlank(appConfigService.getValue(KEY_MODEL));
    }

    /**
     * Gọi chat completion, trả về NỘI DUNG text của message đầu tiên (choices[0].message.content).
     *
     * @param messages    danh sách {role, content}.
     * @param temperature 0..1.
     * @param maxTokens   giới hạn token trả về.
     * @param jsonMode    true -> ép response_format json_object.
     * @return nội dung text; rỗng nếu lỗi/không có.
     */
    public String chatCompletion(List<Map<String, String>> messages, double temperature, int maxTokens, boolean jsonMode) {
        String baseUrl = appConfigService.getValue(KEY_BASE_URL);
        String apiKey = appConfigService.getValue(KEY_API_KEY);
        String model = appConfigService.getValue(KEY_MODEL);
        if (!notBlank(baseUrl) || !notBlank(apiKey) || !notBlank(model)) {
            log.warn("LLM chưa cấu hình đủ (base/key/model) — trả rỗng");
            return "";
        }

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model.trim());
        body.put("messages", messages);
        body.put("temperature", temperature);
        body.put("max_tokens", maxTokens);
        body.put("stream", false);
        if (jsonMode) {
            body.put("response_format", Map.of("type", "json_object"));
        }

        try {
            String raw = restClient.post()
                    .uri(chatCompletionsUri(baseUrl))
                    .header("Authorization", "Bearer " + apiKey.trim())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);

            JsonNode root = objectMapper.readTree(raw);
            return root.path("choices").path(0).path("message").path("content").asText("").trim();
        } catch (Exception ex) {
            log.error("LLM chatCompletion lỗi: {}", ex.getMessage());
            return "";
        }
    }

    /**
     * Test kết nối với cấu hình cho trước (chưa lưu DB cũng test được).
     * Gửi 1 prompt cực ngắn, trả kết quả pass/fail + thông điệp.
     */
    public TestResult testConnection(String baseUrl, String apiKey, String model) {
        if (!notBlank(baseUrl) || !notBlank(apiKey) || !notBlank(model)) {
            return new TestResult(false, "Thiếu base URL, API key hoặc model.");
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", model.trim());
        body.put("messages", List.of(Map.of("role", "user", "content", "ping")));
        body.put("max_tokens", 1);
        body.put("stream", false);
        try {
            String raw = restClient.post()
                    .uri(chatCompletionsUri(baseUrl))
                    .header("Authorization", "Bearer " + apiKey.trim())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);

            JsonNode root = objectMapper.readTree(raw);
            if (root.has("error")) {
                String msg = root.path("error").path("message").asText("Provider trả lỗi.");
                return new TestResult(false, msg);
            }
            if (root.path("choices").isArray() && !root.path("choices").isEmpty()) {
                return new TestResult(true, "Kết nối thành công. Model phản hồi hợp lệ.");
            }
            return new TestResult(false, "Phản hồi không đúng định dạng OpenAI-compatible.");
        } catch (Exception ex) {
            return new TestResult(false, "Kết nối thất bại: " + rootMessage(ex));
        }
    }

    /** Nối base url + /chat/completions, chịu cả khi admin dán sẵn đường dẫn đầy đủ. */
    private static String chatCompletionsUri(String baseUrl) {
        String b = baseUrl.trim();
        while (b.endsWith("/")) {
            b = b.substring(0, b.length() - 1);
        }
        if (b.endsWith("/chat/completions")) {
            return b;
        }
        // Cho phép dán cả ".../v1" hoặc gốc; cứ nối đuôi chuẩn.
        return b + "/chat/completions";
    }

    private static boolean notBlank(String s) {
        return s != null && !s.isBlank();
    }

    private static String rootMessage(Throwable ex) {
        Throwable t = ex;
        while (t.getCause() != null && t.getCause() != t) {
            t = t.getCause();
        }
        String m = t.getMessage();
        return m == null ? t.getClass().getSimpleName() : m;
    }

    /** Kết quả test kết nối hiển thị cho admin. */
    public record TestResult(boolean success, String message) {
    }
}
