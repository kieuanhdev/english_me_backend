<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminStudySessionRow" %>
<%@ page import="org.springframework.data.domain.Page" %>
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
        Page<AdminStudySessionRow> sessionsPage = (Page<AdminStudySessionRow>) request.getAttribute("sessionsPage");
        String selectedStatus = (String) request.getAttribute("selectedStatus");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        String selectedDeskId = (String) request.getAttribute("selectedDeskId");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer pageSize = (Integer) request.getAttribute("pageSize");
        if (selectedStatus == null) selectedStatus = "";
        if (selectedKeyword == null) selectedKeyword = "";
        if (selectedDeskId == null) selectedDeskId = "";
        if (currentPage == null) currentPage = 0;
        if (pageSize == null) pageSize = 20;
        long totalElements = sessionsPage == null ? 0 : sessionsPage.getTotalElements();
        int totalPages = sessionsPage == null ? 0 : sessionsPage.getTotalPages();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM HH:mm");
    %>

    <div class="p-8 space-y-8">
        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Study Sessions</h1>
            <p class="text-slate-500 font-medium">Theo dõi hoạt động học flashcard SM-2 — <%= totalElements %> session.</p>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/study-sessions"
              class="bg-surface-container-lowest rounded-2xl p-4 flex flex-wrap items-end gap-3">
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Status</label>
                <select name="status" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedStatus.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <option value="active" <%= "active".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Active</option>
                    <option value="completed" <%= "completed".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Completed</option>
                </select>
            </div>
            <div class="space-y-1 flex-1 min-w-[200px]">
                <label class="text-xs font-bold text-slate-500 uppercase">User (name/email/UID)</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
            </div>
            <div class="space-y-1 flex-1 min-w-[260px]">
                <label class="text-xs font-bold text-slate-500 uppercase">Desk ID (UUID)</label>
                <input type="text" name="deskId" value="<%= selectedDeskId %>" placeholder="vd: 7d3c…"
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-mono text-slate-700">
            </div>
            <input type="hidden" name="size" value="<%= pageSize %>">
            <button type="submit"
                    class="primary-gradient text-white px-6 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2">
                <span class="material-symbols-outlined text-base">filter_alt</span>
                Lọc
            </button>
            <a href="${pageContext.request.contextPath}/admin/study-sessions"
               class="bg-slate-100 text-slate-700 px-5 py-2.5 rounded-xl font-bold text-sm">Reset</a>
        </form>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">User</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Desk</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Status</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Cards</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Mastered / Hard / Again</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">XP</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">New</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Started</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Completed</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (sessionsPage == null || !sessionsPage.hasContent()) {
                    %>
                    <tr>
                        <td colspan="10" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Không có session nào khớp bộ lọc.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminStudySessionRow s : sessionsPage.getContent()) {
                                String detailUrl = request.getContextPath() + "/admin/study-sessions/" + s.id();
                                String statusClass = "completed".equalsIgnoreCase(s.status())
                                        ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700";
                                int mastered = s.masteredCards() == null ? 0 : s.masteredCards();
                                int hard = s.hardCards() == null ? 0 : s.hardCards();
                                int again = s.againCards() == null ? 0 : s.againCards();
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5">
                            <div class="text-sm font-bold text-indigo-950"><%= s.userFullName() == null ? "—" : s.userFullName() %></div>
                            <div class="text-xs text-slate-500"><%= s.userEmail() == null ? "—" : s.userEmail() %></div>
                        </td>
                        <td class="px-6 py-5">
                            <div class="text-sm font-bold text-indigo-950"><%= s.deskTitle() == null ? "—" : s.deskTitle() %></div>
                            <div class="text-xs text-slate-500"><%= s.deskCefrLevel() == null ? "" : s.deskCefrLevel() %></div>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex px-3 py-1 text-xs font-black rounded-xl <%= statusClass %>"><%= s.status() %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= s.totalCards() == null ? 0 : s.totalCards() %></td>
                        <td class="px-6 py-5 text-center text-xs font-bold whitespace-nowrap">
                            <span class="text-emerald-700"><%= mastered %></span> /
                            <span class="text-amber-700"><%= hard %></span> /
                            <span class="text-rose-700"><%= again %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-indigo-700"><%= s.xpEarned() == null ? 0 : s.xpEarned() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= s.newWordsLearned() == null ? 0 : s.newWordsLearned() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600"><%= s.startedAt() == null ? "—" : fmt.format(s.startedAt()) %></td>
                        <td class="px-6 py-5 text-sm text-slate-600"><%= s.completedAt() == null ? "—" : fmt.format(s.completedAt()) %></td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <a href="<%= detailUrl %>" class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200">
                                <span class="material-symbols-outlined text-base">visibility</span>
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

        <% if (totalPages > 1) {
            String base = request.getContextPath() + "/admin/study-sessions?status=" + selectedStatus
                    + "&q=" + selectedKeyword + "&deskId=" + selectedDeskId + "&size=" + pageSize + "&page=";
        %>
        <div class="flex items-center justify-between text-sm font-semibold text-slate-600">
            <div>Trang <%= currentPage + 1 %> / <%= totalPages %></div>
            <div class="flex items-center gap-2">
                <% if (currentPage > 0) { %>
                    <a href="<%= base + (currentPage - 1) %>" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200">← Trước</a>
                <% } %>
                <% if (currentPage + 1 < totalPages) { %>
                    <a href="<%= base + (currentPage + 1) %>" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200">Sau →</a>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>
<%@ include file="layout/footer.jspf" %>
</body>
</html>
