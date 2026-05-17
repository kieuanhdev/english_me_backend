package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.AdminAuditLogService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@RequestMapping("/admin/audit-log")
public class AdminAuditController {

    private final AdminAuditLogService auditService;

    public AdminAuditController(AdminAuditLogService auditService) {
        this.auditService = auditService;
    }

    @GetMapping
    public String list(@RequestParam(required = false) String email,
                       @RequestParam(required = false) String action,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                       @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                       Model model) {
        model.addAttribute("logs", auditService.search(email, action, from, to));
        model.addAttribute("filterEmail", email);
        model.addAttribute("filterAction", action);
        model.addAttribute("filterFrom", from);
        model.addAttribute("filterTo", to);
        return "admin/audit-log";
    }
}
