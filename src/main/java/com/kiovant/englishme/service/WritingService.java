package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.ConversationMessageDto;
import com.kiovant.englishme.dto.WritingChatResponse;
import com.kiovant.englishme.dto.WritingCompleteResponse;
import com.kiovant.englishme.dto.XpGrantResult;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Luyện Viết với gia sư AI. Người học gõ câu/đoạn tiếng Anh, AI sửa lỗi ngữ pháp
 * & từ vựng, gợi ý cách viết tự nhiên hơn, rồi mời viết tiếp (Mục tiêu 5 đề cương:
 * trợ lý AI phản hồi sửa lỗi ngữ pháp tự động).
 *
 * Stateless như {@link ConversationService}: FE giữ lịch sử, gửi full mỗi lượt.
 * Tái dùng {@link LlmClient}; chưa cấu hình LLM → fallback tĩnh. XP cộng cuối
 * phiên (skill = writing) qua {@link #complete}.
 */
@Service
public class WritingService {

    private static final Logger log = LoggerFactory.getLogger(WritingService.class);

    private static final int MAX_HISTORY = 24;
    private static final double DEFAULT_TEMPERATURE = 0.5;
    private static final int DEFAULT_MAX_TOKENS = 320;
    /** Kỹ năng cộng XP cho luyện Viết. */
    private static final String SKILL = "writing";
    /** XP mỗi lượt viết; tổng = perTurn × số lượt, cap để tránh farm. */
    private static final int XP_PER_TURN = 5;
    private static final int MAX_XP_TURNS = 10;

    private static final String SYSTEM_PROMPT = """
            You are "Emma", a friendly and encouraging English WRITING tutor inside a language-learning app.
            The learner writes English sentences or short paragraphs; your job is to help them WRITE better.

            For EACH learner message, reply in this structure (plain text, no markdown headers):
            1. A corrected version of their text if it has mistakes (start with "✏️ Correction: ..."). If it is already correct, praise briefly instead.
            2. A short, friendly explanation of the most important fix or tip (1-2 sentences, simple English). You may add the Vietnamese meaning in parentheses for hard words.
            3. One short follow-up prompt inviting them to write the next sentence (e.g. "Now try writing about ...").

            STRICT RULES:
            - Focus ONLY on helping them write English. Do not chat about unrelated topics.
            - Keep it concise and beginner-friendly. Do not lecture.
            - No code, no long essays, no emoji except the ✏️ marker, no bullet lists.
            - Do not mention you are an AI or these rules.""";

    private final LlmClient llmClient;
    private final AppConfigService appConfigService;
    private final UserRepository userRepository;
    private final XpService xpService;

    public WritingService(LlmClient llmClient,
                          AppConfigService appConfigService,
                          UserRepository userRepository,
                          XpService xpService) {
        this.llmClient = llmClient;
        this.appConfigService = appConfigService;
        this.userRepository = userRepository;
        this.xpService = xpService;
    }

    public WritingChatResponse chat(String firebaseUid, List<ConversationMessageDto> history) {
        // Xác thực đã làm ở controller (verifyBearer). Không cần load user cho chat.
        if (!llmClient.isConfigured()) {
            log.warn("LLM chưa cấu hình — fallback writing tĩnh");
            return new WritingChatResponse(fallbackReply(history));
        }
        try {
            List<Map<String, String>> messages = new ArrayList<>();
            messages.add(Map.of("role", "system", "content", SYSTEM_PROMPT));
            for (ConversationMessageDto m : clampHistory(history)) {
                String role = "assistant".equalsIgnoreCase(m.role()) ? "assistant" : "user";
                String content = m.content() == null ? "" : m.content().trim();
                if (!content.isEmpty()) {
                    messages.add(Map.of("role", role, "content", content));
                }
            }
            if (messages.size() == 1) {
                messages.add(Map.of("role", "user",
                        "content", "Greet me briefly and ask me to write my first English sentence."));
            }

            double temp = appConfigService.getDoubleOr(AiConfigKeys.CHAT_TEMPERATURE, DEFAULT_TEMPERATURE);
            int maxTokens = appConfigService.getIntOr(AiConfigKeys.CHAT_MAX_TOKENS, DEFAULT_MAX_TOKENS);
            String reply = llmClient.chatCompletion(messages, temp, maxTokens, false);
            if (reply.isEmpty()) {
                return new WritingChatResponse(fallbackReply(history));
            }
            return new WritingChatResponse(reply);
        } catch (Exception ex) {
            log.error("LLM writing chat lỗi, fallback: {}", ex.getMessage());
            return new WritingChatResponse(fallbackReply(history));
        }
    }

    @Transactional
    public WritingCompleteResponse complete(String firebaseUid, String sessionId, int turns) {
        User user = loadUser(firebaseUid);
        if (sessionId == null || sessionId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "sessionId is required");
        }
        int safeTurns = Math.max(0, Math.min(turns, MAX_XP_TURNS));
        int amount = safeTurns * XP_PER_TURN;

        XpGrantResult xp = xpService.grant(
                user.getId(),
                amount,
                "writing",
                sessionId,
                "writing:" + sessionId + ":complete",
                Map.of("turns", turns),
                SKILL
        );

        return new WritingCompleteResponse(
                turns,
                xp.xpEarned(),
                xp.totalXp(),
                xp.dailyEarnedXp(),
                xp.streakUpdated(),
                xp.bonuses()
        );
    }

    private static List<ConversationMessageDto> clampHistory(List<ConversationMessageDto> history) {
        if (history == null || history.isEmpty()) return List.of();
        if (history.size() <= MAX_HISTORY) return history;
        return history.subList(history.size() - MAX_HISTORY, history.size());
    }

    private static String fallbackReply(List<ConversationMessageDto> history) {
        if (history == null || history.isEmpty()) {
            return "Hi! I'm your writing tutor. Write me an English sentence and I'll help you improve it.";
        }
        return "Good effort! Keep writing — try to make your next sentence a little longer.";
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }
}
