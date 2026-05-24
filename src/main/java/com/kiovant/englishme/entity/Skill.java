package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "skills")
@Data
public class Skill {
    @Id
    @Column(length = 20)
    private String code;

    @Column(nullable = false, length = 80)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(length = 40)
    private String icon;

    @Column(name = "accent_color", length = 7)
    private String accentColor;

    @Column(name = "display_order", nullable = false)
    private Short displayOrder;
}
