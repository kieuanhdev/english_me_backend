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
@Table(name = "pronunciation_exercises")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString
public class PronunciationExercise {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;

    /** IPA phonetic (spec gọi là `expected_phonetic`). Cột cũ giữ tên `phonetic`. */
    @Column(length = 512)
    private String phonetic;

    @Column(columnDefinition = "TEXT")
    private String meaning;

    /** Reference audio mẫu (URL hoặc /uploads/pronunciation/...). */
    @Column(name = "audio_url", length = 1024)
    private String audioUrl;

    @Column(nullable = false, length = 20)
    private String difficulty;

    /** CEFR level (A1–C2). Nullable để tương thích dữ liệu cũ. */
    @Column(length = 4)
    private String level;

    /** Gợi ý phát âm (tips). */
    @Column(columnDefinition = "TEXT")
    private String tips;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
