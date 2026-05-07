package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record PronunciationAssessResponse(
        UUID attemptId,
        int overallScore,
        int accuracyScore,
        int fluencyScore,
        List<PronunciationWordFeedbackDto> wordFeedback,
        List<String> tips,
        String retryAdvice,
        String provider
) {
}
