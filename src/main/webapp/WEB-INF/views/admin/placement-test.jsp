<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.TestSession" %>
<%@ page import="org.springframework.data.domain.Page" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    @SuppressWarnings("unchecked")
    Page<TestSession> sessionsPage = (Page<TestSession>) request.getAttribute("sessionsPage");
    var sessions = sessionsPage == null ? java.util.List.of() : sessionsPage.getContent();
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    if (currentPage == null) currentPage = 0;
    if (pageSize == null) pageSize = 20;
    DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <%@ include file="layout/head.jspf" %>
</head>
<body class="bg-surface text-on-surface">
<%@ include file="layout/sidebar.jspf" %>
<main class="ml-64 min-h-screen">
    <%@ include file="layout/topbar.jspf" %>

    <div class="p-8 space-y-8">
        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quản lý Bài kiểm tra đầu vào</h1>
            <p class="text-slate-500 font-medium">Theo dõi phiên kiểm tra và kết quả xếp lớp của học viên.</p>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Học viên</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Email</th>
                        <th class="px-4 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Trạng thái</th>
                        <th class="px-4 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Kết quả CEFR</th>
                        <th class="px-4 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Điểm</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Bắt đầu</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (sessions.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-10 text-center text-slate-500 font-semibold">
                            Chưa có phiên kiểm tra nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (TestSession ts : sessions) {
                                String userName = ts.getUser().getFullName() != null && !ts.getUser().getFullName().isBlank()
                                        ? ts.getUser().getFullName() : "Chưa cập nhật";
                                String statusText = ts.getStatus() == TestSession.TestStatus.COMPLETED ? "Hoàn thành" : "Đang làm";
                                String statusClass = ts.getStatus() == TestSession.TestStatus.COMPLETED
                                        ? "bg-green-50 text-green-700"
                                        : "bg-amber-50 text-amber-700";
                                String level = ts.getResultLevel() != null ? ts.getResultLevel() : "—";
                                String score = ts.getScore() != null ? ts.getScore().toString() : "—";
                                String started = ts.getStartedAt() != null ? ts.getStartedAt().format(df) : "—";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5">
                            <span class="text-sm font-bold text-indigo-950"><%= userName %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-sm font-medium text-slate-600"><%= ts.getUser().getEmail() %></span>
                        </td>
                        <td class="px-4 py-5 text-center">
                            <span class="inline-flex items-center gap-1.5 px-3 py-1 text-[10px] font-bold uppercase tracking-wider rounded-full <%= statusClass %>">
                                <span class="w-1 h-1 rounded-full bg-current"></span><%= statusText %>
                            </span>
                        </td>
                        <td class="px-4 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-700 text-xs font-bold rounded-lg"><%= level %></span>
                        </td>
                        <td class="px-4 py-5 text-center">
                            <span class="text-sm font-semibold text-slate-700"><%= score %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-xs text-slate-500"><%= started %></span>
                        </td>
                        <td class="px-6 py-5 text-right">
                            <a href="${pageContext.request.contextPath}/admin/placement-test/<%= ts.getId() %>"
                               class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
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

        <%
            if (sessionsPage != null && sessionsPage.getTotalPages() > 1) {
                int prev = Math.max(currentPage - 1, 0);
                int next = Math.min(currentPage + 1, sessionsPage.getTotalPages() - 1);
        %>
        <div class="flex items-center justify-between">
            <span class="text-sm text-slate-500">Trang <%= currentPage + 1 %> / <%= sessionsPage.getTotalPages() %></span>
            <div class="flex gap-2">
                <a class="px-4 py-2 rounded-xl bg-white text-slate-600 text-sm font-bold <%= currentPage == 0 ? "pointer-events-none opacity-50" : "" %>"
                   href="${pageContext.request.contextPath}/admin/placement-test?size=<%= pageSize %>&page=<%= prev %>">Trước</a>
                <a class="px-4 py-2 rounded-xl bg-white text-slate-600 text-sm font-bold <%= currentPage == sessionsPage.getTotalPages() - 1 ? "pointer-events-none opacity-50" : "" %>"
                   href="${pageContext.request.contextPath}/admin/placement-test?size=<%= pageSize %>&page=<%= next %>">Sau</a>
            </div>
        </div>
        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
