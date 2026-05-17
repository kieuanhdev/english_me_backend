package com.kiovant.englishme.config;

import com.kiovant.englishme.interceptor.AdminRoleInterceptor;
import com.kiovant.englishme.interceptor.AuditLogInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final AdminRoleInterceptor adminRoleInterceptor;
    private final AuditLogInterceptor auditLogInterceptor;

    public WebMvcConfig(AdminRoleInterceptor adminRoleInterceptor,
                        AuditLogInterceptor auditLogInterceptor) {
        this.adminRoleInterceptor = adminRoleInterceptor;
        this.auditLogInterceptor = auditLogInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(adminRoleInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login", "/admin/logout");

        registry.addInterceptor(auditLogInterceptor)
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login", "/admin/logout");
    }
}
