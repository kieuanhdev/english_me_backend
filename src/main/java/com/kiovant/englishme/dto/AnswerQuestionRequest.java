package com.kiovant.englishme.dto;

import java.util.UUID;

public record AnswerQuestionRequest(
        UUID questionId,
        String selectedAnswer
) {}
