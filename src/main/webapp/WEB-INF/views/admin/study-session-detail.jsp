<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminStudySessionDetail" %>
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
        AdminStudySessionDetail d = (AdminStudySessionDetail) request.getAttribute("detail");
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        long max = 1L;
        for (AdminStudySessionDetail.QualityBucket b : d.qualityBuckets()) {
            if (b.count() > max) max = b.count();
        }
        Long secs = d.durationSeconds();
        String durationStr;
        if (secs == null) {
            durationStr = "—";
        } else if (secs < 60) {
            durationStr = secs + "s";
        } else if (secs < 3600) {
            durationStr = (secs / 60) + "m " + (secs % 60) + "s";
        } else {
            durationStr = (secs / 3600) + "h " + ((secs % 3600) / 60) + "m";
        }
        String statusClass = "completed".equalsIgnoreCase(d.status())
                ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700";
    %>

    <div class="p-8 space-y-8">
        <div class="flex items-center gap-2 text-sm font-semibold text-slate-500">
            <a href="${pageContext.request.contextPath}/admin/study-sessions" class="hover:text-indigo-600">← Study Sessions</a>
        </div>

        <div class="flex flex-wrap items-end justify-between gap-4">
            <div class="space-y-1">
                <span class="inline-flex px-3 py-1 text-xs font-black rounded-xl <%= statusClass %>"><%= d.status() %></span>
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline mt-2">
                    Session <%= d.id().toString().substring(0, 8) %>…
                </h1>
                <p class="text-slate-500 font-medium">
                    User: <strong class="text-indigo-700"><%= d.userFullName() == null ? "—" : d.userFullName() %></strong>
                    (<%= d.userEmail() == null ? "" : d.userEmail() %>)
                    — Desk: <strong class="text-indigo-700"><%= d.deskTitle() == null ? "—" : d.deskTitle() %></strong>
                    <% if (d.deskCefrLevel() != null) { %><span class="text-xs text-slate-500">[<%= d.deskCefrLevel() %>]</span><% } %>
                </p>
            </div>
            <% if (d.userId() != null) { %>
                <a href="${pageContext.request.contextPath}/admin/users/<%= d.userId() %>"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">person</span>
                    Hồ sơ user
                </a>
            <% } %>
        </div>

        <!-- Stat cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-surface-container-lowest p-5 rounded-2xl">
                <div class="text-xs font-bold text-slate-500 uppercase">Total cards</div>
                <div class="text-3xl font-headline font-black text-indigo-950 mt-1"><%= d.totalCards() == null ? 0 : d.totalCards() %></div>
            </div>
            <div class="bg-surface-container-lowest p-5 rounded-2xl">
                <div class="text-xs font-bold text-slate-500 uppercase">XP earned</div>
                <div class="text-3xl font-headline font-black text-indigo-700 mt-1"><%= d.xpEarned() == null ? 0 : d.xpEarned() %></div>
            </div>
            <div class="bg-surface-container-lowest p-5 rounded-2xl">
                <div class="text-xs font-bold text-slate-500 uppercase">New words</div>
                <div class="text-3xl font-headline font-black text-emerald-700 mt-1"><%= d.newWordsLearned() == null ? 0 : d.newWordsLearned() %></div>
            </div>
            <div class="bg-surface-container-lowest p-5 rounded-2xl">
                <div class="text-xs font-bold text-slate-500 uppercase">Duration</div>
                <div class="text-3xl font-headline font-black text-slate-700 mt-1"><%= durationStr %></div>
            </div>
        </div>

        <!-- Timeline -->
        <div class="bg-surface-container-lowest p-6 rounded-[2rem] grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <div class="text-xs font-bold text-slate-500 uppercase">Started at</div>
                <div class="text-lg font-bold text-indigo-950 mt-1"><%= d.startedAt() == null ? "—" : fmt.format(d.startedAt()) %></div>
            </div>
            <div>
                <div class="text-xs font-bold text-slate-500 uppercase">Completed at</div>
                <div class="text-lg font-bold text-indigo-950 mt-1"><%= d.completedAt() == null ? "(chưa hoàn tất)" : fmt.format(d.completedAt()) %></div>
            </div>
        </div>

        <!-- Quality distribution -->
        <section class="bg-surface-container-lowest p-6 rounded-[2rem]">
            <h2 class="text-lg font-headline font-bold text-indigo-950 mb-1">Phân bố quality (1-5)</h2>
            <p class="text-xs text-slate-500 mb-4">
                Quality per-card không được lưu trong DB hiện tại. Bucket được suy ra từ counter của session:
                <strong>q 1-2 = Again</strong>, <strong>q 3 = Hard</strong>, <strong>q 4-5 = Mastered</strong>.
            </p>
            <div class="space-y-2">
                <%
                    String[] colors = new String[]{"bg-rose-500", "bg-amber-500", "bg-emerald-500", "bg-slate-300"};
                    int colorIdx = 0;
                    for (AdminStudySessionDetail.QualityBucket b : d.qualityBuckets()) {
                        int pct = (int) Math.round(b.count() * 100.0 / Math.max(max, 1));
                        String barColor = colors[Math.min(colorIdx, colors.length - 1)];
                %>
                    <div class="flex items-center gap-4">
                        <div class="w-44 text-xs font-bold text-slate-600"><%= b.label() %></div>
                        <div class="flex-1 bg-slate-100 rounded-full h-4 overflow-hidden">
                            <div class="<%= barColor %> h-full rounded-full" style="width: <%= pct %>%;"></div>
                        </div>
                        <div class="w-12 text-right text-sm font-bold text-slate-700"><%= b.count() %></div>
                    </div>
                <%
                        colorIdx++;
                    }
                %>
            </div>
        </section>
    </div>
</main>
<%@ include file="layout/footer.jspf" %>
</body>
</html>
