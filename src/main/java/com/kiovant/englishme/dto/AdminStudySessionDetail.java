package com.kiovant.englishme.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record AdminStudySessionDetail(
        UUID id,
        UUID userId,
        String userFullName,
        String userEmail,
        UUID deskId,
        String deskTitle,
        String deskCefrLevel,
        String status,
        Integer totalCards,
        Integer masteredCards,
        Integer hardCards,
        Integer againCards,
        Integer xpEarned,
        Integer newWordsLearned,
        LocalDateTime startedAt,
        LocalDateTime completedAt,
        Long durationSeconds,
        List<QualityBucket> qualityBuckets
) {
    public record QualityBucket(String label, int count) {}
}
