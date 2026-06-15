package com.kiovant.englishme.dto;

/**
 * Đề bài viết do AI sinh theo level. promptId dùng làm khóa idempotency khi chấm.
 *
 * @param promptId   định danh phiên (server cấp).
 * @param level      CEFR của đề.
 * @param title      tiêu đề ngắn (vd "Cuối tuần của bạn").
 * @param prompt     yêu cầu viết (tiếng Việt, rõ số câu/độ dài mong đợi).
 * @param minWords   số từ tối thiểu gợi ý (0 nếu không áp).
 */
public record WritingPromptResponse(
        String promptId,
        String level,
        String title,
        String prompt,
        int minWords
) {
}
