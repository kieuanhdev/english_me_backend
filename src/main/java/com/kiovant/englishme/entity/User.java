package com.kiovant.englishme.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

// equals/hashCode CHỈ theo id (identity của entity) — equals trên mọi field
// mutable vỡ khi entity nằm trong Set/Map mà state thay đổi (totalXp, streak...).
@Entity
@Table(name = "users")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
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

    @Column(nullable = false)
    private Integer totalXp = 0;

    @Column(nullable = false)
    private Integer currentStreak = 0;

    @Column(nullable = false)
    private Integer longestStreak = 0;

    private LocalDate lastActiveDate;

    /** Ngày cuối cùng user thực sự kiếm được XP — chuẩn cho tính streak (spec XP_SYSTEM_SPEC §2.1). */
    @Column(name = "last_xp_date")
    private LocalDate lastXpDate;

    @CreationTimestamp
    private LocalDateTime createdAt;

    /** Soft delete: khi != null, user bị ẩn khỏi list và sync Firebase bị chặn. */
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
}
