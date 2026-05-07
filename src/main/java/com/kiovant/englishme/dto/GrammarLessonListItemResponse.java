package com.kiovant.englishme.dto;

import java.util.UUID;

public record GrammarLessonListItemResponse(
        UUID id,
        String sourceId,
        String title,
        Integer sortOrder
) {}
