package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Badge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BadgeRepository extends JpaRepository<Badge, UUID> {

    Optional<Badge> findByConditionType(String conditionType);

    /** Badge đang bật — dùng cho auto-award (bỏ badge admin tắt). */
    List<Badge> findByIsActiveTrue();

    List<Badge> findAllByOrderByConditionTypeAscConditionValueAsc();
}
