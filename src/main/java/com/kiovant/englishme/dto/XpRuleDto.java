package com.kiovant.englishme.dto;

import com.kiovant.englishme.entity.XpRule;

import java.time.Instant;

/**
 * DTO trả về cho admin endpoint xp-rules. Mirror toàn bộ field của entity
 * (không expose entity trực tiếp).
 */
public record XpRuleDto(
        String sourceType,
        Integer baseAmount,
        Integer perCorrect,
        Integer accuracyBonus,
        Short accuracyThresholdPct,
        Integer dailyCap,
        Boolean enabled,
        String description,
        Instant updatedAt
) {
    public static XpRuleDto from(XpRule r) {
        return new XpRuleDto(
                r.getSourceType(),
                r.getBaseAmount(),
                r.getPerCorrect(),
                r.getAccuracyBonus(),
                r.getAccuracyThresholdPct(),
                r.getDailyCap(),
                r.getEnabled(),
                r.getDescription(),
                r.getUpdatedAt()
        );
    }
}
