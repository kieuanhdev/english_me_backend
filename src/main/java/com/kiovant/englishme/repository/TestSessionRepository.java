package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.TestSession;
import com.kiovant.englishme.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TestSessionRepository extends JpaRepository<TestSession, UUID> {

    List<TestSession> findByUserOrderByStartedAtDesc(User user);
}
