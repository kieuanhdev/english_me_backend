package com.kiovant.englishme.dto;

public record CreateVocabularyTopicRequest(
        String name,
        String nameEn,
        String icon,
        String level,
        String colorHex,
        Integer sortOrder
) {}
