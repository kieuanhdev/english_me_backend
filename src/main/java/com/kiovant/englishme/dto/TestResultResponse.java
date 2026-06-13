package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record TestResultResponse(
        UUID sessionId,
        String resultLevel,
        int score,
        int totalQuestions,
        // Ability estimate cuối của phiên CAT (IRT 1PL θ) → vẽ biểu đồ trong báo cáo.
        double finalTheta,
        // Cờ tín hiệu UI: học viên kịch trần C1 và có dấu hiệu giỏi hơn (gợi ý C2).
        boolean canGoHigherThanC1,
        // Thông báo gợi ý làm bài kiểm tra lên cấp (chỉ set khi canGoHigherThanC1 == true).
        String aboveLevelMessage,
        List<AnswerReview> review
) {
    public record AnswerReview(
            UUID questionId,
            String question,
            String selectedAnswer,
            String correctAnswer,
            boolean isCorrect,
            String explanation
    ) {}
}
