package com.kiovant.englishme.dto;

import java.util.UUID;

public record PronunciationAssessTextRequest(
        String referenceText,
        String spokenText,
        UUID exerciseId,
        UUID lessonItemId
) {
}
