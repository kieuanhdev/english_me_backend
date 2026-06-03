package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

/**
 * Một câu hỏi trắc nghiệm do AI sinh ra. Field khớp với CurriculumActivity ở FE
 * để FE parse thẳng bằng CurriculumActivity.fromJson.
 *
 * @param id              định danh tạm (gen-0, gen-1...).
 * @param type            luôn "multiple_choice".
 * @param phase           luôn "practice".
 * @param difficulty      easy | medium | hard.
 * @param question        nội dung câu hỏi.
 * @param options         danh sách lựa chọn [{id, text}].
 * @param correctOptionId id đáp án đúng.
 * @param explanationVi   giải thích tiếng Việt.
 */
public record GeneratedQuestion(
        String id,
        String type,
        String phase,
        String difficulty,
        String question,
        List<Map<String, String>> options,
        String correctOptionId,
        String explanationVi
) {
}
