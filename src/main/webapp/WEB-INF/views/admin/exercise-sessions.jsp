<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminExerciseSessionRow" %>
<%@ page import="org.springframework.data.domain.Page" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.UUID" %>
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
        Page<AdminExerciseSessionRow> sessions = (Page<AdminExerciseSessionRow>) request.getAttribute("sessions");
        String selectedCategory = (String) request.getAttribute("selectedCategory");
        String selectedStatus = (String) request.getAttribute("selectedStatus");
        UUID selectedUserId = (UUID) request.getAttribute("selectedUserId");
        if (selectedCategory == null) selectedCategory = "";
        if (selectedStatus == null) selectedStatus = "";
        String userIdStr = selectedUserId == null ? "" : selectedUserId.toString();
        long totalElements = sessions == null ? 0 : sessions.getTotalElements();
        int totalPages = sessions == null ? 0 : sessions.getTotalPages();
        int currentPage = sessions == null ? 0 : sessions.getNumber();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String errorMessage = (String) request.getAttribute("errorMessage");
    %>

    <div class="p-8 space-y-8">
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Exercise Sessions</h1>
                <p class="text-slate-500 font-medium">Lịch sử phiên làm bài của học viên — <%= totalElements %> session.</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/exercises"
               class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                <span class="material-symbols-outlined text-lg">arrow_back</span>
                Quay lại Exercise Bank
            </a>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/exercises/sessions"
              class="bg-surface-container-lowest rounded-2xl p-4 flex flex-wrap items-end gap-3">
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Category</label>
                <select name="category" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedCategory.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <option value="vocabulary" <%= "vocabulary".equals(selectedCategory) ? "selected" : "" %>>Vocabulary</option>
                    <option value="grammar" <%= "grammar".equals(selectedCategory) ? "selected" : "" %>>Grammar</option>
                </select>
            </div>
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Status</label>
                <select name="status" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedStatus.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <option value="active"    <%= "active".equals(selectedStatus)    ? "selected" : "" %>>Đang làm</option>
                    <option value="completed" <%= "completed".equals(selectedStatus) ? "selected" : "" %>>Hoàn thành</option>
                </select>
            </div>
            <div class="space-y-1 flex-1 min-w-[260px]">
                <label class="text-xs font-bold text-slate-500 uppercase">User ID (UUID, để trống = tất cả)</label>
                <input type="text" name="userId" value="<%= userIdStr %>"
                       placeholder="VD: 8c2a0b0a-..."
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
            </div>
            <button type="submit"
                    class="primary-gradient text-white px-6 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2">
                <span class="material-symbols-outlined text-base">filter_alt</span>
                Lọc
            </button>
        </form>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">User</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Category</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Status</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Câu</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đã trả lời</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đúng</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Bắt đầu</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Hoàn thành</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Chi tiết</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (sessions == null || sessions.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="9" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có session nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminExerciseSessionRow s : sessions) {
                                String detailUrl = request.getContextPath() + "/admin/exercises/sessions/" + s.id();
                                String statusClass = "completed".equals(s.status())
                                        ? "bg-emerald-50 text-emerald-700"
                                        : "bg-amber-50 text-amber-700";
                                String fullName = s.userFullName() == null || s.userFullName().isBlank()
                                        ? (s.userEmail() == null ? "(unknown)" : s.userEmail())
                                        : s.userFullName();
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-sm">
                            <div class="font-bold text-indigo-950"><%= fullName %></div>
                            <% if (s.userEmail() != null && !s.userEmail().equals(fullName)) { %>
                            <div class="text-xs text-slate-500"><%= s.userEmail() %></div>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-sm font-semibold text-slate-700"><%= s.category() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= statusClass %>"><%= s.status() %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-700"><%= s.questionCount() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-700"><%= s.answeredCount() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-emerald-700"><%= s.correctCount() %></td>
                        <td class="px-6 py-5 text-xs text-slate-600"><%= s.createdAt() == null ? "—" : s.createdAt().format(fmt) %></td>
                        <td class="px-6 py-5 text-xs text-slate-600"><%= s.completedAt() == null ? "—" : s.completedAt().format(fmt) %></td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <a href="<%= detailUrl %>"
                               class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90">
                                <span class="material-symbols-outlined text-base">visibility</span>
                                Xem
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

            <% if (totalPages > 1) { %>
            <div class="flex justify-between items-center px-6 py-4 border-t border-slate-100">
                <div class="text-xs font-semibold text-slate-500">
                    Trang <%= currentPage + 1 %> / <%= totalPages %>
                </div>
                <div class="flex gap-2">
                    <%
                        String baseUrl = request.getContextPath() + "/admin/exercises/sessions?category=" + selectedCategory
                                + "&status=" + selectedStatus
                                + (selectedUserId == null ? "" : "&userId=" + selectedUserId);
                        if (currentPage > 0) {
                    %>
                    <a href="<%= baseUrl %>&page=<%= currentPage - 1 %>"
                       class="px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200">‹ Trước</a>
                    <% } %>
                    <% if (currentPage + 1 < totalPages) { %>
                    <a href="<%= baseUrl %>&page=<%= currentPage + 1 %>"
                       class="px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200">Sau ›</a>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
