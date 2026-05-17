package com.kiovant.englishme.dto;

public record UpdateTestBankQuestionRequest(
        String cefrLevel,
        String skillCategory,
        String question,
        String optionsJson,
        String correctAnswer,
        String explanation,
        String audioUrl,
        String passage
) {
}
