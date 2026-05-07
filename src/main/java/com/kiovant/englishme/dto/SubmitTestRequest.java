package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record SubmitTestRequest(
        List<AnswerItem> answers
) {
    public record AnswerItem(
            UUID questionId,
            String selectedAnswer
    ) {}
}
