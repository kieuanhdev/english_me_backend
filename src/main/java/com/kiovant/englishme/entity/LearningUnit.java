package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;

/**
 * Cấp "chương" của giáo trình, nằm giữa CEFR Level và Lesson.
 * id dùng VARCHAR(64) đồng bộ với learning_lessons.id.
 */
@Entity
@Table(name = "learning_units")
@Data
public class LearningUnit {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "level_code", nullable = false, length = 2)
    private String levelCode;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(length = 60)
    private String theme;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "skill_coverage", nullable = false, columnDefinition = "jsonb")
    private List<String> skillCoverage;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "required_review_score", nullable = false)
    private Short requiredReviewScore = 75;

    @Column(name = "review_lesson_id", length = 64)
    private String reviewLessonId;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }
}
