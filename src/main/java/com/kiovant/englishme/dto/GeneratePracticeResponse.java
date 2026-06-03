package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Kết quả sinh thêm câu hỏi luyện tập. Rỗng nếu thiếu API key hoặc AI lỗi.
 */
public record GeneratePracticeResponse(List<GeneratedQuestion> questions) {
}
