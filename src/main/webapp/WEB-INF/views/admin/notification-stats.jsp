<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.AdminNotification" %>
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
        AdminNotification n = (AdminNotification) request.getAttribute("notification");
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        double rate = (n.getTargetCount() == null || n.getTargetCount() == 0)
                ? 0.0
                : (n.getSuccessCount() * 100.0 / n.getTargetCount());
    %>

    <div class="p-8 space-y-8">
        <a href="${pageContext.request.contextPath}/admin/notifications"
           class="inline-flex items-center gap-2 text-sm font-bold text-primary hover:underline">
            <span class="material-symbols-outlined text-base">arrow_back</span>
            Quay lại
        </a>

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline"><%= n.getTitle() %></h1>
            <p class="text-slate-500 font-medium">
                Gửi <%= n.getSentAt() == null ? "—" : n.getSentAt().format(fmt) %>
                <% if (n.getSentByEmail() != null) { %> · bởi <%= n.getSentByEmail() %> <% } %>
            </p>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-xs font-bold uppercase tracking-widest text-slate-400">Target</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-1"><%= n.getTargetCount() %></p>
            </div>
            <div class="bg-emerald-50 rounded-2xl p-5">
                <p class="text-xs font-bold uppercase tracking-widest text-emerald-600">Thành công</p>
                <p class="text-3xl font-extrabold text-emerald-800 mt-1"><%= n.getSuccessCount() %></p>
            </div>
            <div class="bg-rose-50 rounded-2xl p-5">
                <p class="text-xs font-bold uppercase tracking-widest text-rose-600">Thất bại</p>
                <p class="text-3xl font-extrabold text-rose-800 mt-1"><%= n.getFailureCount() %></p>
            </div>
            <div class="bg-indigo-50 rounded-2xl p-5">
                <p class="text-xs font-bold uppercase tracking-widest text-primary">Tỉ lệ deliver</p>
                <p class="text-3xl font-extrabold text-primary mt-1"><%= String.format("%.1f%%", rate) %></p>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-4">
            <div>
                <p class="text-xs font-bold uppercase tracking-widest text-slate-400">Segment</p>
                <p class="text-base font-semibold text-indigo-950">
                    <%= n.getSegmentType() %><% if (n.getSegmentValue() != null) { %> = <%= n.getSegmentValue() %><% } %>
                </p>
            </div>
            <div>
                <p class="text-xs font-bold uppercase tracking-widest text-slate-400">Nội dung</p>
                <p class="text-sm text-slate-700 whitespace-pre-line"><%= n.getBody() %></p>
            </div>
            <% if (n.getImageUrl() != null) { %>
            <div>
                <p class="text-xs font-bold uppercase tracking-widest text-slate-400">Ảnh</p>
                <img src="<%= n.getImageUrl() %>" alt="image" class="mt-2 max-w-xs rounded-xl"/>
            </div>
            <% } %>
            <% if (n.getActionUrl() != null) { %>
            <div>
                <p class="text-xs font-bold uppercase tracking-widest text-slate-400">Action URL</p>
                <p class="text-sm text-primary font-semibold break-all"><%= n.getActionUrl() %></p>
            </div>
            <% } %>
        </div>

        <p class="text-xs text-slate-400">
            * Stats hiện chỉ phản ánh số token FCM trả về OK/FAIL tại thời điểm gửi. Open-rate / click-rate cần
            client gửi event về backend (chưa wire ở phiên bản này).
        </p>
    </div>
</main>
</body>
</html>
