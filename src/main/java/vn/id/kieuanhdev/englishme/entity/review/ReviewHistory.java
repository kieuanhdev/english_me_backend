package vn.id.kieuanhdev.englishme.entity.review;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import vn.id.kieuanhdev.englishme.entity.auth.User;
import vn.id.kieuanhdev.englishme.entity.deck.Flashcard;

@Getter
@Setter
@Entity
@Table(name = "review_history")
@Check(constraints = "quality >= 0 and quality <= 5")
public class ReviewHistory {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "flashcard_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private Flashcard flashcard;

	@Column(nullable = false)
	private Integer quality;

	@Column(name = "ef_before", nullable = false)
	private Double efBefore;

	@Column(name = "ef_after", nullable = false)
	private Double efAfter;

	@Column(name = "interval_before", nullable = false)
	private Integer intervalBefore;

	@Column(name = "interval_after", nullable = false)
	private Integer intervalAfter;

	@Column(name = "reviewed_at", nullable = false)
	private Instant reviewedAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (reviewedAt == null) {
			reviewedAt = Instant.now();
		}
	}
}
