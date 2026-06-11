package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.User;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID>, JpaSpecificationExecutor<User> {
    Optional<User> findByFirebaseUid(String firebaseUid);

    /**
     * Load user kèm row lock (SELECT ... FOR UPDATE) — dùng cho XpService.grant.
     * Hai request cộng XP song song cho cùng user sẽ serialize tại đây, tránh
     * lost update trên total_xp / streak (load-modify-save không atomic).
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT u FROM User u WHERE u.id = :id")
    Optional<User> findByIdForUpdate(@Param("id") UUID id);

    @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :since AND u.deletedAt IS NULL")
    long countCreatedSince(LocalDateTime since);

    @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :from AND u.createdAt < :to AND u.deletedAt IS NULL")
    long countCreatedBetween(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query("SELECT u.cefrLevel, COUNT(u) FROM User u WHERE u.deletedAt IS NULL GROUP BY u.cefrLevel")
    List<Object[]> countByCefrLevel();

    @Query("SELECT u.fullName, u.email, u.cefrLevel, u.totalXp, u.currentStreak FROM User u " +
            "WHERE u.deletedAt IS NULL ORDER BY u.totalXp DESC, u.currentStreak DESC")
    List<Object[]> findTopLearners(org.springframework.data.domain.Pageable pageable);
}
