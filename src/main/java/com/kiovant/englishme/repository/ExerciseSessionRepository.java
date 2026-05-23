package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.ExerciseSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

public interface ExerciseSessionRepository extends JpaRepository<ExerciseSession, UUID> {

    Optional<ExerciseSession> findByIdAndUser_FirebaseUid(UUID id, String firebaseUid);

    @Query("SELECT COUNT(e) FROM ExerciseSession e WHERE e.createdAt >= :since")
    long countSince(@Param("since") LocalDateTime since);

    @Query("SELECT COUNT(DISTINCT e.user.id) FROM ExerciseSession e WHERE e.createdAt >= :since")
    long countDistinctUsersSince(@Param("since") LocalDateTime since);

    long countByUser_Id(UUID userId);

    java.util.List<ExerciseSession> findTop50ByUser_IdOrderByCreatedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);
}
