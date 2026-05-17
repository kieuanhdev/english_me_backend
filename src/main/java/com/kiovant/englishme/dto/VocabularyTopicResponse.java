package com.kiovant.englishme.dto;

import java.util.UUID;

public record VocabularyTopicResponse(
        UUID id,
        String name,
        String nameEn,
        String icon,
        long wordCount,
        String level,
        String colorHex
) {}
