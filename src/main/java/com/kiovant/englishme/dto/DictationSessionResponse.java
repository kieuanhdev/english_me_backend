package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Phiên dictation: sessionId do server cấp (dùng làm khóa idempotency khi
 * complete), kèm danh sách câu. Không lưu DB phiên — client tự theo dõi tiến độ.
 */
public record DictationSessionResponse(
        String sessionId,
        String level,
        int total,
        List<DictationSentenceResponse> sentences
) {
}
