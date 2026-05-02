package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.Map;
import java.util.UUID;

@Data
public class QuestionDto {
    private UUID id;
    private String cefrLevel;
    private String skillCategory;
    private String question;
    private Map<String, String> options;
    // correctAnswer và explanation KHÔNG trả về để tránh gian lận
}
