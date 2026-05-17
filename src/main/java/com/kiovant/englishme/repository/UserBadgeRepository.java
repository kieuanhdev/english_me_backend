package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserBadgeRepository extends JpaRepository<UserBadge, UUID> {

    List<UserBadge> findByUser_Id(UUID userId);

    List<UserBadge> findByBadge_IdOrderByEarnedAtDesc(UUID badgeId);

    boolean existsByUser_IdAndBadge_Id(UUID userId, UUID badgeId);

    long countByBadge_Id(UUID badgeId);

    void deleteByUser_Id(UUID userId);

    void deleteByBadge_Id(UUID badgeId);
}
