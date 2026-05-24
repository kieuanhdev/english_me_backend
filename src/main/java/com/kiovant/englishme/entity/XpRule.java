package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;

/**
 * Cấu hình XP cho từng nguồn (source_type).
 *
 * <p>Schema áp dụng linh hoạt theo nguồn:
 * <ul>
 *   <li><b>test/exercise</b>: dùng cả {@code perCorrect} + {@code accuracyBonus} + {@code accuracyThresholdPct}.
 *       Công thức: {@code base + perCorrect*correct + (accuracy>=threshold ? accuracyBonus : 0)}.</li>
 *   <li><b>daily_goal_bonus / path_bonus / level_bonus / streak_bonus / pronunciation</b>:
 *       chỉ dùng {@code baseAmount}.</li>
 * </ul>
 *
 * <p>KHÔNG dùng cho lesson XP (đọc từ learning_lessons.xp_reward) và sm2_review (rating-based).
 */
@Entity
@Table(name = "xp_rules")
@Data
public class XpRule {

    @Id
    @Column(name = "source_type", length = 40)
    private String sourceType;

    @Column(name = "base_amount", nullable = false)
    private Integer baseAmount = 0;

    @Column(name = "per_correct", nullable = false)
    private Integer perCorrect = 0;

    @Column(name = "accuracy_bonus", nullable = false)
    private Integer accuracyBonus = 0;

    @Column(name = "accuracy_threshold_pct", nullable = false)
    private Short accuracyThresholdPct = 0;

    @Column(name = "daily_cap")
    private Integer dailyCap;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(length = 255)
    private String description;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    @PreUpdate
    @PrePersist
    void touch() {
        this.updatedAt = Instant.now();
    }
}
