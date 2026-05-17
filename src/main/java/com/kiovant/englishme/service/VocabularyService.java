package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.VocabularyTopicResponse;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.entity.VocabularyTopic;
import com.kiovant.englishme.repository.VocabularyTopicRepository;
import com.kiovant.englishme.repository.VocabularyWordRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class VocabularyService {

    private final VocabularyTopicRepository topicRepository;
    private final VocabularyWordRepository wordRepository;

    public VocabularyService(VocabularyTopicRepository topicRepository, VocabularyWordRepository wordRepository) {
        this.topicRepository = topicRepository;
        this.wordRepository = wordRepository;
    }

    @Transactional(readOnly = true)
    public List<VocabularyTopicResponse> getTopics() {
        return topicRepository.findAllByOrderBySortOrderAsc().stream()
                .map(t -> new VocabularyTopicResponse(
                        t.getId(),
                        t.getName(),
                        t.getNameEn(),
                        t.getIcon(),
                        topicRepository.countWordsByTopicId(t.getId()),
                        t.getLevel(),
                        t.getColorHex()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<VocabularyWordResponse> getWordsByTopic(UUID topicId) {
        if (!topicRepository.existsById(topicId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vocabulary topic not found");
        }
        return wordRepository.findByTopic_IdOrderByWordAsc(topicId).stream()
                .map(w -> new VocabularyWordResponse(
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
                        w.getAudioUrl()))
                .toList();
    }
}
