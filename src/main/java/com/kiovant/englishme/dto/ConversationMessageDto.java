package com.kiovant.englishme.dto;

/**
 * Một tin nhắn trong đoạn hội thoại luyện nói với AI.
 *
 * @param role    "user" (người học) hoặc "assistant" (AI).
 * @param content nội dung tiếng Anh của tin nhắn.
 */
public record ConversationMessageDto(String role, String content) {
}
