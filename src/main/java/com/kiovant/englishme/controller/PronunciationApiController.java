package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationAttemptHistoryItemResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.PronunciationAssessmentService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/pronunciation")
public class PronunciationApiController {

    private final PronunciationAssessmentService pronunciationAssessmentService;
    private final FirebaseAuthHelper authHelper;

    public PronunciationApiController(PronunciationAssessmentService pronunciationAssessmentService, FirebaseAuthHelper authHelper) {
        this.pronunciationAssessmentService = pronunciationAssessmentService;
        this.authHelper = authHelper;
    }

    @PostMapping("/assess")
    public PronunciationAssessResponse assess(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam("audio") MultipartFile audio,
            @RequestParam("referenceText") String referenceText,
            @RequestParam(value = "language", required = false, defaultValue = "en-us") String language,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.assess(
                token.getUid(),
                audio,
                referenceText,
                language,
                lessonItemId
        );
    }

    @GetMapping("/history")
    public List<PronunciationAttemptHistoryItemResponse> history(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId,
            @RequestParam(value = "limit", required = false, defaultValue = "20") int limit
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.history(token.getUid(), lessonItemId, limit);
    }
}
