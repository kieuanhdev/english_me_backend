package vn.id.kieuanhdev.englishme.entity.placement;

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
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.type.SqlTypes;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.auth.User;

@Getter
@Setter
@Entity
@Table(name = "placement_sessions")
@Check(constraints = "total_questions >= 0 and correct_answers >= 0")
public class PlacementSession {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private User user;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(nullable = false, length = 20)
	private PlacementSessionStatus status = PlacementSessionStatus.IN_PROGRESS;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(name = "final_cefr_band", length = 2)
	private CefrLevel finalCefrBand;

	@Column(name = "total_questions", nullable = false)
	private Integer totalQuestions = 0;

	@Column(name = "correct_answers", nullable = false)
	private Integer correctAnswers = 0;

	@Column(name = "started_at", nullable = false)
	private Instant startedAt;

	@Column(name = "completed_at")
	private Instant completedAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (startedAt == null) {
			startedAt = Instant.now();
		}
		if (status == null) {
			status = PlacementSessionStatus.IN_PROGRESS;
		}
		if (totalQuestions == null) {
			totalQuestions = 0;
		}
		if (correctAnswers == null) {
			correctAnswers = 0;
		}
	}
}
