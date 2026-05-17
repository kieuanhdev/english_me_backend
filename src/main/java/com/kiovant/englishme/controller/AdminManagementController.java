package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AdminManagementService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/admin/admins")
public class AdminManagementController {

    private final AdminManagementService adminMgmt;

    public AdminManagementController(AdminManagementService adminMgmt) {
        this.adminMgmt = adminMgmt;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("admins", adminMgmt.listAccounts());
        model.addAttribute("roles", AdminManagementService.ALLOWED_ROLES);
        return "admin/admin-accounts";
    }

    @PostMapping
    public String create(@RequestParam String email,
                         @RequestParam String password,
                         @RequestParam(required = false, defaultValue = "") String fullName,
                         @RequestParam(required = false, defaultValue = "VIEWER") String role,
                         RedirectAttributes ra) {
        try {
            var a = adminMgmt.create(email, password, fullName, role);
            ra.addFlashAttribute("successMessage",
                    "Đã tạo admin: " + a.getEmail() + " (" + a.getRole() + ").");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể tạo admin."));
        }
        return "redirect:/admin/admins";
    }

    @PostMapping("/{id}/role")
    public String updateRole(@PathVariable UUID id,
                             @RequestParam String role,
                             RedirectAttributes ra) {
        try {
            var a = adminMgmt.updateRole(id, role);
            ra.addFlashAttribute("successMessage",
                    "Đã đổi role của " + a.getEmail() + " thành " + a.getRole() + ".");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể đổi role."));
        }
        return "redirect:/admin/admins";
    }

    @PostMapping("/{id}/reset-password")
    public String resetPassword(@PathVariable UUID id,
                                @RequestParam(required = false, defaultValue = "") String newPassword,
                                RedirectAttributes ra) {
        try {
            String generated = adminMgmt.resetPassword(id, newPassword.isBlank() ? null : newPassword);
            if (newPassword.isBlank()) {
                ra.addFlashAttribute("successMessage",
                        "Đã reset password. Mật khẩu tạm thời: " + generated + " (lưu lại ngay, chỉ hiển thị 1 lần).");
            } else {
                ra.addFlashAttribute("successMessage", "Đã reset password.");
            }
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể reset password."));
        }
        return "redirect:/admin/admins";
    }

    @PostMapping("/{id}/disable")
    public String disable(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminMgmt.disable(id);
            ra.addFlashAttribute("successMessage", "Đã vô hiệu hóa admin.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể vô hiệu hóa admin."));
        }
        return "redirect:/admin/admins";
    }

    @PostMapping("/{id}/enable")
    public String enable(@PathVariable UUID id, RedirectAttributes ra) {
        try {
            adminMgmt.setActive(id, true);
            ra.addFlashAttribute("successMessage", "Đã kích hoạt lại admin.");
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage", reasonOr(ex, "Không thể kích hoạt admin."));
        }
        return "redirect:/admin/admins";
    }

    private static String reasonOr(ResponseStatusException ex, String fallback) {
        return ex.getReason() == null ? fallback : ex.getReason();
    }
}
