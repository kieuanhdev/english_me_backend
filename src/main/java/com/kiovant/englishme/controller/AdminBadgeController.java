package com.kiovant.englishme.controller;

import com.kiovant.englishme.dto.CreateBadgeRequest;
import com.kiovant.englishme.dto.UpdateBadgeRequest;
import com.kiovant.englishme.service.AdminBadgeService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/admin/badges")
public class AdminBadgeController {

    private final AdminBadgeService adminBadgeService;

    public AdminBadgeController(AdminBadgeService adminBadgeService) {
        this.adminBadgeService = adminBadgeService;
    }

    // ── List ────────────────────────────────────────────────────────────────

    @GetMapping
    public String list(Model model) {
        model.addAttribute("badges", adminBadgeService.listBadges());
        return "admin/badges";
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    @PostMapping
    public String create(
            @RequestParam String name,
            @RequestParam(required = false, defaultValue = "") String description,
            @RequestParam(required = false, defaultValue = "") String iconUrl,
            @RequestParam String conditionType,
            @RequestParam(required = false) Integer conditionValue,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra
    ) {
        try {
            var badge = adminBadgeService.create(new CreateBadgeRequest(
                    name, blankToNull(description), blankToNull(iconUrl),
                    conditionType, conditionValue,
                    isActive == null ? Boolean.TRUE : isActive));
            int awarded = adminBadgeService.reevaluateBadge(badge.getId());
            ra.addFlashAttribute("successMessage",
                    "Đã tạo badge \"" + badge.getName() + "\". Đã backfill " + awarded + " user thỏa điều kiện.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo badge."));
        }
        return "redirect:/admin/badges";
    }

    @PostMapping("/{id}/update")
    public String update(
            @PathVariable UUID id,
            @RequestParam String name,
            @RequestParam(required = false, defaultValue = "") String description,
            @RequestParam(required = false, defaultValue = "") String iconUrl,
            @RequestParam String conditionType,
            @RequestParam(required = false) Integer conditionValue,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra
    ) {
        try {
            adminBadgeService.update(id, new UpdateBadgeRequest(
                    name, blankToNull(description), blankToNull(iconUrl),
                    conditionType, conditionValue,
                    isActive == null ? Boolean.TRUE : isActive));
            int awarded = adminBadgeService.reevaluateBadge(id);
            ra.addFlashAttribute("successMessage",
                    "Đã cập nhật badge. Re-evaluate: +" + awarded + " user mới đạt.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật badge."));
        }
        return "redirect:/admin/badges";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminBadgeService.delete(id);
            ra.addFlashAttribute("successMessage", "Đã xóa badge.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa badge."));
        }
        return "redirect:/admin/badges";
    }

    // ── Icon upload ─────────────────────────────────────────────────────────

    @PostMapping("/{id}/icon")
    public String uploadIcon(@PathVariable UUID id,
                             @RequestParam("icon") MultipartFile icon,
                             RedirectAttributes ra) {
        try {
            String url = adminBadgeService.uploadIcon(id, icon);
            ra.addFlashAttribute("successMessage", "Đã upload icon: " + url);
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể upload icon."));
        }
        return "redirect:/admin/badges";
    }

    // ── Users earned ────────────────────────────────────────────────────────

    @GetMapping("/{id}/users")
    public String users(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            var badge = adminBadgeService.getOrThrow(id);
            model.addAttribute("badge", badge);
            model.addAttribute("users", adminBadgeService.listUsersForBadge(id));
            return "admin/badge-users";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Badge không tồn tại."));
            return "redirect:/admin/badges";
        }
    }

    // ── Re-evaluate trigger (cron-like, manual) ─────────────────────────────

    @PostMapping("/{id}/reevaluate")
    public String reevaluate(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            int awarded = adminBadgeService.reevaluateBadge(id);
            ra.addFlashAttribute("successMessage", "Đã quét lại: +" + awarded + " user được gắn badge.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể re-evaluate."));
        }
        return "redirect:/admin/badges";
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
