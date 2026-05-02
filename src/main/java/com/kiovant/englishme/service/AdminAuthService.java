package com.kiovant.englishme.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class AdminAuthService {
    private final String adminEmail;
    private final String adminPassword;
    private final String adminRole;

    public AdminAuthService(
            @Value("${admin.auth.email}") String adminEmail,
            @Value("${admin.auth.password}") String adminPassword,
            @Value("${admin.auth.role}") String adminRole
    ) {
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
        this.adminRole = adminRole;
    }

    public boolean authenticate(String email, String password) {
        if (email == null || password == null) {
            return false;
        }
        return adminEmail.equalsIgnoreCase(email.trim()) && adminPassword.equals(password);
    }

    public String getAdminRole() {
        return adminRole;
    }
}
