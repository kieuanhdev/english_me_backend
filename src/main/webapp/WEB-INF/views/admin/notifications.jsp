<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminNotificationRow" %>
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
        List<AdminNotificationRow> rows = (List<AdminNotificationRow>) request.getAttribute("rows");
        int total = rows == null ? 0 : rows.size();
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

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Push Notifications</h1>
            <p class="text-slate-500 font-medium">Lịch sử push — <%= total %> chiến dịch.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Broadcast -->
            <div class="bg-surface-container-lowest rounded-[2rem] p-6">
                <h2 class="text-lg font-bold text-indigo-950 mb-4 flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">campaign</span>
                    Gửi broadcast
                </h2>
                <form method="post" action="${pageContext.request.contextPath}/admin/notifications/broadcast"
                      class="space-y-3">
                    <input type="text" name="title" placeholder="Tiêu đề" required maxlength="200"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <textarea name="body" placeholder="Nội dung" required rows="3"
                              class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"></textarea>
                    <input type="text" name="imageUrl" placeholder="URL ảnh (tùy chọn)"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <input type="text" name="actionUrl" placeholder="URL hành động (tùy chọn)"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <button type="submit"
                            onclick="return confirm('Gửi tới TẤT CẢ device đang đăng ký?');"
                            class="w-full primary-gradient text-white py-2.5 rounded-xl font-bold">
                        Gửi broadcast
                    </button>
                </form>
            </div>

            <!-- Targeted -->
            <div class="bg-surface-container-lowest rounded-[2rem] p-6">
                <h2 class="text-lg font-bold text-indigo-950 mb-4 flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">filter_alt</span>
                    Gửi theo segment
                </h2>
                <form method="post" action="${pageContext.request.contextPath}/admin/notifications/targeted"
                      class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <select name="segmentType" required
                                class="rounded-xl border border-slate-200 px-3 py-2 text-sm">
                            <option value="cefr">CEFR level</option>
                            <option value="inactive">Inactive (ngày)</option>
                        </select>
                        <input type="text" name="segmentValue" placeholder="Giá trị (vd: A1 hoặc 14)" required
                               class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    </div>
                    <input type="text" name="title" placeholder="Tiêu đề" required maxlength="200"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <textarea name="body" placeholder="Nội dung" required rows="3"
                              class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"></textarea>
                    <input type="text" name="imageUrl" placeholder="URL ảnh (tùy chọn)"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <input type="text" name="actionUrl" placeholder="URL hành động (tùy chọn)"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                    <p class="text-xs text-slate-500">
                        Segment <code>cefr</code> nhận giá trị A1..C2. Segment <code>inactive</code>
                        nhận số ngày (vd: <code>14</code> = user không active &gt;14 ngày).
                    </p>
                    <button type="submit"
                            class="w-full bg-indigo-100 text-primary py-2.5 rounded-xl font-bold hover:bg-indigo-200">
                        Gửi targeted
                    </button>
                </form>
            </div>
        </div>

        <!-- Bảng lịch sử -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Thời gian</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Segment</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Target</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">OK</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Fail</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Người gửi</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (rows == null || rows.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có push nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminNotificationRow r : rows) {
                                String statsUrl = request.getContextPath() + "/admin/notifications/" + r.id() + "/stats";
                                String segLabel = r.segmentValue() == null
                                        ? r.segmentType()
                                        : r.segmentType() + " = " + r.segmentValue();
                    %>
                    <tr class="hover:bg-white transition-all duration-300">
                        <td class="px-4 py-4 text-sm text-slate-500"><%= r.sentAt() == null ? "—" : r.sentAt().format(fmt) %></td>
                        <td class="px-4 py-4 text-sm font-bold text-indigo-950 max-w-xs truncate"><%= r.title() %></td>
                        <td class="px-4 py-4 text-sm">
                            <span class="px-2 py-1 rounded-lg bg-indigo-50 text-primary text-xs font-bold"><%= segLabel %></span>
                        </td>
                        <td class="px-4 py-4 text-sm text-center font-bold"><%= r.targetCount() %></td>
                        <td class="px-4 py-4 text-sm text-center text-emerald-700 font-bold"><%= r.successCount() %></td>
                        <td class="px-4 py-4 text-sm text-center text-rose-700 font-bold"><%= r.failureCount() %></td>
                        <td class="px-4 py-4 text-sm text-slate-500"><%= r.sentByEmail() == null ? "—" : r.sentByEmail() %></td>
                        <td class="px-4 py-4 text-right">
                            <a href="<%= statsUrl %>"
                               class="px-3 py-1.5 rounded-lg bg-indigo-50 text-primary text-xs font-bold hover:bg-indigo-100">
                                Chi tiết
                            </a>
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
