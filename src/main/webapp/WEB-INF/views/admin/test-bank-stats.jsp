<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.TestBankStats" %>
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
        TestBankStats stats = (TestBankStats) request.getAttribute("stats");
        String overall = stats == null || stats.overallAccuracy() == null
                ? "—" : (stats.overallAccuracy() + "%");
    %>

    <div class="p-8 space-y-8">
        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Test Bank — Thống kê</h1>
                <p class="text-slate-500 font-medium">Phân bố câu hỏi và tỉ lệ trả lời đúng theo CEFR / Skill.</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/test-bank"
               class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                <span class="material-symbols-outlined text-lg">arrow_back</span>
                Quay lại danh sách
            </a>
        </div>

        <% if (stats == null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100">
            Không có dữ liệu thống kê.
        </div>
        <% } else { %>

        <!-- Top stat cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Tổng câu hỏi</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= stats.totalQuestions() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Tổng lượt trả lời</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= stats.totalAttempts() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Đúng</p>
                <p class="text-3xl font-extrabold text-emerald-700 mt-2"><%= stats.totalCorrect() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Tỉ lệ đúng chung</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= overall %></p>
            </div>
        </div>

        <!-- Theo CEFR -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="px-6 pt-6">
                <h2 class="text-lg font-headline font-extrabold text-primary">Phân bố theo CEFR Level</h2>
                <p class="text-sm text-slate-500">Số câu hỏi, lượt trả lời và % đúng cho từng cấp độ.</p>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0 mt-2">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">CEFR</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Số câu</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Lượt trả lời</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đúng</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">% đúng</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (stats.byLevel().isEmpty()) {
                    %>
                    <tr><td colspan="5" class="px-8 py-10 text-center text-slate-500 font-semibold">Chưa có câu hỏi.</td></tr>
                    <%
                        } else {
                            for (TestBankStats.LevelStat lv : stats.byLevel()) {
                                String accStr = lv.accuracy() == null ? "—" : (lv.accuracy() + "%");
                                String accClass = "bg-slate-100 text-slate-700";
                                if (lv.accuracy() != null) {
                                    if (lv.accuracy() < 30) accClass = "bg-rose-50 text-rose-700";
                                    else if (lv.accuracy() > 95) accClass = "bg-amber-50 text-amber-700";
                                    else accClass = "bg-emerald-50 text-emerald-700";
                                }
                    %>
                    <tr class="hover:bg-white">
                        <td class="px-6 py-4">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= lv.cefrLevel() %></span>
                        </td>
                        <td class="px-6 py-4 text-center text-sm font-bold text-indigo-950"><%= lv.questionCount() %></td>
                        <td class="px-6 py-4 text-center text-sm font-bold text-slate-600"><%= lv.attempts() %></td>
                        <td class="px-6 py-4 text-center text-sm font-bold text-emerald-700"><%= lv.correct() %></td>
                        <td class="px-6 py-4 text-center">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= accClass %>"><%= accStr %></span>
                        </td>
                    </tr>
                    <%      }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Theo Skill + Difficulty buckets -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
                <div class="px-6 pt-6">
                    <h2 class="text-lg font-headline font-extrabold text-primary">Phân bố theo Skill</h2>
                </div>
                <table class="w-full text-left border-separate border-spacing-0 mt-2">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Skill</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Số câu</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (stats.bySkill().isEmpty()) {
                    %>
                    <tr><td colspan="2" class="px-8 py-10 text-center text-slate-500 font-semibold">Chưa có câu hỏi.</td></tr>
                    <%
                        } else {
                            for (TestBankStats.SkillStat sk : stats.bySkill()) {
                    %>
                    <tr class="hover:bg-white">
                        <td class="px-6 py-4 text-sm font-bold text-indigo-950"><%= sk.skillCategory() %></td>
                        <td class="px-6 py-4 text-right text-sm font-bold text-slate-600"><%= sk.questionCount() %></td>
                    </tr>
                    <%      }
                        }
                    %>
                    </tbody>
                </table>
            </div>

            <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
                <div class="px-6 pt-6">
                    <h2 class="text-lg font-headline font-extrabold text-primary">Nhóm độ khó (theo tỉ lệ đúng)</h2>
                    <p class="text-xs text-slate-500">Proxy đơn giản cho "difficulty index": &lt;30% là quá khó, &gt;95% là quá dễ.</p>
                </div>
                <table class="w-full text-left border-separate border-spacing-0 mt-2">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Nhóm</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Số câu</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        for (TestBankStats.DifficultyBucket b : stats.difficultyBuckets()) {
                            String labelClass = "bg-slate-100 text-slate-700";
                            switch (b.label()) {
                                case "Quá khó (<30%)": labelClass = "bg-rose-50 text-rose-700"; break;
                                case "Quá dễ (>95%)":  labelClass = "bg-amber-50 text-amber-700"; break;
                                case "Bình thường":    labelClass = "bg-emerald-50 text-emerald-700"; break;
                                default: break;
                            }
                    %>
                    <tr class="hover:bg-white">
                        <td class="px-6 py-4">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= labelClass %>"><%= b.label() %></span>
                        </td>
                        <td class="px-6 py-4 text-right text-sm font-bold text-slate-600"><%= b.questionCount() %></td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
