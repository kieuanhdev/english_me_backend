package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

/** Cấu hình bài kiểm tra cuối Level (điều kiện lên cấp CEFR). */
@Entity
@Table(name = "level_checkpoint_tests")
@Data
public class LevelCheckpointTest {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "level_code", nullable = false, length = 2)
    private String levelCode;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(name = "question_count", nullable = false)
    private Integer questionCount = 20;

    @Column(name = "pass_score", nullable = false)
    private Short passScore = 75;

    @Column(name = "required_unit_progress", nullable = false)
    private BigDecimal requiredUnitProgress = new BigDecimal("0.800");

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() { if (createdAt == null) createdAt = Instant.now(); }
}
