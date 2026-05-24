package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserDailyGoal;
import com.kiovant.englishme.entity.UserDailyGoalId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface UserDailyGoalRepository extends JpaRepository<UserDailyGoal, UserDailyGoalId> {
    Optional<UserDailyGoal> findByUserIdAndGoalDate(UUID userId, LocalDate goalDate);
}
