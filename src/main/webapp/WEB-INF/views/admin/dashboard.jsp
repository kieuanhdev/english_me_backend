<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.DashboardStats" %>
<%@ page import="com.kiovant.englishme.dto.DashboardAnalytics" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    long totalDesks = stats != null ? stats.totalDesks() : 0;
    long totalFlashcards = stats != null ? stats.totalFlashcards() : 0;
    long totalAttempts = stats != null ? stats.totalPronunciationAttempts() : 0;

    DashboardAnalytics analytics = (DashboardAnalytics) request.getAttribute("analytics");
    DashboardAnalytics.KpiSummary kpi = analytics != null ? analytics.kpi() : new DashboardAnalytics.KpiSummary(
            0, 0, 0, 0, 0, 0.0, 0);

    ObjectMapper mapper = new ObjectMapper();
    String newUsersJson = analytics != null ? mapper.writeValueAsString(analytics.newUsersSeries()) : "{\"labels\":[],\"values\":[]}";
    String cefrJson = analytics != null ? mapper.writeValueAsString(analytics.cefrDistribution()) : "[]";
    String xpSourceJson = analytics != null ? mapper.writeValueAsString(analytics.xpBySource7d()) : "[]";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <%@ include file="layout/head.jspf" %>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body class="bg-surface text-on-surface">
<%@ include file="layout/sidebar.jspf" %>

<main class="ml-64 min-h-screen">
    <%@ include file="layout/topbar.jspf" %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Dashboard Analytics</h1>
            <p class="max-w-2xl text-indigo-100">KPI người dùng, biểu đồ đăng ký 14 ngày và phân bố XP/CEFR.</p>
        </section>

        <%-- KPI ROW --%>
        <section class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Tổng user</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", kpi.totalUsers()) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">User mới hôm nay</p>
                <h3 class="text-3xl text-emerald-600 font-black font-headline mt-2"><%= String.format("%,d", kpi.newUsersToday()) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">DAU</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", kpi.dau()) %></h3>
                <p class="text-[11px] text-slate-500 mt-1">WAU <%= String.format("%,d", kpi.wau()) %> · MAU <%= String.format("%,d", kpi.mau()) %></p>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Retention 7d</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= kpi.retention7d() %>%</h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">XP cấp hôm nay</p>
                <h3 class="text-3xl text-amber-600 font-black font-headline mt-2"><%= String.format("%,d", kpi.xpAwardedToday()) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Flashcards</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalFlashcards) %></h3>
                <p class="text-[11px] text-slate-500 mt-1">Desk <%= String.format("%,d", totalDesks) %> · Pron <%= String.format("%,d", totalAttempts) %></p>
            </article>
        </section>

        <%-- CHARTS --%>
        <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">User mới — 14 ngày</h4>
                <p class="text-xs text-slate-500 mb-4">Số người đăng ký mỗi ngày</p>
                <canvas id="chartNewUsers" height="120"></canvas>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">XP theo nguồn — 7 ngày</h4>
                <p class="text-xs text-slate-500 mb-4">Study / Exercise / Test</p>
                <canvas id="chartXpSource" height="120"></canvas>
            </div>
        </section>

        <section class="bg-surface-container-lowest rounded-3xl p-6">
            <h4 class="text-lg font-headline font-black text-primary mb-1">Phân bố CEFR</h4>
            <p class="text-xs text-slate-500 mb-4">Tổng user theo trình độ</p>
            <canvas id="chartCefr" height="80"></canvas>
        </section>
    </div>
    <%@ include file="layout/footer.jspf" %>
</main>

<script>
    const newUsers = <%= newUsersJson %>;
    const cefr = <%= cefrJson %>;
    const xpSource = <%= xpSourceJson %>;

    new Chart(document.getElementById("chartNewUsers"), {
        type: "line",
        data: {
            labels: newUsers.labels,
            datasets: [{
                label: "New users",
                data: newUsers.values,
                borderColor: "#24389c",
                backgroundColor: "#24389c33",
                fill: true,
                tension: 0.35,
                pointRadius: 3
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
    });

    new Chart(document.getElementById("chartCefr"), {
        type: "bar",
        data: {
            labels: cefr.map(c => c.label),
            datasets: [{
                label: "Users",
                data: cefr.map(c => c.value),
                backgroundColor: ["#24389c", "#3f51b5", "#5c6bc0", "#7e57c2", "#9575cd", "#b39ddb", "#cbd5e1"]
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
    });

    new Chart(document.getElementById("chartXpSource"), {
        type: "bar",
        data: {
            labels: xpSource.map(x => x.label),
            datasets: [{
                label: "XP",
                data: xpSource.map(x => x.value),
                backgroundColor: ["#24389c", "#10b981", "#f59e0b"]
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
    });
</script>
</body>
</html>
