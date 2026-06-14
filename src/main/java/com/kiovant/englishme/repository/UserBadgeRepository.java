package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserBadgeRepository extends JpaRepository<UserBadge, UUID> {

    List<UserBadge> findByUser_Id(UUID userId);

    boolean existsByUser_IdAndBadge_Id(UUID userId, UUID badgeId);

    void deleteByUser_Id(UUID userId);

    /** Gỡ mọi lượt đã cấp của 1 badge — gọi trước khi xóa badge (FK không cascade). */
    void deleteByBadge_Id(UUID badgeId);
}
