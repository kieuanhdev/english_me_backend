package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.ExerciseCompleteRequest;
import com.kiovant.englishme.dto.ExerciseCompleteResponse;
import com.kiovant.englishme.dto.ExerciseSessionResponse;
import com.kiovant.englishme.service.ExerciseService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/exercises")
public class ExerciseApiController {

    private final ExerciseService exerciseService;
    private final FirebaseAuthHelper authHelper;

    public ExerciseApiController(ExerciseService exerciseService, FirebaseAuthHelper authHelper) {
        this.exerciseService = exerciseService;
        this.authHelper = authHelper;
    }

    @GetMapping("/sessions")
    public ExerciseSessionResponse createSession(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam String category,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String level
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return exerciseService.createSession(token.getUid(), category, size, level);
    }

    @PostMapping("/sessions/{sessionId}/complete")
    public ExerciseCompleteResponse completeSession(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID sessionId,
            @RequestBody(required = false) ExerciseCompleteRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return exerciseService.completeSession(
                token.getUid(),
                sessionId,
                body == null ? List.of() : body.answers()
        );
    }
}
