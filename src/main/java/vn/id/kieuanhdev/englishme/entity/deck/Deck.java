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
import vn.id.kieuanhdev.englishme.entity.auth.User;

@Getter
@Setter
@Entity
@Table(name = "decks")
public class Deck {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "owner_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private User owner;

	@Column(nullable = false, length = 200)
	private String title;

	@Column(columnDefinition = "text")
	private String description;

	@Column(name = "is_public", nullable = false)
	private boolean isPublic = false;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(name = "cefr_level", length = 2)
	private CefrLevel cefrLevel;

	@Column(length = 100)
	private String topic;

	@Column(name = "is_system", nullable = false)
	private boolean isSystem = false;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "cloned_from_deck_id")
	private Deck clonedFrom;

	@Column(name = "word_count", nullable = false)
	private int wordCount = 0;

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
