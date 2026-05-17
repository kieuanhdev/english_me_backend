<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.GrammarLessonListItemResponse" %>
<%@ page import="java.util.List" %>
<%
    @SuppressWarnings("unchecked")
    List<GrammarLessonListItemResponse> lessons = (List<GrammarLessonListItemResponse>) request.getAttribute("lessons");
    String topicId = (String) request.getAttribute("topicId");
    int n = lessons == null ? 0 : lessons.size();
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
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
        <% if (successMessage != null) { %>
        <div class="rounded-2xl bg-emerald-50 text-emerald-800 px-5 py-3 text-sm font-semibold border border-emerald-100"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100"><%= errorMessage %></div>
        <% } %>

        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/admin/grammar" class="text-xs font-bold text-primary hover:underline inline-flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách chủ đề
            </a>
        </div>

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Danh sách bài học</h1>
            <p class="text-slate-500 font-medium"><%= n %> bài học trong chủ đề này.</p>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Source ID</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Thứ tự</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (lessons == null || lessons.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="4" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có bài học nào trong chủ đề này.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (GrammarLessonListItemResponse lesson : lessons) {
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <span class="text-sm font-bold text-indigo-950"><%= lesson.title() %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-xs font-mono text-slate-500"><%= lesson.sourceId() != null ? lesson.sourceId() : "—" %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="text-sm font-semibold text-slate-600"><%= lesson.sortOrder() %></span>
                        </td>
                        <td class="px-6 py-5 text-right">
                            <a href="${pageContext.request.contextPath}/admin/grammar/lessons/<%= lesson.id() %>"
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
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
