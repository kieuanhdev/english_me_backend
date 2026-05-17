package com.kiovant.englishme.dto;

import java.util.List;

public record TestBankImportResult(
        int totalRows,
        int inserted,
        int skipped,
        List<String> errors
) {
}
