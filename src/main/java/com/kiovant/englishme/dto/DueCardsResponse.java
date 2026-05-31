package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Response cho GET /api/study-sessions/due-cards.
 * Tach 2 nhom: the den han on (dueCards) + the moi chua hoc (newCards).
 * totalDue/totalNew la TONG that su trong desk (khong bi gioi han boi limit),
 * dung cho dem tien do (FE: dueToday + mini progress tren card).
 */
public record DueCardsResponse(
        List<DueCardResponse> dueCards,
        List<DueCardResponse> newCards,
        long totalDue,
        long totalNew
) {
}
