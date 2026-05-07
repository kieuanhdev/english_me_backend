package com.kiovant.englishme.dto;

import java.util.List;

public record ChatRequest(
        String message,
        List<ChatMessageDto> history
) {}
