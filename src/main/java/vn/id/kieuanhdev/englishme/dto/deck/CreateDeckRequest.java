package vn.id.kieuanhdev.englishme.dto.deck;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateDeckRequest(
	@NotBlank @Size(max = 200) String name,
	@Size(max = 10_000) String description,
	@Size(max = 100) String topic
) {
}
