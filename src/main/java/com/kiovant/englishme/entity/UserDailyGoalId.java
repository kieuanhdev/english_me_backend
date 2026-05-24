package com.kiovant.englishme.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDailyGoalId implements Serializable {
    private UUID userId;
    private LocalDate goalDate;
}
