package com.kiovant.englishme.dto;

import java.time.LocalDate;

public record XpHistoryItem(
        LocalDate date,
        Integer xp
) {}
