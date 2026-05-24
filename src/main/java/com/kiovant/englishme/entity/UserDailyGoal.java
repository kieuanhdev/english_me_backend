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

    /** Đã cộng bonus 5 XP khi đạt target_xp trong ngày chưa (chống cộng nhiều lần). */
    @Column(name = "daily_bonus_granted", nullable = false)
    private Boolean dailyBonusGranted = false;
}
