<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.GrammarLessonDetailResponse" %>
<%@ page import="com.kiovant.englishme.dto.GrammarExerciseResponse" %>
<%@ page import="java.util.List" %>
<%
    GrammarLessonDetailResponse lesson = (GrammarLessonDetailResponse) request.getAttribute("lesson");
    List<GrammarExerciseResponse> exercises = lesson != null ? lesson.exercises() : List.of();
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
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
        <% if (successMessage != null) { %>
        <div class="rounded-2xl bg-emerald-50 text-emerald-800 px-5 py-3 text-sm font-semibold border border-emerald-100"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100"><%= errorMessage %></div>
        <% } %>

        <% if (lesson != null) { %>
        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/admin/grammar/topics/<%= lesson.topicId() %>" class="text-xs font-bold text-primary hover:underline inline-flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách bài học
            </a>
        </div>

        <div class="space-y-1">
            <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline"><%= lesson.title() %></h1>
            <p class="text-slate-500 font-medium">Source ID: <%= lesson.sourceId() != null ? lesson.sourceId() : "—" %> &middot; Thứ tự: <%= lesson.sortOrder() %></p>
        </div>

        <% if (lesson.explanationVi() != null && !lesson.explanationVi().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">menu_book</span> Giải thích
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.explanationVi() %></div>
        </section>
        <% } %>

        <% if (lesson.whenToUseVi() != null && !lesson.whenToUseVi().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">help</span> Khi nào dùng
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.whenToUseVi() %></div>
        </section>
        <% } %>

        <% if (lesson.tipsVi() != null && !lesson.tipsVi().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">lightbulb</span> Mẹo
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.tipsVi() %></div>
        </section>
        <% } %>

        <% if (lesson.formulas() != null && !lesson.formulas().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">function</span> Công thức
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.formulas() %></div>
        </section>
        <% } %>

        <% if (lesson.keyWords() != null && !lesson.keyWords().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">vpn_key</span> Từ khóa nhận biết
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.keyWords() %></div>
        </section>
        <% } %>

        <% if (lesson.examples() != null && !lesson.examples().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">format_quote</span> Ví dụ
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.examples() %></div>
        </section>
        <% } %>

        <% if (lesson.commonMistakes() != null && !lesson.commonMistakes().isBlank()) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">warning</span> Lỗi thường gặp
            </h2>
            <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= lesson.commonMistakes() %></div>
        </section>
        <% } %>

        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">quiz</span> Bài tập (<%= exercises.size() %>)
            </h2>
            <% if (exercises.isEmpty()) { %>
            <p class="text-slate-500 text-sm">Chưa có bài tập cho bài học này.</p>
            <% } else { %>
            <div class="space-y-4">
                <%
                    for (int i = 0; i < exercises.size(); i++) {
                        GrammarExerciseResponse ex = exercises.get(i);
                %>
                <div class="bg-white rounded-xl p-5 space-y-3">
                    <div class="flex items-center gap-2">
                        <span class="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-indigo-100 text-primary text-xs font-bold"><%= i + 1 %></span>
                        <span class="text-[10px] font-black uppercase tracking-wider text-slate-400"><%= ex.exerciseType() %></span>
                    </div>
                    <div class="prose prose-slate max-w-none text-sm leading-relaxed whitespace-pre-wrap"><%= ex.content() %></div>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>
        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
