package vn.id.kieuanhdev.englishme.dto.admin.vocabulary;

import java.time.Instant;
import java.util.UUID;

public record VocabularyAdminResponse(
	UUID id,
	String word,
	String phonetic,
	String partOfSpeech,
	String meaningVi,
	String exampleSentence,
	String audioUrl,
	String imageUrl,
	String cefrLevel,
	Instant createdAt,
	Instant updatedAt,
	Instant deletedAt
) {
}
