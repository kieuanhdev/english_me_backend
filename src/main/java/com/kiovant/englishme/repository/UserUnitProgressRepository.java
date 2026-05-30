package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserUnitProgress;
import com.kiovant.englishme.entity.UserUnitProgressId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserUnitProgressRepository extends JpaRepository<UserUnitProgress, UserUnitProgressId> {
    List<UserUnitProgress> findByUserIdAndUnitIdIn(UUID userId, List<String> unitIds);
}
