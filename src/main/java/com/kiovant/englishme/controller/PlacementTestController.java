package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.*;
import com.kiovant.englishme.service.PlacementTestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/placement-test")
public class PlacementTestController {

    @Autowired
    private PlacementTestService placementTestService;

    // Bắt đầu bài kiểm tra — trả về 12 câu hỏi (không có đáp án)
    @PostMapping("/start")
    public StartTestResponse startTest(@RequestHeader("Authorization") String token) throws Exception {
        String uid = verifyToken(token);
        return placementTestService.startTest(uid);
    }

    // Trả lời 1 câu — nhận ngay đáp án đúng + giải thích
    @PostMapping("/{sessionId}/answer")
    public AnswerQuestionResponse answerQuestion(
            @RequestHeader("Authorization") String token,
            @PathVariable UUID sessionId,
            @RequestBody AnswerQuestionRequest request
    ) throws Exception {
        verifyToken(token);
        return placementTestService.answerQuestion(sessionId, request);
    }

    // Hoàn thành bài — nhận kết quả CEFR + tổng điểm
    @PostMapping("/{sessionId}/complete")
    public TestResultResponse completeTest(
            @RequestHeader("Authorization") String token,
            @PathVariable UUID sessionId
    ) throws Exception {
        verifyToken(token);
        return placementTestService.completeTest(sessionId);
    }

    private String verifyToken(String authHeader) throws Exception {
        String idToken = authHeader.replace("Bearer ", "");
        FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(idToken);
        return decoded.getUid();
    }
}
