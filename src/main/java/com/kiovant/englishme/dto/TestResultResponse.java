package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record TestResultResponse(
        UUID sessionId,
        String resultLevel,
        int score,
        int totalQuestions,
        // Cờ tín hiệu UI: học viên đã kịch trần B2 và có dấu hiệu giỏi hơn B2.
        // KHÔNG đổi resultLevel (vẫn "B2"). Xem HE_THONG_KIEM_TRA_TRINH_DO.md §A.3.
        boolean canGoHigherThanB2,
        // Thông báo gợi ý làm bài kiểm tra lên cấp (chỉ set khi canGoHigherThanB2 == true).
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
