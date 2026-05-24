package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Append-only ledger ghi nhận từng giao dịch cộng/trừ XP.
 *
 * Invariant: users.total_xp == SUM(xp_ledger.amount WHERE user_id = users.id).
 * UNIQUE (user_id, idempotency_key) đảm bảo retry mạng không cộng XP gấp đôi.
 */
@Entity
@Table(name = "xp_ledger")
@Data
public class XpLedger {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private Integer amount;

    @Column(name = "source_type", nullable = false, length = 40)
    private String sourceType;

    @Column(name = "source_id", nullable = false, length = 120)
    private String sourceId;

    @Column(name = "idempotency_key", nullable = false, length = 160)
    private String idempotencyKey;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> metadata = new HashMap<>();

    @Column(name = "occurred_at", nullable = false)
    private Instant occurredAt;

    @PrePersist
    void onCreate() {
        if (occurredAt == null) occurredAt = Instant.now();
        if (metadata == null) metadata = new HashMap<>();
    }
}
