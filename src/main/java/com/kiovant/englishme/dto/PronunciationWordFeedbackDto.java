package com.kiovant.englishme.dto;

public record PronunciationWordFeedbackDto(
        String word,
        int score,
        int startMs,
        int endMs,
        String issueType,
        String suggestion
) {
}
