package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Kết quả tổng kết đoạn hội thoại: điểm + nhận xét bằng tiếng Việt.
 *
 * @param overallScore     điểm giao tiếp tổng 0-100.
 * @param summary          tóm tắt ngắn đoạn hội thoại.
 * @param strengths        các điểm tốt.
 * @param improvements     các điểm cần cải thiện (ngữ pháp/từ vựng/độ tự nhiên).
 * @param vocabSuggestions từ/cụm tiếng Anh nên học thêm.
 * @param encouragement    câu động viên.
 */
public record ConversationSummaryResponse(
        int overallScore,
        String summary,
        List<String> strengths,
        List<String> improvements,
        List<String> vocabSuggestions,
        String encouragement
) {
}
