package vn.id.kieuanhdev.englishme.entity.deck;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import vn.id.kieuanhdev.englishme.entity.auth.User;

@Getter
@Setter
@Entity
@Table(
	name = "deck_subscriptions",
	uniqueConstraints = @UniqueConstraint(name = "uq_deck_subscription_user_deck", columnNames = { "user_id", "deck_id" })
)
public class DeckSubscription {
	@Id
	private UUID id;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "user_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private User user;

	@ManyToOne(fetch = FetchType.LAZY, optional = false)
	@JoinColumn(name = "deck_id", nullable = false)
	@OnDelete(action = OnDeleteAction.CASCADE)
	private Deck deck;

	@Column(name = "subscribed_at", nullable = false)
	private Instant subscribedAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		if (subscribedAt == null) {
			subscribedAt = Instant.now();
		}
	}
}
