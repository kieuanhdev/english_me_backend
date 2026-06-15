package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Request luyện Viết với gia sư AI (stateless): FE gửi toàn bộ lịch sử mỗi lượt.
 * Tái dùng {@link ConversationMessageDto} (role user|assistant, content). History
 * rỗng → AI mở đầu, mời người học viết.
 */
public record WritingChatRequest(
        List<ConversationMessageDto> history
) {
}
