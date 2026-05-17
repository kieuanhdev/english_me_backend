package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Badge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BadgeRepository extends JpaRepository<Badge, UUID> {

    Optional<Badge> findByConditionType(String conditionType);

    List<Badge> findByIsActiveTrue();

    List<Badge> findAllByOrderByCreatedAtDesc();

    boolean existsByNameIgnoreCase(String name);

    /**
     * Đếm số user đã đạt từng badge (group by badge_id).
     * Trả về Object[]{badge_id (UUID), count (Long)}.
     */
    @Query("SELECT ub.badge.id, COUNT(ub.id) FROM UserBadge ub GROUP BY ub.badge.id")
    List<Object[]> countAwardedGroupByBadge();
}
