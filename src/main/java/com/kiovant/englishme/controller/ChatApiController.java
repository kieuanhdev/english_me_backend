package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.ChatRequest;
import com.kiovant.englishme.dto.ChatResponse;
import com.kiovant.englishme.service.DeepSeekChatService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chat")
public class ChatApiController {

    private final DeepSeekChatService chatService;
    private final FirebaseAuthHelper authHelper;

    public ChatApiController(DeepSeekChatService chatService, FirebaseAuthHelper authHelper) {
        this.chatService = chatService;
        this.authHelper = authHelper;
    }

    @PostMapping
    public ChatResponse chat(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody ChatRequest body
    ) {
        authHelper.verifyBearer(authorization);
        return chatService.chat(body);
    }
}
