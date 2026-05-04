package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.Desk;
import com.kiovant.englishme.entity.Flashcard;
import com.kiovant.englishme.repository.DeskRepository;
import com.kiovant.englishme.repository.FlashcardRepository;
import jakarta.persistence.EntityManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class VocabularyImportService {

    private static final Logger log = LoggerFactory.getLogger(VocabularyImportService.class);
    private static final int BATCH = 200;

    private final FlashcardRepository flashcardRepository;
    private final DeskRepository deskRepository;
    private final EntityManager entityManager;

    public VocabularyImportService(
            FlashcardRepository flashcardRepository,
            DeskRepository deskRepository,
            EntityManager entityManager) {
        this.flashcardRepository = flashcardRepository;
        this.deskRepository = deskRepository;
        this.entityManager = entityManager;
    }

    @Transactional
    public void importRows(List<Map<String, Object>> rows) {
        Map<String, Desk> deskByCefr = new HashMap<>();
        for (Desk d : deskRepository.findAll()) {
            deskByCefr.put(d.getCefrLevel(), d);
        }

        List<Flashcard> batch = new ArrayList<>(BATCH);
        int skipped = 0;

        for (Map<String, Object> raw : rows) {
            String word = stringVal(raw.get("word"));
            String cefr = stringVal(raw.get("cefr"));
            if (word == null || word.isBlank() || cefr == null || cefr.isBlank()) {
                skipped++;
                continue;
            }

            Desk desk = deskByCefr.get(cefr.trim());
            if (desk == null) {
                log.warn("[VocabularyImport] Unknown CEFR '{}', skip word '{}'", cefr, word);
                skipped++;
                continue;
            }

            Flashcard fc = new Flashcard();
            fc.setDesk(desk);
            fc.setWord(word);
            fc.setCefr(cefr.trim());
            fc.setPosJson(readPos(raw.get("pos")));
            fc.setAllLevelsJson(readAllLevels(raw.get("all_levels")));
            fc.setIpa(stringVal(raw.get("ipa")));
            fc.setAudioUrl(stringVal(raw.get("audio_url")));
            fc.setDefinition(stringVal(raw.get("definition")));
            fc.setExample(stringVal(raw.get("example")));
            fc.setTopic(stringVal(raw.get("topic")));
            fc.setVietnamese(stringVal(raw.get("vietnamese")));
            fc.setViDefinition(stringVal(raw.get("vi_definition")));
            fc.setViExample(stringVal(raw.get("vi_example")));

            batch.add(fc);
            if (batch.size() >= BATCH) {
                persistBatch(batch);
            }
        }

        if (!batch.isEmpty()) {
            persistBatch(batch);
        }

        if (skipped > 0) {
            log.info("[VocabularyImport] Skipped {} rows (missing desk/word/cefr).", skipped);
        }
    }

    private void persistBatch(List<Flashcard> batch) {
        flashcardRepository.saveAll(batch);
        entityManager.flush();
        entityManager.clear();
        batch.clear();
    }

    private static String stringVal(Object o) {
        return o == null ? null : String.valueOf(o).trim();
    }

    private static List<String> readPos(Object posField) {
        if (!(posField instanceof List<?> list)) {
            return null;
        }
        List<String> out = new ArrayList<>();
        for (Object item : list) {
            if (item != null) {
                out.add(String.valueOf(item));
            }
        }
        return out.isEmpty() ? null : out;
    }

    private static List<Map<String, Object>> readAllLevels(Object levelsField) {
        if (!(levelsField instanceof List<?> list)) {
            return null;
        }
        List<Map<String, Object>> out = new ArrayList<>();
        for (Object item : list) {
            if (item instanceof Map<?, ?> m) {
                Map<String, Object> copy = new HashMap<>();
                for (Map.Entry<?, ?> e : m.entrySet()) {
                    copy.put(String.valueOf(e.getKey()), e.getValue());
                }
                out.add(copy);
            }
        }
        return out.isEmpty() ? null : out;
    }
}
