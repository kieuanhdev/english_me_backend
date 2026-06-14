package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.GrammarLessonDetailResponse;
import com.kiovant.englishme.dto.GrammarLessonListItemResponse;
import com.kiovant.englishme.dto.GrammarLevelGroupResponse;
import com.kiovant.englishme.dto.GrammarPracticeItem;
import com.kiovant.englishme.dto.GrammarPracticeRequest;
import com.kiovant.englishme.dto.GrammarTopicResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.GrammarPracticeService;
import com.kiovant.englishme.service.GrammarService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/grammar")
public class GrammarController {

    private final GrammarService grammarService;
    private final GrammarPracticeService grammarPracticeService;
    private final FirebaseAuthHelper authHelper;

    public GrammarController(
            GrammarService grammarService,
            GrammarPracticeService grammarPracticeService,
            FirebaseAuthHelper authHelper
    ) {
        this.grammarService = grammarService;
        this.grammarPracticeService = grammarPracticeService;
        this.authHelper = authHelper;
    }

    @GetMapping("/topics")
    public List<GrammarTopicResponse> getTopics() {
        return grammarService.getTopics();
    }

    @GetMapping("/levels")
    public List<GrammarLevelGroupResponse> getTopicsByLevel() {
        return grammarService.getTopicsGroupedByLevel();
    }

    @GetMapping("/topics/{id}/lessons")
    public List<GrammarLessonListItemResponse> getLessonsByTopic(@PathVariable String id) {
        return grammarService.getLessonsByTopicId(id);
    }

    @GetMapping("/lessons/{id}")
    public GrammarLessonDetailResponse getLessonDetail(@PathVariable String id) {
        return grammarService.getLessonDetail(id);
    }

    /**
     * Sinh thêm câu luyện tập CÙNG DẠNG với câu người học vừa làm sai (AI).
     * Auth Firebase Bearer như mọi endpoint mobile. AI hỏng -> trả list rỗng (200), FE báo thử lại.
     */
    @PostMapping("/practice/similar")
    public List<GrammarPracticeItem> generateSimilarPractice(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody GrammarPracticeRequest request
    ) {
        authHelper.verifyBearer(authorization);
        return grammarPracticeService.generateSimilar(
                request.lessonId(), request.exerciseType(), request.wrongContent(), request.count());
    }
}
