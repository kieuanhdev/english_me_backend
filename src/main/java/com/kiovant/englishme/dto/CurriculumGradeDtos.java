package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

/**
 * DTO cho chấm bài server-side (Pha 3a).
 * FE gửi đáp án THÔ; BE chấm và trả feedback từng câu.
 */
public final class CurriculumGradeDtos {

    private CurriculumGradeDtos() {}

    /**
     * Body cho cả submit practice lẫn submit quiz.
     * answers: mỗi phần tử là 1 đáp án thô — bắt buộc có "activityId" + field theo dạng bài.
     */
    public record SubmitRequest(
            List<Map<String, Object>> answers,
            Integer timeSpentSeconds
    ) {}

    /** Feedback 1 câu (cho FE tô đúng/sai + hiển thị đáp án đúng). */
    public record AnswerFeedback(
            String activityId,
            String type,
            boolean correct,
            boolean autoGraded,
            Object correctAnswer,
            String explanationVi
    ) {}

    /**
     * Kết quả nộp PRACTICE — không tính mastery.
     * retryActivityIds: các câu sai cần làm lại (FE đưa vào hàng đợi).
     */
    public record ExercisesResult(
            int total,
            int correct,
            List<String> retryActivityIds,
            List<AnswerFeedback> feedback
    ) {}
}
