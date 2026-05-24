package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_lesson_progress")
@IdClass(UserLessonProgressId.class)
@Data
public class UserLessonProgress {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Id
    @Column(name = "lesson_id", length = 64)
    private String lessonId;

    @Column(name = "path_id", length = 64)
    private String pathId;

    @Column(nullable = false, length = 20)
    private String status = "locked";

    @Column(name = "best_score")
    private Short bestScore;

    @Column(name = "last_score")
    private Short lastScore;

    @Column(nullable = false)
    private Integer attempts = 0;

    @Column(name = "xp_earned", nullable = false)
    private Integer xpEarned = 0;

    @Column(name = "time_spent_seconds", nullable = false)
    private Integer timeSpentSeconds = 0;

    @Column(name = "completed_at")
    private Instant completedAt;
}
