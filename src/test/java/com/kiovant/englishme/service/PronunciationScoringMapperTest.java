package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PronunciationScoringMapperTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final PronunciationScoringMapper mapper = new PronunciationScoringMapper();

    @Test
    void mapSpeechace_shouldMapScoresAndErrors() throws Exception {
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

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "hello world");

        assertEquals(83.0, response.score());
        assertEquals(80.0, response.accuracy());
        assertEquals(78.0, response.fluency());
        assertTrue(response.completeness() > 0);
        assertEquals("hello world", response.transcription());
        assertFalse(response.errors().isEmpty());
        assertEquals("world", response.errors().get(0).word());
        assertEquals(1, response.errors().get(0).position());
        assertNotNull(response.overallComment());
        assertFalse(response.overallComment().isEmpty());
    }

    @Test
    void mapSpeechace_shouldReturnEmptyErrorsWhenAllGood() throws Exception {
        String json = """
                {
                  "text_score": {
                    "quality_score": 90,
                    "pronunciation": { "score": 92 },
                    "fluency": { "score": 88 },
                    "word_score_list": [
                      { "word": "good", "quality_score": 92, "start": 0.10, "end": 0.50 },
                      { "word": "job", "quality_score": 88, "start": 0.52, "end": 0.90 }
                    ]
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "good job");

        assertTrue(response.errors().isEmpty());
        assertEquals(100.0, response.completeness());
    }
}
