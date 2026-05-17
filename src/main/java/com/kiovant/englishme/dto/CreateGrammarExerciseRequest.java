package com.kiovant.englishme.dto;

public record CreateGrammarExerciseRequest(
        Integer exerciseOrder,
        String exerciseType,
        String contentJson
) {}
