package com.kiovant.englishme.dto;

import java.util.List;

public record GrammarImportResult(
        int totalTopics,
        int topicsInserted,
        int topicsSkipped,
        int totalLessons,
        int lessonsInserted,
        int lessonsSkipped,
        int totalExercises,
        int exercisesInserted,
        List<String> errors
) {}
