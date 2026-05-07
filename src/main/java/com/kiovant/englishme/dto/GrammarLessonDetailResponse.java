package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;
import java.util.UUID;

public record GrammarLessonDetailResponse(
        UUID id,
        UUID topicId,
        String sourceId,
        String title,
        Integer sortOrder,
        String explanationVi,
        String whenToUseVi,
        String tipsVi,
        List<Map<String, Object>> formulas,
        List<String> keyWords,
        List<Map<String, Object>> examples,
        List<Map<String, Object>> commonMistakes,
        List<GrammarExerciseResponse> exercises
) {}
