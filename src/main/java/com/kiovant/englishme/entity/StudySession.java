package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "study_session")
@Data
public class StudySession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "desk_id", nullable = false)
    private Desk desk;

    @Column(nullable = false, length = 20)
    private String status = "active"; // active | completed

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "card_ids", nullable = false, columnDefinition = "jsonb")
    private List<UUID> cardIds;

    /// Các thẻ đã review trong phiên — dùng để cộng "pending XP" đúng 1 lần/thẻ
    /// (retry review cùng thẻ không làm phình XP). XP chỉ grant khi phiên hoàn thành.
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "reviewed_card_ids", columnDefinition = "jsonb")
    private List<UUID> reviewedCardIds;

    @Column(name = "total_cards", nullable = false)
    private Integer totalCards;

    @Column(name = "mastered_cards")
    private Integer masteredCards = 0;

    @Column(name = "again_cards")
    private Integer againCards = 0;

    @Column(name = "hard_cards")
    private Integer hardCards = 0;

    @Column(name = "xp_earned")
    private Integer xpEarned = 0;

    @Column(name = "new_words_learned")
    private Integer newWordsLearned = 0;

    @CreationTimestamp
    @Column(name = "started_at", nullable = false, updatable = false)
    private LocalDateTime startedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}
