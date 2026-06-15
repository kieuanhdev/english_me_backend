package com.kiovant.englishme.dto;

/**
 * Nộp bài viết để AI chấm.
 *
 * @param promptId  định danh đề (từ {@link WritingPromptResponse}) — khóa idempotency XP.
 * @param prompt    đề bài (FE gửi lại để AI có ngữ cảnh chấm; tránh lưu phiên ở DB).
 * @param level     CEFR của đề.
 * @param essay     bài viết tiếng Anh của người học.
 */
public record WritingGradeRequest(
        String promptId,
        String prompt,
        String level,
        String essay
) {
}
