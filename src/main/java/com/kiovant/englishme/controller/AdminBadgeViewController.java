package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.BadgeService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

/**
 * Trang admin quản lý thành tựu (badge): tạo / sửa / xóa, bật-tắt.
 * Điều kiện auto-award lưu dưới dạng condition_type + condition_value (xem V72,
 * {@link BadgeService}). Badge bật sẽ được {@code XpService.grant} tự rà & cấp.
 */
@Controller
@RequestMapping("/admin/badges")
public class AdminBadgeViewController {

    private final BadgeService badgeService;

    public AdminBadgeViewController(BadgeService badgeService) {
        this.badgeService = badgeService;
    }

    @GetMapping
    public String page(Model model) {
        model.addAttribute("badges", badgeService.listAll());
        model.addAttribute("conditionTypes", BadgeService.CONDITION_TYPES);
        return "admin/badges";
    }

    @PostMapping
    public String save(
            @RequestParam(required = false) String id,
            @RequestParam String name,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String iconUrl,
            @RequestParam String conditionType,
            @RequestParam(required = false) String conditionValueRaw,
            @RequestParam(required = false) String isActive,
            RedirectAttributes ra
    ) {
        try {
            UUID badgeId = (id == null || id.isBlank()) ? null : UUID.fromString(id.trim());
            Integer value = null;
            if (conditionValueRaw != null && !conditionValueRaw.isBlank()) {
                value = Integer.parseInt(conditionValueRaw.trim());
            }
            boolean active = "on".equalsIgnoreCase(isActive) || "true".equalsIgnoreCase(isActive);
            badgeService.save(badgeId, name, description, iconUrl, conditionType, value, active);
            ra.addFlashAttribute("successMessage",
                    badgeId == null ? "Đã tạo badge mới." : "Đã cập nhật badge.");
        } catch (NumberFormatException ex) {
            ra.addFlashAttribute("errorMessage", "Ngưỡng phải là số nguyên.");
        } catch (IllegalArgumentException ex) {
            ra.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/admin/badges";
    }

    @PostMapping("/delete")
    public String delete(@RequestParam String id, RedirectAttributes ra) {
        try {
            badgeService.delete(UUID.fromString(id.trim()));
            ra.addFlashAttribute("successMessage", "Đã xóa badge.");
        } catch (Exception ex) {
            ra.addFlashAttribute("errorMessage", "Không xóa được badge: " + ex.getMessage());
        }
        return "redirect:/admin/badges";
    }
}
