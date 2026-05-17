<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminGrammarLessonRow" %>
<%@ page import="com.kiovant.englishme.entity.GrammarTopic" %>
<%@ page import="java.util.List" %>
<%
    GrammarTopic topic = (GrammarTopic) request.getAttribute("topic");
    @SuppressWarnings("unchecked")
    List<AdminGrammarLessonRow> lessons = (List<AdminGrammarLessonRow>) request.getAttribute("lessons");
    String topicId = (String) request.getAttribute("topicId");
    int n = lessons == null ? 0 : lessons.size();
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

        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/admin/grammar" class="text-xs font-bold text-primary hover:underline inline-flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách chủ đề
            </a>
        </div>

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">
                    <% if (topic != null) { %><%= topic.getTitle() %><% } else { %>Bài học<% } %>
                </h1>
                <% if (topic != null) { %>
                <p class="text-slate-500 font-medium">
                    <span class="font-mono"><%= topic.getSlug() %></span> &middot; <%= topic.getCategory() %> &middot; <%= topic.getLevel() %> &middot; <%= n %> bài học
                </p>
                <% } %>
            </div>
            <button type="button" id="openLessonModal"
                    class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                <span class="material-symbols-outlined text-xl">add_circle</span> Thêm bài học
            </button>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Source ID</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Sort</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Bài tập</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (lessons == null || lessons.isEmpty()) { %>
                    <tr>
                        <td colspan="5" class="px-8 py-12 text-center text-slate-500 font-semibold">Chưa có bài học nào trong chủ đề này.</td>
                    </tr>
                    <% } else {
                        for (AdminGrammarLessonRow l : lessons) {
                            String detailUrl = request.getContextPath() + "/admin/grammar/lessons/" + l.id();
                            String deleteUrl = request.getContextPath() + "/admin/grammar/lessons/" + l.id() + "/delete";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <a href="<%= detailUrl %>" class="text-sm font-bold text-indigo-950 hover:underline"><%= l.title() %></a>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-xs font-mono text-slate-500"><%= l.sourceId() != null ? l.sourceId() : "—" %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-semibold text-slate-600"><%= l.sortOrder() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-bold"><%= l.exerciseCount() %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <a href="<%= detailUrl %>"
                               class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-base">visibility</span> Chi tiết
                            </a>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa bài học này? Bài tập đi kèm cũng sẽ bị xóa.')">
                                <button type="submit"
                                        class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-rose-50 text-rose-700 hover:bg-rose-100">
                                    <span class="material-symbols-outlined text-base">delete</span> Xóa
                                </button>
                            </form>
                        </td>
                    </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Create lesson modal -->
    <div id="lessonCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md lesson-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-3xl rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Grammar lesson</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm bài học</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface lesson-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4 overflow-y-auto" method="post" action="${pageContext.request.contextPath}/admin/grammar/topics/<%= topicId %>/lessons">
                <%@ include file="grammar-lesson-form-fields.jspf" %>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl lesson-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">Tạo bài học</button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
<script>
    (function () {
        function bindModal(openSelector, modalId, closeSelector, backdropSelector) {
            var openBtn = openSelector ? document.querySelector(openSelector) : null;
            var modal = document.getElementById(modalId);
            if (!modal) return null;
            function openModal() { modal.classList.remove("hidden"); modal.classList.add("flex"); }
            function closeModal() { modal.classList.remove("flex"); modal.classList.add("hidden"); }
            if (openBtn) openBtn.addEventListener("click", openModal);
            document.querySelectorAll(closeSelector).forEach(function (el) { el.addEventListener("click", closeModal); });
            document.querySelectorAll(backdropSelector).forEach(function (el) { el.addEventListener("click", closeModal); });
            document.addEventListener("keydown", function (e) { if (e.key === "Escape" && modal.classList.contains("flex")) closeModal(); });
            return { open: openModal, close: closeModal };
        }
        bindModal("#openLessonModal", "lessonCreateModal", ".lesson-modal-close", ".lesson-modal-backdrop");
    })();
</script>
</body>
</html>
