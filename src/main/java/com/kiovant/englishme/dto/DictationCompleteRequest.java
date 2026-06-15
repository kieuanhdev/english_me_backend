package com.kiovant.englishme.dto;

/**
 * Body khi hoàn thành phiên dictation. Client đã tự chấm (có đáp án), gửi lên
 * số câu đúng / tổng để server tính & lưu XP. sessionId = khóa idempotency.
 */
public record DictationCompleteRequest(
        String sessionId,
        int correct,
        int total
) {
}
