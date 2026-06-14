package com.kiovant.englishme.dto;

import java.util.Map;

/**
 * Yêu cầu sinh thêm câu luyện tập CÙNG DẠNG với câu user vừa làm SAI.
 *
 * @param lessonId     bài học gốc (UUID) — lấy lý thuyết làm ngữ cảnh.
 * @param exerciseType loại bài tập cần sinh: multiple_choice | fill_blank | error_correction.
 * @param wrongContent nội dung câu user vừa sai (chính là content của exercise gốc) — AI bám
 *                     đúng kiểu lỗi này để sinh câu tương tự. Có thể null/rỗng.
 * @param count        số câu muốn sinh (clamp 1..5 ở service).
 */
public record GrammarPracticeRequest(
        String lessonId,
        String exerciseType,
        Map<String, Object> wrongContent,
        int count
) {
}
