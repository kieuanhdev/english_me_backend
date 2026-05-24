package com.kiovant.englishme.dto;

import java.util.List;

/**
 * Trang lịch sử ledger với cursor pagination.
 * nextCursor = id của row cuối cùng trong items (null nếu hết).
 */
public record XpLedgerPage(
        List<XpLedgerItem> items,
        String nextCursor
) {}
