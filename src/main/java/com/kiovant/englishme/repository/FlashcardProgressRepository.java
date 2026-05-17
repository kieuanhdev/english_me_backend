package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.FlashcardProgress;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FlashcardProgressRepository extends JpaRepository<FlashcardProgress, UUID> {

    Optional<FlashcardProgress> findByUser_IdAndFlashcard_Id(UUID userId, UUID flashcardId);

    /**
     * Due cards in a desk: progress rows whose next_review_at <= now (or null = chua hoc).
     */
    @Query("""
            SELECT p FROM FlashcardProgress p
            WHERE p.user.id = :userId
              AND p.flashcard.desk.id = :deskId
              AND (p.nextReviewAt IS NULL OR p.nextReviewAt <= :now)
            ORDER BY p.nextReviewAt ASC NULLS FIRST
            """)
    List<FlashcardProgress> findDueProgress(UUID userId, UUID deskId, LocalDateTime now, Pageable pageable);

    /**
     * Flashcards in a desk that user has NOT started yet (no progress row).
     */
    @Query("""
            SELECT f.id FROM Flashcard f
            WHERE f.desk.id = :deskId
              AND f.id NOT IN (
                  SELECT p.flashcard.id FROM FlashcardProgress p
                  WHERE p.user.id = :userId AND p.flashcard.desk.id = :deskId
              )
            ORDER BY f.word ASC
            """)
    List<UUID> findUnseenFlashcardIds(UUID userId, UUID deskId, Pageable pageable);

    void deleteByUser_Id(UUID userId);
}
