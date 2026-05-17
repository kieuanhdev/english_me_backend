package com.kiovant.englishme.dto;

import java.time.LocalDate;
import java.util.UUID;

public record AdminWordOfDayRow(
        UUID id,
        LocalDate scheduledDate,
        UUID wordId,
        String word,
        String pronunciation,
        String definitionVi,
        String level,
        String note
) {
}
