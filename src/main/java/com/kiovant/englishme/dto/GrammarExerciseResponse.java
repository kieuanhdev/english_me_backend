package com.kiovant.englishme.dto;

import java.util.Map;
import java.util.UUID;

public record GrammarExerciseResponse(
        UUID id,
        Integer exerciseOrder,
        String exerciseType,
        Map<String, Object> content
) {}
