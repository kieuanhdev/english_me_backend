package com.kiovant.englishme.dto;

import java.time.Instant;

/**
 * Một entry trong lịch sử transaction XP (GET /api/users/me/xp/ledger).
 *
 * Khác với XpHistoryItem (cộng dồn theo ngày, phục vụ chart streak):
 * XpLedgerItem ánh xạ 1-1 tới 1 row xp_ledger — 1 transaction cụ thể.
 */
public record XpLedgerItem(
        Long id,
        int amount,
        String sourceType,
        String sourceId,
        Instant occurredAt
) {}
