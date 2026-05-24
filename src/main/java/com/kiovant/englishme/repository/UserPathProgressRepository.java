package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserPathProgress;
import com.kiovant.englishme.entity.UserPathProgressId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserPathProgressRepository extends JpaRepository<UserPathProgress, UserPathProgressId> {
    List<UserPathProgress> findByUserId(UUID userId);

    List<UserPathProgress> findByUserIdAndPathIdIn(UUID userId, List<String> pathIds);
}
