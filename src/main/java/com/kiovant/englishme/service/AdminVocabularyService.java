package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiovant.englishme.dto.AdminVocabularyTopicRow;
import com.kiovant.englishme.dto.AdminVocabularyWordRow;
import com.kiovant.englishme.dto.CreateVocabularyTopicRequest;
import com.kiovant.englishme.dto.CreateVocabularyWordRequest;
import com.kiovant.englishme.dto.UpdateVocabularyTopicRequest;
import com.kiovant.englishme.dto.UpdateVocabularyWordRequest;
import com.kiovant.englishme.dto.VocabularyImportResult;
import com.kiovant.englishme.entity.VocabularyTopic;
import com.kiovant.englishme.entity.VocabularyWord;
import com.kiovant.englishme.repository.VocabularyTopicRepository;
import com.kiovant.englishme.repository.VocabularyWordRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminVocabularyService {

    private static final Set<String> ALLOWED_LEVELS = Set.of("A1", "A2", "B1", "B2", "C1", "C2");

    private final VocabularyTopicRepository topicRepository;
    private final VocabularyWordRepository wordRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AdminVocabularyService(VocabularyTopicRepository topicRepository,
                                  VocabularyWordRepository wordRepository) {
        this.topicRepository = topicRepository;
        this.wordRepository = wordRepository;
    }

    // ── Topics ──────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminVocabularyTopicRow> listTopics(String level, String keyword) {
        String normalizedLevel = level == null ? null : level.trim();
        String normalizedKeyword = keyword == null ? null : keyword.trim();
        return topicRepository.searchTopics(normalizedLevel, normalizedKeyword).stream()
                .map(t -> new AdminVocabularyTopicRow(
                        t.getId(),
                        t.getName(),
                        t.getNameEn(),
                        t.getIcon(),
                        t.getLevel(),
                        t.getColorHex(),
                        t.getSortOrder(),
                        topicRepository.countWordsByTopicId(t.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public VocabularyTopic getTopicOrThrow(UUID id) {
        return topicRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary topic not found"));
    }

    @Transactional
    public VocabularyTopic createTopic(CreateVocabularyTopicRequest req) {
        validateTopicPayload(req.name(), req.nameEn(), req.level(), req.colorHex());
        VocabularyTopic topic = new VocabularyTopic();
        topic.setName(req.name().trim());
        topic.setNameEn(req.nameEn().trim());
        topic.setIcon(blankToNull(req.icon()));
        topic.setLevel(normalizeLevel(req.level()));
        topic.setColorHex(blankToNull(req.colorHex()));
        topic.setSortOrder(req.sortOrder() == null
                ? (topicRepository.maxSortOrder() == null ? 1 : topicRepository.maxSortOrder() + 1)
                : req.sortOrder());
        return topicRepository.save(topic);
    }

    @Transactional
    public VocabularyTopic updateTopic(UUID id, UpdateVocabularyTopicRequest req) {
        validateTopicPayload(req.name(), req.nameEn(), req.level(), req.colorHex());
        VocabularyTopic topic = getTopicOrThrow(id);
        topic.setName(req.name().trim());
        topic.setNameEn(req.nameEn().trim());
        topic.setIcon(blankToNull(req.icon()));
        topic.setLevel(normalizeLevel(req.level()));
        topic.setColorHex(blankToNull(req.colorHex()));
        if (req.sortOrder() != null) {
            topic.setSortOrder(req.sortOrder());
        }
        return topicRepository.save(topic);
    }

    @Transactional
    public void deleteTopic(UUID id) {
        VocabularyTopic topic = getTopicOrThrow(id);
        // Cascade on DB will remove words, but make it explicit for safety/visibility.
        long wordCount = topicRepository.countWordsByTopicId(id);
        if (wordCount > 0) {
            // Force delete words first (DB ON DELETE CASCADE also handles this)
            wordRepository.deleteAll(wordRepository.findByTopic_IdOrderByWordAsc(id));
        }
        topicRepository.delete(topic);
    }

    // ── Words ───────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AdminVocabularyWordRow> listWords(UUID topicId, String keyword) {
        getTopicOrThrow(topicId);
        String normalizedKeyword = keyword == null ? null : keyword.trim();
        List<VocabularyWord> words = wordRepository.searchWordsByTopic(topicId, normalizedKeyword);
        Set<String> duplicates = new HashSet<>();
        for (Object[] row : wordRepository.findDuplicateWordsByTopic(topicId)) {
            if (row.length > 0 && row[0] != null) {
                duplicates.add(row[0].toString().toLowerCase());
            }
        }
        return words.stream()
                .map(w -> new AdminVocabularyWordRow(
                        w.getId(),
                        w.getTopic().getId(),
                        w.getWord(),
                        w.getPronunciation(),
                        w.getPartOfSpeech(),
                        w.getDefinitionVi(),
                        w.getDefinitionEn(),
                        w.getExampleSentence(),
                        w.getExampleTranslation(),
                        w.getLevel(),
                        w.getAudioUrl(),
                        w.getWord() != null && duplicates.contains(w.getWord().toLowerCase())))
                .toList();
    }

    @Transactional(readOnly = true)
    public VocabularyWord getWordOrThrow(UUID id) {
        return wordRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary word not found"));
    }

    @Transactional
    public VocabularyWord createWord(UUID topicId, CreateVocabularyWordRequest req) {
        validateWordPayload(req.word(), req.level());
        VocabularyTopic topic = getTopicOrThrow(topicId);
        if (wordRepository.existsByTopic_IdAndWordIgnoreCase(topicId, req.word().trim())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Từ này đã tồn tại trong chủ đề.");
        }
        VocabularyWord word = new VocabularyWord();
        word.setTopic(topic);
        applyWordPayload(word, req.word(), req.pronunciation(), req.partOfSpeech(),
                req.definitionVi(), req.definitionEn(), req.exampleSentence(),
                req.exampleTranslation(), req.level(), req.audioUrl());
        return wordRepository.save(word);
    }

    @Transactional
    public VocabularyWord updateWord(UUID id, UpdateVocabularyWordRequest req) {
        validateWordPayload(req.word(), req.level());
        VocabularyWord word = getWordOrThrow(id);
        UUID topicId = word.getTopic().getId();
        if (!word.getWord().equalsIgnoreCase(req.word().trim())
                && wordRepository.existsByTopic_IdAndWordIgnoreCase(topicId, req.word().trim())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Từ này đã tồn tại trong chủ đề.");
        }
        applyWordPayload(word, req.word(), req.pronunciation(), req.partOfSpeech(),
                req.definitionVi(), req.definitionEn(), req.exampleSentence(),
                req.exampleTranslation(), req.level(), req.audioUrl());
        return wordRepository.save(word);
    }

    @Transactional
    public void deleteWord(UUID id) {
        VocabularyWord word = getWordOrThrow(id);
        wordRepository.delete(word);
    }

    // ── Bulk import ─────────────────────────────────────────────────────────

    @Transactional
    public VocabularyImportResult importWords(UUID topicId, String jsonPayload) {
        VocabularyTopic topic = getTopicOrThrow(topicId);
        if (jsonPayload == null || jsonPayload.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Payload JSON trống.");
        }
        JsonNode root;
        try {
            root = objectMapper.readTree(jsonPayload);
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "JSON không hợp lệ: " + ex.getMessage());
        }
        JsonNode array = root;
        if (root.isObject() && root.has("words")) {
            array = root.get("words");
        }
        if (!array.isArray()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Định dạng không hợp lệ — cần là JSON array hoặc {\"words\": [...]}.");
        }
        int total = 0;
        int inserted = 0;
        int skipped = 0;
        List<String> errors = new ArrayList<>();
        for (JsonNode item : array) {
            total++;
            String word = textOrNull(item, "word");
            String level = textOrNull(item, "level");
            if (word == null || word.isBlank()) {
                skipped++;
                errors.add("Dòng " + total + ": thiếu trường word.");
                continue;
            }
            if (level == null || level.isBlank()) {
                level = topic.getLevel(); // fallback theo topic
            }
            try {
                validateWordPayload(word, level);
            } catch (ResponseStatusException ex) {
                skipped++;
                errors.add("Dòng " + total + " (" + word + "): " + ex.getReason());
                continue;
            }
            if (wordRepository.existsByTopic_IdAndWordIgnoreCase(topicId, word.trim())) {
                skipped++;
                errors.add("Dòng " + total + " (" + word + "): đã tồn tại trong chủ đề.");
                continue;
            }
            VocabularyWord entity = new VocabularyWord();
            entity.setTopic(topic);
            applyWordPayload(entity,
                    word,
                    textOrNull(item, "pronunciation"),
                    textOrNull(item, "partOfSpeech", "part_of_speech"),
                    textOrNull(item, "definitionVi", "definition_vi"),
                    textOrNull(item, "definitionEn", "definition_en"),
                    textOrNull(item, "exampleSentence", "example_sentence", "example"),
                    textOrNull(item, "exampleTranslation", "example_translation"),
                    level,
                    textOrNull(item, "audioUrl", "audio_url"));
            wordRepository.save(entity);
            inserted++;
        }
        return new VocabularyImportResult(total, inserted, skipped, errors);
    }

    // ── CSV export ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public String exportTopicAsCsv(UUID topicId) {
        VocabularyTopic topic = getTopicOrThrow(topicId);
        List<VocabularyWord> words = wordRepository.findByTopic_IdOrderByWordAsc(topicId);
        StringBuilder sb = new StringBuilder();
        sb.append("word,pronunciation,part_of_speech,definition_vi,definition_en,example_sentence,example_translation,level,audio_url\n");
        for (VocabularyWord w : words) {
            sb.append(csvEscape(w.getWord())).append(',')
                    .append(csvEscape(w.getPronunciation())).append(',')
                    .append(csvEscape(w.getPartOfSpeech())).append(',')
                    .append(csvEscape(w.getDefinitionVi())).append(',')
                    .append(csvEscape(w.getDefinitionEn())).append(',')
                    .append(csvEscape(w.getExampleSentence())).append(',')
                    .append(csvEscape(w.getExampleTranslation())).append(',')
                    .append(csvEscape(w.getLevel())).append(',')
                    .append(csvEscape(w.getAudioUrl())).append('\n');
        }
        // touch `topic` to avoid unused warning (and keep guarantee topic exists before export)
        if (topic == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary topic not found");
        }
        return sb.toString();
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private void validateTopicPayload(String name, String nameEn, String level, String colorHex) {
        if (name == null || name.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên chủ đề không được trống.");
        }
        if (nameEn == null || nameEn.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên tiếng Anh không được trống.");
        }
        if (level != null && !level.isBlank() && !ALLOWED_LEVELS.contains(level.trim().toUpperCase())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cấp độ không hợp lệ (A1..C2).");
        }
        if (colorHex != null && !colorHex.isBlank() && !colorHex.trim().matches("^#?[0-9A-Fa-f]{6}$")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mã màu phải dạng #RRGGBB.");
        }
    }

    private void validateWordPayload(String word, String level) {
        if (word == null || word.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Từ không được trống.");
        }
        if (level == null || level.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cấp độ từ không được trống.");
        }
        if (!ALLOWED_LEVELS.contains(level.trim().toUpperCase())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cấp độ không hợp lệ (A1..C2).");
        }
    }

    private void applyWordPayload(VocabularyWord target,
                                  String word,
                                  String pronunciation,
                                  String partOfSpeech,
                                  String definitionVi,
                                  String definitionEn,
                                  String exampleSentence,
                                  String exampleTranslation,
                                  String level,
                                  String audioUrl) {
        target.setWord(word.trim());
        target.setPronunciation(blankToNull(pronunciation));
        target.setPartOfSpeech(blankToNull(partOfSpeech));
        target.setDefinitionVi(blankToNull(definitionVi));
        target.setDefinitionEn(blankToNull(definitionEn));
        target.setExampleSentence(blankToNull(exampleSentence));
        target.setExampleTranslation(blankToNull(exampleTranslation));
        target.setLevel(normalizeLevel(level));
        target.setAudioUrl(blankToNull(audioUrl));
    }

    private static String normalizeLevel(String level) {
        if (level == null || level.isBlank()) return null;
        return level.trim().toUpperCase();
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String textOrNull(JsonNode node, String... fields) {
        if (node == null) return null;
        for (String f : fields) {
            JsonNode child = node.get(f);
            if (child != null && !child.isNull()) {
                String s = child.asText();
                if (s != null && !s.isBlank()) return s;
            }
        }
        return null;
    }

    private static String csvEscape(String value) {
        if (value == null) return "";
        String v = value.replace("\"", "\"\"");
        if (v.contains(",") || v.contains("\"") || v.contains("\n") || v.contains("\r")) {
            return "\"" + v + "\"";
        }
        return v;
    }
}
