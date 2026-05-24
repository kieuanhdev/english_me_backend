package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "user_lesson_attempts")
@Data
public class UserLessonAttempt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "lesson_id", nullable = false, length = 64)
    private String lessonId;

    @Column(nullable = false)
    private Short score;

    @Column(name = "xp_earned", nullable = false)
    private Short xpEarned;

    @Column(name = "time_spent_seconds", nullable = false)
    private Integer timeSpentSeconds;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<Map<String, Object>> answers;

    @Column(name = "submitted_at", nullable = false)
    private Instant submittedAt;

    @PrePersist
    void onCreate() { if (submittedAt == null) submittedAt = Instant.now(); }
}
