package com.kiovant.englishme.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Trang tĩnh về pháp lý (điều khoản sử dụng, chính sách quyền riêng tư).
 * Truy cập công khai — không qua AdminRoleInterceptor (chỉ chặn /admin/**).
 */
@Controller
public class LegalViewController {

    /** Điều khoản sử dụng — mở từ màn đăng ký của app. */
    @GetMapping("/terms")
    public String termsPage() {
        return "terms";
    }

    /** Chính sách quyền riêng tư. */
    @GetMapping("/privacy")
    public String privacyPage() {
        return "privacy";
    }
}
