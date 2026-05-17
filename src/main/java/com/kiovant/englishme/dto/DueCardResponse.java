package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record DueCardResponse(
        UUID flashcardId,
        UUID deskId,
        String word,
        String cefr,
        String ipa,
        String audioUrl,
        String definition,
        String example,
        String vietnamese,
        String viDefinition,
        String viExample,
        Integer repetitions,
        Double easinessFactor,
        Integer intervalDays,
        LocalDateTime nextReviewAt,
        boolean isNew
) {
}
