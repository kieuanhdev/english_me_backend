package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

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

    @Column(length = 512)
    private String phonetic;

    @Column(columnDefinition = "TEXT")
    private String meaning;

    @Column(name = "audio_url", length = 1024)
    private String audioUrl;

    @Column(nullable = false, length = 20)
    private String difficulty;
}
