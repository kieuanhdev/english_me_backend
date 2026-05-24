package com.kiovant.englishme.dto;

/**
 * Body cho PUT /admin/api/xp-rules/{sourceType}. Tất cả field optional —
 * chỉ field được gửi sẽ ghi đè giá trị hiện tại.
 */
public record XpRuleUpdateRequest(
        Integer baseAmount,
        Integer perCorrect,
        Integer accuracyBonus,
        Short accuracyThresholdPct,
        Integer dailyCap,
        Boolean enabled,
        String description
) {}
