package com.kiovant.englishme.dto;

/**
 * Request khi user tự đặt mục tiêu XP/ngày.
 * targetXp phải thuộc tập preset hợp lệ (xem ProgressService.ALLOWED_DAILY_GOALS).
 */
public record UpdateDailyGoalRequest(
        Integer targetXp
) {}
