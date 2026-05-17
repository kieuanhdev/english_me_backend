package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.util.UUID;

@Entity
@Table(name = "exercise_answer")
@Data
public class ExerciseAnswer {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private ExerciseSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private ExerciseQuestion question;

    @Column(name = "selected_answer", columnDefinition = "TEXT")
    private String selectedAnswer;

    @Column(name = "is_correct")
    private Boolean isCorrect;
}
