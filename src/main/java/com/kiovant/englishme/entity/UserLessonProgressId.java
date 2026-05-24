package com.kiovant.englishme.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserLessonProgressId implements Serializable {
    private UUID userId;
    private String lessonId;
}
