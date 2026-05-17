package com.kiovant.englishme.dto;

import java.util.List;

public record VocabularyImportResult(
        int totalRows,
        int inserted,
        int skipped,
        List<String> errors
) {}
