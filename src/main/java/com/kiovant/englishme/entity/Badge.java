package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "badge")
@Data
public class Badge {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String name;

    private String description;

    private String iconUrl;

    @Column(nullable = false, length = 50)
    private String conditionType;

    /** Ngưỡng numeric cho điều kiện tùy biến (vd: streak >= conditionValue, xp >= conditionValue). */
    private Integer conditionValue;

    @Column(nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
