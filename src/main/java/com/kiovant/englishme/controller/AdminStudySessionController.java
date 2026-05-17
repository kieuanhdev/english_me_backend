package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AdminStudySessionService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.UUID;

@Controller
@RequestMapping("/admin/study-sessions")
public class AdminStudySessionController {

    private final AdminStudySessionService service;

    public AdminStudySessionController(AdminStudySessionService service) {
        this.service = service;
    }

    @GetMapping
    public String list(
            @RequestParam(required = false, defaultValue = "") String status,
            @RequestParam(required = false, defaultValue = "") String q,
            @RequestParam(required = false) UUID deskId,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "20") int size,
            Model model
    ) {
        var data = service.list(status, q, deskId, page, size);
        model.addAttribute("sessionsPage", data);
        model.addAttribute("selectedStatus", status == null ? "" : status);
        model.addAttribute("selectedKeyword", q == null ? "" : q);
        model.addAttribute("selectedDeskId", deskId == null ? "" : deskId.toString());
        model.addAttribute("currentPage", Math.max(page, 0));
        model.addAttribute("pageSize", Math.min(Math.max(size, 1), 100));
        return "admin/study-sessions";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable UUID id, Model model, RedirectAttributes ra) {
        try {
            model.addAttribute("detail", service.getDetail(id));
            return "admin/study-session-detail";
        } catch (ResponseStatusException ex) {
            ra.addFlashAttribute("errorMessage",
                    ex.getReason() == null ? "Không tìm thấy study session." : ex.getReason());
            return "redirect:/admin/study-sessions";
        }
    }
}
