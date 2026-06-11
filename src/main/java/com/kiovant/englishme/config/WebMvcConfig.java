package com.kiovant.englishme.config;

import com.kiovant.englishme.interceptor.AdminRoleInterceptor;
import com.kiovant.englishme.interceptor.CsrfInterceptor;
import com.kiovant.englishme.interceptor.SecurityHeadersInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final AdminRoleInterceptor adminRoleInterceptor;
    private final CsrfInterceptor csrfInterceptor;
    private final SecurityHeadersInterceptor securityHeadersInterceptor;

    /**
     * Danh sách origin được phép, override qua property `app.cors.allowed-origins`
     * (vd. trong application.yaml hoặc env: APP_CORS_ALLOWED_ORIGINS).
     * Mobile app KHÔNG cần CORS — chỉ web client (dev tool, admin SPA tương lai) cần.
     */
    @Value("${app.cors.allowed-origins:http://localhost:3000,https://app.englishme.vn}")
    private String[] allowedOrigins;

    public WebMvcConfig(AdminRoleInterceptor adminRoleInterceptor,
                        CsrfInterceptor csrfInterceptor,
                        SecurityHeadersInterceptor securityHeadersInterceptor) {
        this.adminRoleInterceptor = adminRoleInterceptor;
        this.csrfInterceptor = csrfInterceptor;
        this.securityHeadersInterceptor = securityHeadersInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(adminRoleInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login", "/admin/logout");
        // CSRF áp cho TOÀN BỘ /admin/** kể cả login/logout (login-CSRF cũng là tấn công).
        registry.addInterceptor(csrfInterceptor)
                .addPathPatterns("/admin/**");
        registry.addInterceptor(securityHeadersInterceptor)
                .addPathPatterns("/admin/**");
    }

    /**
     * CORS cho API client (spec mục 8 — Acceptance Checklist).
     * Siết theo SECURITY_REVIEW SEC-07: origin cụ thể (hết wildcard port),
     * header whitelist (hết "*"), allowCredentials=false vì auth là Bearer
     * token trong header — không dùng cookie, không cần credentials mode.
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(allowedOrigins)
                .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                .allowedHeaders("Authorization", "Content-Type", "X-Requested-With")
                .allowCredentials(false)
                .maxAge(3600);
    }
}
