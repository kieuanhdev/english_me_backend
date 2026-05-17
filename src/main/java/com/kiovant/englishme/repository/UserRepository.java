package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID>, JpaSpecificationExecutor<User> {
    Optional<User> findByFirebaseUid(String firebaseUid);

    @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :since AND u.deletedAt IS NULL")
    long countCreatedSince(LocalDateTime since);

    @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :from AND u.createdAt < :to AND u.deletedAt IS NULL")
    long countCreatedBetween(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query("SELECT DATE(u.createdAt), COUNT(u) FROM User u WHERE u.createdAt >= :since AND u.deletedAt IS NULL GROUP BY DATE(u.createdAt) ORDER BY DATE(u.createdAt) ASC")
    List<Object[]> countNewUsersByDaySince(@Param("since") LocalDateTime since);

    @Query("SELECT u.cefrLevel, COUNT(u) FROM User u WHERE u.deletedAt IS NULL GROUP BY u.cefrLevel")
    List<Object[]> countByCefrLevel();

    @Query("SELECT COALESCE(AVG(u.currentStreak), 0) FROM User u WHERE u.currentStreak > 0 AND u.deletedAt IS NULL")
    Double averageCurrentStreak();

    @Query("""
            SELECT u FROM User u
            WHERE COALESCE(u.accountLocked, false) = false
              AND u.deletedAt IS NULL
            ORDER BY u.currentStreak DESC, u.longestStreak DESC
            """)
    List<User> findTopByStreak(org.springframework.data.domain.Pageable pageable);

    @Query("""
            SELECT u FROM User u
            WHERE COALESCE(u.accountLocked, false) = false
              AND u.deletedAt IS NULL
            ORDER BY u.totalXp DESC
            """)
    List<User> findTopByXp(org.springframework.data.domain.Pageable pageable);

    @Query("""
            SELECT u FROM User u
            WHERE COALESCE(u.accountLocked, false) = false
              AND u.deletedAt IS NULL
              AND (u.lastActiveDate IS NULL OR u.lastActiveDate < :threshold)
            ORDER BY CASE WHEN u.lastActiveDate IS NULL THEN 0 ELSE 1 END ASC, u.lastActiveDate ASC
            """)
    List<User> findInactiveUsers(@Param("threshold") LocalDate threshold, org.springframework.data.domain.Pageable pageable);
}
