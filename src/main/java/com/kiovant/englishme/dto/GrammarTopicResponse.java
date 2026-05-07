package com.kiovant.englishme.dto;

import java.util.UUID;

public record GrammarTopicResponse(
        UUID id,
        String slug,
        String category,
        String level,
        String title,
        Integer sortOrder,
        Long lessonCount
) {}
