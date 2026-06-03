package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Request sinh thêm câu hỏi luyện tập (AI gen) cho một lesson.
 *
 * @param existingQuestions text các câu hỏi đã có/đã gen (để AI tránh tạo trùng).
 * @param count             số câu cần tạo (mặc định 5 nếu &lt;= 0).
 */
public record GeneratePracticeRequest(
        List<String> existingQuestions,
        int count
) {
}
