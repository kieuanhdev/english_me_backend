package com.kiovant.englishme.controller;

import com.google.firebase.auth.FirebaseAuth;
import com.kiovant.englishme.dto.ChatRequest;
import com.kiovant.englishme.dto.ChatResponse;
import com.kiovant.englishme.service.GroqChatService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@RestController
@RequestMapping("/api/chat")
public class ChatApiController {

    private final GroqChatService groqChatService;

    public ChatApiController(GroqChatService groqChatService) {
        this.groqChatService = groqChatService;
    }

    /** Chat với AI (ngữ cảnh giáo viên tiếng Anh) — yêu cầu Bearer Firebase */
    @PostMapping
    public ChatResponse chat(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody ChatRequest body
    ) throws Exception {
        verifyBearer(authorization);
        return groqChatService.chat(body);
    }

    private static void verifyBearer(String authorization) throws Exception {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(UNAUTHORIZED, "Authorization Bearer token required");
        }
        String idToken = authorization.substring(7).trim();
        if (idToken.isEmpty()) {
            throw new ResponseStatusException(UNAUTHORIZED, "Missing token");
        }
        FirebaseAuth.getInstance().verifyIdToken(idToken);
    }
}
