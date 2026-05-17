package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "user_test_session")
@Data
public class UserTestSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 50)
    private String topic; // grammar | vocabulary

    @Column(nullable = false, length = 10)
    private String level; // a1|a2|b1|b2|c1|c2

    @Column(nullable = false, length = 20)
    private String status = "active"; // active | completed

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "question_ids", nullable = false, columnDefinition = "jsonb")
    private List<UUID> questionIds;

    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds = 900;

    private Integer correct;
    private Integer total;

    @Column(name = "xp_earned")
    private Integer xpEarned;

    @Column(name = "time_taken_seconds")
    private Integer timeTakenSeconds;

    @Column(name = "cefr_suggestion", length = 10)
    private String cefrSuggestion;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}
