package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.XpLedger;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface XpLedgerRepository extends JpaRepository<XpLedger, Long> {

    Optional<XpLedger> findByUserIdAndIdempotencyKey(UUID userId, String idempotencyKey);

    /**
     * Idempotent insert: chỉ chèn nếu (user_id, idempotency_key) chưa tồn tại.
     * Trả về số row đã insert (0 nếu duplicate).
     */
    @Modifying
    @Query(value = """
            INSERT INTO xp_ledger (user_id, amount, source_type, source_id, idempotency_key, metadata, occurred_at)
            VALUES (:userId, :amount, :sourceType, :sourceId, :idempotencyKey, CAST(:metadataJson AS jsonb), NOW())
            ON CONFLICT (user_id, idempotency_key) DO NOTHING
            """, nativeQuery = true)
    int insertIfAbsent(@Param("userId") UUID userId,
                       @Param("amount") int amount,
                       @Param("sourceType") String sourceType,
                       @Param("sourceId") String sourceId,
                       @Param("idempotencyKey") String idempotencyKey,
                       @Param("metadataJson") String metadataJson);

    /** Cursor-based: lấy các row có id < cursor (id giảm dần). */
    @Query("SELECT l FROM XpLedger l WHERE l.userId = :userId AND l.id < :cursorId ORDER BY l.id DESC")
    List<XpLedger> findByUserIdBeforeCursor(@Param("userId") UUID userId,
                                            @Param("cursorId") Long cursorId,
                                            Pageable pageable);

    @Query("SELECT l FROM XpLedger l WHERE l.userId = :userId ORDER BY l.id DESC")
    List<XpLedger> findFirstPage(@Param("userId") UUID userId, Pageable pageable);
}
