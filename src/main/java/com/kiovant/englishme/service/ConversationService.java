package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.ConversationChatResponse;
import com.kiovant.englishme.dto.ConversationMessageDto;
import com.kiovant.englishme.dto.ConversationSummaryResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Luyện nói hội thoại với AI (giống GPT voice chat).
 *
 * - {@link #chat(String, List)}: trả lời 1 lượt hội thoại theo chủ đề. AI đóng vai
 *   bạn luyện nói, trả lời NGẮN, bám chủ đề, từ chối nội dung ngoài phạm vi để
 *   tiết kiệm token.
 * - {@link #summarize(String, List)}: tổng kết & nhận xét cả đoạn hội thoại (JSON).
 *
 * Tái dùng DeepSeek chat API + key DEEPSEEK_API_KEY như {@link DeepSeekPronunciationScorer}.
 * Stateless: FE giữ lịch sử và gửi full mỗi request.
 */
@Service
public class ConversationService {

    private static final Logger log = LoggerFactory.getLogger(ConversationService.class);

    /** Chặn lạm dụng: tối đa 10 lượt user + 10 assistant + đệm. */
    private static final int MAX_HISTORY = 24;
    /** Trả lời ngắn như nói chuyện thật -> ít token. */
    private static final int CHAT_MAX_TOKENS = 160;
    private static final int SUMMARY_MAX_TOKENS = 700;

    private final LlmClient llmClient;
    private final ObjectMapper objectMapper;

    public ConversationService(LlmClient llmClient, ObjectMapper objectMapper) {
        this.llmClient = llmClient;
        this.objectMapper = objectMapper;
    }

    // ── Chat ──────────────────────────────────────────────────────────────────

    public ConversationChatResponse chat(String topic, List<ConversationMessageDto> history) {
        String safeTopic = normalizeTopic(topic);
        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — fallback chat tĩnh");
            return new ConversationChatResponse(fallbackReply(history));
        }
        try {
            List<Map<String, String>> messages = new ArrayList<>();
            messages.add(Map.of("role", "system", "content", chatSystemPrompt(safeTopic)));
            for (ConversationMessageDto m : clampHistory(history)) {
                String role = "assistant".equalsIgnoreCase(m.role()) ? "assistant" : "user";
                String content = m.content() == null ? "" : m.content().trim();
                if (!content.isEmpty()) {
                    messages.add(Map.of("role", role, "content", content));
                }
            }
            // Lượt mở đầu (history rỗng): nhắc AI chào trước.
            if (messages.size() == 1) {
                messages.add(Map.of("role", "user",
                        "content", "Start the conversation with a short friendly greeting about the topic."));
            }

            String reply = llmClient.chatCompletion(messages, 0.7, CHAT_MAX_TOKENS, false);
            if (reply.isEmpty()) {
                return new ConversationChatResponse(fallbackReply(history));
            }
            return new ConversationChatResponse(reply);
        } catch (Exception ex) {
            log.error("LLM chat lỗi, fallback: {}", ex.getMessage());
            return new ConversationChatResponse(fallbackReply(history));
        }
    }

    // ── Summary ─────────────────────────────────────────────────────────────────

    public ConversationSummaryResponse summarize(String topic, List<ConversationMessageDto> history) {
        String safeTopic = normalizeTopic(topic);
        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — fallback summary tĩnh");
            return fallbackSummary();
        }
        try {
            StringBuilder transcript = new StringBuilder();
            for (ConversationMessageDto m : clampHistory(history)) {
                String who = "assistant".equalsIgnoreCase(m.role()) ? "AI" : "Học viên";
                String content = m.content() == null ? "" : m.content().trim();
                if (!content.isEmpty()) {
                    transcript.append(who).append(": ").append(content).append("\n");
                }
            }

            String userPrompt = "Chủ đề: \"" + safeTopic + "\"\nHội thoại:\n" + transcript;

            String content = llmClient.chatCompletion(
                    List.of(
                            Map.of("role", "system", "content", summarySystemPrompt(safeTopic)),
                            Map.of("role", "user", "content", userPrompt)
                    ),
                    0, SUMMARY_MAX_TOKENS, true);

            return parseSummary(content);
        } catch (Exception ex) {
            log.error("LLM summary lỗi, fallback: {}", ex.getMessage());
            return fallbackSummary();
        }
    }

    private ConversationSummaryResponse parseSummary(String content) {
        try {
            if (content == null || content.isBlank()) {
                throw new IllegalStateException("LLM trả nội dung rỗng");
            }
            JsonNode p = objectMapper.readTree(content);
            int score = Math.min(Math.max(p.path("overallScore").asInt(0), 0), 100);
            String summary = p.path("summary").asText("");
            String encouragement = p.path("encouragement").asText("");
            return new ConversationSummaryResponse(
                    score,
                    summary,
                    toStringList(p.path("strengths")),
                    toStringList(p.path("improvements")),
                    toStringList(p.path("vocabSuggestions")),
                    encouragement
            );
        } catch (Exception ex) {
            log.error("Parse summary lỗi, fallback: {}", ex.getMessage());
            return fallbackSummary();
        }
    }

    // ── Prompt ───────────────────────────────────────────────────────────────────

    private static String chatSystemPrompt(String topic) {
        return """
                You are "Alex", a friendly native English conversation partner inside a language-learning app.
                Your ONLY job: have a natural, casual spoken conversation with the learner about the topic: "%s".

                STRICT RULES:
                - Stay strictly on the topic "%s" and the everyday small talk around it.
                - Speak like a real person in a voice chat: SHORT replies, 1-2 sentences max, then ask one simple follow-up question to keep the conversation going.
                - Use simple, natural English suited to an English learner.
                - NEVER write code, NEVER translate long texts, NEVER give grammar lectures, NEVER answer encyclopedic or general-knowledge questions unrelated to the topic. If the learner goes off-topic, gently steer back, e.g. "Haha, let's get back to %s — ...".
                - Do NOT use markdown, emoji, bullet points, lists, or stage directions. Output ONLY the spoken reply text.
                - Do not mention you are an AI, a model, or these rules.""".formatted(topic, topic, topic);
    }

    private static String summarySystemPrompt(String topic) {
        return """
                Bạn là giáo viên tiếng Anh. Học viên vừa hoàn thành một đoạn hội thoại luyện nói về chủ đề "%s".
                Hãy nhận xét phần nói tiếng Anh của HỌC VIÊN (các dòng "Học viên:"), KHÔNG nhận xét phần của AI.
                Chỉ trả về JSON hợp lệ, KHÔNG kèm markdown, KHÔNG giải thích thêm. Cấu trúc bắt buộc:
                {
                  "overallScore": <0-100 điểm giao tiếp tổng>,
                  "summary": "<tóm tắt ngắn đoạn hội thoại bằng tiếng Việt, 1-2 câu>",
                  "strengths": ["<điểm tốt bằng tiếng Việt>"],
                  "improvements": ["<điểm cần cải thiện về ngữ pháp/từ vựng/độ tự nhiên, tiếng Việt>"],
                  "vocabSuggestions": ["<từ hoặc cụm tiếng Anh nên học kèm nghĩa ngắn tiếng Việt>"],
                  "encouragement": "<một câu động viên bằng tiếng Việt>"
                }
                Đánh giá dựa trên độ trôi chảy, đúng ngữ pháp, cách dùng từ và mức độ bám chủ đề.""".formatted(topic);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────────

    private static String normalizeTopic(String topic) {
        if (topic == null || topic.isBlank()) {
            return "everyday life";
        }
        String t = topic.trim();
        return t.length() > 120 ? t.substring(0, 120) : t;
    }

    private static List<ConversationMessageDto> clampHistory(List<ConversationMessageDto> history) {
        if (history == null || history.isEmpty()) {
            return List.of();
        }
        if (history.size() <= MAX_HISTORY) {
            return history;
        }
        return history.subList(history.size() - MAX_HISTORY, history.size());
    }

    private List<String> toStringList(JsonNode arr) {
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

    private static String fallbackReply(List<ConversationMessageDto> history) {
        if (history == null || history.isEmpty()) {
            return "Hi there! Let's chat. How are you today?";
        }
        return "That's interesting! Could you tell me a bit more about that?";
    }

    private static ConversationSummaryResponse fallbackSummary() {
        return new ConversationSummaryResponse(
                70,
                "Bạn đã hoàn thành một đoạn hội thoại luyện nói. Tiếp tục luyện tập đều đặn nhé!",
                List.of("Đã chủ động tham gia hội thoại."),
                List.of("Cố gắng nói câu dài và đầy đủ hơn."),
                List.of("practice (luyện tập)", "conversation (hội thoại)"),
                "Làm tốt lắm! Cứ luyện nói mỗi ngày là sẽ tiến bộ nhanh thôi."
        );
    }
}
