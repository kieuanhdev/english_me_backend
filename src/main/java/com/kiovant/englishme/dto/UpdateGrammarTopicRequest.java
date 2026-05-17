package com.kiovant.englishme.dto;

public record UpdateGrammarTopicRequest(
        String slug,
        String category,
        String level,
        String title,
        Integer sortOrder
) {}
