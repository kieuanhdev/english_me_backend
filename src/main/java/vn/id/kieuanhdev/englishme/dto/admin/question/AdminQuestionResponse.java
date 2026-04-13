package vn.id.kieuanhdev.englishme.dto.admin.question;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record AdminQuestionResponse(
	UUID id,
	String content,
	List<String> options,
	String correctAnswer,
	String cefrBand,
	String skillType,
	double difficultyScore,
	boolean isActive,
	UUID createdBy,
	Instant createdAt,
	Instant updatedAt,
	Instant deletedAt
) {
}
