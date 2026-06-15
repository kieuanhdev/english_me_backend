package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.WritingGradeResponse;
import com.kiovant.englishme.dto.WritingPromptResponse;
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
import java.util.UUID;

/**
 * Luyện Viết theo đề bài với AI (Mục tiêu 5 đề cương: trợ lý AI + sửa lỗi ngữ
 * pháp tự động). Luồng: AI sinh đề theo CEFR → người học viết → AI chấm (điểm +
 * bản sửa + nhận xét) và cộng XP theo điểm thực (skill = writing).
 *
 * Stateless: không lưu phiên ở DB. FE giữ promptId + đề, gửi lại khi nộp.
 * Tái dùng {@link LlmClient}; chưa cấu hình LLM → fallback tĩnh.
 */
@Service
public class WritingService {

    private static final Logger log = LoggerFactory.getLogger(WritingService.class);

    private static final double DEFAULT_PROMPT_TEMPERATURE = 0.8;
    private static final int DEFAULT_PROMPT_MAX_TOKENS = 220;
    private static final int DEFAULT_GRADE_MAX_TOKENS = 700;
    private static final String SKILL = "writing";
    /** XP tối đa cho 1 bài điểm 100; thực nhận = round(MAX_XP × score/100). */
    private static final int MAX_XP = 25;

    private static final String PROMPT_SYSTEM = """
            You generate ONE short English WRITING task for a learner at CEFR level %s.
            Return ONLY valid JSON, no markdown, structure:
            {
              "title": "<short Vietnamese title, 2-5 words>",
              "prompt": "<the writing task written in Vietnamese, telling the learner what to write in English; specify expected length in sentences>",
              "minWords": <suggested minimum word count as integer>
            }
            The task must suit level %s: simple everyday topics for A1/A2, opinions/experiences for B1/B2, abstract/argumentative for C1/C2.""";

    private static final String GRADE_SYSTEM = """
            You are an English writing examiner. The learner (CEFR level %s) was given this task:
            "%s"
            Grade ONLY the learner's essay below. Return ONLY valid JSON, no markdown, structure:
            {
              "score": <0-100 overall writing score>,
              "correctedEssay": "<the learner's essay rewritten with grammar/spelling/word-choice fixed, keeping their ideas>",
              "summary": "<1-2 sentence overall comment in Vietnamese>",
              "strengths": ["<strength in Vietnamese>"],
              "improvements": ["<concrete improvement in Vietnamese: grammar/vocabulary/structure>"],
              "vocabSuggestions": ["<English word or phrase + short Vietnamese meaning>"],
              "encouragement": "<one encouraging sentence in Vietnamese>"
            }
            Judge grammar, vocabulary, coherence, task achievement and relevance to the task.""";

    private final LlmClient llmClient;
    private final AppConfigService appConfigService;
    private final UserRepository userRepository;
    private final XpService xpService;
    private final ObjectMapper objectMapper;

    public WritingService(LlmClient llmClient,
                          AppConfigService appConfigService,
                          UserRepository userRepository,
                          XpService xpService,
                          ObjectMapper objectMapper) {
        this.llmClient = llmClient;
        this.appConfigService = appConfigService;
        this.userRepository = userRepository;
        this.xpService = xpService;
        this.objectMapper = objectMapper;
    }

    // ── Sinh đề ──────────────────────────────────────────────────────────────

    public WritingPromptResponse generatePrompt(String firebaseUid, String level) {
        loadUser(firebaseUid);
        String lv = normalizeLevel(level);
        String promptId = UUID.randomUUID().toString();

        if (!llmClient.isConfigured()) {
            return fallbackPrompt(promptId, lv);
        }
        try {
            String content = llmClient.chatCompletion(
                    List.of(Map.of("role", "system", "content", PROMPT_SYSTEM.formatted(lv, lv))),
                    appConfigService.getDoubleOr(AiConfigKeys.CHAT_TEMPERATURE, DEFAULT_PROMPT_TEMPERATURE),
                    DEFAULT_PROMPT_MAX_TOKENS,
                    true);
            if (content == null || content.isBlank()) {
                return fallbackPrompt(promptId, lv);
            }
            JsonNode p = objectMapper.readTree(content);
            String title = p.path("title").asText("Bài viết");
            String prompt = p.path("prompt").asText("");
            int minWords = Math.max(0, p.path("minWords").asInt(0));
            if (prompt.isBlank()) {
                return fallbackPrompt(promptId, lv);
            }
            return new WritingPromptResponse(promptId, lv, title, prompt, minWords);
        } catch (Exception ex) {
            log.error("LLM sinh đề viết lỗi, fallback: {}", ex.getMessage());
            return fallbackPrompt(promptId, lv);
        }
    }

