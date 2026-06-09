package com.kiovant.englishme.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AdminRoleInterceptor implements HandlerInterceptor {

    private final String adminRole;

    public AdminRoleInterceptor(@Value("${admin.auth.role}") String adminRole) {
        this.adminRole = adminRole;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Phòng thủ: không bao giờ gác trang login/logout, tránh redirect loop
        // nếu excludePathPatterns ở WebMvcConfig vì lý do nào đó không khớp.
        String path = request.getRequestURI().substring(request.getContextPath().length());
        if (path.equals("/admin/login") || path.equals("/admin/logout")) {
            return true;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return false;
        }

        Object role = session.getAttribute("ADMIN_ROLE");
        if (role == null || !adminRole.equals(role.toString())) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return false;
        }
        return true;
    }
}
