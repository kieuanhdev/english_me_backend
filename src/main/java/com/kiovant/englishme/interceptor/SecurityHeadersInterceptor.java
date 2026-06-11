package com.kiovant.englishme.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Security headers cho admin panel (HTML render — không áp cho /api JSON):
 * - X-Frame-Options DENY: chống clickjacking (nhúng admin vào iframe lừa bấm).
 * - X-Content-Type-Options nosniff: chặn browser đoán MIME.
 * - Referrer-Policy: không leak URL admin (kèm query) sang site ngoài.
 */
@Component
public class SecurityHeadersInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Referrer-Policy", "no-referrer");
        return true;
    }
}
