package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Trạng thái SM-2 cho từng user và từng flashcard ({@code easiness_factor}, {@code interval_days}, {@code repetitions}
 * và lịch ôn {@code next_review_at} được cập nhật sau mỗi lần đánh giá chất lượng ôn).
 */
@Entity
@Table(name = "flashcard_progress")
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

    /** Hệ số dễ (SM-2), thường bắt đầu tại 2.5 */
    @Column(name = "easiness_factor", nullable = false)
    private double easinessFactor = 2.5;

    /** Khoảng cách ôn tiếp theo (ngày) */
    @Column(name = "interval_days", nullable = false)
    private int intervalDays = 0;

    /** Số lần ôn thành công liên tiếp */
    @Column(nullable = false)
    private int repetitions = 0;

    @Column(name = "next_review_at")
    private LocalDateTime nextReviewAt;

    @Column(name = "last_reviewed_at")
    private LocalDateTime lastReviewedAt;
}
