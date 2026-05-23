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

    @Test
    void mapSpeechace_shouldNotNpeOnEmptyWordList() throws Exception {
        String json = """
                {
                  "text_score": {
                    "quality_score": 0,
                    "pronunciation": { "score": 0 },
                    "fluency": { "score": 0 },
                    "word_score_list": []
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "hello world");

        assertNotNull(response);
        assertEquals(0.0, response.score());
        assertTrue(response.errors().isEmpty());
        assertEquals("", response.transcription());
        assertEquals(0.0, response.completeness());
        assertNotNull(response.overallComment());
    }

    @Test
    void mapSpeechace_shouldClampScoresAbove100() throws Exception {
        String json = """
                {
                  "text_score": {
                    "quality_score": 150,
                    "pronunciation": { "score": -20 },
                    "fluency": { "score": 200 },
                    "word_score_list": [
                      { "word": "ok", "quality_score": 999, "start": 0.0, "end": 0.3 }
                    ]
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "ok");

        assertEquals(100.0, response.score());
        assertEquals(0.0, response.accuracy());
        assertEquals(100.0, response.fluency());
        assertTrue(response.errors().isEmpty()); // clamped to 100 -> >= 80 -> không error
    }

    @Test
    void mapSpeechace_shouldOrderWordsByStartTime() throws Exception {
        // Word list cố tình bị xáo trộn theo start time
        String json = """
                {
                  "text_score": {
                    "quality_score": 70,
                    "pronunciation": { "score": 70 },
                    "fluency": { "score": 70 },
                    "word_score_list": [
                      { "word": "world", "quality_score": 70, "start": 0.50, "end": 1.0 },
                      { "word": "hello", "quality_score": 70, "start": 0.10, "end": 0.40 }
                    ]
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "hello world");

        assertEquals("hello world", response.transcription());
    }

    @Test
    void mapSpeechace_shouldSkipEmptyTokens() throws Exception {
        String json = """
                {
                  "text_score": {
                    "quality_score": 80,
                    "pronunciation": { "score": 80 },
                    "fluency": { "score": 80 },
                    "word_score_list": [
                      { "word": "hello", "quality_score": 90, "start": 0.0, "end": 0.3 },
                      { "word": "   ",   "quality_score": 90, "start": 0.4, "end": 0.5 },
                      { "word": "world", "quality_score": 90, "start": 0.6, "end": 1.0 }
                    ]
                  }
                }
                """;
        JsonNode root = objectMapper.readTree(json);

        PronunciationAssessResponse response = mapper.mapSpeechace(root, "hello world");

        assertEquals("hello world", response.transcription());
        assertTrue(response.errors().isEmpty());
    }
}
