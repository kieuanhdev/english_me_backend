package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record StudySessionStartResponse(
        UUID sessionId,
        UUID deskId,
        int totalCards,
        List<DueCardResponse> cards
) {
}
