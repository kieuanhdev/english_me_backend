package com.kiovant.englishme.service;

/**
 * Hằng số config key cho cấu hình AI (app_config). Gom 1 chỗ để tránh
 * magic string lệch nhau giữa service / migration / admin.
 *
 * Quy ước placeholder trong prompt:
 *   AI_PROMPT_CHAT       — chứa 3 lần %s (topic).
 *   AI_PROMPT_SUMMARY    — chứa 1 lần %s (topic).
 *   AI_PROMPT_PRACTICE   — chứa 1 lần %d (số câu).
 *   AI_PROMPT_PRONUN     — không placeholder.
 */
public final class AiConfigKeys {

    private AiConfigKeys() {
    }

    // Prompt
    public static final String PROMPT_CHAT = "AI_PROMPT_CHAT";
    public static final String PROMPT_SUMMARY = "AI_PROMPT_SUMMARY";
    public static final String PROMPT_PRACTICE = "AI_PROMPT_PRACTICE";
    public static final String PROMPT_GRAMMAR_PRACTICE = "AI_PROMPT_GRAMMAR_PRACTICE";
    public static final String PROMPT_PRONUN = "AI_PROMPT_PRONUN";

    // Tham số sinh
    public static final String CHAT_TEMPERATURE = "AI_CHAT_TEMPERATURE";
    public static final String CHAT_MAX_TOKENS = "AI_CHAT_MAX_TOKENS";
    public static final String SUMMARY_MAX_TOKENS = "AI_SUMMARY_MAX_TOKENS";
    public static final String PRACTICE_TEMPERATURE = "AI_PRACTICE_TEMPERATURE";
    public static final String PRACTICE_MAX_TOKENS = "AI_PRACTICE_MAX_TOKENS";
    public static final String PRONUN_MAX_TOKENS = "AI_PRONUN_MAX_TOKENS";

    // Rate limit (dùng chung cho các endpoint AI nặng)
    public static final String RATELIMIT_MAX = "AI_RATELIMIT_MAX";
    public static final String RATELIMIT_WINDOW_SEC = "AI_RATELIMIT_WINDOW_SEC";
}
