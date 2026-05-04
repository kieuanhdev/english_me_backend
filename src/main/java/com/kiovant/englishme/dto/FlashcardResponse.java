package com.kiovant.englishme.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FlashcardResponse {
    private UUID id;
    private UUID deskId;
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
