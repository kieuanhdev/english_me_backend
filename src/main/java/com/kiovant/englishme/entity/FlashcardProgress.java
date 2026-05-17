package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "flashcard_progress",
        uniqueConstraints = {
                @UniqueConstraint(name = "uq_flashcard_progress_user_card", columnNames = {"user_id", "flashcard_id"})
        }
)
@Data
public class FlashcardProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flashcard_id", nullable = false)
    private Flashcard flashcard;

    @Column(name = "easiness_factor", nullable = false)
    private Double easinessFactor = 2.5;

    @Column(name = "interval_days", nullable = false)
    private Integer intervalDays = 0;

    @Column(nullable = false)
    private Integer repetitions = 0;

    @Column(name = "next_review_at")
    private LocalDateTime nextReviewAt;

    @Column(name = "last_reviewed_at")
    private LocalDateTime lastReviewedAt;
}
