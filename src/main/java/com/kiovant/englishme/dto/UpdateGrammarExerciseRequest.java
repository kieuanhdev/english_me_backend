package com.kiovant.englishme.dto;

public record UpdateGrammarExerciseRequest(
        Integer exerciseOrder,
        String exerciseType,
        String contentJson
) {}
