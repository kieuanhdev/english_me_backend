package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "pronunciation_attempts")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = "user")
public class PronunciationAttempt {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "lesson_item_id")
    private UUID lessonItemId;

    @Column(name = "reference_text", nullable = false, columnDefinition = "TEXT")
    private String referenceText;

    @Column(name = "overall_score", nullable = false)
    private Integer overallScore;

    @Column(name = "accuracy_score", nullable = false)
    private Integer accuracyScore;

    @Column(name = "fluency_score", nullable = false)
    private Integer fluencyScore;

    @Column(name = "provider", nullable = false, length = 50)
    private String provider;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
