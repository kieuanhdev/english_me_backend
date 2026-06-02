package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.ConversationChatRequest;
import com.kiovant.englishme.dto.ConversationChatResponse;
import com.kiovant.englishme.dto.ConversationSummaryRequest;
import com.kiovant.englishme.dto.ConversationSummaryResponse;
import com.kiovant.englishme.service.ConversationService;
import com.kiovant.englishme.service.FirebaseAuthHelper;
import org.springframework.web.bind.annotation.*;

/**
 * API luyện nói hội thoại với AI (giống GPT voice chat). Stateless: FE gửi full
 * lịch sử mỗi lượt. Auth bằng Firebase Bearer token, nhất quán với các API khác.
 */
@RestController
@RequestMapping("/api/conversation")
public class ConversationApiController {

    private final ConversationService conversationService;
    private final FirebaseAuthHelper authHelper;

    public ConversationApiController(
            ConversationService conversationService,
            FirebaseAuthHelper authHelper
    ) {
        this.conversationService = conversationService;
        this.authHelper = authHelper;
    }

    /** Một lượt hội thoại: nhận lịch sử (kèm câu user vừa nói) -> trả câu AI. */
    @PostMapping("/chat")
    public ConversationChatResponse chat(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody ConversationChatRequest request
    ) {
        authHelper.verifyBearer(authorization);
        return conversationService.chat(request.topic(), request.history());
    }

    /** Tổng kết & nhận xét cả đoạn hội thoại sau khi người học kết thúc. */
    @PostMapping("/summary")
    public ConversationSummaryResponse summary(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody ConversationSummaryRequest request
    ) {
        authHelper.verifyBearer(authorization);
        return conversationService.summarize(request.topic(), request.history());
    }
}
