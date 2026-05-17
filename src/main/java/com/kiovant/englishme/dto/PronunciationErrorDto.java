package com.kiovant.englishme.dto;

public record PronunciationErrorDto(
        String word,
        int position,
        String expected,
        String actual,
        String suggestion
) {
}
