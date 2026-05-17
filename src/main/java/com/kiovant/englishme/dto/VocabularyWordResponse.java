package com.kiovant.englishme.dto;

import java.util.UUID;

public record VocabularyWordResponse(
        UUID id,
        UUID topicId,
        String word,
        String pronunciation,
        String partOfSpeech,
        String definitionVi,
        String definitionEn,
        String exampleSentence,
        String exampleTranslation,
        String level,
        String audioUrl
) {}
