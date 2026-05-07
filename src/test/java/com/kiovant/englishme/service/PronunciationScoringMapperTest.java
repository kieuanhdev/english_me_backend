package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class PronunciationScoringMapperTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final PronunciationScoringMapper mapper = new PronunciationScoringMapper();

    @Test
    void mapSpeechace_shouldMapScoresAndWordFeedback() throws Exception {
        String json = """
                {
                  "text_score": {
                    "quality_score": 83,
                    "pronunciation": { "score": 80 },
                    "fluency": { "score": 78 },
                    "word_score_list": [
                      { "word": "hello", "quality_score": 88, "start": 0.10, "end": 0.50 },
                      { "word": "world", "quality_score": 55, "start": 0.52, "end": 0.90 }
                    ]
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(UUID.randomUUID(), root, "speechace");

        assertEquals(83, response.overallScore());
        assertEquals(80, response.accuracyScore());
        assertEquals(78, response.fluencyScore());
        assertEquals(2, response.wordFeedback().size());
        assertEquals("hello", response.wordFeedback().get(0).word());
        assertEquals("critical", response.wordFeedback().get(1).issueType());
        assertFalse(response.tips().isEmpty());
    }
}
