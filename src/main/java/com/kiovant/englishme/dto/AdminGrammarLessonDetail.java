package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record AdminGrammarLessonDetail(
        UUID id,
        UUID topicId,
        String topicTitle,
        String sourceId,
        String title,
        Integer sortOrder,
        String explanationVi,
        String whenToUseVi,
        String tipsVi,
        String formulasJson,
        String keyWordsJson,
        String examplesJson,
        String commonMistakesJson,
        List<AdminGrammarExerciseRow> exercises
) {}
