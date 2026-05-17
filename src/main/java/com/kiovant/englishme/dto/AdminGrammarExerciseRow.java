package com.kiovant.englishme.dto;

import java.util.UUID;

public record AdminGrammarExerciseRow(
        UUID id,
        Integer exerciseOrder,
        String exerciseType,
        String contentJson
) {}
