package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.VocabularyTopicResponse;
import com.kiovant.englishme.dto.VocabularyWordResponse;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.UserRepository;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.VocabularyService;
import com.kiovant.englishme.service.WordOfDayService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/vocabulary")
public class VocabularyController {

    private final VocabularyService vocabularyService;
    private final WordOfDayService wordOfDayService;
    private final FirebaseAuthHelper firebaseAuthHelper;
    private final UserRepository userRepository;

    public VocabularyController(VocabularyService vocabularyService,
                                WordOfDayService wordOfDayService,
                                FirebaseAuthHelper firebaseAuthHelper,
                                UserRepository userRepository) {
        this.vocabularyService = vocabularyService;
        this.wordOfDayService = wordOfDayService;
        this.firebaseAuthHelper = firebaseAuthHelper;
        this.userRepository = userRepository;
    }

    @GetMapping("/topics")
    public List<VocabularyTopicResponse> getTopics() {
        return vocabularyService.getTopics();
    }

    @GetMapping("/topics/{topicId}/words")
    public List<VocabularyWordResponse> getWordsByTopic(@PathVariable UUID topicId) {
        return vocabularyService.getWordsByTopic(topicId);
    }

    @GetMapping("/word-of-day")
    public VocabularyWordResponse getWordOfDay(@RequestHeader("Authorization") String authorization) {
        var token = firebaseAuthHelper.verifyBearer(authorization);
        User user = userRepository.findByFirebaseUid(token.getUid())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        if (user.getCefrLevel() == null || user.getCefrLevel().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User has no CEFR level set");
        }
        return wordOfDayService.getWordOfDay(user.getCefrLevel());
    }
}
