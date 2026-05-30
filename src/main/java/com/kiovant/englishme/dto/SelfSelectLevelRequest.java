package com.kiovant.englishme.dto;

/**
 * Request khi học viên tự chọn trình độ CEFR mà không làm bài kiểm tra đầu vào.
 * level phải thuộc {A1, A2, B1, B2, C1, C2}.
 */
public record SelfSelectLevelRequest(
        String level
) {}
