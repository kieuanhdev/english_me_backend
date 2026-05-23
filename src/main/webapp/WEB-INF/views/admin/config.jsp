<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.AppConfig" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <%@ include file="layout/head.jspf" %>
</head>
<body class="bg-surface text-on-surface">
<%@ include file="layout/sidebar.jspf" %>
<main class="ml-64 min-h-screen">
    <%@ include file="layout/topbar.jspf" %>

    <%
        List<AppConfig> configs = (List<AppConfig>) request.getAttribute("configs");
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Cấu hình hệ thống</h1>
            <p class="max-w-2xl text-indigo-100">Quản lý API keys và các tham số vận hành của ứng dụng.</p>
        </section>

        <% if (successMessage != null) { %>
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl px-6 py-4"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="bg-red-50 border border-red-200 text-red-800 rounded-2xl px-6 py-4"><%= errorMessage %></div>
        <% } %>

        <div class="space-y-4">
            <% if (configs != null) { for (AppConfig cfg : configs) {
                boolean isSecret = cfg.isSecret();
                String displayValue = (isSecret && cfg.getConfigValue() != null && !cfg.getConfigValue().isBlank())
                        ? "••••••••" : (cfg.getConfigValue() != null ? cfg.getConfigValue() : "");
                String inputType = isSecret ? "password" : "text";
            %>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <div class="flex items-start justify-between gap-4 mb-4">
                    <div>
                        <div class="flex items-center gap-2">
                            <code class="text-sm font-bold text-primary bg-indigo-50 px-2 py-0.5 rounded"><%= cfg.getConfigKey() %></code>
                            <% if (isSecret) { %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">Secret</span>
                            <% } %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-slate-100 text-slate-500 px-2 py-0.5 rounded-full"><%= cfg.getValueType() %></span>
                        </div>
                        <% if (cfg.getDescription() != null) { %>
                        <p class="text-sm text-slate-500 mt-1"><%= cfg.getDescription() %></p>
                        <% } %>
                    </div>
                    <% if (cfg.getUpdatedAt() != null) { %>
                    <p class="text-xs text-slate-400 whitespace-nowrap">Cập nhật: <%= cfg.getUpdatedAt().format(dtf) %>
                        <% if (cfg.getUpdatedByEmail() != null) { %> bởi <%= cfg.getUpdatedByEmail() %><% } %>
                    </p>
                    <% } %>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/config" class="flex gap-3">
                    <input type="hidden" name="key" value="<%= cfg.getConfigKey() %>">
                    <input
                        type="<%= inputType %>"
                        name="value"
                        placeholder="<%= isSecret ? "Nhập giá trị mới..." : displayValue %>"
                        value="<%= isSecret ? "" : displayValue %>"
                        class="flex-1 border border-slate-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
                    >
                    <button type="submit" class="px-5 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:opacity-90">Lưu</button>
                </form>
            </div>
            <% } } %>
        </div>
    </div>
</main>
</body>
</html>
