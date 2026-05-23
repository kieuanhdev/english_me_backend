package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.service.LearningService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/learning")
public class LearningController {

    private final LearningService learningService;

    public LearningController(LearningService learningService) {
        this.learningService = learningService;
    }

    @GetMapping("/hub")
    public LearningHubResponse getHub(@RequestParam(required = false) String level) {
        return learningService.getHub(level);
    }

    @GetMapping("/levels/{level}")
    public LevelDetailResponse getLevel(@PathVariable String level) {
        return learningService.getLevel(level);
    }

    @GetMapping("/levels/{level}/skills/{skill}/lessons")
    public SkillLessonsResponse getSkillLessons(@PathVariable String level, @PathVariable String skill) {
        return learningService.getSkillLessons(level, skill);
    }

    @GetMapping("/lessons/{lessonId}")
    public LessonDetailResponse getLessonDetail(@PathVariable String lessonId) {
        return learningService.getLessonDetail(lessonId);
    }

    @PostMapping("/lessons/{lessonId}/complete")
    public LessonCompleteResponse completeLesson(@PathVariable String lessonId,
                                                  @RequestBody LessonCompleteRequest request) {
        return learningService.completeLesson(lessonId, request);
    }

    @GetMapping("/recommendations")
    public RecommendationsResponse getRecommendations() {
        return learningService.getRecommendations();
    }
}
