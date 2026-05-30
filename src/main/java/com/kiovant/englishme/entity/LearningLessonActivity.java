package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.Map;

@Entity
@Table(name = "learning_lesson_activities")
@Data
public class LearningLessonActivity {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "lesson_id", nullable = false, length = 64)
    private String lessonId;

    @Column(name = "activity_type", nullable = false, length = 40)
    private String activityType;

    @Column(name = "phase", nullable = false, length = 12)
    private String phase = "quiz";

    @Column(name = "difficulty", length = 8)
    private String difficulty;

    @Column(name = "counts_toward_mastery", nullable = false)
    private Boolean countsTowardMastery = true;

    @Column(name = "display_order", nullable = false)
    private Short displayOrder;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> payload;

    @Column(name = "min_score_to_pass")
    private Short minScoreToPass;
}
