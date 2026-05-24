package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;

@Entity
@Table(name = "learning_lessons")
@Data
public class LearningLesson {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "level_code", nullable = false, length = 2)
    private String levelCode;

    @Column(name = "skill_code", nullable = false, length = 20)
    private String skillCode;

    @Column(name = "unit_id", length = 64)
    private String unitId;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(name = "duration_minutes", nullable = false)
    private Short durationMinutes = 5;

    @Column(name = "xp_reward", nullable = false)
    private Short xpReward = 10;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> content;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void onUpdate() { updatedAt = Instant.now(); }
}
