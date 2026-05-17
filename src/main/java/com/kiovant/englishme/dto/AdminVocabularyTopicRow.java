package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminVocabularyTopicRow(
        UUID id,
        String name,
        String nameEn,
        String icon,
        String level,
        String colorHex,
        Integer sortOrder,
        long wordCount
) {}
