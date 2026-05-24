package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "user_daily_goals")
@IdClass(UserDailyGoalId.class)
@Data
public class UserDailyGoal {
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Id
    @Column(name = "goal_date")
    private LocalDate goalDate;

    @Column(name = "target_xp", nullable = false)
    private Short targetXp = 30;

    @Column(name = "earned_xp", nullable = false)
    private Short earnedXp = 0;

    @Column(name = "completed_activities", nullable = false)
    private Short completedActivities = 0;
}
