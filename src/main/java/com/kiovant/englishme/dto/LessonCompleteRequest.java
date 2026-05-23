package com.kiovant.englishme.dto;

import java.util.List;

public record LessonCompleteRequest(
        int score,
        int timeSpentSeconds,
        List<Answer> answers
) {
    public record Answer(
            String activityId,
            String type,
            String selectedOptionId,
            Boolean isCorrect,
            String textAnswer
    ) {}
}
