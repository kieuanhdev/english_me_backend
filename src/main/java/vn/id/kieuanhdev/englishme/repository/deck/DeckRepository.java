package vn.id.kieuanhdev.englishme.repository.deck;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.deck.Deck;

public interface DeckRepository extends JpaRepository<Deck, UUID> {
	Optional<Deck> findByIdAndIsSystemTrueAndDeletedAtIsNull(UUID id);

	Optional<Deck> findByIdAndOwner_IdAndDeletedAtIsNullAndIsSystemFalse(UUID id, UUID ownerId);
	@Query(
		"""
		select d from Deck d
		where d.isSystem = true
		and d.deletedAt is null
		and (:topic is null or :topic = '' or lower(d.topic) = lower(:topic))
		and (:level is null or d.cefrLevel = :level)
		order by d.createdAt desc
		"""
	)
	List<Deck> findSystemDecksVisible(@Param("topic") String topic, @Param("level") CefrLevel level);
}
