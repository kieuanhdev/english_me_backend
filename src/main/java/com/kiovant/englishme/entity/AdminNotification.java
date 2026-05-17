package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "admin_notification")
@Data
public class AdminNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @Column(name = "action_url", length = 500)
    private String actionUrl;

    @Column(name = "segment_type", nullable = false, length = 50)
    private String segmentType;

    @Column(name = "segment_value", length = 200)
    private String segmentValue;

    @Column(name = "target_count", nullable = false)
    private Integer targetCount = 0;

    @Column(name = "success_count", nullable = false)
    private Integer successCount = 0;

    @Column(name = "failure_count", nullable = false)
    private Integer failureCount = 0;

    @Column(name = "sent_by_email", length = 255)
    private String sentByEmail;

    @CreationTimestamp
    @Column(name = "sent_at", nullable = false, updatable = false)
    private LocalDateTime sentAt;
}
