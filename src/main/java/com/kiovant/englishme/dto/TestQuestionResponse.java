package com.kiovant.englishme.dto;

import java.util.Map;
import java.util.UUID;

public record TestQuestionResponse(
        UUID id,
        String cefrLevel,
        String skillCategory,
        String question,
        Map<String, String> options
) {
}
