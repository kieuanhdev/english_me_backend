package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AdminAuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/admin")
public class AdminAuthViewController {

    private final AdminAuthService adminAuthService;

    public AdminAuthViewController(AdminAuthService adminAuthService) {
        this.adminAuthService = adminAuthService;
    }

    @GetMapping("/login")
    public String loginPage(HttpSession session) {
        Object role = session.getAttribute("ADMIN_ROLE");
        if (role != null && adminAuthService.getAdminRole().equals(role.toString())) {
            return "redirect:/admin";
        }
        return "admin/login";
    }

    @PostMapping("/login")
    public String login(
            @RequestParam String email,
            @RequestParam String password,
            HttpServletRequest request,
            Model model
    ) {
        if (!adminAuthService.authenticate(email, password)) {
            model.addAttribute("errorMessage", "Email hoặc mật khẩu không đúng, hoặc bạn không có quyền admin.");
            return "admin/login";
        }

        // Chống session fixation: hủy session cũ (attacker có thể đã biết ID),
        // cấp session ID mới rồi mới gắn quyền admin.
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("ADMIN_EMAIL", email);
        session.setAttribute("ADMIN_ROLE", adminAuthService.getAdminRole());
        return "redirect:/admin";
    }

    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/admin/login";
    }
}
