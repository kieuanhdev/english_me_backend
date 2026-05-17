package com.kiovant.englishme.dto;

import java.util.UUID;

public record ReviewRequest(
        UUID flashcardId,
        Integer quality,
        Integer responseTimeMs
) {
}
