package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "cefr_levels")
@Data
public class CefrLevel {
    @Id
    @Column(length = 2)
    private String code;

    @Column(nullable = false, length = 80)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "display_order", nullable = false)
    private Short displayOrder;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
}
