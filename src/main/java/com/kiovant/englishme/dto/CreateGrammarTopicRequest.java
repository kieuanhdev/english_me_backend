package com.kiovant.englishme.dto;

public record CreateGrammarTopicRequest(
        String slug,
        String category,
        String level,
        String title,
        Integer sortOrder
) {}
