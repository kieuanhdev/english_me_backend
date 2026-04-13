package vn.id.kieuanhdev.englishme.dto.admin.vocabulary;

import jakarta.validation.constraints.Size;

/**
 * Cập nhật một phần: chỉ trường khác {@code null} được áp dụng.
 */
public record VocabularyUpdateRequest(
	@Size(max = 200) String word,
	@Size(max = 200) String phonetic,
	@Size(max = 50) String partOfSpeech,
	String meaningVi,
	String exampleSentence,
	@Size(max = 500) String audioUrl,
	@Size(max = 500) String imageUrl,
	@Size(max = 2) String cefrLevel
) {
}
