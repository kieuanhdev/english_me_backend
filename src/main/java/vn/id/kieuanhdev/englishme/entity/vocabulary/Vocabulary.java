package vn.id.kieuanhdev.englishme.entity.vocabulary;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import vn.id.kieuanhdev.englishme.entity.common.LexicalContent;

@Getter
@Setter
@Entity
@Table(name = "vocabularies")
public class Vocabulary extends LexicalContent {
	@Id
	private UUID id;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (createdAt == null) {
			createdAt = Instant.now();
		}
	}
}
