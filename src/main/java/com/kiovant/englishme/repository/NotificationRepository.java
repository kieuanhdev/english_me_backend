package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.Notification;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    List<Notification> findByUser_IdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    List<Notification> findByUser_IdAndIsReadFalseOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    long countByUser_IdAndIsReadFalse(UUID userId);

    /** Guard idempotency cho generator: thông báo logic này đã tồn tại cho user chưa. */
    boolean existsByUser_IdAndDedupKey(UUID userId, String dedupKey);

    /** Fetch 1 thông báo có kiểm tra ownership — dùng cho mark-read. */
    Optional<Notification> findByIdAndUser_Id(UUID id, UUID userId);

    @Modifying
    @Query("""
            UPDATE Notification n
               SET n.isRead = true, n.readAt = :now
             WHERE n.user.id = :userId AND n.isRead = false
            """)
    int markAllRead(@Param("userId") UUID userId, @Param("now") LocalDateTime now);
}
