<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.PronunciationAnalytics" %>
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
        PronunciationAnalytics a = (PronunciationAnalytics) request.getAttribute("analytics");
        long maxBucket = 1L;
        for (PronunciationAnalytics.ScoreBucket b : a.scoreBuckets()) {
            if (b.count() > maxBucket) maxBucket = b.count();
        }
    %>

    <div class="p-8 space-y-8">
        <div class="flex items-center gap-2 text-sm font-semibold text-slate-500">
            <a href="${pageContext.request.contextPath}/admin/pronunciation/exercises" class="hover:text-indigo-600">← Pronunciation Exercises</a>
        </div>

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Pronunciation Analytics</h1>
            <p class="text-slate-500 font-medium">
                Tổng <%= a.totalAttempts() %> attempts —
                điểm trung bình <strong class="text-indigo-700"><%= a.averageScore() == null ? "—" : a.averageScore() %></strong>.
            </p>
        </div>

        <!-- Score distribution -->
        <section class="bg-surface-container-lowest p-6 rounded-[2rem]">
            <h2 class="text-lg font-headline font-bold text-indigo-950 mb-4">Phân bố điểm overall</h2>
            <div class="space-y-2">
                <% for (PronunciationAnalytics.ScoreBucket b : a.scoreBuckets()) {
                    int pct = (int) Math.round(b.count() * 100.0 / Math.max(maxBucket, 1));
                %>
                    <div class="flex items-center gap-4">
                        <div class="w-20 text-xs font-bold text-slate-500"><%= b.label() %></div>
                        <div class="flex-1 bg-slate-100 rounded-full h-4 overflow-hidden">
                            <div class="primary-gradient h-full rounded-full" style="width: <%= pct %>%;"></div>
                        </div>
                        <div class="w-12 text-right text-sm font-bold text-slate-700"><%= b.count() %></div>
                    </div>
                <% } %>
            </div>
        </section>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Weakest words -->
            <section class="bg-surface-container-lowest p-6 rounded-[2rem]">
                <h2 class="text-lg font-headline font-bold text-indigo-950 mb-4">Word có điểm thấp nhất</h2>
                <% if (a.weakestWords().isEmpty()) { %>
                    <p class="text-sm text-slate-500">Chưa đủ dữ liệu (cần ≥ 3 attempts/word).</p>
                <% } else { %>
                    <table class="w-full text-sm">
                        <thead>
                        <tr class="text-[10px] font-black uppercase tracking-widest text-slate-400">
                            <th class="text-left py-2">Word</th>
                            <th class="text-right py-2">Lượt</th>
                            <th class="text-right py-2">Avg score</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (PronunciationAnalytics.WeakWord w : a.weakestWords()) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 font-mono font-bold text-indigo-950"><%= w.word() %></td>
                                <td class="py-2 text-right text-slate-600"><%= w.attempts() %></td>
                                <td class="py-2 text-right">
                                    <span class="inline-flex px-3 py-1 rounded-xl text-xs font-bold
                                          <%= w.avgScore() != null && w.avgScore() < 50 ? "bg-rose-50 text-rose-700"
                                              : w.avgScore() != null && w.avgScore() < 75 ? "bg-amber-50 text-amber-700"
                                              : "bg-emerald-50 text-emerald-700" %>">
                                        <%= w.avgScore() == null ? "—" : w.avgScore() %>
                                    </span>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                <% } %>
            </section>

            <!-- Issue types -->
            <section class="bg-surface-container-lowest p-6 rounded-[2rem]">
                <h2 class="text-lg font-headline font-bold text-indigo-950 mb-4">Loại lỗi phổ biến</h2>
                <% if (a.topIssues().isEmpty()) { %>
                    <p class="text-sm text-slate-500">Chưa có feedback nào.</p>
                <% } else { %>
                    <table class="w-full text-sm">
                        <thead>
                        <tr class="text-[10px] font-black uppercase tracking-widest text-slate-400">
                            <th class="text-left py-2">Issue type</th>
                            <th class="text-right py-2">Số lần</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (PronunciationAnalytics.IssueType i : a.topIssues()) { %>
                            <tr class="border-t border-slate-100">
                                <td class="py-2 font-semibold text-slate-700"><%= i.issueType() %></td>
                                <td class="py-2 text-right font-bold text-slate-700"><%= i.count() %></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                <% } %>
            </section>
        </div>

        <!-- Provider compare -->
        <section class="bg-surface-container-lowest p-6 rounded-[2rem]">
            <h2 class="text-lg font-headline font-bold text-indigo-950 mb-4">So sánh provider</h2>
            <% if (a.providers().isEmpty()) { %>
                <p class="text-sm text-slate-500">Chưa có attempt nào.</p>
            <% } else { %>
                <table class="w-full text-sm">
                    <thead>
                    <tr class="text-[10px] font-black uppercase tracking-widest text-slate-400">
                        <th class="text-left py-2">Provider</th>
                        <th class="text-right py-2">Attempts</th>
                        <th class="text-right py-2">Avg overall</th>
                        <th class="text-right py-2">Avg accuracy</th>
                        <th class="text-right py-2">Avg fluency</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (PronunciationAnalytics.ProviderStat p : a.providers()) { %>
                        <tr class="border-t border-slate-100">
                            <td class="py-2 font-bold text-indigo-950"><%= p.provider() %></td>
                            <td class="py-2 text-right text-slate-700 font-semibold"><%= p.attempts() %></td>
                            <td class="py-2 text-right text-slate-700"><%= p.avgOverall() == null ? "—" : p.avgOverall() %></td>
                            <td class="py-2 text-right text-slate-700"><%= p.avgAccuracy() == null ? "—" : p.avgAccuracy() %></td>
                            <td class="py-2 text-right text-slate-700"><%= p.avgFluency() == null ? "—" : p.avgFluency() %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            <% } %>
        </section>
    </div>
</main>
<%@ include file="layout/footer.jspf" %>
</body>
</html>
