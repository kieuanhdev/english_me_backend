package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_path_progress")
@IdClass(UserPathProgressId.class)
@Data
public class UserPathProgress {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Id
    @Column(name = "path_id", length = 64)
    private String pathId;

    @Column(nullable = false, length = 20)
    private String status = "locked";

    @Column(name = "completed_count", nullable = false)
    private Integer completedCount = 0;

    @Column(name = "total_count", nullable = false)
    private Integer totalCount = 0;

    @Column(name = "best_score")
    private Short bestScore;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;
}
