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
            return buildMockResult(referenceText);
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
        if (apiKey == null || apiKey.isBlank()) {
            return "mock";
        }
        return provider == null ? "unknown" : provider.toLowerCase();
    }

    private JsonNode buildMockResult(String referenceText) {
        String[] words = referenceText.trim().split("\\s+");
        var wordList = objectMapper.createArrayNode();
        double time = 0.1;
        for (int i = 0; i < words.length; i++) {
            String clean = words[i].replaceAll("[^a-zA-Z']", "").toLowerCase();
            if (clean.isEmpty()) {
                continue;
            }
            int wordScore = 55 + (int) (Math.random() * 40) + (clean.length() > 3 ? 5 : 0);
            if (wordScore > 100) wordScore = 100;
            double end = time + 0.3 + Math.random() * 0.3;
            var wordNode = objectMapper.createObjectNode();
            wordNode.put("word", clean);
            wordNode.put("quality_score", wordScore);
            wordNode.put("start", Math.round(time * 100.0) / 100.0);
            wordNode.put("end", Math.round(end * 100.0) / 100.0);
            wordList.add(wordNode);
            time = end + 0.05;
        }

        int avgScore = words.length == 0 ? 80 : Math.min(100, 55 + (int) (Math.random() * 35));
        var pronunciation = objectMapper.createObjectNode();
        pronunciation.put("score", avgScore - 2 + (int) (Math.random() * 5));
        var fluency = objectMapper.createObjectNode();
        fluency.put("score", avgScore - 3 + (int) (Math.random() * 5));
        var textScore = objectMapper.createObjectNode();
        textScore.put("quality_score", avgScore);
        textScore.set("pronunciation", pronunciation);
        textScore.set("fluency", fluency);
        textScore.set("word_score_list", wordList);
        var root = objectMapper.createObjectNode();
        root.set("text_score", textScore);
        return root;
    }
}
