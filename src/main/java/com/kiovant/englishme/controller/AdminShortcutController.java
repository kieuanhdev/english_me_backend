package com.kiovant.englishme.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminShortcutController {

    @GetMapping({"/", "/a"})
    public String shortcutToAdmin() {
        return "redirect:/admin/login";
    }
}
