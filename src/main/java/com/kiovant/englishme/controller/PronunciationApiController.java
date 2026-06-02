package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.PronunciationAssessTextRequest;
import com.kiovant.englishme.dto.PronunciationAttemptHistoryItemResponse;
import com.kiovant.englishme.entity.PronunciationExercise;
import com.kiovant.englishme.repository.PronunciationExerciseRepository;
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
    private final PronunciationExerciseRepository exerciseRepository;
    private final FirebaseAuthHelper authHelper;

    public PronunciationApiController(
            PronunciationAssessmentService pronunciationAssessmentService,
            PronunciationExerciseRepository exerciseRepository,
            FirebaseAuthHelper authHelper
    ) {
        this.pronunciationAssessmentService = pronunciationAssessmentService;
        this.exerciseRepository = exerciseRepository;
        this.authHelper = authHelper;
    }

    @GetMapping("/exercises")
    public List<PronunciationExercise> exercises() {
        return exerciseRepository.findAllByOrderByDifficultyAsc();
    }

    @PostMapping("/assess")
    public PronunciationAssessResponse assess(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam("audio") MultipartFile audio,
            @RequestParam(value = "expectedText", required = false) String expectedText,
            @RequestParam(value = "referenceText", required = false) String referenceText,
            @RequestParam(value = "exerciseId", required = false) UUID exerciseId,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId,
            @RequestParam(value = "language", required = false, defaultValue = "en-us") String language
    ) {
        String text = expectedText != null ? expectedText : referenceText;
        UUID exId = exerciseId != null ? exerciseId : lessonItemId;
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.assess(token.getUid(), audio, text, language, exId);
    }

    @PostMapping("/assess-text")
    public PronunciationAssessResponse assessText(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody PronunciationAssessTextRequest request
    ) {
        UUID exId = request.exerciseId() != null ? request.exerciseId() : request.lessonItemId();
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.assessText(
                token.getUid(), request.referenceText(), request.spokenText(), exId);
    }

    @GetMapping("/history")
    public List<PronunciationAttemptHistoryItemResponse> history(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(value = "exerciseId", required = false) UUID exerciseId,
            @RequestParam(value = "lessonItemId", required = false) UUID lessonItemId,
            @RequestParam(value = "limit", required = false, defaultValue = "20") int limit
    ) {
        UUID exId = exerciseId != null ? exerciseId : lessonItemId;
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return pronunciationAssessmentService.history(token.getUid(), exId, limit);
    }
}
