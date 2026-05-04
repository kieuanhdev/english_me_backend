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
public class GroqChatService {

    private static final URI GROQ_CHAT_URI = URI.create("https://api.groq.com/openai/v1/chat/completions");
    private static final int HARD_TPM_LIMIT = 8000;
    private static final int SAFE_INPUT_BUDGET = 6000;
    private static final int MIN_COMPLETION_TOKENS = 128;
    private static final int MAX_COMPLETION_TOKENS = 1024;

    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${englishme.ai.groq.api-key:}")
    private String groqApiKey;

    @Value("${englishme.ai.groq.model:openai/gpt-oss-120b}")
    private String model;

    @Value("${englishme.ai.teacher-system-prompt:You are an English teacher. Correct grammar, explain clearly, give practical examples, and keep responses concise and friendly for English learners.}")
    private String teacherSystemPrompt;

    public GroqChatService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(20))
                .build();
    }

    public ChatResponse chat(ChatRequest request) {
        if (groqApiKey == null || groqApiKey.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Missing GROQ API key. Set englishme.ai.groq.api-key or GROQ_API_KEY."
            );
        }
        if (request == null || request.getMessage() == null || request.getMessage().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "message is required");
        }

        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of(
                "role", "system",
                "content", teacherSystemPrompt
        ));

        if (request.getHistory() != null) {
            // Keep only the most recent history first to avoid Groq TPM overflow.
            List<ChatMessageDto> history = request.getHistory();
            int start = Math.max(history.size() - 12, 0);
            for (int i = start; i < history.size(); i++) {
                ChatMessageDto msg = history.get(i);
                if (msg == null || msg.getRole() == null || msg.getContent() == null) {
                    continue;
                }
                String role = msg.getRole().trim().toLowerCase();
                if (!role.equals("user") && !role.equals("assistant")) {
                    continue;
                }
                String content = msg.getContent().trim();
                if (content.isEmpty()) {
                    continue;
                }
                messages.add(Map.of("role", role, "content", truncateText(content, 600)));
            }
        }

        String userMessage = truncateText(request.getMessage().trim(), 1200);
        messages.add(Map.of(
                "role", "user",
                "content", userMessage
        ));

        int promptTokens = estimateTokens(messages);
        while (promptTokens > SAFE_INPUT_BUDGET && messages.size() > 2) {
            // Remove oldest history item, keep system + latest user message.
            messages.remove(1);
            promptTokens = estimateTokens(messages);
        }

        int maxCompletionTokens = Math.min(MAX_COMPLETION_TOKENS, HARD_TPM_LIMIT - promptTokens - 200);
        if (maxCompletionTokens < MIN_COMPLETION_TOKENS) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Input is too long. Please shorten your message or send less chat history."
            );
        }

        Map<String, Object> body = Map.of(
                "model", model,
                "messages", messages,
                "temperature", 1,
                "max_completion_tokens", maxCompletionTokens,
                "top_p", 1,
                "reasoning_effort", "medium",
                "stream", false
        );

        try {
            String jsonBody = objectMapper.writeValueAsString(body);
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(GROQ_CHAT_URI)
                    .timeout(Duration.ofSeconds(60))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + groqApiKey.trim())
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_GATEWAY,
                        "Groq error: HTTP " + response.statusCode() + " - " + response.body()
                );
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode contentNode = root.path("choices").path(0).path("message").path("content");
            String reply = contentNode.isMissingNode() || contentNode.isNull() ? "" : contentNode.asText();
            if (reply.isBlank()) {
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Groq returned empty reply");
            }
            return new ChatResponse(reply, model);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Failed to call Groq: " + ex.getMessage(), ex);
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Failed to call Groq: " + ex.getMessage(), ex);
        }
    }

    private static String truncateText(String input, int maxChars) {
        if (input == null || input.length() <= maxChars) {
            return input;
        }
        return input.substring(0, maxChars);
    }

    private static int estimateTokens(List<Map<String, String>> messages) {
        int chars = 0;
        for (Map<String, String> message : messages) {
            String role = message.get("role");
            String content = message.get("content");
            if (role != null) {
                chars += role.length();
            }
            if (content != null) {
                chars += content.length();
            }
        }
        // Conservative approximation for multilingual text.
        return (chars / 3) + 80;
    }
}
