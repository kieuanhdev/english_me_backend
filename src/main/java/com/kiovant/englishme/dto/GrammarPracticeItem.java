package com.kiovant.englishme.dto;

import java.util.Map;

/**
 * Một câu luyện tập AI sinh ra, khớp ĐÚNG schema mà FE đang render cho 3 loại bài tập
 * (multiple_choice | fill_blank | error_correction). FE parse thẳng như GrammarExercise:
 * {@code content} chứa toàn bộ trường riêng theo từng loại (question/options/answer/sentence/
 * segments/correction/explain_vi...).
 *
 * @param id            định danh tạm (gen-0, gen-1...).
 * @param exerciseType  loại bài tập, trùng yêu cầu.
 * @param content       payload đầy đủ để FE render + tự chấm local.
 */
public record GrammarPracticeItem(
        String id,
        String exerciseType,
        Map<String, Object> content
) {
}
