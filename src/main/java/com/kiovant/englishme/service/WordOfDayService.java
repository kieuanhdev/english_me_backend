package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.entity.WordOfDayCache;
import com.kiovant.englishme.repository.WordOfDayCacheRepository;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class WordOfDayService {

    private static final Logger log = LoggerFactory.getLogger(WordOfDayService.class);

    private final WordOfDayCacheRepository cacheRepository;
    private final ObjectMapper objectMapper;

    // Loaded once at startup: level → list of word nodes
    private final Map<String, List<JsonNode>> wordsByLevel = new HashMap<>();

    public WordOfDayService(WordOfDayCacheRepository cacheRepository) {
        this.cacheRepository = cacheRepository;
        this.objectMapper = new ObjectMapper();
    }

    @PostConstruct
    void loadWordlist() {
        try {
            var resource = new ClassPathResource("vocabulary_oxford5000.json");
            JsonNode root = objectMapper.readTree(resource.getInputStream());
            for (JsonNode node : root) {
                String level = node.path("cefr").asText("").toUpperCase();
                if (level.isBlank()) continue;
                wordsByLevel.computeIfAbsent(level, k -> new ArrayList<>()).add(node);
            }
            wordsByLevel.forEach((level, words) ->
                    log.info("WordOfDay loaded {} words for level {}", words.size(), level));
        } catch (Exception e) {
            log.error("Failed to load Oxford 5000 wordlist", e);
        }
    }

    @Transactional
    public VocabularyWordResponse getWordOfDay(String cefrLevel) {
        String level = cefrLevel.toUpperCase();
        LocalDate today = LocalDate.now();

        // Return cached entry if exists
        var cached = cacheRepository.findByCacheDateAndCefrLevelIgnoreCase(today, level);
        if (cached.isPresent()) {
            return toResponse(cached.get());
        }

        WordOfDayCache entry = buildEntry(level, today);
        cacheRepository.save(entry);
        return toResponse(entry);
    }

    private WordOfDayCache buildEntry(String level, LocalDate date) {
        // C2 fallback to C1 since wordlist has no C2
        List<JsonNode> words = wordsByLevel.getOrDefault(level,
                wordsByLevel.getOrDefault("C1", List.of()));

        WordOfDayCache cache = new WordOfDayCache();
        cache.setCacheDate(date);
        cache.setCefrLevel(level);

        if (words.isEmpty()) {
            log.warn("No words found for level {}", level);
            cache.setWord("N/A");
            return cache;
        }

        int index = (int) (date.toEpochDay() % words.size());
        JsonNode w = words.get(index);

        cache.setWord(w.path("word").asText());
        cache.setPronunciation(nullIfBlank(w.path("ipa").asText()));
        cache.setPartOfSpeech(firstPos(w.path("pos")));
        cache.setDefinitionEn(nullIfBlank(w.path("definition").asText()));
        cache.setDefinitionVi(nullIfBlank(w.path("vi_definition").asText()));
        cache.setExampleSentence(nullIfBlank(w.path("example").asText()));
        cache.setExampleTranslation(nullIfBlank(w.path("vi_example").asText()));
        cache.setAudioUrl(nullIfBlank(w.path("audio_url").asText()));
        return cache;
    }

    private String firstPos(JsonNode posArray) {
        if (posArray.isArray() && !posArray.isEmpty()) {
            return nullIfBlank(posArray.get(0).asText());
        }
        return null;
    }

    private String nullIfBlank(String value) {
        return (value == null || value.isBlank()) ? null : value;
    }

    private VocabularyWordResponse toResponse(WordOfDayCache c) {
        return new VocabularyWordResponse(
                c.getId(),
                null,
                c.getWord(),
                c.getPronunciation(),
                c.getPartOfSpeech(),
                c.getDefinitionVi(),
                c.getDefinitionEn(),
                c.getExampleSentence(),
                c.getExampleTranslation(),
                c.getCefrLevel(),
                c.getAudioUrl());
    }
}
