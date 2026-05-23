package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class MockPronunciationClientTest {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final MockPronunciationClient client = new MockPronunciationClient(objectMapper);

    @Test
    @DisplayName("Mock trả response có cùng shape với Speechace (text_score.word_score_list)")
    void mockProducesSpeechaceCompatibleShape() {
        JsonNode root = client.assess(new byte[]{1, 2, 3}, "hello world", "en-us");

        JsonNode textScore = root.path("text_score");
        assertFalse(textScore.isMissingNode());
        assertTrue(textScore.has("quality_score"));
        assertTrue(textScore.path("pronunciation").has("score"));
        assertTrue(textScore.path("fluency").has("score"));
        JsonNode words = textScore.path("word_score_list");
        assertTrue(words.isArray());
        assertEquals(2, words.size());
        assertEquals("hello", words.get(0).path("word").asText());
        assertEquals("world", words.get(1).path("word").asText());
    }

    @Test
    @DisplayName("Điểm overall trong khoảng [50, 100]")
    void scoresAreInReasonableRange() {
        for (int i = 0; i < 20; i++) {
            JsonNode root = client.assess(new byte[]{1}, "this is a test", "en-us");
            int overall = root.path("text_score").path("quality_score").asInt();
            assertTrue(overall >= 50 && overall <= 100,
                    "overall=" + overall + " out of range");
        }
    }

    @Test
    @DisplayName("providerName trả 'mock'")
    void providerNameIsMock() {
        assertEquals("mock", client.providerName());
    }

    @Test
    @DisplayName("Reference text rỗng -> word_score_list rỗng nhưng không NPE")
    void emptyReferenceProducesEmptyWordList() {
        JsonNode root = client.assess(new byte[]{}, "   ", "en-us");
        JsonNode words = root.path("text_score").path("word_score_list");
        assertTrue(words.isArray());
        assertEquals(0, words.size());
    }
}
