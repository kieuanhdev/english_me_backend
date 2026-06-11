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

    @Query(value = "SELECT ts FROM TestSession ts JOIN FETCH ts.user ORDER BY ts.startedAt DESC",
            countQuery = "SELECT count(ts) FROM TestSession ts")
    Page<TestSession> findAllWithUser(Pageable pageable);

    @Query("SELECT ts FROM TestSession ts JOIN FETCH ts.user WHERE ts.id = :id")
    java.util.Optional<TestSession> findByIdWithUser(UUID id);

    // Chống IDOR: chỉ trả session nếu thuộc đúng user đang đăng nhập.
    java.util.Optional<TestSession> findByIdAndUser_FirebaseUid(UUID id, String firebaseUid);

    long countByUser_Id(UUID userId);

    java.util.List<TestSession> findTop50ByUser_IdOrderByStartedAtDesc(UUID userId);

    void deleteByUser_Id(UUID userId);
}
