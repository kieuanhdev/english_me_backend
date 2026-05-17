package com.kiovant.englishme.dto;

import java.util.List;

public record ExerciseCompleteRequest(
        List<AnswerSubmit> answers
) {
}
