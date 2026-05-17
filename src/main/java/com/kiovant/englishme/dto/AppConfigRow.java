package com.kiovant.englishme.dto;

import java.time.LocalDateTime;

public record AppConfigRow(
        String configKey,
        String configValue,
        String displayValue,
        String valueType,
        String description,
        boolean isSecret,
        LocalDateTime updatedAt,
        String updatedByEmail
) {
}
