package com.kiovant.englishme.dto;

import com.kiovant.englishme.entity.PronunciationExercise;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response cho GET /api/pronunciation/exercises — thay vì trả entity JPA thẳng
 * (API contract dính schema DB). Tên field giữ nguyên để mobile không phải đổi.
 */
public record PronunciationExerciseResponse(
        UUID id,
        String text,
        String phonetic,
        String meaning,
        String audioUrl,
        String difficulty,
        String level,
        String tips,
        LocalDateTime createdAt
) {
    public static PronunciationExerciseResponse from(PronunciationExercise e) {
        return new PronunciationExerciseResponse(
                e.getId(), e.getText(), e.getPhonetic(), e.getMeaning(),
                e.getAudioUrl(), e.getDifficulty(), e.getLevel(), e.getTips(),
                e.getCreatedAt());
    }
}
