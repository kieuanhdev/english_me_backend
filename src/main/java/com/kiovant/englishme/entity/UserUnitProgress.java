package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/** Tiến độ học của user ở cấp Unit. Composite key (user_id, unit_id). */
@Entity
@Table(name = "user_unit_progress")
@IdClass(UserUnitProgressId.class)
@Data
public class UserUnitProgress {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Id
    @Column(name = "unit_id", length = 64)
    private String unitId;

    @Column(nullable = false, length = 20)
    private String status = "locked";

    @Column(name = "completed_lessons", nullable = false)
    private Integer completedLessons = 0;

    @Column(name = "total_lessons", nullable = false)
    private Integer totalLessons = 0;

    @Column(name = "review_score")
    private Short reviewScore;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    @PreUpdate
    void touch() { updatedAt = Instant.now(); }
}
