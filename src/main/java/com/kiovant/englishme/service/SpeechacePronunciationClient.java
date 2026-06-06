package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * Speechace pronunciation provider. Kích hoạt khi
 * `englishme.ai.pronunciation.provider = speechace` (mặc định).
 *
 * Nếu không có api-key, fallback tự động sang MockPronunciationClient ở
 * cấu hình bean — service consumer không cần biết.
 */
@Component
@Primary
@ConditionalOnProperty(
        prefix = "englishme.ai.pronunciation",
        name = "provider",
        havingValue = "speechace",
        matchIfMissing = true
)
public class SpeechacePronunciationClient implements CloudPronunciationClient {

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;
    private final MockPronunciationClient fallback;

    @Value("${englishme.ai.pronunciation.api-key:}")
    private String apiKey;

    @Value("${englishme.ai.pronunciation.timeout-ms:15000}")
    private int timeoutMs;

    @Value("${englishme.ai.pronunciation.speechace-url:https://api.speechace.co/api/scoring/text/v9/json}")
    private String speechaceUrl;

    @Value("${englishme.ai.pronunciation.max-retries:1}")
    private int maxRetries;

    public SpeechacePronunciationClient(ObjectMapper objectMapper, MockPronunciationClient fallback) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
        this.fallback = fallback;
    }

    @Override
    public JsonNode assess(byte[] audioBytes, String referenceText, String language) {
        if (apiKey == null || apiKey.isBlank()) {
            return fallback.assess(audioBytes, referenceText, language);
        }

        // Speechace /scoring/text/v9/json yêu cầu multipart/form-data với file âm thanh thật
        // (user_audio_file), KHÔNG phải JSON base64. Gửi sai sẽ luôn lỗi → rơi về mock.
        String dialect = (language == null || language.isBlank()) ? "en-us" : language.toLowerCase();
        String boundary = "----englishme" + Integer.toHexString(audioBytes.length) + referenceText.length();
        byte[] multipartBody;
        try {
            multipartBody = buildMultipartBody(boundary, referenceText, dialect, audioBytes);
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Cannot build pronunciation request body.");
        }

        int attempts = Math.max(maxRetries, 0) + 1;
        for (int attempt = 1; attempt <= attempts; attempt++) {
            try {
                URI uri = URI.create(speechaceUrl + "?key=" + apiKey.trim());
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(uri)
                        .timeout(Duration.ofMillis(Math.max(timeoutMs, 3000)))
                        .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                        .POST(HttpRequest.BodyPublishers.ofByteArray(multipartBody))
                        .build();

                HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
                if (response.statusCode() < 200 || response.statusCode() >= 300) {
                    if (attempt < attempts && response.statusCode() >= 500) {
                        continue;
                    }
                    throw new ResponseStatusException(
                            HttpStatus.BAD_GATEWAY,
                            "Pronunciation provider error: HTTP " + response.statusCode()
                    );
                }
                return objectMapper.readTree(response.body());
            } catch (InterruptedException ex) {
                Thread.currentThread().interrupt();
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Pronunciation provider interrupted.");
            } catch (IOException ex) {
                if (attempt == attempts) {
                    throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Pronunciation provider I/O failure.");
                }
            }
        }
        throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Pronunciation provider retry exhausted.");
    }

    /** Dựng body multipart/form-data: text, dialect (field) + user_audio_file (file). */
    private byte[] buildMultipartBody(String boundary, String text, String dialect, byte[] audioBytes) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        String dash = "--";
        String crlf = "\r\n";

        writeFormField(out, boundary, "text", text);
        writeFormField(out, boundary, "dialect", dialect);

        // Phần file: filename + content-type. Speechace nhận m4a/wav/mp3/webm.
        out.write((dash + boundary + crlf).getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Disposition: form-data; name=\"user_audio_file\"; filename=\"recording.m4a\"" + crlf)
                .getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Type: application/octet-stream" + crlf + crlf).getBytes(StandardCharsets.UTF_8));
        out.write(audioBytes);
        out.write(crlf.getBytes(StandardCharsets.UTF_8));

        out.write((dash + boundary + dash + crlf).getBytes(StandardCharsets.UTF_8));
        return out.toByteArray();
    }

    private void writeFormField(ByteArrayOutputStream out, String boundary, String name, String value) throws IOException {
        String crlf = "\r\n";
        out.write(("--" + boundary + crlf).getBytes(StandardCharsets.UTF_8));
        out.write(("Content-Disposition: form-data; name=\"" + name + "\"" + crlf + crlf)
                .getBytes(StandardCharsets.UTF_8));
        out.write(value.getBytes(StandardCharsets.UTF_8));
        out.write(crlf.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public String providerName() {
        if (apiKey == null || apiKey.isBlank()) {
            return fallback.providerName();
        }
        return "speechace";
    }
}
