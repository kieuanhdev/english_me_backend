package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class TestResultResponse {
    private UUID sessionId;
    private String resultLevel;   // A1, A2, B1, ...
    private int score;            // số câu đúng
    private int totalQuestions;
    private List<AnswerReview> review;

    @Data
    public static class AnswerReview {
        private UUID questionId;
        private String question;
        private String selectedAnswer;
        private String correctAnswer;
        private boolean isCorrect;
        private String explanation;
    }
}
