package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.util.UUID;

@Entity
@Table(name = "vocabulary_word")
@Data
public class VocabularyWord {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "topic_id", nullable = false)
    private VocabularyTopic topic;

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

    @Column(nullable = false, length = 10)
    private String level;

    private String audioUrl;
}
