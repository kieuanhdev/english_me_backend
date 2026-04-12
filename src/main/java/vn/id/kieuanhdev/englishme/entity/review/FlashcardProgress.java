package vn.id.kieuanhdev.englishme.entity.review;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.type.SqlTypes;
import vn.id.kieuanhdev.englishme.entity.auth.User;
import vn.id.kieuanhdev.englishme.entity.deck.Flashcard;

@Getter
@Setter
@Entity
@Table(
	name = "flashcard_progress",
	uniqueConstraints = @UniqueConstraint(name = "uq_flashcard_progress_user_card", columnNames = { "user_id", "flashcard_id" })
)
@Check(
	constraints = "easiness_factor >= 1.3 and interval_days >= 0 and repetitions >= 0 "
		+ "and (last_quality is null or (last_quality >= 0 and last_quality <= 5)) "
		+ "and status in ('NEW','LEARNING','MASTERED')"
)
public class FlashcardProgress {
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

	@Column(name = "easiness_factor", nullable = false)
	private Double easinessFactor = 2.5;

	@Column(name = "interval_days", nullable = false)
	private Integer intervalDays = 0;

	@Column(nullable = false)
	private Integer repetitions = 0;

	@Column(name = "next_review_at", nullable = false)
	private Instant nextReviewAt;

	@Column(name = "last_reviewed_at")
	private Instant lastReviewedAt;

	@Column(name = "last_quality")
	private Integer lastQuality;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(nullable = false, length = 20)
	private FlashcardProgressStatus status;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (nextReviewAt == null) {
			nextReviewAt = Instant.now();
		}
		if (easinessFactor == null) {
			easinessFactor = 2.5;
		}
		if (intervalDays == null) {
			intervalDays = 0;
		}
		if (repetitions == null) {
			repetitions = 0;
		}
		if (status == null) {
			status = FlashcardProgressStatus.NEW;
		}
	}
}
