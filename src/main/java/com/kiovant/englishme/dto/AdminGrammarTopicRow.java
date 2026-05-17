package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminGrammarTopicRow(
        UUID id,
        String slug,
        String category,
        String level,
        String title,
        Integer sortOrder,
        long lessonCount
) {}
