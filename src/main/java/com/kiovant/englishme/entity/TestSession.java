package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "test_sessions")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"user", "answers"})
public class TestSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @CreationTimestamp
    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    // Kết quả phân loại sau khi nộp bài
    private String resultLevel; // A1, A2, B1, ...

    private Integer score; // số câu đúng / tổng số câu

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TestStatus status = TestStatus.IN_PROGRESS;

    // Danh sách UUID câu hỏi được chọn cho session này (giữ thứ tự).
    // CAT: append dần mỗi khi selectNextQuestion() chọn câu mới.
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private List<UUID> questionIds;

    // CAT / IRT 1PL: ability estimate hiện tại của session, khởi đầu 0.0 (~B1).
    @Column(name = "theta")
    private Double theta = 0.0;

    // CAT: số câu tối đa của phiên (dừng khi answeredCount ≥ maxQuestions).
    @Column(name = "max_questions")
    private Integer maxQuestions = 15;

    @OneToMany(mappedBy = "testSession", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TestAnswer> answers;

    public enum TestStatus {
        IN_PROGRESS, COMPLETED
    }
}
