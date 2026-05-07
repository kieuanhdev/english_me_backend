package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.ChatMessageDto;
import com.kiovant.englishme.dto.ChatRequest;
import com.kiovant.englishme.dto.ChatResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class DeepSeekChatService {

    private static final URI DEEPSEEK_CHAT_URI = URI.create("https://api.deepseek.com/v1/chat/completions");
    private static final int MAX_HISTORY = 20;
    private static final int MAX_COMPLETION_TOKENS = 2048;

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${englishme.ai.deepseek.api-key:}")
    private String apiKey;

    @Value("${englishme.ai.deepseek.model:deepseek-chat}")
    private String model;

    @Value("${englishme.ai.teacher-system-prompt:You are an English teacher. Correct grammar, explain clearly, give practical examples, and keep responses concise and friendly for English learners.}")
    private String teacherSystemPrompt;

    public DeepSeekChatService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(20))
                .build();
    }

    public ChatResponse chat(ChatRequest request) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Missing DeepSeek API key. Set englishme.ai.deepseek.api-key or DEEPSEEK_API_KEY."
            );
        }
        if (request == null || request.message() == null || request.message().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "message is required");
        }

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of(
                "role", "system",
                "content", teacherSystemPrompt
        ));

        if (request.history() != null) {
            List<ChatMessageDto> history = request.history();
            int start = Math.max(history.size() - MAX_HISTORY, 0);
            for (int i = start; i < history.size(); i++) {
                ChatMessageDto msg = history.get(i);
                if (msg == null || msg.role() == null || msg.content() == null) {
                    continue;
                }
                String role = msg.role().trim().toLowerCase();
                if (!role.equals("user") && !role.equals("assistant")) {
                    continue;
                }
                String content = msg.content().trim();
                if (content.isEmpty()) {
                    continue;
                }
                messages.add(Map.of("role", role, "content", truncateText(content, 600)));
            }
        }

        String userMessage = truncateText(request.message().trim(), 2000);
        messages.add(Map.of(
                "role", "user",
                "content", userMessage
        ));

        Map<String, Object> body = Map.of(
                "model", model,
                "messages", messages,
                "temperature", 0.7,
                "max_tokens", MAX_COMPLETION_TOKENS,
                "stream", false
        );

        try {
            String jsonBody = objectMapper.writeValueAsString(body);
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(DEEPSEEK_CHAT_URI)
                    .timeout(Duration.ofSeconds(60))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + apiKey.trim())
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_GATEWAY,
                        "DeepSeek error: HTTP " + response.statusCode() + " - " + response.body()
                );
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode contentNode = root.path("choices").path(0).path("message").path("content");
            String reply = contentNode.isMissingNode() || contentNode.isNull() ? "" : contentNode.asText();
            if (reply.isBlank()) {
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "DeepSeek returned empty reply");
            }
            return new ChatResponse(reply, model);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Failed to call DeepSeek: " + ex.getMessage(), ex);
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Failed to call DeepSeek: " + ex.getMessage(), ex);
        }
    }

    private static String truncateText(String input, int maxChars) {
        if (input == null || input.length() <= maxChars) {
            return input;
        }
        return input.substring(0, maxChars);
    }
}
