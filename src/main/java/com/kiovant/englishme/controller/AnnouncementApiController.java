package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.AdminAnnouncementRow;
import com.kiovant.englishme.service.AdminNotificationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/announcements")
public class AnnouncementApiController {

    private final AdminNotificationService service;

    public AnnouncementApiController(AdminNotificationService service) {
        this.service = service;
    }

    /** Trả về danh sách announcement đang active (start_at <= now <= end_at, is_active=true). */
    @GetMapping("/active")
    public List<AdminAnnouncementRow> active() {
        LocalDateTime now = LocalDateTime.now();
        return service.listAnnouncements().stream()
                .filter(a -> Boolean.TRUE.equals(a.isActive()))
                .filter(a -> a.startAt() != null && !a.startAt().isAfter(now))
                .filter(a -> a.endAt() == null || !a.endAt().isBefore(now))
                .toList();
    }
}
