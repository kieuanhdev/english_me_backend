package com.kiovant.englishme.config;

import com.kiovant.englishme.interceptor.AdminRoleInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final AdminRoleInterceptor adminRoleInterceptor;

    /**
     * Danh sách origin được phép, override qua property `app.cors.allowed-origins`
     * (vd. trong application.yaml hoặc env: APP_CORS_ALLOWED_ORIGINS).
     */
    @Value("${app.cors.allowed-origins:http://localhost:*,https://app.englishme.vn}")
    private String[] allowedOrigins;

    public WebMvcConfig(AdminRoleInterceptor adminRoleInterceptor) {
        this.adminRoleInterceptor = adminRoleInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(adminRoleInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login", "/admin/logout");
    }

    /**
     * CORS cho API client (spec mục 8 — Acceptance Checklist).
     * Dùng allowedOriginPatterns để hỗ trợ wildcard port (vd. localhost:* cho dev web).
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns(allowedOrigins)
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .exposedHeaders("Authorization", "Content-Type")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
