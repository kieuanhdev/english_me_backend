package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserDeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserDeviceTokenRepository extends JpaRepository<UserDeviceToken, UUID> {

    Optional<UserDeviceToken> findByToken(String token);

    void deleteByToken(String token);

    @Query("SELECT t.token FROM UserDeviceToken t WHERE t.user.deletedAt IS NULL")
    List<String> findAllActiveTokens();

    @Query("""
            SELECT t.token FROM UserDeviceToken t
            WHERE t.user.deletedAt IS NULL
              AND UPPER(COALESCE(t.user.cefrLevel, '')) = UPPER(:level)
            """)
    List<String> findTokensByCefr(@Param("level") String level);

    @Query("""
            SELECT t.token FROM UserDeviceToken t
            WHERE t.user.deletedAt IS NULL
              AND (t.user.lastActiveDate IS NULL OR t.user.lastActiveDate < :threshold)
            """)
    List<String> findTokensInactiveSince(@Param("threshold") java.time.LocalDate threshold);
}
