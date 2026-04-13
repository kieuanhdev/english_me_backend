package vn.id.kieuanhdev.englishme.repository.deck;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.id.kieuanhdev.englishme.entity.deck.Flashcard;

public interface FlashcardRepository extends JpaRepository<Flashcard, UUID> {
	long countByDeck_IdAndDeletedAtIsNull(UUID deckId);

	boolean existsByDeck_IdAndVocabulary_IdAndDeletedAtIsNull(UUID deckId, UUID vocabularyId);

	Optional<Flashcard> findByDeck_IdAndIdAndDeletedAtIsNull(UUID deckId, UUID flashcardId);

	@Query(
		"""
		select f from Flashcard f
		where f.deck.id = :deckId
		and f.vocabulary.id = :vocabularyId
		and f.deletedAt is null
		"""
	)
	Optional<Flashcard> findActiveByDeckIdAndVocabularyId(@Param("deckId") UUID deckId, @Param("vocabularyId") UUID vocabularyId);

	List<Flashcard> findAllByDeck_IdAndDeletedAtIsNull(UUID deckId);

	@Query(
		"""
		select f.deck.id, count(f)
		from Flashcard f
		where f.deletedAt is null and f.deck.id in :deckIds
		group by f.deck.id
		"""
	)
	List<Object[]> countActiveByDeckIds(@Param("deckIds") Collection<UUID> deckIds);
}
