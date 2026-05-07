package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.GrammarLessonDetailResponse;
import com.kiovant.englishme.dto.GrammarLessonListItemResponse;
import com.kiovant.englishme.dto.GrammarTopicResponse;
import com.kiovant.englishme.service.GrammarService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/grammar")
public class GrammarController {

    private final GrammarService grammarService;

    public GrammarController(GrammarService grammarService) {
        this.grammarService = grammarService;
    }

    @GetMapping("/topics")
    public List<GrammarTopicResponse> getTopics() {
        return grammarService.getTopics();
    }

    @GetMapping("/topics/{id}/lessons")
    public List<GrammarLessonListItemResponse> getLessonsByTopic(@PathVariable String id) {
        return grammarService.getLessonsByTopicId(id);
    }

    @GetMapping("/lessons/{id}")
    public GrammarLessonDetailResponse getLessonDetail(@PathVariable String id) {
        return grammarService.getLessonDetail(id);
    }
}
