package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "learning_path_activities")
@Data
public class LearningPathActivity {
    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "path_id", nullable = false, length = 64)
    private String pathId;

    @Column(name = "lesson_id", nullable = false, length = 64)
    private String lessonId;

    @Column(name = "skill_code", nullable = false, length = 20)
    private String skillCode;

    @Column(name = "activity_type", nullable = false, length = 40)
    private String activityType;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(length = 255)
    private String subtitle;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "duration_minutes", nullable = false)
    private Short durationMinutes = 5;

    @Column(name = "xp_reward", nullable = false)
    private Short xpReward = 10;
}
