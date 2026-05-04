package com.kiovant.englishme.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class CreateFlashcardRequest {
    private String word;
    private String cefr;
    private List<String> pos;
    private List<Map<String, Object>> allLevels;
    private String ipa;
    private String audioUrl;
    private String definition;
    private String example;
    private String topic;
    private String vietnamese;
    private String viDefinition;
    private String viExample;
}
