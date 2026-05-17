<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.GrammarTopicResponse" %>
<%@ page import="java.util.List" %>
<%
    @SuppressWarnings("unchecked")
    List<GrammarTopicResponse> topics = (List<GrammarTopicResponse>) request.getAttribute("topics");
    int n = topics == null ? 0 : topics.size();
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
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quản lý Ngữ pháp</h1>
            <p class="text-slate-500 font-medium"><%= n %> chủ đề ngữ pháp trong hệ thống.</p>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Chủ đề</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Danh mục</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Trình độ</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Số bài học</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (topics == null || topics.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="5" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có chủ đề ngữ pháp nào. Hãy import dữ liệu ngữ pháp trước.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (GrammarTopicResponse t : topics) {
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <span class="text-sm font-bold text-indigo-950"><%= t.title() %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-700 text-xs font-bold rounded-lg"><%= t.category() %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-sm font-semibold text-slate-600"><%= t.level() %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-bold"><%= t.lessonCount() %></span>
                        </td>
                        <td class="px-6 py-5 text-right">
                            <a href="${pageContext.request.contextPath}/admin/grammar/topics/<%= t.id() %>"
                               class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-base">visibility</span>
                                Xem bài học
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
