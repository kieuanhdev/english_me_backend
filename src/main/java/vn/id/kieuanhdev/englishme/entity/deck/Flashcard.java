package vn.id.kieuanhdev.englishme.entity.deck;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import vn.id.kieuanhdev.englishme.entity.common.LexicalContent;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;

@Getter
@Setter
@Entity
@Table(name = "flashcards")
public class Flashcard extends LexicalContent {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "deck_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private Deck deck;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "vocabulary_id")
	private Vocabulary vocabulary;

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
