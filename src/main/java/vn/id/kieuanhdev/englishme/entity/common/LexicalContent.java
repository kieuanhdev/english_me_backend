package vn.id.kieuanhdev.englishme.entity.common;

import jakarta.persistence.Column;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;

/**
 * Các cột nội dung từ vựng dùng chung cho thư viện ({@code vocabularies}) và thẻ trong deck ({@code flashcards}).
 */
@Getter
@Setter
@MappedSuperclass
public abstract class LexicalContent {
	@Column(nullable = false, length = 200)
	private String word;

	@Column(length = 200)
	private String phonetic;

	@Column(name = "part_of_speech", length = 50)
	private String partOfSpeech;

	@Column(name = "meaning_vi", nullable = false, columnDefinition = "text")
	private String meaningVi;

	@Column(name = "example_sentence", columnDefinition = "text")
	private String exampleSentence;

	@Column(name = "audio_url", length = 500)
	private String audioUrl;

	@Column(name = "image_url", length = 500)
	private String imageUrl;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(name = "cefr_level", length = 2)
	private CefrLevel cefrLevel;
}
