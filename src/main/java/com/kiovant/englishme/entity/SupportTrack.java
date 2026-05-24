package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "support_tracks")
@Data
public class SupportTrack {
    @Id
    @Column(length = 20)
    private String type;

    @Column(nullable = false, length = 80)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, length = 120)
    private String route;

    @Column(name = "display_order", nullable = false)
    private Short displayOrder;

    @Column(nullable = false)
    private Boolean enabled = true;
}
