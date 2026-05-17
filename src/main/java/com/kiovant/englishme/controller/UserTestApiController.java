package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.TestHistoryItem;
import com.kiovant.englishme.dto.UserTestStartRequest;
import com.kiovant.englishme.dto.UserTestStartResponse;
import com.kiovant.englishme.dto.UserTestSubmitRequest;
import com.kiovant.englishme.dto.UserTestSubmitResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.UserTestService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tests")
public class UserTestApiController {

    private final UserTestService userTestService;
    private final FirebaseAuthHelper authHelper;

    public UserTestApiController(UserTestService userTestService, FirebaseAuthHelper authHelper) {
        this.userTestService = userTestService;
        this.authHelper = authHelper;
    }

    @PostMapping("/sessions")
    public UserTestStartResponse createSession(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody(required = false) UserTestStartRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        if (body == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Request body is required");
        }
        return userTestService.createSession(token.getUid(), body.topic(), body.level());
    }

    @PostMapping("/sessions/{sessionId}/submit")
    public UserTestSubmitResponse submit(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID sessionId,
            @RequestBody(required = false) UserTestSubmitRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return userTestService.submit(
                token.getUid(),
                sessionId,
                body == null ? List.of() : body.answers(),
                body == null ? null : body.timeTakenSeconds()
        );
    }

    @GetMapping("/history")
    public List<TestHistoryItem> getHistory(
            @RequestHeader(value = "Authorization", required = false) String authorization
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return userTestService.getHistory(token.getUid());
    }
}
