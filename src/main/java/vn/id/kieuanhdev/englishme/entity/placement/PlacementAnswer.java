package vn.id.kieuanhdev.englishme.entity.placement;

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
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@Entity
@Table(name = "placement_answers")
public class PlacementAnswer {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "session_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private PlacementSession session;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "question_id", nullable = false)
	private CefrQuestion question;

	@Column(name = "user_answer", length = 10)
	private String userAnswer;

	@Column(name = "is_correct", nullable = false)
	private boolean correct;

	@Column(name = "answered_at", nullable = false)
	private Instant answeredAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (answeredAt == null) {
			answeredAt = Instant.now();
		}
	}
}
