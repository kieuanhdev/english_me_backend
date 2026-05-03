package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(unique = true, nullable = false)
    private String firebaseUid;

    @Column(unique = true, nullable = false)
    private String email;

    private String fullName;
    private String avatarUrl;

    // Quản lý trạng thái học tập
    private String cefrLevel = null;
    /** Da hoan thanh bai placement test (onboarding) — khong dung de khoa tai khoan */
    private Boolean isOnboarded = false;

    /** Khoa boi admin: chan dang nhap sync va API hoc vien */
    @Column(nullable = false)
    private Boolean accountLocked = false;

    @CreationTimestamp
    private LocalDateTime createdAt;
}