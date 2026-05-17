package com.kiovant.englishme.dto;

import java.util.UUID;

public record AnswerSubmit(
        UUID questionId,
        String selectedAnswer
) {
}
