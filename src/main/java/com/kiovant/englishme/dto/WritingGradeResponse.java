package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Kết quả AI chấm bài viết + XP đã cộng (skill = writing).
 *
 * @param score           điểm tổng 0-100.
 * @param correctedEssay  bản viết đã sửa lỗi.
 * @param summary         nhận xét ngắn (tiếng Việt).
 * @param strengths       điểm mạnh.
 * @param improvements    điểm cần cải thiện (ngữ pháp/từ vựng/bố cục).
 * @param vocabSuggestions từ/cụm nên học kèm nghĩa.
 * @param encouragement   câu động viên.
 */
public record WritingGradeResponse(
        int score,
        String correctedEssay,
        String summary,
        List<String> strengths,
        List<String> improvements,
        List<String> vocabSuggestions,
        String encouragement,
        int xpEarned,
        long totalXp,
        int dailyEarnedXp,
        boolean streakUpdated,
        List<XpGrantResult.Bonus> bonuses
) {
}
