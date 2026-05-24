package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "word_of_day_cache")
@Data
public class WordOfDayCache {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "cache_date", nullable = false)
    private LocalDate cacheDate;

    @Column(name = "cefr_level", nullable = false, length = 10)
    private String cefrLevel;

    @Column(nullable = false, length = 200)
    private String word;

    @Column(length = 200)
    private String pronunciation;

    @Column(length = 50)
    private String partOfSpeech;

    @Column(columnDefinition = "TEXT")
    private String definitionVi;

    @Column(columnDefinition = "TEXT")
    private String definitionEn;

    @Column(columnDefinition = "TEXT")
    private String exampleSentence;

    @Column(columnDefinition = "TEXT")
    private String exampleTranslation;

    @Column(columnDefinition = "TEXT")
    private String audioUrl;
}
