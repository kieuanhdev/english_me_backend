package com.kiovant.englishme.controller;

import com.kiovant.englishme.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.UUID;

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

    @PostMapping("/users/{id}/unlock")
    public String unlockUser(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        userService.unlockUser(id);
        return redirectToUsers(cefr, status, q);
    }

    @PostMapping("/users/{id}/lock")
    public String lockUser(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "") String cefr,
            @RequestParam(required = false, defaultValue = "all") String status,
            @RequestParam(required = false, defaultValue = "") String q
    ) {
        userService.lockUser(id);
        return redirectToUsers(cefr, status, q);
    }

    private static String redirectToUsers(String cefr, String status, String q) {
        String target = UriComponentsBuilder.fromPath("/admin/users")
                .queryParam("cefr", cefr == null ? "" : cefr)
                .queryParam("status", status == null ? "all" : status)
                .queryParam("q", q == null ? "" : q)
                .build()
                .encode()
                .toUriString();
        return "redirect:" + target;
    }

}
