package com.kiovant.englishme.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/practice")
public class PronunciationViewController {

    @GetMapping("/pronunciation")
    public String pronunciationPage() {
        return "pronunciation";
    }
}
