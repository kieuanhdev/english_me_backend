package com.kiovant.englishme.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.repository.FlashcardRepository;
import com.kiovant.englishme.service.VocabularyImportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.List;
import java.util.Map;

/**
 * Import {@code vocabulary_final.json} vào flashcard; âm thanh tham chiếu qua {@code audio_url} (thư mục {@code audio/} hoặc URL).
 */
@Component
@Order(100)
public class VocabularyImportRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(VocabularyImportRunner.class);

    private final FlashcardRepository flashcardRepository;
    private final VocabularyImportService vocabularyImportService;
    private final ObjectMapper objectMapper;
    private final Resource vocabularyResource;

    public VocabularyImportRunner(
            FlashcardRepository flashcardRepository,
            VocabularyImportService vocabularyImportService,
            ObjectMapper objectMapper,
            @Value("${englishme.vocabulary.import.resource:file:vocabulary_final.json}") Resource vocabularyResource) {
        this.flashcardRepository = flashcardRepository;
        this.vocabularyImportService = vocabularyImportService;
        this.objectMapper = objectMapper;
        this.vocabularyResource = vocabularyResource;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        long existing = flashcardRepository.count();
        if (existing > 0) {
            log.info("[VocabularyImportRunner] Skip import: flashcard table already has {} rows.", existing);
            return;
        }

        if (!vocabularyResource.exists() || !vocabularyResource.isReadable()) {
            log.warn("[VocabularyImportRunner] Resource not found or not readable: {} — skipping import.", vocabularyResource);
            return;
        }

        try (InputStream is = vocabularyResource.getInputStream()) {
            List<Map<String, Object>> rows = objectMapper.readValue(is, new TypeReference<>() {});
            vocabularyImportService.importRows(rows);
            log.info("[VocabularyImportRunner] Imported {} flashcards.", flashcardRepository.count());
        }
    }
}
