package com.kiovant.englishme.interceptor;

import com.kiovant.englishme.entity.AdminAuditLog;
import com.kiovant.englishme.repository.AdminAuditLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.lang.Nullable;

import java.util.Set;

/**
 * Ghi audit log cho mọi request thay đổi state (POST/PUT/DELETE/PATCH) trong /admin/**.
 * Chạy sau AdminRoleInterceptor — chỉ những request đã xác thực mới đến đây.
 */
@Component
public class AuditLogInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(AuditLogInterceptor.class);
    private static final Set<String> MUTATING_METHODS = Set.of("POST", "PUT", "DELETE", "PATCH");

    private final AdminAuditLogRepository auditRepo;

    public AuditLogInterceptor(AdminAuditLogRepository auditRepo) {
        this.auditRepo = auditRepo;
    }

    @Override
    public void afterCompletion(HttpServletRequest request,
                                HttpServletResponse response,
                                Object handler,
                                @Nullable Exception ex) {
        try {
            String method = request.getMethod();
            if (!MUTATING_METHODS.contains(method)) return;

            String uri = request.getRequestURI();
            if (uri == null || !uri.contains("/admin/")) return;
            // Bỏ qua login/logout
            if (uri.endsWith("/admin/login") || uri.endsWith("/admin/logout")) return;

            String adminEmail = currentAdminEmail(request);

            AdminAuditLog row = new AdminAuditLog();
            row.setAdminEmail(adminEmail);
            row.setAction(method);
            row.setRequestUri(truncate(uri, 500));
            row.setEntityType(extractEntityType(uri, request.getContextPath()));
            row.setEntityId(extractEntityId(uri));
            row.setStatusCode(response.getStatus());
            row.setIpAddress(truncate(clientIp(request), 45));
            row.setUserAgent(request.getHeader("User-Agent"));
            auditRepo.save(row);
        } catch (Exception e) {
            // Audit log không được làm vỡ request — log warning rồi nuốt.
            log.warn("Audit log write failed: {}", e.getMessage());
        }
    }

    private static String currentAdminEmail(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object email = session.getAttribute("ADMIN_EMAIL");
        return email == null ? null : email.toString();
    }

    private static String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            int comma = forwarded.indexOf(',');
            return comma > 0 ? forwarded.substring(0, comma).trim() : forwarded.trim();
        }
        return request.getRemoteAddr();
    }

    /** /admin/users/123/lock -> "users" */
    private static String extractEntityType(String uri, String contextPath) {
        String path = uri;
        if (contextPath != null && !contextPath.isEmpty() && path.startsWith(contextPath)) {
            path = path.substring(contextPath.length());
        }
        int idx = path.indexOf("/admin/");
        if (idx < 0) return null;
        String rest = path.substring(idx + "/admin/".length());
        int slash = rest.indexOf('/');
        String first = slash < 0 ? rest : rest.substring(0, slash);
        return first.isBlank() ? null : truncate(first, 100);
    }

    /** Trả về segment cuối nếu giống UUID/số; ngược lại null. */
    private static String extractEntityId(String uri) {
        if (uri == null) return null;
        String trimmed = uri.endsWith("/") ? uri.substring(0, uri.length() - 1) : uri;
        int slash = trimmed.lastIndexOf('/');
        if (slash < 0 || slash == trimmed.length() - 1) return null;
        String last = trimmed.substring(slash + 1);
        if (last.length() >= 1 && (isUuid(last) || isNumeric(last))) {
            return truncate(last, 100);
        }
        // thử thêm segment trước đó (vd /admin/users/{id}/lock)
        int prev = trimmed.lastIndexOf('/', slash - 1);
        if (prev < 0) return null;
        String mid = trimmed.substring(prev + 1, slash);
        if (isUuid(mid) || isNumeric(mid)) return truncate(mid, 100);
        return null;
    }

    private static boolean isUuid(String s) {
        if (s.length() != 36) return false;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            boolean hex = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
            boolean dash = c == '-' && (i == 8 || i == 13 || i == 18 || i == 23);
            if (!hex && !dash) return false;
        }
        return true;
    }

    private static boolean isNumeric(String s) {
        if (s.isEmpty()) return false;
        for (int i = 0; i < s.length(); i++) {
            if (!Character.isDigit(s.charAt(i))) return false;
        }
        return true;
    }

    private static String truncate(String s, int max) {
        if (s == null) return null;
        return s.length() <= max ? s : s.substring(0, max);
    }
}
