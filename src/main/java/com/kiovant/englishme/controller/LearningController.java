package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.LearningService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/learning")
public class LearningController {

    private final LearningService learningService;
    private final FirebaseAuthHelper authHelper;

    public LearningController(LearningService learningService, FirebaseAuthHelper authHelper) {
        this.learningService = learningService;
        this.authHelper = authHelper;
    }

    @GetMapping("/hub")
    public LearningHubResponse getHub(@RequestHeader("Authorization") String token,
                                       @RequestParam(required = false) String level) {
        var decoded = authHelper.verifyBearer(token);
        return learningService.getHub(decoded.getUid(), level);
    }

    @GetMapping("/levels/{level}/skills/{skill}/lessons")
    public SkillLessonsResponse getSkillLessons(@RequestHeader("Authorization") String token,
                                                 @PathVariable String level,
                                                 @PathVariable String skill) {
        var decoded = authHelper.verifyBearer(token);
        return learningService.getSkillLessons(decoded.getUid(), level, skill);
    }

    @GetMapping("/paths/{pathId}")
    public LearningPathDetailResponse getPathDetail(@RequestHeader("Authorization") String token,
                                                     @PathVariable String pathId) {
        var decoded = authHelper.verifyBearer(token);
        return learningService.getPathDetail(decoded.getUid(), pathId);
    }

    @GetMapping("/lessons/{lessonId}")
    public LessonDetailResponse getLessonDetail(@RequestHeader("Authorization") String token,
                                                 @PathVariable String lessonId) {
        var decoded = authHelper.verifyBearer(token);
        return learningService.getLessonDetail(decoded.getUid(), lessonId);
    }

    @PostMapping("/lessons/{lessonId}/complete")
    public LessonCompleteResponse completeLesson(@RequestHeader("Authorization") String token,
                                                  @PathVariable String lessonId,
                                                  @RequestBody LessonCompleteRequest request) {
        var decoded = authHelper.verifyBearer(token);
        return learningService.completeLesson(decoded.getUid(), lessonId, request);
    }
}
