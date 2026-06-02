package com.kiovant.englishme.dto;

/**
 * Câu trả lời tiếng Anh của AI cho một lượt hội thoại.
 *
 * @param reply nội dung AI nói (FE sẽ đọc bằng TTS).
 */
public record ConversationChatResponse(String reply) {
}
