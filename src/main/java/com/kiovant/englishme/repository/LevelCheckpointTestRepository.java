package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.LevelCheckpointTest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LevelCheckpointTestRepository extends JpaRepository<LevelCheckpointTest, String> {
    Optional<LevelCheckpointTest> findByLevelCodeAndIsActiveTrue(String levelCode);
}
