package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.DictationCompleteRequest;
import com.kiovant.englishme.dto.DictationCompleteResponse;
import com.kiovant.englishme.dto.DictationSessionResponse;
import com.kiovant.englishme.service.DictationService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dictation")
public class DictationApiController {

    private final DictationService dictationService;
    private final FirebaseAuthHelper authHelper;

    public DictationApiController(DictationService dictationService, FirebaseAuthHelper authHelper) {
        this.dictationService = dictationService;
        this.authHelper = authHelper;
    }

    @GetMapping("/sessions")
    public DictationSessionResponse createSession(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(required = false) String level,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(required = false) String lessonId
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return dictationService.createSession(token.getUid(), level, size, lessonId);
    }

    @PostMapping("/sessions/complete")
    public DictationCompleteResponse complete(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody DictationCompleteRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return dictationService.complete(
                token.getUid(),
                body == null ? null : body.sessionId(),
                body == null ? 0 : body.correct(),
                body == null ? 0 : body.total()
        );
    }
}
