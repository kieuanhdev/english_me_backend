package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class StartTestResponse {
    private UUID sessionId;
    private List<QuestionDto> questions;
    private int totalQuestions;
}
