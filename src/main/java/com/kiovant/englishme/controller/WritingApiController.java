package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.WritingGradeRequest;
import com.kiovant.englishme.dto.WritingGradeResponse;
import com.kiovant.englishme.dto.WritingPromptResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.WritingService;
import org.springframework.web.bind.annotation.*;

/**
 * API luyện Viết theo đề với AI. /prompt sinh đề theo level; /grade chấm bài +
 * cộng XP. Stateless: FE giữ promptId + đề, gửi lại khi nộp. Auth Firebase Bearer.
 */
@RestController
@RequestMapping("/api/writing")
public class WritingApiController {

    private final WritingService writingService;
    private final FirebaseAuthHelper authHelper;

    public WritingApiController(WritingService writingService, FirebaseAuthHelper authHelper) {
        this.writingService = writingService;
        this.authHelper = authHelper;
    }

    /** Sinh đề viết theo CEFR. */
    @GetMapping("/prompt")
    public WritingPromptResponse prompt(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(required = false) String level
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return writingService.generatePrompt(token.getUid(), level);
    }

    /** Chấm bài viết + cộng XP. */
    @PostMapping("/grade")
    public WritingGradeResponse grade(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody WritingGradeRequest request
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        if (request == null) {
            return writingService.grade(token.getUid(), null, null, null, null);
        }
        return writingService.grade(
                token.getUid(),
                request.promptId(),
                request.prompt(),
                request.level(),
                request.essay()
        );
    }
}
