package com.kiovant.englishme.dto;

public record CreateGrammarLessonRequest(
        String sourceId,
        String title,
        Integer sortOrder,
        String explanationVi,
        String whenToUseVi,
        String tipsVi,
        String formulasJson,
        String keyWordsJson,
        String examplesJson,
        String commonMistakesJson
) {}
