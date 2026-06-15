package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseToken;
import com.kiovant.englishme.dto.WritingChatRequest;
import com.kiovant.englishme.dto.WritingChatResponse;
import com.kiovant.englishme.dto.WritingCompleteRequest;
import com.kiovant.englishme.dto.WritingCompleteResponse;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import com.kiovant.englishme.service.WritingService;
import org.springframework.web.bind.annotation.*;

/**
 * API luyện Viết với gia sư AI. Stateless: FE gửi full lịch sử mỗi lượt.
 * Auth bằng Firebase Bearer token, nhất quán các API mobile khác.
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

    @PostMapping("/chat")
    public WritingChatResponse chat(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody WritingChatRequest request
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return writingService.chat(token.getUid(), request == null ? null : request.history());
    }

    @PostMapping("/complete")
    public WritingCompleteResponse complete(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody WritingCompleteRequest request
    ) {
        FirebaseToken token = authHelper.verifyBearer(authorization);
        return writingService.complete(
                token.getUid(),
                request == null ? null : request.sessionId(),
                request == null ? 0 : request.turns()
        );
    }
}
