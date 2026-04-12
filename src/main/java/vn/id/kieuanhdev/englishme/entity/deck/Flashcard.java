package vn.id.kieuanhdev.englishme.entity.deck;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.type.SqlTypes;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;

@Getter
@Setter
@Entity
@Table(name = "flashcards")
public class Flashcard {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "deck_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private Deck deck;

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

	@Column(name = "deleted_at")
	private Instant deletedAt;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt;

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		var now = Instant.now();
		createdAt = now;
		updatedAt = now;
	}

	@PreUpdate
	void preUpdate() {
		updatedAt = Instant.now();
	}

	public boolean isDeleted() {
		return deletedAt != null;
	}
}
