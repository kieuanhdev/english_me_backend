package com.kiovant.englishme.dto;

import java.util.List;

public record PronunciationAssessResponse(
        double score,
        double accuracy,
        double fluency,
        double completeness,
        String transcription,
        List<PronunciationErrorDto> errors,
        String overallComment
) {
}
