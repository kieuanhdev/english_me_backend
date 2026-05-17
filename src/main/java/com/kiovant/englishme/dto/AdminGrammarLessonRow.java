package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminGrammarLessonRow(
        UUID id,
        String sourceId,
        String title,
        Integer sortOrder,
        long exerciseCount
) {}
