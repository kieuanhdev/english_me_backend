package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Flashcard;
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
     * Tong so the den han on trong desk (khong gioi han boi limit) — cho totalDue.
     */
    @Query("""
            SELECT COUNT(p) FROM FlashcardProgress p
            WHERE p.user.id = :userId
              AND p.flashcard.desk.id = :deskId
              AND (p.nextReviewAt IS NULL OR p.nextReviewAt <= :now)
            """)
    long countDueProgress(UUID userId, UUID deskId, LocalDateTime now);

    /**
     * Tong so the den han on tren TAT CA desk cua user — cho thong bao REVIEW_DUE.
     */
    @Query("""
            SELECT COUNT(p) FROM FlashcardProgress p
            WHERE p.user.id = :userId
              AND (p.nextReviewAt IS NULL OR p.nextReviewAt <= :now)
            """)
    long countAllDueProgress(UUID userId, LocalDateTime now);

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

    /**
     * Tong so the moi chua tung on trong desk (khong gioi han) — cho totalNew.
     */
    @Query("""
            SELECT COUNT(f) FROM Flashcard f
            WHERE f.desk.id = :deskId
              AND f.id NOT IN (
                  SELECT p.flashcard.id FROM FlashcardProgress p
                  WHERE p.user.id = :userId AND p.flashcard.desk.id = :deskId
              )
            """)
    long countUnseenFlashcards(UUID userId, UUID deskId);

    /**
     * Thẻ "yếu nhất / cần ôn nhất" của user trên TẤT CẢ desk — cho Word of Day cá nhân hóa.
     * Ưu tiên thẻ đã tới hạn ôn (next_review_at <= now), khó nhất (easiness thấp) lên trước.
     * Chỉ lấy thẻ user ĐÃ học (có progress row) để đảm bảo là "gap" thật của user.
     */
    @Query("""
            SELECT p.flashcard FROM FlashcardProgress p
            WHERE p.user.id = :userId
              AND (p.nextReviewAt IS NULL OR p.nextReviewAt <= :now)
            ORDER BY p.easinessFactor ASC, p.nextReviewAt ASC NULLS FIRST
            """)
    List<Flashcard> findWeakestDueFlashcards(UUID userId, LocalDateTime now, Pageable pageable);

    void deleteByUser_Id(UUID userId);
}
