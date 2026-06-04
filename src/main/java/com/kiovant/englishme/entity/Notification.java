package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "notification",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_notification_user_dedup",
                columnNames = {"user_id", "dedup_key"}
        )
)
@Data
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** REVIEW_DUE | STREAK_RISK | LESSON_UNLOCKED | PLACEMENT_SUGGESTION | SYSTEM */
    @Column(nullable = false, length = 40)
    private String type;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    /** Deep-link path cho app điều hướng khi bấm vào thông báo (nullable). */
    @Column(name = "action_route", length = 200)
    private String actionRoute;

    /** Khóa idempotency per-user: cùng 1 thông báo logic chỉ tạo 1 lần trong cửa sổ của nó. */
    @Column(name = "dedup_key", nullable = false, length = 120)
    private String dedupKey;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;
}
