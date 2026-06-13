package com.kiovant.englishme.dto;

import java.util.UUID;

/**
 * Phản hồi khi bắt đầu phiên CAT: chỉ trả câu hỏi ĐẦU TIÊN (1 câu).
 * Các câu sau lấy dần qua /answer (nextQuestion). Xem docs/placement-test-cat-upgrade.md.
 */
public record StartTestResponse(
        UUID sessionId,
        QuestionDto firstQuestion,
        // Số câu tối đa của phiên (CAT dừng khi đủ).
        int maxQuestions,
        // Thông báo tĩnh cho người dùng TRƯỚC khi làm bài.
        String notice
) {}
