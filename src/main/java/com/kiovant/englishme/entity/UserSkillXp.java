package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * XP cộng dồn theo từng kỹ năng (vocabulary | grammar | pronunciation | listening).
 *
 * Cập nhật duy nhất qua XpService.grant() (sau khi insert xp_ledger), upsert atomic.
 * Khóa kép (user_id, skill). listening chưa có nguồn XP -> không có row, đọc mặc định 0.
 */
@Entity
@Table(name = "user_skill_xp")
@IdClass(UserSkillXpId.class)
@Data
public class UserSkillXp {

    @Id
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Id
    @Column(nullable = false, length = 32)
    private String skill;

    @Column(nullable = false)
    private Integer xp = 0;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    @PreUpdate
    void touch() {
        updatedAt = Instant.now();
    }
}
