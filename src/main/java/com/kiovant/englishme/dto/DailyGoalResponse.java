package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Trạng thái mục tiêu XP/ngày của user (cho hôm nay).
 *
 * @param targetXp      mục tiêu XP đang đặt cho hôm nay.
 * @param earnedXp      XP đã kiếm trong ngày hôm nay.
 * @param reached       earnedXp >= targetXp.
 * @param allowedGoals  danh sách preset hợp lệ để app render lựa chọn.
 */
public record DailyGoalResponse(
        int targetXp,
        int earnedXp,
        boolean reached,
        List<Integer> allowedGoals
) {}
