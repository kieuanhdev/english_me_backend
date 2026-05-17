package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AppConfigService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/config")
public class AdminConfigController {

    private final AppConfigService configService;

    public AdminConfigController(AppConfigService configService) {
        this.configService = configService;
    }

    @GetMapping
    public String list(@RequestParam(name = "revealSecrets", required = false, defaultValue = "false") boolean reveal,
                       Model model) {
        model.addAttribute("configs", configService.listAll(reveal));
        model.addAttribute("revealSecrets", reveal);
        return "admin/config";
    }

    /** Form submit POST (browser không gửi PUT trực tiếp được trong <form>). */
    @PostMapping("/{key}")
    public String updateForm(@PathVariable("key") String key,
                             @RequestParam(name = "value", required = false, defaultValue = "") String value,
                             HttpSession session,
                             RedirectAttributes ra) {
        return doUpdate(key, value, session, ra);
    }

    /** PUT cho REST/API clients — cùng logic. */
    @PutMapping("/{key}")
    public String updateRest(@PathVariable("key") String key,
                             @RequestParam(name = "value", required = false, defaultValue = "") String value,
                             HttpSession session,
                             RedirectAttributes ra) {
        return doUpdate(key, value, session, ra);
    }

    @PostMapping("/reload")
    public String reload(RedirectAttributes ra) {
        configService.reloadAll();
        ra.addFlashAttribute("successMessage", "Đã reload cache config từ DB.");
        return "redirect:/admin/config";
    }

    private String doUpdate(String key, String value, HttpSession session, RedirectAttributes ra) {
        try {
            String adminEmail = session.getAttribute("ADMIN_EMAIL") == null
                    ? null : session.getAttribute("ADMIN_EMAIL").toString();
            configService.update(key, value, adminEmail);
            ra.addFlashAttribute("successMessage", "Đã cập nhật config: " + key);
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage",
                    ex.getReason() == null ? "Không thể cập nhật config." : ex.getReason());
        }
        return "redirect:/admin/config";
    }
}
