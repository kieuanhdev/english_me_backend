package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.UUID;

@Entity
@Table(name = "pronunciation_word_feedback")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = "attempt")
public class PronunciationWordFeedback {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attempt_id", nullable = false)
    private PronunciationAttempt attempt;

    @Column(name = "word", nullable = false, length = 128)
    private String word;

    @Column(name = "score", nullable = false)
    private Integer score;

    @Column(name = "start_ms", nullable = false)
    private Integer startMs;

    @Column(name = "end_ms", nullable = false)
    private Integer endMs;

    @Column(name = "issue_type", nullable = false, length = 80)
    private String issueType;

    @Column(name = "suggestion", columnDefinition = "TEXT")
    private String suggestion;
}
