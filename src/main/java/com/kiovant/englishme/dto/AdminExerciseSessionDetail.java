package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record AdminExerciseSessionDetail(
        UUID id,
        UUID userId,
        String userEmail,
        String userFullName,
        String category,
        String status,
        LocalDateTime createdAt,
        LocalDateTime completedAt,
        Long durationSeconds,
        int totalQuestions,
        long answeredCount,
        long correctCount,
        List<AnswerRow> answers
) {
    public record AnswerRow(
            UUID answerId,
            UUID questionId,
            String question,
            String optionsJson,
            String correctAnswer,
            String selectedAnswer,
            Boolean isCorrect,
            String level,
            String difficulty
    ) {
    }
}
