package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminViewController {

    @Autowired
    private UserService userService;

    @GetMapping
    public String dashboard() {
        return "admin/dashboard";
    }

    @GetMapping("/users")
    public String users(
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q,
            Model model
    ) {
        model.addAttribute("users", userService.findUsersByFilter(cefr, status, q));
        model.addAttribute("selectedCefr", cefr);
        model.addAttribute("selectedStatus", status);
        model.addAttribute("selectedKeyword", q);
        return "admin/users";
    }
}
