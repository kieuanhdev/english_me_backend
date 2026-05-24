package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserLessonProgress;
import com.kiovant.englishme.entity.UserLessonProgressId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface UserLessonProgressRepository extends JpaRepository<UserLessonProgress, UserLessonProgressId> {
    List<UserLessonProgress> findByUserIdAndPathId(UUID userId, String pathId);

    List<UserLessonProgress> findByUserIdAndLessonIdIn(UUID userId, List<String> lessonIds);

    long countByUserIdAndPathIdAndStatus(UUID userId, String pathId, String status);
}
