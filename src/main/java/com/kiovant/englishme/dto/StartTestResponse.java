package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record StartTestResponse(
        UUID sessionId,
        List<QuestionDto> questions,
        int totalQuestions
) {}
