package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class AnswerQuestionRequest {
    private UUID questionId;
    private String selectedAnswer; // "A", "B", "C", "D"
}
