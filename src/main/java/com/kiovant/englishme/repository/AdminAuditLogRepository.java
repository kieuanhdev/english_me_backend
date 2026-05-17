package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.AdminAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface AdminAuditLogRepository extends JpaRepository<AdminAuditLog, UUID> {

    @Query("""
        SELECT a FROM AdminAuditLog a
        WHERE (:email IS NULL OR LOWER(a.adminEmail) LIKE LOWER(CONCAT('%', :email, '%')))
          AND (:action IS NULL OR a.action = :action)
          AND (:from IS NULL OR a.createdAt >= :from)
          AND (:to IS NULL OR a.createdAt < :to)
        ORDER BY a.createdAt DESC
        """)
    List<AdminAuditLog> search(@Param("email") String email,
                               @Param("action") String action,
                               @Param("from") LocalDateTime from,
                               @Param("to") LocalDateTime to);
}
