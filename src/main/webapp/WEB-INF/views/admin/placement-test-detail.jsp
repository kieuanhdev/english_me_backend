<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.TestSession" %>
<%@ page import="com.kiovant.englishme.entity.TestAnswer" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    TestSession session = (TestSession) request.getAttribute("session");
    @SuppressWarnings("unchecked")
    List<TestAnswer> answers = (List<TestAnswer>) request.getAttribute("answers");
    DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/admin/placement-test" class="text-xs font-bold text-primary hover:underline inline-flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách phiên kiểm tra
            </a>
        </div>

        <% if (session != null) { %>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Học viên</p>
                <h3 class="text-lg text-primary font-black font-headline mt-1">
                    <%= session.getUser().getFullName() != null && !session.getUser().getFullName().isBlank()
                        ? session.getUser().getFullName() : "Chưa cập nhật" %>
                </h3>
                <p class="text-sm text-slate-500"><%= session.getUser().getEmail() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Kết quả</p>
                <h3 class="text-lg text-primary font-black font-headline mt-1">
                    <%= session.getResultLevel() != null ? session.getResultLevel() : "Chưa có" %>
                </h3>
                <p class="text-sm text-slate-500">Điểm: <%= session.getScore() != null ? session.getScore() : "—" %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Thời gian</p>
                <h3 class="text-lg text-primary font-black font-headline mt-1">
                    <%= session.getStartedAt() != null ? session.getStartedAt().format(df) : "—" %>
                </h3>
                <p class="text-sm text-slate-500">
                    <% if (session.getCompletedAt() != null) { %>
                    Hoàn thành: <%= session.getCompletedAt().format(df) %>
                    <% } else { %>
                    <%= session.getStatus() == TestSession.TestStatus.COMPLETED ? "Đã hoàn thành" : "Đang làm" %>
                    <% } %>
                </p>
            </div>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] p-8 space-y-6">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">quiz</span> Câu trả lời (<%= answers != null ? answers.size() : 0 %>)
            </h2>
            <div class="space-y-4">
                <%
                    if (answers == null || answers.isEmpty()) {
                %>
                <p class="text-slate-500 text-sm">Chưa trả lời câu hỏi nào.</p>
                <%
                    } else {
                        for (int i = 0; i < answers.size(); i++) {
                            TestAnswer answer = answers.get(i);
                            var question = answer.getQuestion();
                            String selected = answer.getSelectedAnswer();
                            boolean correct = Boolean.TRUE.equals(answer.getIsCorrect());
                            String rowBg = correct ? "bg-emerald-50 border-emerald-100" : (selected == null ? "bg-slate-50 border-slate-100" : "bg-rose-50 border-rose-100");
                %>
                <div class="rounded-xl p-5 border <%= rowBg %>">
                    <div class="flex items-start justify-between gap-3">
                        <div class="flex-1 space-y-2">
                            <div class="flex items-center gap-2">
                                <span class="inline-flex items-center justify-center w-6 h-6 rounded-lg bg-indigo-100 text-primary text-xs font-bold"><%= i + 1 %></span>
                                <span class="text-[10px] font-black uppercase tracking-wider text-slate-400"><%= question.getCefrLevel() %> &middot; <%= question.getSkillCategory() %></span>
                            </div>
                            <p class="text-sm font-semibold text-indigo-950"><%= question.getQuestion() %></p>
                            <div class="grid grid-cols-2 gap-2 text-xs">
                                <%
                                    for (var entry : question.getOptions().entrySet()) {
                                        String optClass = entry.getKey().equals(question.getCorrectAnswer())
                                            ? "bg-emerald-100 text-emerald-800 font-bold border-emerald-300"
                                            : (entry.getKey().equals(selected) && !correct
                                                ? "bg-rose-100 text-rose-800 font-bold border-rose-300"
                                                : "bg-white text-slate-600 border-slate-100");
                                %>
                                <span class="px-3 py-1.5 rounded-lg border <%= optClass %>">
                                    <%= entry.getKey() %>. <%= entry.getValue() %>
                                </span>
                                <% } %>
                            </div>
                            <% if (question.getExplanation() != null && !question.getExplanation().isBlank()) { %>
                            <p class="text-xs text-slate-500 italic mt-1"><%= question.getExplanation() %></p>
                            <% } %>
                        </div>
                        <div class="flex flex-col items-center gap-1">
                            <% if (correct) { %>
                            <span class="material-symbols-outlined text-emerald-600">check_circle</span>
                            <span class="text-[10px] font-bold text-emerald-600">Đúng</span>
                            <% } else if (selected == null) { %>
                            <span class="material-symbols-outlined text-slate-400">remove_circle</span>
                            <span class="text-[10px] font-bold text-slate-400">Bỏ qua</span>
                            <% } else { %>
                            <span class="material-symbols-outlined text-rose-600">cancel</span>
                            <span class="text-[10px] font-bold text-rose-600">Sai</span>
                            <% } %>
                        </div>
                    </div>
                </div>
                <%
                        }
                    }
                %>
            </div>
        </div>
        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
