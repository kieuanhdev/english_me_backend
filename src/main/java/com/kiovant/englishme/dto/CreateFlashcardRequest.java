package com.kiovant.englishme.dto;

import java.util.List;
import java.util.Map;

public record CreateFlashcardRequest(
        String word,
        String cefr,
        List<String> pos,
        List<Map<String, Object>> allLevels,
        String ipa,
        String audioUrl,
        String definition,
        String example,
        String topic,
        String vietnamese,
        String viDefinition,
        String viExample
) {}
