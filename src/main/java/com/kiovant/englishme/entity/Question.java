package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

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
    private String skillCategory; // Grammar, Vocabulary

    @Column(nullable = false, columnDefinition = "TEXT")
    private String question;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, String> options; // {"A": "...", "B": "...", "C": "...", "D": "..."}

    @Column(nullable = false, length = 1)
    private String correctAnswer; // "A", "B", "C", or "D"

    @Column(columnDefinition = "TEXT")
    private String explanation;
}
