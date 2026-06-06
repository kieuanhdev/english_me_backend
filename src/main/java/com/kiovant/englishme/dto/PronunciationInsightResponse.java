package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Tổng hợp lịch sử phát âm per-user thành insight cá nhân hóa: điểm trung bình,
 * các từ phát âm yếu nhất, phân bố mức độ lỗi. Tận dụng pronunciation_word_feedback
 * đã lưu sẵn mỗi lần assess.
 */
public record PronunciationInsightResponse(
        long totalAttempts,
        int averageScore,
        List<WeakWord> weakestWords,
        IssueBreakdown issueBreakdown
) {

    /**
     * Một từ user thường phát âm yếu, gộp qua nhiều lần thử.
     *
     * @param avgScore      điểm TB của từ (0 với feedback từ DeepSeek — xem lastIssueType).
     * @param attempts      số lần từ này xuất hiện trong feedback.
     * @param lastIssueType "good" | "minor" | "critical" — mức lỗi gần nhất.
     * @param suggestion    gợi ý luyện gần nhất (có thể null nếu provider không trả).
     */
    public record WeakWord(
            String word,
            int avgScore,
            long attempts,
            String lastIssueType,
            String suggestion
    ) {}

    /** Đếm số feedback theo mức độ lỗi. */
    public record IssueBreakdown(
            long good,
            long minor,
            long critical
    ) {}
}
