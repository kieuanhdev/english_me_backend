package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Pronunciation client mô phỏng — demo offline không cần Speechace API key.
 *
 * - Kích hoạt làm bean chính khi `englishme.ai.pronunciation.provider = mock`.
 * - Ngược lại, vẫn được khởi tạo làm bean phụ để `SpeechacePronunciationClient`
 *   inject làm fallback khi thiếu api-key (bean này không bị Conditional che).
 *
 * Sinh điểm trong khoảng hợp lý [55, 95] để response trông tự nhiên khi demo.
 */
@Component
@ConditionalOnProperty(
        prefix = "englishme.ai.pronunciation",
        name = "enable-mock",
        havingValue = "true",
        matchIfMissing = true
)
public class MockPronunciationClient implements CloudPronunciationClient {

    private final ObjectMapper objectMapper;

    public MockPronunciationClient(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public JsonNode assess(byte[] audioBytes, String referenceText, String language) {
        String[] words = referenceText.trim().split("\\s+");
        ArrayNode wordList = objectMapper.createArrayNode();
        double time = 0.1;
        for (String raw : words) {
            String clean = raw.replaceAll("[^a-zA-Z']", "").toLowerCase();
            if (clean.isEmpty()) {
                continue;
            }
            int wordScore = 55 + (int) (Math.random() * 40) + (clean.length() > 3 ? 5 : 0);
            if (wordScore > 100) wordScore = 100;
            double end = time + 0.3 + Math.random() * 0.3;
            ObjectNode wordNode = objectMapper.createObjectNode();
            wordNode.put("word", clean);
            wordNode.put("quality_score", wordScore);
            wordNode.put("start", Math.round(time * 100.0) / 100.0);
            wordNode.put("end", Math.round(end * 100.0) / 100.0);
            wordList.add(wordNode);
            time = end + 0.05;
        }

        int avgScore = words.length == 0 ? 80 : Math.min(100, 55 + (int) (Math.random() * 35));
        ObjectNode pronunciation = objectMapper.createObjectNode();
        pronunciation.put("score", avgScore - 2 + (int) (Math.random() * 5));
        ObjectNode fluency = objectMapper.createObjectNode();
        fluency.put("score", avgScore - 3 + (int) (Math.random() * 5));
        ObjectNode textScore = objectMapper.createObjectNode();
        textScore.put("quality_score", avgScore);
        textScore.set("pronunciation", pronunciation);
        textScore.set("fluency", fluency);
        textScore.set("word_score_list", wordList);
        ObjectNode root = objectMapper.createObjectNode();
        root.set("text_score", textScore);
        return root;
    }

    @Override
    public String providerName() {
        return "mock";
    }
}
