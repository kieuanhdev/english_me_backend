package com.kiovant.englishme.dto;

import java.util.List;
import java.util.UUID;

public record StartTestResponse(
        UUID sessionId,
        List<QuestionDto> questions,
        int totalQuestions,
        // Thông báo tĩnh cho người dùng TRƯỚC khi làm bài: bài đầu vào chỉ xác định
        // trình độ tối đa tới B2 + câu bỏ trống tính là sai. Xem HE_THONG_KIEM_TRA_TRINH_DO.md §A.7.
        String notice
) {}
