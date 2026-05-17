package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.util.UUID;

@Entity
@Table(name = "vocabulary_topic")
@Data
public class VocabularyTopic {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 100)
    private String nameEn;

    @Column(length = 50)
    private String icon;

    @Column(length = 10)
    private String level;

    @Column(length = 7)
    private String colorHex;

    @Column(nullable = false)
    private Integer sortOrder = 0;
}
