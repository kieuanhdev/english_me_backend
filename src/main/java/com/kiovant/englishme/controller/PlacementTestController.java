package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.PlacementTestService;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/placement-test")
public class PlacementTestController {

    private final PlacementTestService placementTestService;
    private final FirebaseAuthHelper authHelper;

    public PlacementTestController(PlacementTestService placementTestService, FirebaseAuthHelper authHelper) {
        this.placementTestService = placementTestService;
        this.authHelper = authHelper;
    }

    // Bắt đầu phiên CAT — trả về câu hỏi ĐẦU TIÊN (1 câu) + notice + maxQuestions
    @PostMapping("/start")
    public StartTestResponse startTest(@RequestHeader("Authorization") String token) {
        FirebaseToken decoded = authHelper.verifyBearer(token);
        return placementTestService.startTest(decoded.getUid());
    }

    // Trả lời 1 câu — nhận đáp án đúng + giải thích + câu kế tiếp (CAT) hoặc isDone.
    // Session load theo (sessionId, uid) trong service — user khác không đụng được.
    @PostMapping("/{sessionId}/answer")
    public CatAnswerResponse answerQuestion(
            @RequestHeader("Authorization") String token,
            @PathVariable UUID sessionId,
            @RequestBody AnswerQuestionRequest request
    ) {
        FirebaseToken decoded = authHelper.verifyBearer(token);
        return placementTestService.answerQuestion(decoded.getUid(), sessionId, request);
    }

    // Hoàn thành bài — nhận kết quả CEFR + tổng điểm
    @PostMapping("/{sessionId}/complete")
    public TestResultResponse completeTest(
            @RequestHeader("Authorization") String token,
            @PathVariable UUID sessionId
    ) {
        FirebaseToken decoded = authHelper.verifyBearer(token);
        return placementTestService.completeTest(decoded.getUid(), sessionId);
    }

    // Tự chọn trình độ — không làm bài kiểm tra, set CEFR + onboarded
    @PostMapping("/self-select")
    public UserSyncResponse selfSelectLevel(
            @RequestHeader("Authorization") String token,
            @RequestBody SelfSelectLevelRequest request
    ) {
        FirebaseToken decoded = authHelper.verifyBearer(token);
        return placementTestService.selfSelectLevel(decoded.getUid(), request);
    }
}
