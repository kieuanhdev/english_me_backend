<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminAccountRow" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
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
        @SuppressWarnings("unchecked")
        List<AdminAccountRow> admins = (List<AdminAccountRow>) request.getAttribute("admins");
        @SuppressWarnings("unchecked")
        Set<String> roles = (Set<String>) request.getAttribute("roles");
        int total = admins == null ? 0 : admins.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <div class="p-8 space-y-8">
        <% if (successMessage != null) { %>
        <div class="rounded-2xl bg-emerald-50 text-emerald-800 px-5 py-3 text-sm font-semibold border border-emerald-100">
            <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Admin Accounts</h1>
                <p class="text-slate-500 font-medium">Quản lý tài khoản admin DB-backed — <%= total %> account.</p>
            </div>
            <div class="flex gap-3 text-sm">
                <a href="${pageContext.request.contextPath}/admin/audit-log"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Audit log</a>
            </div>
        </div>

        <!-- Form tạo admin -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6">
            <h2 class="text-lg font-bold text-indigo-950 mb-4">Tạo admin mới</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin/admins"
                  class="grid grid-cols-1 md:grid-cols-5 gap-3">
                <input type="email" name="email" placeholder="email@kiovant.com" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="password" name="password" placeholder="Mật khẩu (≥ 8 ký tự)" required minlength="8"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <input type="text" name="fullName" placeholder="Họ tên"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <select name="role" class="rounded-xl border border-slate-200 px-3 py-2 text-sm">
                    <% if (roles != null) for (String r : roles) { %>
                        <option value="<%= r %>" <%= "VIEWER".equals(r) ? "selected" : "" %>><%= r %></option>
                    <% } %>
                </select>
                <div class="md:col-span-5 flex justify-end">
                    <button type="submit"
                            class="px-5 py-2 rounded-xl bg-primary text-white font-semibold hover:opacity-90">
                        + Tạo admin
                    </button>
                </div>
            </form>
        </div>

        <!-- Bảng admin -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 uppercase text-xs tracking-wider">
                <tr>
                    <th class="text-left px-5 py-3">Email</th>
                    <th class="text-left px-5 py-3">Họ tên</th>
                    <th class="text-left px-5 py-3">Role</th>
                    <th class="text-left px-5 py-3">Trạng thái</th>
                    <th class="text-left px-5 py-3">Login lần cuối</th>
                    <th class="text-left px-5 py-3">Tạo lúc</th>
                    <th class="text-right px-5 py-3">Hành động</th>
                </tr>
                </thead>
                <tbody>
                <% if (admins == null || admins.isEmpty()) { %>
                <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Chưa có admin DB-backed nào.</td></tr>
                <% } else for (AdminAccountRow a : admins) { %>
                <tr class="border-t border-slate-100">
                    <td class="px-5 py-3 font-semibold text-indigo-950"><%= a.email() %></td>
                    <td class="px-5 py-3 text-slate-600"><%= a.fullName() == null ? "—" : a.fullName() %></td>
                    <td class="px-5 py-3">
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/admins/<%= a.id() %>/role"
                              class="flex items-center gap-2">
                            <select name="role" class="rounded-lg border border-slate-200 px-2 py-1 text-xs">
                                <% if (roles != null) for (String r : roles) { %>
                                    <option value="<%= r %>" <%= r.equals(a.role()) ? "selected" : "" %>><%= r %></option>
                                <% } %>
                            </select>
                            <button type="submit"
                                    class="px-2 py-1 rounded-lg bg-indigo-50 text-primary text-xs font-semibold hover:bg-indigo-100">
                                Lưu
                            </button>
                        </form>
                    </td>
                    <td class="px-5 py-3">
                        <% if (a.isActive()) { %>
                        <span class="inline-block px-2 py-1 rounded-md bg-emerald-50 text-emerald-700 text-xs font-bold">Active</span>
                        <% } else { %>
                        <span class="inline-block px-2 py-1 rounded-md bg-rose-50 text-rose-700 text-xs font-bold">Disabled</span>
                        <% } %>
                    </td>
                    <td class="px-5 py-3 text-slate-600"><%= a.lastLoginAt() == null ? "—" : fmt.format(a.lastLoginAt()) %></td>
                    <td class="px-5 py-3 text-slate-600"><%= a.createdAt() == null ? "—" : fmt.format(a.createdAt()) %></td>
                    <td class="px-5 py-3">
                        <div class="flex justify-end gap-2">
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/admins/<%= a.id() %>/reset-password"
                                  onsubmit="return confirm('Reset password admin này? Mật khẩu mới sẽ hiển thị 1 lần.');">
                                <button type="submit"
                                        class="px-3 py-1 rounded-lg bg-amber-50 text-amber-700 text-xs font-semibold hover:bg-amber-100">
                                    Reset password
                                </button>
                            </form>
                            <% if (a.isActive()) { %>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/admins/<%= a.id() %>/disable"
                                  onsubmit="return confirm('Vô hiệu hóa admin <%= a.email() %>?');">
                                <button type="submit"
                                        class="px-3 py-1 rounded-lg bg-rose-50 text-rose-700 text-xs font-semibold hover:bg-rose-100">
                                    Vô hiệu hóa
                                </button>
                            </form>
                            <% } else { %>
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/admins/<%= a.id() %>/enable">
                                <button type="submit"
                                        class="px-3 py-1 rounded-lg bg-emerald-50 text-emerald-700 text-xs font-semibold hover:bg-emerald-100">
                                    Kích hoạt
                                </button>
                            </form>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>
</body>
</html>
