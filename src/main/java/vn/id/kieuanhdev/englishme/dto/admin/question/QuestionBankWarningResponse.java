package vn.id.kieuanhdev.englishme.dto.admin.question;

import java.util.Map;

public record QuestionBankWarningResponse(int minQuestionsPerBand, Map<String, Long> currentCountByBand, Map<String, Long> missingByBand) {
}
