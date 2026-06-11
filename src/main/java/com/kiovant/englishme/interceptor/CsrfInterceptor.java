package com.kiovant.englishme.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

/**
 * CSRF cho admin panel (session-based, không dùng Spring Security).
 *
 * - Mọi request /admin/**: nếu session chưa có token thì phát một token mới
 *   (template đọc qua ${session.CSRF_TOKEN} để nhúng vào form).
 * - Mọi POST /admin/**: bắt buộc form param `_csrf` khớp token trong session,
 *   sai/thiếu trả 403. So sánh constant-time chống timing attack.
 *
 * Form admin đều là application/x-www-form-urlencoded (không multipart) nên
 * đọc bằng request.getParameter được trong interceptor.
 */
@Component
public class CsrfInterceptor implements HandlerInterceptor {

    public static final String SESSION_ATTR = "CSRF_TOKEN";
    public static final String FORM_PARAM = "_csrf";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession();
        String sessionToken = (String) session.getAttribute(SESSION_ATTR);
        if (sessionToken == null) {
            sessionToken = UUID.randomUUID().toString();
            session.setAttribute(SESSION_ATTR, sessionToken);
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String formToken = request.getParameter(FORM_PARAM);
            if (formToken == null || !constantTimeEquals(sessionToken, formToken)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid");
                return false;
            }
        }
        return true;
    }

    private static boolean constantTimeEquals(String a, String b) {
        return MessageDigest.isEqual(
                a.getBytes(StandardCharsets.UTF_8),
                b.getBytes(StandardCharsets.UTF_8));
    }
}
