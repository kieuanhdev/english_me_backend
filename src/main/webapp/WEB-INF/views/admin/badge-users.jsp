<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminBadgeUserRow" %>
<%@ page import="com.kiovant.englishme.entity.Badge" %>
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
        Badge badge = (Badge) request.getAttribute("badge");
        @SuppressWarnings("unchecked")
        List<AdminBadgeUserRow> users = (List<AdminBadgeUserRow>) request.getAttribute("users");
        int total = users == null ? 0 : users.size();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        String iconUrl = badge.getIconUrl();
    %>

    <div class="p-8 space-y-8">
        <div class="flex items-center gap-2 text-sm font-semibold text-slate-500">
            <a href="${pageContext.request.contextPath}/admin/badges" class="hover:text-indigo-600">← Badge Management</a>
        </div>

        <div class="flex items-center gap-4 flex-wrap">
            <% if (iconUrl != null && !iconUrl.isBlank()) { %>
                <img src="<%= iconUrl.startsWith("http") ? iconUrl : request.getContextPath() + iconUrl %>"
                     class="w-16 h-16 rounded-2xl object-cover" alt="icon"/>
            <% } else { %>
                <div class="w-16 h-16 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-400">
                    <span class="material-symbols-outlined text-3xl">emoji_events</span>
                </div>
            <% } %>
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline"><%= badge.getName() %></h1>
                <p class="text-slate-500 font-medium">
                    Điều kiện: <span class="font-bold text-indigo-700"><%= badge.getConditionType() %></span>
                    <% if (badge.getConditionValue() != null) { %>
                        (value = <%= badge.getConditionValue() %>)
                    <% } %>
                    — <%= total %> user đã đạt.
                </p>
                <% if (badge.getDescription() != null && !badge.getDescription().isBlank()) { %>
                    <p class="text-slate-500 text-sm"><%= badge.getDescription() %></p>
                <% } %>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Họ tên</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Email</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Total XP</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Streak</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Earned At</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (users == null || users.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có user nào đạt badge này.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminBadgeUserRow u : users) {
                                String userDetail = request.getContextPath() + "/admin/users/" + u.userId();
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= u.fullName() == null ? "—" : u.fullName() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600"><%= u.email() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-700"><%= u.totalXp() == null ? 0 : u.totalXp() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-700"><%= u.currentStreak() == null ? 0 : u.currentStreak() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600"><%= u.earnedAt() == null ? "—" : fmt.format(u.earnedAt()) %></td>
                        <td class="px-6 py-5 text-right">
                            <a href="<%= userDetail %>"
                               class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200">
                                <span class="material-symbols-outlined text-base">person</span>
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
<%@ include file="layout/footer.jspf" %>
</body>
</html>
