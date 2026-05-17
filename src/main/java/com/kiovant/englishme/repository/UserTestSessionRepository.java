package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserTestSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserTestSessionRepository extends JpaRepository<UserTestSession, UUID> {

    Optional<UserTestSession> findByIdAndUser_FirebaseUid(UUID id, String firebaseUid);

    List<UserTestSession> findByUser_FirebaseUidOrderByCreatedAtDesc(String firebaseUid);

    @Query("SELECT COUNT(t) FROM UserTestSession t WHERE t.createdAt >= :since")
    long countSince(@Param("since") LocalDateTime since);

    @Query("SELECT COUNT(DISTINCT t.user.id) FROM UserTestSession t WHERE t.createdAt >= :since")
    long countDistinctUsersSince(@Param("since") LocalDateTime since);
}
