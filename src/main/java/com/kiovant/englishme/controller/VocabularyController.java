package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.VocabularyTopicResponse;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.service.VocabularyService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/vocabulary")
public class VocabularyController {

    private final VocabularyService vocabularyService;

    public VocabularyController(VocabularyService vocabularyService) {
        this.vocabularyService = vocabularyService;
    }

    @GetMapping("/topics")
    public List<VocabularyTopicResponse> getTopics() {
        return vocabularyService.getTopics();
    }

    @GetMapping("/topics/{topicId}/words")
    public List<VocabularyWordResponse> getWordsByTopic(@PathVariable UUID topicId) {
        return vocabularyService.getWordsByTopic(topicId);
    }
}
