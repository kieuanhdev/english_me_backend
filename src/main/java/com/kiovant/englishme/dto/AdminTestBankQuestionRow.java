package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminTestBankQuestionRow(
        UUID id,
        String cefrLevel,
        String skillCategory,
        String question,
        String optionsJson,
        String correctAnswer,
        String explanation,
        String audioUrl,
        String passage,
        long attemptCount,
        long correctCount,
        Double avgAccuracy
) {
}
