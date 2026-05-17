<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminAnnouncementRow" %>
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
        @SuppressWarnings("unchecked")
        List<AdminAnnouncementRow> rows = (List<AdminAnnouncementRow>) request.getAttribute("rows");
        int total = rows == null ? 0 : rows.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter fmtIso = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        DateTimeFormatter fmtDisplay = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String[] severities = new String[]{"info", "warning", "success"};
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

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Announcements</h1>
            <p class="text-slate-500 font-medium">Banner hiển thị trong app (không gửi push) — <%= total %> mục.</p>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] p-6">
            <h2 class="text-lg font-bold text-indigo-950 mb-4">Tạo announcement</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin/announcements"
                  class="grid grid-cols-1 md:grid-cols-6 gap-3">
                <input type="text" name="title" placeholder="Tiêu đề" required maxlength="200"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-3"/>
                <select name="severity" class="rounded-xl border border-slate-200 px-3 py-2 text-sm">
                    <% for (String s : severities) { %>
                        <option value="<%= s %>"><%= s %></option>
                    <% } %>
                </select>
                <input type="datetime-local" name="startAt" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <input type="datetime-local" name="endAt"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <textarea name="body" placeholder="Nội dung" required rows="2"
                          class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-5"></textarea>
                <label class="flex items-center gap-2 text-sm font-semibold text-slate-600">
                    <input type="checkbox" name="isActive" value="true" checked class="rounded text-primary"/>
                    Active
                </label>
                <button type="submit"
                        class="primary-gradient text-white px-6 py-2 rounded-xl font-bold md:col-span-6">
                    Tạo announcement
                </button>
            </form>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Nội dung</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Severity</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Bắt đầu</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Kết thúc</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Active</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (rows == null || rows.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có announcement nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminAnnouncementRow a : rows) {
                                String updateUrl = request.getContextPath() + "/admin/announcements/" + a.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/announcements/" + a.id() + "/delete";
                                String startVal = a.startAt() == null ? "" : a.startAt().format(fmtIso);
                                String endVal = a.endAt() == null ? "" : a.endAt().format(fmtIso);
                                String sev = a.severity() == null ? "info" : a.severity();
                                String sevClass = switch (sev) {
                                    case "warning" -> "bg-amber-50 text-amber-700";
                                    case "success" -> "bg-emerald-50 text-emerald-700";
                                    default -> "bg-sky-50 text-sky-700";
                                };
                    %>
                    <tr class="hover:bg-white transition-all duration-300">
                        <form method="post" action="<%= updateUrl %>" class="contents">
                            <td class="px-4 py-3">
                                <input type="text" name="title" value="<%= a.title() == null ? "" : a.title() %>" required
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-44"/>
                            </td>
                            <td class="px-4 py-3">
                                <textarea name="body" rows="2"
                                          class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-72"><%= a.body() == null ? "" : a.body() %></textarea>
                            </td>
                            <td class="px-4 py-3">
                                <span class="px-2 py-1 rounded-lg text-xs font-bold <%= sevClass %> block mb-2"><%= sev %></span>
                                <select name="severity" class="rounded-lg border border-slate-200 px-2 py-1 text-xs w-full">
                                    <% for (String s : severities) { %>
                                        <option value="<%= s %>" <%= s.equals(sev) ? "selected" : "" %>><%= s %></option>
                                    <% } %>
                                </select>
                            </td>
                            <td class="px-4 py-3">
                                <input type="datetime-local" name="startAt" value="<%= startVal %>" required
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm"/>
                                <p class="text-[11px] text-slate-400 mt-1">
                                    <%= a.startAt() == null ? "" : a.startAt().format(fmtDisplay) %>
                                </p>
                            </td>
                            <td class="px-4 py-3">
                                <input type="datetime-local" name="endAt" value="<%= endVal %>"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm"/>
                            </td>
                            <td class="px-4 py-3 text-center">
                                <input type="checkbox" name="isActive" value="true"
                                       <%= Boolean.TRUE.equals(a.isActive()) ? "checked" : "" %>
                                       class="rounded text-primary"/>
                            </td>
                            <td class="px-4 py-3 text-right space-x-1">
                                <button type="submit"
                                        class="px-3 py-1.5 rounded-lg bg-indigo-50 text-primary text-xs font-bold hover:bg-indigo-100">
                                    Lưu
                                </button>
                        </form>
                                <form method="post" action="<%= deleteUrl %>"
                                      onsubmit="return confirm('Xóa announcement này?');" class="inline">
                                    <button type="submit"
                                            class="px-3 py-1.5 rounded-lg bg-rose-50 text-rose-700 text-xs font-bold hover:bg-rose-100">
                                        Xóa
                                    </button>
                                </form>
                            </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>
</body>
</html>
