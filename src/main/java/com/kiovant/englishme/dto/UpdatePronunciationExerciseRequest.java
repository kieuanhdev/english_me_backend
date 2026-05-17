package com.kiovant.englishme.dto;

public record UpdatePronunciationExerciseRequest(
        String text,
        String expectedPhonetic,
        String meaning,
        String level,
        String difficulty,
        String referenceAudioUrl,
        String tips
) {
}
