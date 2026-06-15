package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;
import java.util.UUID;

/**
 * Câu cho bài luyện Nghe - chép chính tả (dictation). TTS đọc {@code text},
 * user gõ lại; client chấm so khớp chuẩn hóa (có {@code text} làm đáp án).
 * Không MCQ. {@code audioUrl} để trống → client dùng on-device TTS đọc text.
 */
@Entity
@Table(name = "dictation_sentence")
@Data
public class DictationSentence {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "cefr_level", nullable = false, length = 10)
    private String cefrLevel;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String text;

    @Column(columnDefinition = "TEXT")
    private String hint;

    @Column(name = "audio_url", columnDefinition = "TEXT")
    private String audioUrl;

    @Column(name = "created_at")
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }
}
