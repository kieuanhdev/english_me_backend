package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_levels")
@Data
public class UserLevel {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "current_level", nullable = false, length = 2)
    private String currentLevel;

    @Column(name = "selected_level", nullable = false, length = 2)
    private String selectedLevel;

    @Column(name = "current_path_id", length = 64)
    private String currentPathId;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "last_level_up_at")
    private Instant lastLevelUpAt;

    @PrePersist
    @PreUpdate
    void touch() { updatedAt = Instant.now(); }
}
