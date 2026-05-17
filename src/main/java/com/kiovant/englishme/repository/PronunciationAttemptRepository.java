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
    List<PronunciationAttempt> findByUser_FirebaseUidOrderByCreatedAtDesc(String firebaseUid, Pageable pageable);

    List<PronunciationAttempt> findByUser_FirebaseUidAndExerciseIdOrderByCreatedAtDesc(
            String firebaseUid,
            UUID exerciseId,
            Pageable pageable
    );

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

    @Query("SELECT COUNT(DISTINCT p.user.id) FROM PronunciationAttempt p WHERE p.createdAt >= :since")
    long countDistinctUsersSince(@Param("since") LocalDateTime since);

    @Query("""
            SELECT p.referenceText, AVG(p.overallScore), COUNT(p)
            FROM PronunciationAttempt p
            GROUP BY p.referenceText
            HAVING COUNT(p) >= 3
            ORDER BY AVG(p.overallScore) ASC
            """)
    List<Object[]> findTopMissedWords(org.springframework.data.domain.Pageable pageable);

    long countByUser_Id(UUID userId);

    List<PronunciationAttempt> findTop50ByUser_IdOrderByCreatedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);

}