    // ── Chấm bài ─────────────────────────────────────────────────────────────

    @Transactional
    public WritingGradeResponse grade(String firebaseUid, String promptId, String prompt, String level, String essay) {
        User user = loadUser(firebaseUid);
        if (promptId == null || promptId.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "promptId is required");
        }
        if (essay == null || essay.trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "essay is required");
        }
        String lv = normalizeLevel(level);
        String safePrompt = prompt == null ? "" : prompt.trim();

        GradeResult g = llmClient.isConfigured()
                ? gradeWithLlm(lv, safePrompt, essay.trim())
                : fallbackGrade();

        // XP theo điểm thực; idempotent theo promptId (nộp lại cùng bài không cộng thêm).
        int amount = Math.round(MAX_XP * (g.score / 100f));
        XpGrantResult xp = xpService.grant(
                user.getId(),
                amount,
                "writing",
                promptId,
                "writing:" + promptId + ":grade",
                Map.of("score", g.score),
                SKILL
        );

        return new WritingGradeResponse(
                g.score, g.correctedEssay, g.summary, g.strengths, g.improvements,
                g.vocabSuggestions, g.encouragement,
                xp.xpEarned(), xp.totalXp(), xp.dailyEarnedXp(), xp.streakUpdated(), xp.bonuses()
        );
    }

    private GradeResult gradeWithLlm(String level, String prompt, String essay) {
        try {
            String content = llmClient.chatCompletion(
                    List.of(
                            Map.of("role", "system", "content", GRADE_SYSTEM.formatted(level, prompt)),
                            Map.of("role", "user", "content", essay)
                    ),
                    0,
                    appConfigService.getIntOr(AiConfigKeys.SUMMARY_MAX_TOKENS, DEFAULT_GRADE_MAX_TOKENS),
                    true);
            if (content == null || content.isBlank()) {
                return fallbackGrade();
            }
            JsonNode p = objectMapper.readTree(content);
            int score = Math.min(Math.max(p.path("score").asInt(0), 0), 100);
            return new GradeResult(
                    score,
                    p.path("correctedEssay").asText(essay),
                    p.path("summary").asText(""),
                    toStringList(p.path("strengths")),
                    toStringList(p.path("improvements")),
                    toStringList(p.path("vocabSuggestions")),
                    p.path("encouragement").asText("")
            );
        } catch (Exception ex) {
            log.error("LLM chấm bài viết lỗi, fallback: {}", ex.getMessage());
            return fallbackGrade();
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static String normalizeLevel(String level) {
        if (level == null || level.isBlank()) return "A1";
        String lv = level.trim().toUpperCase();
        return switch (lv) {
            case "A1", "A2", "B1", "B2", "C1", "C2" -> lv;
            default -> "A1";
        };
    }

    private List<String> toStringList(JsonNode arr) {
        List<String> out = new ArrayList<>();
        if (arr != null && arr.isArray()) {
            for (JsonNode n : arr) {
                String s = n.asText("").trim();
                if (!s.isEmpty()) out.add(s);
            }
        }
        return out;
    }

    private WritingPromptResponse fallbackPrompt(String promptId, String level) {
        return new WritingPromptResponse(
                promptId, level, "Giới thiệu bản thân",
                "Viết 3-4 câu tiếng Anh giới thiệu về bản thân: tên, tuổi, sở thích và công việc/học tập.",
                30
        );
    }

    private GradeResult fallbackGrade() {
        return new GradeResult(
                70,
                "",
                "Bạn đã hoàn thành bài viết. Tiếp tục luyện tập để tiến bộ nhé!",
                List.of("Đã hoàn thành bài viết theo yêu cầu."),
                List.of("Cố gắng viết câu đầy đủ và đúng ngữ pháp hơn."),
                List.of("improve (cải thiện)", "practice (luyện tập)"),
                "Làm tốt lắm! Cứ viết mỗi ngày là sẽ tiến bộ nhanh thôi."
        );
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User profile not found. Please sync account first."));
    }

    /** Kết quả chấm nội bộ trước khi gắn XP. */
    private record GradeResult(
            int score, String correctedEssay, String summary,
            List<String> strengths, List<String> improvements,
            List<String> vocabSuggestions, String encouragement) {
    }
}
