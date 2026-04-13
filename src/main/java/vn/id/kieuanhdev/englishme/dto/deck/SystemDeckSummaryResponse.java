package vn.id.kieuanhdev.englishme.dto.deck;

import java.util.UUID;

public record SystemDeckSummaryResponse(
	UUID deckId,
	String name,
	String description,
	long wordCount,
	String topic,
	String cefrLevel
) {
}
