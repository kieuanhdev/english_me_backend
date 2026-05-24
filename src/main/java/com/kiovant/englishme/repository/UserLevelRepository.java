package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserLevelRepository extends JpaRepository<UserLevel, UUID> {
}
