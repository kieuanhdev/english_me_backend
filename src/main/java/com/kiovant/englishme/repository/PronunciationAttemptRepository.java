package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationAttempt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface PronunciationAttemptRepository extends JpaRepository<PronunciationAttempt, UUID> {
    @Query("""
            SELECT p FROM PronunciationAttempt p
            JOIN p.user u
            WHERE (:provider = '' OR LOWER(p.provider) = LOWER(:provider))
              AND p.overallScore >= :minScore
              AND (:keyword = ''
                   OR LOWER(COALESCE(u.fullName, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(u.firebaseUid) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY p.createdAt DESC
            """)
    Page<PronunciationAttempt> findForAdmin(
            @Param("provider") String provider,
            @Param("minScore") int minScore,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    @Query("SELECT COUNT(p) FROM PronunciationAttempt p WHERE p.createdAt >= :since")
    long countSince(LocalDateTime since);

    long countByUser_FirebaseUid(String firebaseUid);

    /** Điểm tổng trung bình của user (null nếu chưa có lần thử nào). */
    @Query("SELECT AVG(p.overallScore) FROM PronunciationAttempt p WHERE p.user.firebaseUid = :firebaseUid")
    Double averageOverallScore(@Param("firebaseUid") String firebaseUid);

    long countByUser_Id(UUID userId);

    List<PronunciationAttempt> findTop50ByUser_IdOrderByCreatedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);

}
