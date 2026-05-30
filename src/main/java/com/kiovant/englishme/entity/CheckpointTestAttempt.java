package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Một lần user nộp bài checkpoint. */
@Entity
@Table(name = "checkpoint_test_attempts")
@Data
public class CheckpointTestAttempt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "test_id", nullable = false, length = 64)
    private String testId;

    @Column(name = "level_code", nullable = false, length = 2)
    private String levelCode;

    @Column(nullable = false)
    private Short score;

    @Column(nullable = false)
    private Boolean passed;

    @Column(name = "leveled_up", nullable = false)
    private Boolean leveledUp = false;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<Map<String, Object>> answers;

    @Column(name = "attempted_at", nullable = false)
    private Instant attemptedAt;

    @PrePersist
    void onCreate() { if (attemptedAt == null) attemptedAt = Instant.now(); }
}
