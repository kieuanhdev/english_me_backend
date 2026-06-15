package com.kiovant.englishme.dto;

/**
 * Hoàn thành phiên luyện Viết. sessionId = khóa idempotency; turns = số lượt
 * người học đã viết (dùng để tính XP). Không lưu nội dung chat ở DB.
 */
public record WritingCompleteRequest(
        String sessionId,
        int turns
) {
}
