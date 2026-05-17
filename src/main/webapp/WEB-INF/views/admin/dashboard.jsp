<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.DashboardStats" %>
<%@ page import="com.kiovant.englishme.dto.DashboardAnalytics" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    long totalUsers = stats != null ? stats.totalUsers() : 0;
    long totalDesks = stats != null ? stats.totalDesks() : 0;
    long totalFlashcards = stats != null ? stats.totalFlashcards() : 0;
    long totalAttempts = stats != null ? stats.totalPronunciationAttempts() : 0;

    DashboardAnalytics analytics = (DashboardAnalytics) request.getAttribute("analytics");
    DashboardAnalytics.KpiSummary kpi = analytics != null ? analytics.kpi() : new DashboardAnalytics.KpiSummary(
            totalUsers, 0, 0, 0, 0, 0, 0.0, 0.0, 0, 0, 0.0);

    ObjectMapper mapper = new ObjectMapper();
    String newUsersJson = analytics != null ? mapper.writeValueAsString(analytics.newUsersSeries()) : "{\"labels\":[],\"values\":[]}";
    String activeUsersJson = analytics != null ? mapper.writeValueAsString(analytics.activeUsersSeries()) : "{\"labels\":[],\"values\":[]}";
    String cefrJson = analytics != null ? mapper.writeValueAsString(analytics.cefrDistribution()) : "[]";
    String contentJson = analytics != null ? mapper.writeValueAsString(analytics.contentDistribution()) : "[]";
    String xpSourceJson = analytics != null ? mapper.writeValueAsString(analytics.xpBySource7d()) : "[]";
    String heatmapJson = analytics != null ? mapper.writeValueAsString(analytics.activityHeatmap()) : "[]";

    List<DashboardAnalytics.TopUserRow> topStreak = analytics != null ? analytics.topStreak() : List.of();
    List<DashboardAnalytics.TopUserRow> topXp = analytics != null ? analytics.topXp() : List.of();
    List<DashboardAnalytics.TopPronunciationMissRow> topPron = analytics != null ? analytics.topPronunciationMisses() : List.of();
    List<DashboardAnalytics.InactiveUserRow> inactiveUsers = analytics != null ? analytics.inactiveUsers() : List.of();
    DashboardAnalytics.SystemHealth health = analytics != null ? analytics.health() : new DashboardAnalytics.SystemHealth("?", "?", "?", 0, 0, 0);
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
            <p class="max-w-2xl text-indigo-100">Theo dõi sức khỏe hệ thống EnglishMe — KPI, biểu đồ xu hướng, top-N người dùng &amp; nội dung.</p>
        </section>

        <%-- KPI ROW 1 --%>
        <section class="grid grid-cols-2 md:grid-cols-4 gap-6">
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
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Retention</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= kpi.retention7d() %>%</h3>
                <p class="text-[11px] text-slate-500 mt-1">7d / 30d <%= kpi.retention30d() %>%</p>
            </article>
        </section>

        <%-- KPI ROW 2 --%>
        <section class="grid grid-cols-2 md:grid-cols-4 gap-6">
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Sessions hôm nay</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", kpi.studySessionsToday()) %></h3>
                <p class="text-[11px] text-slate-500 mt-1">study + exercise + test</p>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">XP cấp hôm nay</p>
                <h3 class="text-3xl text-amber-600 font-black font-headline mt-2"><%= String.format("%,d", kpi.xpAwardedToday()) %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Streak trung bình</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= kpi.averageStreak() %></h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Tổng flashcard</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2"><%= String.format("%,d", totalFlashcards) %></h3>
                <p class="text-[11px] text-slate-500 mt-1">Desk <%= String.format("%,d", totalDesks) %> · Phát âm <%= String.format("%,d", totalAttempts) %></p>
            </article>
        </section>

        <%-- CHARTS ROW 1: time series --%>
        <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">User mới — 14 ngày</h4>
                <p class="text-xs text-slate-500 mb-4">Số người đăng ký mỗi ngày</p>
                <canvas id="chartNewUsers" height="120"></canvas>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">Active users — 14 ngày</h4>
                <p class="text-xs text-slate-500 mb-4">Lượt user có activity (XP) mỗi ngày</p>
                <canvas id="chartActive" height="120"></canvas>
            </div>
        </section>

        <%-- CHARTS ROW 2: distributions --%>
        <section class="grid grid-cols-1 xl:grid-cols-3 gap-6">
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">Phân bố CEFR</h4>
                <p class="text-xs text-slate-500 mb-4">Tổng user theo trình độ</p>
                <canvas id="chartCefr" height="200"></canvas>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">Nội dung học (30 ngày)</h4>
                <p class="text-xs text-slate-500 mb-4">Tỉ lệ session theo module</p>
                <canvas id="chartContent" height="200"></canvas>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-1">XP theo nguồn (7 ngày)</h4>
                <p class="text-xs text-slate-500 mb-4">Study / Exercise / Test</p>
                <canvas id="chartXpSource" height="200"></canvas>
            </div>
        </section>

        <%-- HEATMAP --%>
        <section class="bg-surface-container-lowest rounded-3xl p-6">
            <h4 class="text-lg font-headline font-black text-primary mb-1">Hoạt động theo giờ × ngày trong tuần (30 ngày)</h4>
            <p class="text-xs text-slate-500 mb-4">Mật độ session học flashcard</p>
            <div id="heatmap" class="overflow-x-auto"></div>
        </section>

        <%-- TOP-N ROW --%>
        <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-4">Top 10 — Streak</h4>
                <table class="w-full text-sm">
                    <thead class="text-left text-xs text-slate-500 uppercase">
                        <tr><th class="py-2">#</th><th>User</th><th>CEFR</th><th class="text-right">Streak</th></tr>
                    </thead>
                    <tbody>
                        <% int i = 1; for (DashboardAnalytics.TopUserRow r : topStreak) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 text-slate-400"><%= i++ %></td>
                                <td class="py-2 font-semibold text-indigo-950"><%= r.fullName().isEmpty() ? r.email() : r.fullName() %></td>
                                <td class="py-2 text-slate-500"><%= r.cefrLevel().isEmpty() ? "—" : r.cefrLevel() %></td>
                                <td class="py-2 text-right font-bold text-amber-600"><%= r.value() %> 🔥</td>
                            </tr>
                        <% } if (topStreak.isEmpty()) { %>
                            <tr><td colspan="4" class="py-6 text-center text-slate-400">Chưa có dữ liệu</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-4">Top 10 — XP</h4>
                <table class="w-full text-sm">
                    <thead class="text-left text-xs text-slate-500 uppercase">
                        <tr><th class="py-2">#</th><th>User</th><th>CEFR</th><th class="text-right">XP</th></tr>
                    </thead>
                    <tbody>
                        <% int j = 1; for (DashboardAnalytics.TopUserRow r : topXp) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 text-slate-400"><%= j++ %></td>
                                <td class="py-2 font-semibold text-indigo-950"><%= r.fullName().isEmpty() ? r.email() : r.fullName() %></td>
                                <td class="py-2 text-slate-500"><%= r.cefrLevel().isEmpty() ? "—" : r.cefrLevel() %></td>
                                <td class="py-2 text-right font-bold text-primary"><%= String.format("%,d", r.value()) %></td>
                            </tr>
                        <% } if (topXp.isEmpty()) { %>
                            <tr><td colspan="4" class="py-6 text-center text-slate-400">Chưa có dữ liệu</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-4">Top 10 — Từ phát âm sai nhiều</h4>
                <table class="w-full text-sm">
                    <thead class="text-left text-xs text-slate-500 uppercase">
                        <tr><th class="py-2">#</th><th>Reference</th><th class="text-right">Score TB</th><th class="text-right">Attempts</th></tr>
                    </thead>
                    <tbody>
                        <% int k = 1; for (DashboardAnalytics.TopPronunciationMissRow r : topPron) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 text-slate-400"><%= k++ %></td>
                                <td class="py-2 font-semibold text-indigo-950 truncate max-w-xs"><%= r.referenceText() %></td>
                                <td class="py-2 text-right font-bold text-rose-600"><%= r.averageScore() %></td>
                                <td class="py-2 text-right text-slate-500"><%= r.attempts() %></td>
                            </tr>
                        <% } if (topPron.isEmpty()) { %>
                            <tr><td colspan="4" class="py-6 text-center text-slate-400">Chưa có dữ liệu</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <div class="bg-surface-container-lowest rounded-3xl p-6">
                <h4 class="text-lg font-headline font-black text-primary mb-4">Top 10 — User sắp churn (inactive ≥ 7 ngày)</h4>
                <table class="w-full text-sm">
                    <thead class="text-left text-xs text-slate-500 uppercase">
                        <tr><th class="py-2">#</th><th>User</th><th>Streak</th><th class="text-right">Last active</th></tr>
                    </thead>
                    <tbody>
                        <% int m = 1; for (DashboardAnalytics.InactiveUserRow r : inactiveUsers) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 text-slate-400"><%= m++ %></td>
                                <td class="py-2 font-semibold text-indigo-950"><%= r.fullName().isEmpty() ? r.email() : r.fullName() %></td>
                                <td class="py-2 text-slate-500"><%= r.currentStreak() %></td>
                                <td class="py-2 text-right text-slate-500"><%= r.lastActive() %></td>
                            </tr>
                        <% } if (inactiveUsers.isEmpty()) { %>
                            <tr><td colspan="4" class="py-6 text-center text-slate-400">Tất cả user còn hoạt động</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <%-- SYSTEM HEALTH --%>
        <section class="bg-surface-container-lowest rounded-3xl p-6">
            <h4 class="text-lg font-headline font-black text-primary mb-4">System Health</h4>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
                <div class="p-4 rounded-2xl bg-emerald-50">
                    <p class="text-xs text-slate-500">Firebase</p>
                    <p class="text-sm font-bold text-emerald-700"><%= health.firebaseStatus() %></p>
                </div>
                <div class="p-4 rounded-2xl bg-emerald-50">
                    <p class="text-xs text-slate-500">Pronunciation API</p>
                    <p class="text-sm font-bold text-emerald-700"><%= health.pronunciationStatus() %></p>
                </div>
                <div class="p-4 rounded-2xl bg-emerald-50">
                    <p class="text-xs text-slate-500">Chat API</p>
                    <p class="text-sm font-bold text-emerald-700"><%= health.chatStatus() %></p>
                </div>
                <div class="p-4 rounded-2xl bg-indigo-50">
                    <p class="text-xs text-slate-500">DB size</p>
                    <p class="text-sm font-bold text-primary"><%= health.databaseSizeMb() %> MB</p>
                </div>
                <div class="p-4 rounded-2xl bg-indigo-50">
                    <p class="text-xs text-slate-500">DB connections</p>
                    <p class="text-sm font-bold text-primary"><%= health.dbConnections() %></p>
                </div>
                <div class="p-4 rounded-2xl bg-indigo-50">
                    <p class="text-xs text-slate-500">Audio disk</p>
                    <p class="text-sm font-bold text-primary"><%= health.audioDiskUsageMb() %> MB</p>
                </div>
            </div>
        </section>
    </div>
    <%@ include file="layout/footer.jspf" %>
</main>

<script>
    const newUsers = <%= newUsersJson %>;
    const activeUsers = <%= activeUsersJson %>;
    const cefr = <%= cefrJson %>;
    const content = <%= contentJson %>;
    const xpSource = <%= xpSourceJson %>;
    const heatmap = <%= heatmapJson %>;

    const baseLine = (ctx, labels, values, label, color) => new Chart(ctx, {
        type: "line",
        data: {
            labels: labels,
            datasets: [{
                label: label,
                data: values,
                borderColor: color,
                backgroundColor: color + "33",
                fill: true,
                tension: 0.35,
                pointRadius: 3
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
        }
    });

    baseLine(document.getElementById("chartNewUsers"), newUsers.labels, newUsers.values, "New users", "#24389c");
    baseLine(document.getElementById("chartActive"), activeUsers.labels, activeUsers.values, "Active users", "#10b981");

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

    new Chart(document.getElementById("chartContent"), {
        type: "doughnut",
        data: {
            labels: content.map(c => c.label),
            datasets: [{ data: content.map(c => c.value), backgroundColor: ["#24389c", "#10b981", "#f59e0b", "#ef4444"] }]
        },
        options: { responsive: true, plugins: { legend: { position: "bottom" } } }
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

    // Heatmap (DOW × Hour)
    (function renderHeatmap() {
        const days = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];
        const container = document.getElementById("heatmap");
        if (!heatmap || !heatmap.length) { container.innerHTML = '<p class="text-sm text-slate-400">Chưa có dữ liệu</p>'; return; }
        let max = 0;
        for (let d = 0; d < 7; d++) for (let h = 0; h < 24; h++) if (heatmap[d] && heatmap[d][h] > max) max = heatmap[d][h];
        if (max === 0) max = 1;
        let html = '<table class="text-[10px] border-separate" style="border-spacing:2px"><thead><tr><th></th>';
        for (let h = 0; h < 24; h++) html += '<th class="text-slate-400 font-normal w-6">' + h + '</th>';
        html += '</tr></thead><tbody>';
        for (let d = 0; d < 7; d++) {
            html += '<tr><td class="pr-2 text-slate-500 font-semibold">' + days[d] + '</td>';
            for (let h = 0; h < 24; h++) {
                const v = (heatmap[d] && heatmap[d][h]) || 0;
                const alpha = (v / max).toFixed(2);
                html += '<td title="' + days[d] + ' ' + h + 'h: ' + v + '" style="width:18px;height:18px;background-color:rgba(36,56,156,' + alpha + ');border-radius:3px"></td>';
            }
            html += '</tr>';
        }
        html += '</tbody></table>';
        container.innerHTML = html;
    })();
</script>
</body>
</html>
