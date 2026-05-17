package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AdminHomeContentService;
import org.springframework.format.annotation.DateTimeFormat;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Controller
@RequestMapping("/admin/home-content")
public class AdminHomeContentController {

    private final AdminHomeContentService service;

    public AdminHomeContentController(AdminHomeContentService service) {
        this.service = service;
    }

    // ── Word of Day ─────────────────────────────────────────────────────────

    @GetMapping("/word-of-day")
    public String wordOfDayPage(@RequestParam(required = false, defaultValue = "") String levelFilter,
                                Model model) {
        model.addAttribute("rows", service.listWordOfDay());
        model.addAttribute("words", service.wordsForPicker(levelFilter));
        model.addAttribute("levelFilter", levelFilter);
        return "admin/home-word-of-day";
    }

    @PostMapping("/word-of-day")
    public String createWordOfDay(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate scheduledDate,
            @RequestParam UUID wordId,
            @RequestParam(required = false, defaultValue = "") String level,
            @RequestParam(required = false, defaultValue = "") String note,
            RedirectAttributes ra) {
        try {
            service.createWordOfDay(scheduledDate, wordId, level, note);
            ra.addFlashAttribute("successMessage",
                    "Đã lên lịch Word of Day cho ngày " + scheduledDate + ".");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo Word of Day."));
        }
        return "redirect:/admin/home-content/word-of-day";
    }

    @PostMapping("/word-of-day/{id}/delete")
    public String deleteWordOfDay(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            service.deleteWordOfDay(id);
            ra.addFlashAttribute("successMessage", "Đã xóa Word of Day.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa."));
        }
        return "redirect:/admin/home-content/word-of-day";
    }

    // ── Recommendations ─────────────────────────────────────────────────────

    @GetMapping("/recommendations")
    public String recommendationsPage(Model model) {
        model.addAttribute("rows", service.listRecommendations());
        return "admin/home-recommendations";
    }

    @PostMapping("/recommendations")
    public String createRecommendation(
            @RequestParam String level,
            @RequestParam String type,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String description,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            @RequestParam(required = false) Integer sortOrder,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra) {
        try {
            service.createRecommendation(level, type, title, description, actionUrl, sortOrder, isActive);
            ra.addFlashAttribute("successMessage", "Đã tạo recommendation.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo recommendation."));
        }
        return "redirect:/admin/home-content/recommendations";
    }

    @PostMapping("/recommendations/{id}/update")
    public String updateRecommendation(
            @PathVariable UUID id,
            @RequestParam String level,
            @RequestParam String type,
            @RequestParam String title,
            @RequestParam(required = false, defaultValue = "") String description,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            @RequestParam(required = false) Integer sortOrder,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra) {
        try {
            service.updateRecommendation(id, level, type, title, description, actionUrl, sortOrder, isActive);
            ra.addFlashAttribute("successMessage", "Đã cập nhật recommendation.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật."));
        }
        return "redirect:/admin/home-content/recommendations";
    }

    @PostMapping("/recommendations/{id}/delete")
    public String deleteRecommendation(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            service.deleteRecommendation(id);
            ra.addFlashAttribute("successMessage", "Đã xóa recommendation.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa."));
        }
        return "redirect:/admin/home-content/recommendations";
    }

    // ── Banners ─────────────────────────────────────────────────────────────

    @GetMapping("/banners")
    public String bannersPage(Model model) {
        model.addAttribute("rows", service.listBanners());
        return "admin/home-banners";
    }

    @PostMapping("/banners")
    public String createBanner(
            @RequestParam String title,
            @RequestParam String imageUrl,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
            @RequestParam(required = false) Integer sortOrder,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra) {
        try {
            service.createBanner(title, imageUrl, actionUrl, startAt, endAt, sortOrder, isActive);
            ra.addFlashAttribute("successMessage", "Đã tạo banner.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo banner."));
        }
        return "redirect:/admin/home-content/banners";
    }

    @PostMapping("/banners/{id}/update")
    public String updateBanner(
            @PathVariable UUID id,
            @RequestParam String title,
            @RequestParam String imageUrl,
            @RequestParam(required = false, defaultValue = "") String actionUrl,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endAt,
            @RequestParam(required = false) Integer sortOrder,
            @RequestParam(required = false) Boolean isActive,
            RedirectAttributes ra) {
        try {
            service.updateBanner(id, title, imageUrl, actionUrl, startAt, endAt, sortOrder, isActive);
            ra.addFlashAttribute("successMessage", "Đã cập nhật banner.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể cập nhật banner."));
        }
        return "redirect:/admin/home-content/banners";
    }

    @PostMapping("/banners/{id}/delete")
    public String deleteBanner(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            service.deleteBanner(id);
            ra.addFlashAttribute("successMessage", "Đã xóa banner.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể xóa banner."));
        }
        return "redirect:/admin/home-content/banners";
    }

    @PostMapping("/banners/{id}/image")
    public String uploadBannerImage(@PathVariable UUID id,
                                    @RequestParam("image") MultipartFile image,
                                    RedirectAttributes ra) {
        try {
            String url = service.uploadBannerImage(id, image);
            ra.addFlashAttribute("successMessage", "Đã upload ảnh: " + url);
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể upload ảnh."));
        }
        return "redirect:/admin/home-content/banners";
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
