package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class AnswerQuestionResponse {
    private UUID questionId;
    private String selectedAnswer;
    private String correctAnswer;
    private boolean isCorrect;
    private String explanation;
    private int answeredCount;   // số câu đã trả lời trong session
    private int totalQuestions;  // tổng số câu của session
}
