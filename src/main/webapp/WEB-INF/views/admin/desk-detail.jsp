<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.Desk" %>
<%@ page import="com.kiovant.englishme.dto.FlashcardResponse" %>
<%@ page import="org.springframework.data.domain.Page" %>
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
        Desk desk = (Desk) request.getAttribute("desk");
        @SuppressWarnings("unchecked")
        Page<FlashcardResponse> fp = (Page<FlashcardResponse>) request.getAttribute("flashcardsPage");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        if (currentPage == null) currentPage = 0;
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        String ctx = request.getContextPath();
        String deskUrl = desk != null ? ctx + "/admin/desks/" + desk.getId() : ctx + "/admin/desks";
        long total = fp != null ? fp.getTotalElements() : 0;
    %>

    <div class="p-8 space-y-8">
        <% if (successMessage != null) { %>
        <div class="rounded-2xl bg-emerald-50 text-emerald-800 px-5 py-3 text-sm font-semibold border border-emerald-100"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100"><%= errorMessage %></div>
        <% } %>

        <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="space-y-2">
                <a href="<%= ctx %>/admin/desks" class="text-xs font-bold text-primary hover:underline inline-flex items-center gap-1">
                    <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách desk
                </a>
                <% if (desk != null) { %>
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline flex flex-wrap items-center gap-3">
                    <%= desk.getTitle() %>
                    <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-sm font-black rounded-xl"><%= desk.getCefrLevel() %></span>
                </h1>
                <p class="text-slate-500 font-medium"><%= total %> flashcard trong desk này (<%= fp != null ? fp.getSize() : 0 %> / trang).</p>
                <% } %>
            </div>
        </div>

        <section class="bg-surface-container-low rounded-[2rem] p-8 space-y-6">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">note_add</span> Thêm flashcard
            </h2>
            <% if (desk != null) { %>
            <form method="post" action="<%= ctx %>/admin/desks/<%= desk.getId() %>/flashcards" class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Từ (word) *</label>
                    <input name="word" required type="text" placeholder="abandon"
                           class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR *</label>
                    <input name="cefr" required type="text" value="<%= desk.getCefrLevel() %>"
                           class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Audio URL</label>
                    <input name="audioUrl" type="text" placeholder="audio/word.mp3 hoặc URL"
                           class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">IPA</label>
                    <input name="ipa" type="text" placeholder="/əˈbæn.dən/"
                           class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Definition (EN)</label>
                    <textarea name="definition" rows="2" placeholder="Định nghĩa tiếng Anh"
                              class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Example (EN)</label>
                    <textarea name="example" rows="2" placeholder="Ví dụ"
                              class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Topic</label>
                    <input name="topic" type="text" class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tiếng Việt</label>
                    <input name="vietnamese" type="text" class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Giải thích (VI)</label>
                    <textarea name="viDefinition" rows="2" class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2 md:col-span-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Ví dụ (VI)</label>
                    <textarea name="viExample" rows="2" class="mt-1 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="md:col-span-2 flex justify-end">
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Lưu flashcard
                    </button>
                </div>
            </form>
            <% } %>
        </section>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="px-8 py-5 border-b border-slate-100 flex flex-wrap justify-between items-center gap-4">
                <h2 class="text-lg font-headline font-black text-primary">Flashcard trong desk</h2>
                <% if (fp != null && fp.getTotalPages() > 1) { %>
                <nav class="flex items-center gap-2 text-xs font-bold">
                    <% if (fp.hasPrevious()) { %>
                    <a href="<%= deskUrl %>?page=<%= currentPage - 1 %>" class="px-3 py-2 rounded-xl bg-white text-primary hover:bg-indigo-50">← Trước</a>
                    <% } %>
                    <span class="text-slate-500">Trang <%= fp.getNumber() + 1 %> / <%= fp.getTotalPages() %></span>
                    <% if (fp.hasNext()) { %>
                    <a href="<%= deskUrl %>?page=<%= currentPage + 1 %>" class="px-3 py-2 rounded-xl bg-white text-primary hover:bg-indigo-50">Sau →</a>
                    <% } %>
                </nav>
                <% } %>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Từ</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Audio</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Định nghĩa (rút)</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Xóa</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (fp == null || fp.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="4" class="px-8 py-10 text-center text-slate-500 font-semibold">Chưa có flashcard.</td>
                    </tr>
                    <%
                        } else {
                            for (FlashcardResponse fc : fp.getContent()) {
                                String def = fc.getDefinition();
                                if (def != null && def.length() > 120) def = def.substring(0, 117) + "...";
                                String au = fc.getAudioUrl();
                                if (au == null || au.isBlank()) au = "—";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-4">
                            <span class="text-sm font-bold text-indigo-950"><%= fc.getWord() %></span>
                            <% if (fc.getIpa() != null && !fc.getIpa().isBlank()) { %>
                            <span class="block text-[11px] text-slate-400 font-medium mt-0.5"><%= fc.getIpa() %></span>
                            <% } %>
                        </td>
                        <td class="px-6 py-4 text-xs font-mono text-slate-600 max-w-[200px] truncate" title="<%= fc.getAudioUrl() != null ? fc.getAudioUrl() : "" %>"><%= au %></td>
                        <td class="px-6 py-4 text-xs text-slate-600 max-w-xl"><%= def != null ? def : "—" %></td>
                        <td class="px-6 py-4 text-right">
                            <form method="post" action="<%= ctx %>/admin/desks/<%= desk.getId() %>/flashcards/<%= fc.getId() %>/delete"
                                  onsubmit="return confirm('Xóa flashcard này?')">
                                <button type="submit" class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold bg-rose-100 text-rose-700 hover:bg-rose-200 transition-colors">
                                    <span class="material-symbols-outlined text-sm">delete</span>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
