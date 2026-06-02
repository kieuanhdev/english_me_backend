package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Request tổng kết & nhận xét cả đoạn hội thoại sau khi người học kết thúc.
 *
 * @param topic   chủ đề đã luyện.
 * @param history toàn bộ hội thoại để AI nhận xét phần nói của người học.
 */
public record ConversationSummaryRequest(
        String topic,
        List<ConversationMessageDto> history
) {
}
