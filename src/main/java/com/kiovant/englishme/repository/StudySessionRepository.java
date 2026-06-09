package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.StudySession;
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
    List<java.time.LocalDate> findActiveDaysForUser(@Param("userId") UUID userId, @Param("since") LocalDateTime since);

    List<StudySession> findTop50ByUser_IdOrderByStartedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);

}
