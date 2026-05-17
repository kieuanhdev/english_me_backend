package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminPronunciationExerciseRow(
        UUID id,
        String text,
        String expectedPhonetic,
        String meaning,
        String level,
        String difficulty,
        String referenceAudioUrl,
        String tips,
        long attemptCount,
        Double avgScore
) {
}
