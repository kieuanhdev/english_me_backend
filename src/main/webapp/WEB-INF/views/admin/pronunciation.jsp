<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminPronunciationAttemptRow" %>
<%@ page import="org.springframework.data.domain.Page" %>
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
        Page<AdminPronunciationAttemptRow> attemptsPage = (Page<AdminPronunciationAttemptRow>) request.getAttribute("attemptsPage");
        List<AdminPronunciationAttemptRow> attempts = attemptsPage == null ? List.of() : attemptsPage.getContent();
        String selectedProvider = (String) request.getAttribute("selectedProvider");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        Integer selectedMinScore = (Integer) request.getAttribute("selectedMinScore");
        Integer pageSize = (Integer) request.getAttribute("pageSize");
        if (selectedProvider == null) selectedProvider = "";
        if (selectedKeyword == null) selectedKeyword = "";
        if (selectedMinScore == null) selectedMinScore = 0;
        if (pageSize == null) pageSize = 20;
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <div class="p-8 space-y-8">
        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quan ly luyen phat am</h1>
            <p class="text-slate-500 font-medium">Theo doi lich su cham diem phat am AI cua hoc vien.</p>
        </div>

        <section class="bg-surface-container-low p-6 rounded-[2rem] space-y-6">
            <form method="get" action="${pageContext.request.contextPath}/admin/pronunciation" class="flex flex-wrap items-end gap-4">
                <div class="flex-1 min-w-[200px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Provider</label>
                    <select name="provider" class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        <option value="" <%= selectedProvider.isEmpty() ? "selected" : "" %>>Tat ca</option>
                        <option value="speechace" <%= "speechace".equalsIgnoreCase(selectedProvider) ? "selected" : "" %>>Speechace</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[180px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Diem toi thieu</label>
                    <input type="number" name="minScore" min="0" max="100" value="<%= selectedMinScore %>"
                           class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"/>
                </div>
                <div class="flex-[2] min-w-[240px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tim user</label>
                    <input type="text" name="q" value="<%= selectedKeyword %>" placeholder="Ho ten, email, firebase UID..."
                           class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"/>
                </div>
                <input type="hidden" name="size" value="<%= pageSize %>"/>
                <div class="flex items-center gap-2">
                    <button type="submit" class="primary-gradient text-white px-5 py-3 rounded-xl text-sm font-bold">Loc</button>
                    <a href="${pageContext.request.contextPath}/admin/pronunciation" class="bg-white text-slate-600 px-5 py-3 rounded-xl text-sm font-bold">Reset</a>
                </div>
            </form>
        </section>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">User</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Reference text</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Overall</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Accuracy</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Fluency</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Provider</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Created at</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (attempts.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-10 text-center text-slate-500 font-semibold">
                            Chua co du lieu luyen phat am theo bo loc hien tai.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminPronunciationAttemptRow row : attempts) {
                                String displayName = (row.userFullName() == null || row.userFullName().isBlank())
                                        ? "Nguoi dung chua cap nhat"
                                        : row.userFullName();
                                String referenceText = row.referenceText() == null ? "" : row.referenceText();
                                if (referenceText.length() > 120) {
                                    referenceText = referenceText.substring(0, 120) + "...";
                                }
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5">
                            <div class="flex flex-col">
                                <span class="text-sm font-bold text-indigo-950"><%= displayName %></span>
                                <span class="text-xs text-slate-500"><%= row.userEmail() %></span>
                                <span class="text-[10px] text-slate-400">UID: <%= row.firebaseUid() %></span>
                            </div>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-sm font-medium text-slate-600"><%= referenceText %></span>
                        </td>
                        <td class="px-4 py-5 text-center"><span class="inline-flex px-3 py-1 rounded-lg bg-indigo-50 text-indigo-700 text-xs font-bold"><%= row.overallScore() %></span></td>
                        <td class="px-4 py-5 text-center"><span class="text-sm font-semibold text-slate-700"><%= row.accuracyScore() %></span></td>
                        <td class="px-4 py-5 text-center"><span class="text-sm font-semibold text-slate-700"><%= row.fluencyScore() %></span></td>
                        <td class="px-6 py-5"><span class="text-xs font-bold uppercase text-slate-500"><%= row.provider() %></span></td>
                        <td class="px-6 py-5"><span class="text-xs text-slate-500"><%= row.createdAt() == null ? "--" : row.createdAt().format(dateFormatter) %></span></td>
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
            int currentPage = attemptsPage == null ? 0 : attemptsPage.getNumber();
            int totalPages = attemptsPage == null ? 0 : attemptsPage.getTotalPages();
            if (totalPages > 1) {
                int prev = Math.max(currentPage - 1, 0);
                int next = Math.min(currentPage + 1, totalPages - 1);
        %>
        <div class="flex items-center justify-between">
            <span class="text-sm text-slate-500">Trang <%= currentPage + 1 %> / <%= totalPages %></span>
            <div class="flex gap-2">
                <a class="px-4 py-2 rounded-xl bg-white text-slate-600 text-sm font-bold <%= currentPage == 0 ? "pointer-events-none opacity-50" : "" %>"
                   href="${pageContext.request.contextPath}/admin/pronunciation?provider=<%= selectedProvider %>&minScore=<%= selectedMinScore %>&q=<%= selectedKeyword %>&size=<%= pageSize %>&page=<%= prev %>">Truoc</a>
                <a class="px-4 py-2 rounded-xl bg-white text-slate-600 text-sm font-bold <%= currentPage == totalPages - 1 ? "pointer-events-none opacity-50" : "" %>"
                   href="${pageContext.request.contextPath}/admin/pronunciation?provider=<%= selectedProvider %>&minScore=<%= selectedMinScore %>&q=<%= selectedKeyword %>&size=<%= pageSize %>&page=<%= next %>">Sau</a>
            </div>
        </div>
        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
