package vn.id.kieuanhdev.englishme.repository.deck;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.id.kieuanhdev.englishme.entity.deck.DeckSubscription;

public interface DeckSubscriptionRepository extends JpaRepository<DeckSubscription, UUID> {
	boolean existsByUser_IdAndDeck_Id(UUID userId, UUID deckId);

	Optional<DeckSubscription> findByUser_IdAndDeck_Id(UUID userId, UUID deckId);
}
