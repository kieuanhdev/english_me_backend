package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;

@Entity
@Table(name = "learning_paths")
@Data
public class LearningPath {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "level_code", nullable = false, length = 2)
    private String levelCode;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "required_score_to_pass", nullable = false)
    private Short requiredScoreToPass = 70;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "skills_coverage", nullable = false, columnDefinition = "jsonb")
    private List<String> skillsCoverage;

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
