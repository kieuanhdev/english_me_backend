package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Request luyện nói hội thoại (stateless): FE gửi toàn bộ lịch sử mỗi lượt.
 *
 * @param topic   chủ đề hội thoại (có sẵn hoặc người dùng tự nhập).
 * @param history toàn bộ hội thoại tới hiện tại; phần tử cuối là câu user vừa nói.
 *                Khi rỗng -> AI chào mở đầu theo chủ đề.
 */
public record ConversationChatRequest(
        String topic,
        List<ConversationMessageDto> history
) {
}
