package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
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
    private List<String> options;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String correctAnswer;

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @Column(columnDefinition = "TEXT")
    private String hint;

    @Column(length = 10)
    private String level;
}
