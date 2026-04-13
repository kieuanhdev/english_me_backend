package vn.id.kieuanhdev.englishme.dto.admin.vocabulary;

import java.util.List;

public record VocabularyImportResponse(
	int totalRows,
	int successCount,
	int errorCount,
	List<ImportRowError> errors
) {
}
