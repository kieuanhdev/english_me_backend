package com.kiovant.englishme.dto;

public record UpdateVocabularyWordRequest(
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
