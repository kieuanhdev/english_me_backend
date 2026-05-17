package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.DueCardResponse;
import com.kiovant.englishme.dto.ReviewRequest;
import com.kiovant.englishme.dto.ReviewResponse;
import com.kiovant.englishme.dto.StudySessionStartResponse;
import com.kiovant.englishme.dto.StudySessionSummaryResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.StudySessionService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/study-sessions")
public class StudySessionApiController {

    private final StudySessionService studySessionService;
    private final FirebaseAuthHelper authHelper;

    public StudySessionApiController(StudySessionService studySessionService,
                                     FirebaseAuthHelper authHelper) {
        this.studySessionService = studySessionService;
        this.authHelper = authHelper;
    }

    @GetMapping("/due-cards")
    public List<DueCardResponse> getDueCards(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam UUID deskId,
            @RequestParam(defaultValue = "20") int limit
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return studySessionService.getDueCards(token.getUid(), deskId, limit);
    }

    @PostMapping("/start")
    public StudySessionStartResponse startSession(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody Map<String, Object> body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        UUID deskId = parseDeskId(body.get("deskId"));
        int limit = parseLimit(body.get("limit"));
        return studySessionService.startSession(token.getUid(), deskId, limit);
    }

    @PostMapping("/{sessionId}/review")
    public ReviewResponse review(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID sessionId,
            @RequestBody ReviewRequest body
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        if (body == null || body.flashcardId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "flashcardId is required");
        }
        if (body.quality() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "quality is required");
        }
        return studySessionService.review(token.getUid(), sessionId, body.flashcardId(), body.quality(), body.responseTimeMs());
    }

    @GetMapping("/{sessionId}/summary")
    public StudySessionSummaryResponse getSummary(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable UUID sessionId
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return studySessionService.getSummary(token.getUid(), sessionId);
    }

    private static UUID parseDeskId(Object raw) {
        if (raw == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "deskId is required");
        }
        try {
            return UUID.fromString(raw.toString());
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "deskId must be a valid UUID");
        }
    }

    private static int parseLimit(Object raw) {
        if (raw == null) return 20;
        try {
            return Integer.parseInt(raw.toString());
        } catch (NumberFormatException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "limit must be a number");
        }
    }
}
