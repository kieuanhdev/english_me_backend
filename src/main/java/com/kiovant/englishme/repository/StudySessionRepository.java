package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.StudySession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface StudySessionRepository extends JpaRepository<StudySession, UUID> {

    Optional<StudySession> findByIdAndUser_FirebaseUid(UUID id, String firebaseUid);

    @Query("SELECT COUNT(s) FROM StudySession s WHERE s.startedAt >= :since")
    long countSince(@Param("since") LocalDateTime since);

    @Query("SELECT COUNT(DISTINCT s.user.id) FROM StudySession s WHERE s.startedAt >= :since")
    long countDistinctUsersSince(@Param("since") LocalDateTime since);

    @Query(value = "SELECT CAST(EXTRACT(DOW FROM started_at) AS INTEGER) AS dow, " +
            "CAST(EXTRACT(HOUR FROM started_at) AS INTEGER) AS hour, COUNT(*) AS cnt " +
            "FROM study_session WHERE started_at >= :since " +
            "GROUP BY EXTRACT(DOW FROM started_at), EXTRACT(HOUR FROM started_at)",
            nativeQuery = true)
    List<Object[]> heatmapSince(@Param("since") LocalDateTime since);

    long countByUser_Id(UUID userId);

    /** [date, xpEarned] gộp theo ngày, dùng cho biểu đồ XP 30 ngày. */
    @Query("""
            SELECT DATE(s.startedAt), COALESCE(SUM(s.xpEarned), 0)
            FROM StudySession s
            WHERE s.user.id = :userId AND s.startedAt >= :since
            GROUP BY DATE(s.startedAt)
            ORDER BY DATE(s.startedAt) ASC
            """)
    List<Object[]> sumXpByDayForUser(@Param("userId") UUID userId, @Param("since") LocalDateTime since);

    /** Các ngày user có ít nhất 1 study session (cho streak calendar). */
    @Query("""
            SELECT DISTINCT DATE(s.startedAt)
            FROM StudySession s
            WHERE s.user.id = :userId AND s.startedAt >= :since
            """)
    List<java.sql.Date> findActiveDaysForUser(@Param("userId") UUID userId, @Param("since") LocalDateTime since);

    List<StudySession> findTop50ByUser_IdOrderByStartedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);

    // ── Admin monitoring ────────────────────────────────────────────────────

    /**
     * Tìm sessions cho trang admin theo (user, desk, status). Param truyền chuỗi rỗng để bỏ filter.
     */
    @EntityGraph(attributePaths = {"user", "desk"})
    @Query("""
            SELECT s FROM StudySession s
            WHERE (:status = '' OR LOWER(s.status) = LOWER(:status))
              AND (:keyword = ''
                   OR LOWER(COALESCE(s.user.fullName, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(s.user.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(s.user.firebaseUid) LIKE LOWER(CONCAT('%', :keyword, '%')))
              AND (:deskId IS NULL OR s.desk.id = :deskId)
            ORDER BY s.startedAt DESC
            """)
    Page<StudySession> searchForAdmin(
            @Param("status") String status,
            @Param("keyword") String keyword,
            @Param("deskId") UUID deskId,
            Pageable pageable);

    @EntityGraph(attributePaths = {"user", "desk"})
    @Query("SELECT s FROM StudySession s WHERE s.id = :id")
    Optional<StudySession> findWithUserAndDeskById(@Param("id") UUID id);

    /** [status, count]. */
    @Query("SELECT s.status, COUNT(s) FROM StudySession s GROUP BY s.status")
    List<Object[]> countByStatus();
}
