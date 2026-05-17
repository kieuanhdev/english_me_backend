package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.TestSession;
import com.kiovant.englishme.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface TestSessionRepository extends JpaRepository<TestSession, UUID> {

    List<TestSession> findByUserOrderByStartedAtDesc(User user);

    @Query("SELECT ts FROM TestSession ts JOIN FETCH ts.user ORDER BY ts.startedAt DESC")
    Page<TestSession> findAllWithUser(Pageable pageable);

    @Query("SELECT ts FROM TestSession ts JOIN FETCH ts.user WHERE ts.id = :id")
    java.util.Optional<TestSession> findByIdWithUser(UUID id);

    long countByUser_Id(UUID userId);

    java.util.List<TestSession> findTop50ByUser_IdOrderByStartedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);
}
