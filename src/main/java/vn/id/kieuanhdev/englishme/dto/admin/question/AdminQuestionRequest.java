package vn.id.kieuanhdev.englishme.dto.admin.question;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record AdminQuestionRequest(
	@NotBlank @Size(max = 2000) String content,
	@NotNull @Size(min = 4, max = 4) List<String> options,
	@NotBlank String correctAnswer,
	@NotBlank String cefrBand,
	@NotBlank String skillType,
	@NotNull @Min(0) @Max(1) Double difficultyScore,
	Boolean isActive
) {
}
