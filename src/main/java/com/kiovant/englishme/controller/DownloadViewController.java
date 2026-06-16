package com.kiovant.englishme.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Trang tải app công khai — ai cũng truy cập, KHÔNG qua AdminRoleInterceptor
 * (interceptor chỉ chặn /admin/**).
 *
 * File APK đặt ở static/downloads/englishme.apk, Spring tự serve qua URL
 * /downloads/englishme.apk — không cần endpoint riêng.
 */
@Controller
public class DownloadViewController {

    /** Landing page giới thiệu app + nút tải. */
    @GetMapping("/download")
    public String downloadPage(Model model) {
        boolean apkAvailable = new ClassPathResource("static/downloads/englishme.apk").exists();
        model.addAttribute("apkAvailable", apkAvailable);
        return "download";
    }
}
