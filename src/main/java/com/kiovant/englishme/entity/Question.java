package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "questions")
@Data
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String cefrLevel; // A1, A2, B1, B2, C1, C2

    @Column(nullable = false)
    private String skillCategory; // grammar, vocabulary, reading, listening

    // IRT 1PL b-parameter (độ khó). Map từ cefr_level làm proxy (V67):
    // A1=-2.0, A2=-1.0, B1=0.0, B2=1.0, C1=2.0. Dùng cho CAT chọn câu theo |b_i - θ|.
    @Column(nullable = false)
    private Double difficulty;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, String> options; // {"A": "...", "B": "...", "C": "...", "D": "..."}

    @Column(nullable = false, length = 1)
    private String correctAnswer; // "A", "B", "C", or "D"

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "audio_url", columnDefinition = "TEXT")
    private String audioUrl;

    @Column(columnDefinition = "TEXT")
    private String passage;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}
