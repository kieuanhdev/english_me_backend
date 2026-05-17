<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.DashboardStats" %>
<%
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    long totalUsers = stats != null ? stats.totalUsers() : 0;
    long activeToday = stats != null ? stats.activeToday() : 0;
    long newUsersToday = stats != null ? stats.newUsersToday() : 0;
    long totalDesks = stats != null ? stats.totalDesks() : 0;
    long totalFlashcards = stats != null ? stats.totalFlashcards() : 0;
    long totalAttempts = stats != null ? stats.totalPronunciationAttempts() : 0;
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
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Chào buổi sáng, Admin</h1>
            <p class="max-w-2xl text-indigo-100">Tổng quan hệ thống EnglishMe — theo dõi người dùng, từ vựng, và hoạt động học tập.</p>
        </section>

        <section class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Tổng người dùng</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalUsers) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Luyện phát âm hôm nay</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", activeToday) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Người dùng mới hôm nay</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", newUsersToday) %></h3>
            </article>
        </section>
        <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Desk (CEFR)</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalDesks) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Flashcard</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalFlashcards) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Tổng lượt phát âm</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalAttempts) %></h3>
            </article>
        </section>

        <section class="grid grid-cols-1 xl:grid-cols-2 gap-8">
            <div class="bg-surface-container-low rounded-3xl p-8">
                <h4 class="text-xl text-primary font-headline font-black">Điều hướng nhanh</h4>
                <p class="text-sm text-slate-500 mb-6">Truy cập các khu vực quản lý</p>
                <div class="grid grid-cols-2 gap-4">
                    <a href="${pageContext.request.contextPath}/admin/users" class="flex items-center gap-3 p-4 rounded-2xl bg-white hover:bg-indigo-50 transition-colors">
                        <span class="material-symbols-outlined text-primary text-3xl">group</span>
                        <div>
                            <p class="text-sm font-bold text-indigo-950">Người dùng</p>
                            <p class="text-xs text-slate-500">Quản lý học viên</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/desks" class="flex items-center gap-3 p-4 rounded-2xl bg-white hover:bg-indigo-50 transition-colors">
                        <span class="material-symbols-outlined text-primary text-3xl">menu_book</span>
                        <div>
                            <p class="text-sm font-bold text-indigo-950">Desk / Từ vựng</p>
                            <p class="text-xs text-slate-500">Quản lý thẻ từ</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/grammar" class="flex items-center gap-3 p-4 rounded-2xl bg-white hover:bg-indigo-50 transition-colors">
                        <span class="material-symbols-outlined text-primary text-3xl">auto_stories</span>
                        <div>
                            <p class="text-sm font-bold text-indigo-950">Ngữ pháp</p>
                            <p class="text-xs text-slate-500">Bài học & chủ đề</p>
                        </div>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/pronunciation" class="flex items-center gap-3 p-4 rounded-2xl bg-white hover:bg-indigo-50 transition-colors">
                        <span class="material-symbols-outlined text-primary text-3xl">graphic_eq</span>
                        <div>
                            <p class="text-sm font-bold text-indigo-950">Phát âm</p>
                            <p class="text-xs text-slate-500">Lịch sử chấm điểm</p>
                        </div>
                    </a>
                </div>
            </div>
            <div class="bg-surface-container-low rounded-3xl p-8">
                <h4 class="text-xl text-primary font-headline font-black">Trạng thái hệ thống</h4>
                <p class="text-sm text-slate-500 mb-6">Thông tin nhanh</p>
                <div class="space-y-4">
                    <div class="flex justify-between items-center p-4 bg-white rounded-2xl">
                        <span class="text-sm font-semibold text-slate-700">Tổng người dùng</span>
                        <span class="text-sm font-black text-primary"><%= String.format("%,d", totalUsers) %></span>
                    </div>
                    <div class="flex justify-between items-center p-4 bg-white rounded-2xl">
                        <span class="text-sm font-semibold text-slate-700">Người mới hôm nay</span>
                        <span class="text-sm font-black text-emerald-600"><%= String.format("%,d", newUsersToday) %></span>
                    </div>
                    <div class="flex justify-between items-center p-4 bg-white rounded-2xl">
                        <span class="text-sm font-semibold text-slate-700">Tổng flashcard</span>
                        <span class="text-sm font-black text-primary"><%= String.format("%,d", totalFlashcards) %></span>
                    </div>
                    <div class="flex justify-between items-center p-4 bg-white rounded-2xl">
                        <span class="text-sm font-semibold text-slate-700">Lượt luyện phát âm</span>
                        <span class="text-sm font-black text-primary"><%= String.format("%,d", totalAttempts) %></span>
                    </div>
                </div>
            </div>
        </section>
    </div>
    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
