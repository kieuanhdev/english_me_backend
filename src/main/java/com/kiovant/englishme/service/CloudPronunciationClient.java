package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.Map;

@Component
public class CloudPronunciationClient {

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${englishme.ai.pronunciation.provider:speechace}")
    private String provider;

    @Value("${englishme.ai.pronunciation.api-key:}")
    private String apiKey;

    @Value("${englishme.ai.pronunciation.timeout-ms:15000}")
    private int timeoutMs;

    @Value("${englishme.ai.pronunciation.speechace-url:https://api.speechace.co/api/scoring/text/v9/json}")
    private String speechaceUrl;

    @Value("${englishme.ai.pronunciation.max-retries:1}")
    private int maxRetries;

    public CloudPronunciationClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    }

    public JsonNode assess(byte[] audioBytes, String referenceText, String language) {
        if (!"speechace".equalsIgnoreCase(provider)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported pronunciation provider: " + provider);
        }
        if (apiKey == null || apiKey.isBlank()) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Missing pronunciation API key.");
        }

        String base64Audio = Base64.getEncoder().encodeToString(audioBytes);
        Map<String, Object> body = Map.of(
                "text", referenceText,
                "user_audio_file", "data:audio/webm;base64," + base64Audio,
                "question_info", Map.of("question_type", "reading"),
                "dialect", (language == null || language.isBlank()) ? "en-us" : language.toLowerCase()
        );

        int attempts = Math.max(maxRetries, 0) + 1;
        for (int attempt = 1; attempt <= attempts; attempt++) {
            try {
                URI uri = URI.create(speechaceUrl + "?key=" + apiKey.trim());
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(uri)
                        .timeout(Duration.ofMillis(Math.max(timeoutMs, 3000)))
                        .header("Content-Type", "application/json; charset=utf-8")
                        .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body), StandardCharsets.UTF_8))
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

    public String providerName() {
        return provider == null ? "unknown" : provider.toLowerCase();
    }
}
