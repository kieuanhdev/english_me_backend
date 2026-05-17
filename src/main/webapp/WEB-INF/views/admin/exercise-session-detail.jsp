<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminExerciseSessionDetail" %>
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
        AdminExerciseSessionDetail session = (AdminExerciseSessionDetail) request.getAttribute("session");
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        long accuracy = session != null && session.totalQuestions() > 0
                ? Math.round(session.correctCount() * 100.0 / session.totalQuestions())
                : 0L;
        String fullName = session == null ? "" :
                (session.userFullName() == null || session.userFullName().isBlank()
                        ? (session.userEmail() == null ? "(unknown)" : session.userEmail())
                        : session.userFullName());
    %>

    <div class="p-8 space-y-8">
        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Session #<%= session.id().toString().substring(0, 8) %></h1>
                <p class="text-slate-500 font-medium">
                    <%= fullName %><% if (session.userEmail() != null && !session.userEmail().equals(fullName)) { %> · <%= session.userEmail() %><% } %>
                </p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/exercises/sessions"
               class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                <span class="material-symbols-outlined text-lg">arrow_back</span>
                Quay lại
            </a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Category</p>
                <p class="mt-2 text-xl font-extrabold text-indigo-950"><%= session.category() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Status</p>
                <p class="mt-2 text-xl font-extrabold text-indigo-950"><%= session.status() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Tổng câu</p>
                <p class="mt-2 text-2xl font-black text-indigo-950"><%= session.totalQuestions() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Đã trả lời</p>
                <p class="mt-2 text-2xl font-black text-indigo-950"><%= session.answeredCount() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-5">
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Đúng / Tỉ lệ</p>
                <p class="mt-2 text-2xl font-black text-emerald-700"><%= session.correctCount() %> · <%= accuracy %>%</p>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-2xl p-5 grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Bắt đầu</p>
                <p class="font-semibold text-slate-700 mt-1"><%= session.createdAt() == null ? "—" : session.createdAt().format(fmt) %></p>
            </div>
            <div>
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Hoàn thành</p>
                <p class="font-semibold text-slate-700 mt-1"><%= session.completedAt() == null ? "—" : session.completedAt().format(fmt) %></p>
            </div>
            <div>
                <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Thời lượng</p>
                <p class="font-semibold text-slate-700 mt-1">
                    <%= session.durationSeconds() == null ? "—" : (session.durationSeconds() + " giây") %>
                </p>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="px-6 py-4 border-b border-slate-100">
                <h2 class="text-sm font-black uppercase tracking-widest text-slate-500">Đáp án từng câu</h2>
            </div>
            <div class="divide-y divide-slate-100">
                <%
                    if (session.answers() == null || session.answers().isEmpty()) {
                %>
                <div class="px-8 py-12 text-center text-slate-500 font-semibold">
                    Học viên chưa trả lời câu nào.
                </div>
                <%
                    } else {
                        int idx = 0;
                        for (AdminExerciseSessionDetail.AnswerRow a : session.answers()) {
                            idx++;
                            boolean correct = Boolean.TRUE.equals(a.isCorrect());
                            String rowBg = correct ? "bg-emerald-50/30" : "bg-rose-50/30";
                            String badge = correct
                                    ? "bg-emerald-100 text-emerald-700"
                                    : "bg-rose-100 text-rose-700";
                            String badgeText = correct ? "Đúng" : "Sai";
                %>
                <div class="px-6 py-5 <%= rowBg %>">
                    <div class="flex items-start gap-4">
                        <div class="text-xs font-black text-slate-400 mt-1 w-6"><%= idx %>.</div>
                        <div class="flex-1 space-y-2">
                            <div class="flex items-center gap-3 flex-wrap">
                                <span class="inline-flex items-center px-2.5 py-1 text-xs font-black rounded-lg <%= badge %>"><%= badgeText %></span>
                                <% if (a.level() != null) { %>
                                <span class="inline-flex items-center px-2 py-0.5 bg-indigo-50 text-indigo-700 text-[10px] font-black rounded"><%= a.level() %></span>
                                <% } %>
                                <% if (a.difficulty() != null) { %>
                                <span class="inline-flex items-center px-2 py-0.5 bg-slate-100 text-slate-600 text-[10px] font-black rounded"><%= a.difficulty() %></span>
                                <% } %>
                            </div>
                            <p class="text-sm font-semibold text-indigo-950"><%= a.question() == null ? "(câu hỏi đã bị xóa)" : a.question() %></p>
                            <% if (a.optionsJson() != null) { %>
                            <pre class="text-[11px] font-mono text-slate-500 bg-white/60 rounded-lg p-2 overflow-x-auto"><%= a.optionsJson() %></pre>
                            <% } %>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs">
                                <div class="bg-white/70 rounded-lg p-2">
                                    <span class="font-black uppercase text-[10px] text-slate-400">Học viên chọn:</span>
                                    <span class="ml-2 font-semibold <%= correct ? "text-emerald-700" : "text-rose-700" %>"><%= a.selectedAnswer() == null ? "(không trả lời)" : a.selectedAnswer() %></span>
                                </div>
                                <div class="bg-white/70 rounded-lg p-2">
                                    <span class="font-black uppercase text-[10px] text-slate-400">Đáp án đúng:</span>
                                    <span class="ml-2 font-semibold text-emerald-700"><%= a.correctAnswer() == null ? "—" : a.correctAnswer() %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%
                        }
                    }
                %>
            </div>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
