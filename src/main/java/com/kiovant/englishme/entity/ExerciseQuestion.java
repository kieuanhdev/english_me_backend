package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "exercise_question")
@Data
public class ExerciseQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 50)
    private String category; // vocabulary | grammar

    @Column(nullable = false, length = 20)
    private String difficulty; // easy | medium | hard

    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, String> options;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String correctAnswer;

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @Column(columnDefinition = "TEXT")
    private String hint;

    @Column(length = 10)
    private String level;

    /** Đoạn văn cho câu reading (đọc hiểu). Null với vocabulary/grammar. */
    @Column(columnDefinition = "TEXT")
    private String passage;

    /** URL audio (nếu có). Reading/listening tái dùng — hiện để trống, client TTS. */
    @Column(name = "audio_url", columnDefinition = "TEXT")
    private String audioUrl;
}
