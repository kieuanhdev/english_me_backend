package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.CheckpointTestAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CheckpointTestAttemptRepository extends JpaRepository<CheckpointTestAttempt, Long> {
    boolean existsByUserIdAndLevelCodeAndPassedTrue(UUID userId, String levelCode);
}
