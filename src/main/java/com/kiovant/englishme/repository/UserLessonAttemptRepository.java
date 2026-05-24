package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.UserLessonAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserLessonAttemptRepository extends JpaRepository<UserLessonAttempt, Long> {
}
