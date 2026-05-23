package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AppConfigService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/config")
public class AdminConfigController {

    private final AppConfigService appConfigService;

    public AdminConfigController(AppConfigService appConfigService) {
        this.appConfigService = appConfigService;
    }

    @GetMapping
    public String configPage(Model model) {
        model.addAttribute("configs", appConfigService.findAll());
        return "admin/config";
    }

    @PostMapping
    public String updateConfig(
            @RequestParam String key,
            @RequestParam String value,
            HttpSession session,
            RedirectAttributes ra
    ) {
        try {
            String adminEmail = (String) session.getAttribute("ADMIN_EMAIL");
            appConfigService.setValue(key, value, adminEmail);
            ra.addFlashAttribute("successMessage", "Đã cập nhật cấu hình.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/admin/config";
    }
}
