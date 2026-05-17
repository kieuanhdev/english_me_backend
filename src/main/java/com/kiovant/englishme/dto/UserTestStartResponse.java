package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record UserTestStartResponse(
        UUID sessionId,
        String topic,
        String level,
        int totalQuestions,
        int durationSeconds,
        List<TestQuestionResponse> questions
) {
}
