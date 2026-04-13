package vn.id.kieuanhdev.englishme.repository.review;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.id.kieuanhdev.englishme.entity.review.FlashcardProgress;

public interface FlashcardProgressRepository extends JpaRepository<FlashcardProgress, UUID> {
	Optional<FlashcardProgress> findByUser_IdAndFlashcard_Id(UUID userId, UUID flashcardId);
}
