package com.kiovant.englishme.controller;

import com.kiovant.englishme.entity.AdminNotification;
import com.kiovant.englishme.service.AdminNotificationService;
import jakarta.servlet.http.HttpSession;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.UUID;

@Controller
@RequestMapping("/admin")
public class AdminNotificationController {

    private final AdminNotificationService service;

    public AdminNotificationController(AdminNotificationService service) {
        this.service = service;
    }

    // ── Push notification ───────────────────────────────────────────────────

    @GetMapping("/notifications")
    public String list(Model model) {
        model.addAttribute("rows", service.listHistory());
        return "admin/notifications";
    }

    @PostMapping("/notifications/broadcast")
    public String broadcast(
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(required = false, defaultValue = "") String imageUrl,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            HttpSession session,
            RedirectAttributes ra) {
        try {
            AdminNotification n = service.broadcast(title, body, imageUrl, actionUrl, sessionEmail(session));
            ra.addFlashAttribute("successMessage",
                    "Đã gửi broadcast tới " + n.getTargetCount() + " device (thành công: "
                            + n.getSuccessCount() + ", thất bại: " + n.getFailureCount() + ").");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể gửi broadcast."));
        }
        return "redirect:/admin/notifications";
    }

    @PostMapping("/notifications/targeted")
    public String targeted(
            @RequestParam String segmentType,
            @RequestParam(required = false, defaultValue = "") String segmentValue,
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(required = false, defaultValue = "") String imageUrl,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            HttpSession session,
            RedirectAttributes ra) {
        try {
            AdminNotification n = service.targeted(segmentType, segmentValue, title, body,
                    imageUrl, actionUrl, sessionEmail(session));
            ra.addFlashAttribute("successMessage",
                    "Đã gửi tới segment " + n.getSegmentType()
                            + (n.getSegmentValue() == null ? "" : "=" + n.getSegmentValue())
                            + " — target=" + n.getTargetCount()
                            + ", thành công=" + n.getSuccessCount()
                            + ", thất bại=" + n.getFailureCount() + ".");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể gửi push."));
        }
        return "redirect:/admin/notifications";
    }

    @GetMapping("/notifications/{id}/stats")
    public String stats(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            AdminNotification n = service.getOrThrow(id);
            model.addAttribute("notification", n);
            return "admin/notification-stats";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không tìm thấy push."));
            return "redirect:/admin/notifications";
        }
    }

    // ── Announcement (banner trong app) ─────────────────────────────────────

    @GetMapping("/announcements")
    public String announcements(Model model) {
        model.addAttribute("rows", service.listAnnouncements());
        return "admin/announcements";
    }

    @PostMapping("/announcements")
    public String createAnnouncement(
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(required = false, defaultValue = "info") String severity,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
            @RequestParam(required = false) Boolean isActive,
            HttpSession session,
            RedirectAttributes ra) {
        try {
            service.createAnnouncement(title, body, severity, startAt, endAt, isActive, sessionEmail(session));
            ra.addFlashAttribute("successMessage", "Đã tạo announcement.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo announcement."));
        }
        return "redirect:/admin/announcements";
    }

    @PostMapping("/announcements/{id}/update")
    public String updateAnnouncement(
            @PathVariable UUID id,
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(required = false, defaultValue = "info") String severity,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra) {
        try {
            service.updateAnnouncement(id, title, body, severity, startAt, endAt, isActive);
            ra.addFlashAttribute("successMessage", "Đã cập nhật announcement.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật."));
        }
        return "redirect:/admin/announcements";
    }

    @PostMapping("/announcements/{id}/delete")
    public String deleteAnnouncement(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            service.deleteAnnouncement(id);
            ra.addFlashAttribute("successMessage", "Đã xóa announcement.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa."));
        }
        return "redirect:/admin/announcements";
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static String sessionEmail(HttpSession session) {
        Object e = session.getAttribute("ADMIN_EMAIL");
        return e == null ? null : e.toString();
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
