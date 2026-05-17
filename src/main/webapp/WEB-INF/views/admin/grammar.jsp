<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminGrammarTopicRow" %>
<%@ page import="java.util.List" %>
<%
    @SuppressWarnings("unchecked")
    List<AdminGrammarTopicRow> topics = (List<AdminGrammarTopicRow>) request.getAttribute("topics");
    int n = topics == null ? 0 : topics.size();
    String selectedLevel = (String) request.getAttribute("selectedLevel");
    String selectedKeyword = (String) request.getAttribute("selectedKeyword");
    if (selectedLevel == null) selectedLevel = "";
    if (selectedKeyword == null) selectedKeyword = "";
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

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quản lý Ngữ pháp</h1>
                <p class="text-slate-500 font-medium"><%= n %> chủ đề ngữ pháp trong hệ thống.</p>
            </div>
            <div class="flex gap-2">
                <button type="button" id="openImportModal"
                        class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-base">upload_file</span> Import JSON
                </button>
                <button type="button" id="openTopicModal"
                        class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-xl">add_circle</span> Thêm chủ đề
                </button>
            </div>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/grammar"
              class="bg-surface-container-lowest rounded-2xl p-4 flex flex-wrap items-end gap-3">
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">CEFR</label>
                <select name="level" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedLevel.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                        <option value="<%= lv %>" <%= lv.equalsIgnoreCase(selectedLevel) ? "selected" : "" %>><%= lv %></option>
                    <% } %>
                </select>
            </div>
            <div class="space-y-1 flex-1 min-w-[220px]">
                <label class="text-xs font-bold text-slate-500 uppercase">Tìm theo tên / danh mục / slug</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       placeholder="VD: tenses, present-simple"
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
            </div>
            <button type="submit"
                    class="primary-gradient text-white px-6 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2">
                <span class="material-symbols-outlined text-base">filter_alt</span> Lọc
            </button>
        </form>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Chủ đề</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Slug</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Danh mục</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Sort</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Bài học</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (topics == null || topics.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có chủ đề ngữ pháp nào. Thêm chủ đề hoặc import JSON.
                        </td>
                    </tr>
                    <% } else {
                        for (AdminGrammarTopicRow t : topics) {
                            String detailUrl = request.getContextPath() + "/admin/grammar/topics/" + t.id();
                            String updateUrl = request.getContextPath() + "/admin/grammar/topics/" + t.id() + "/update";
                            String deleteUrl = request.getContextPath() + "/admin/grammar/topics/" + t.id() + "/delete";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <a href="<%= detailUrl %>" class="text-sm font-bold text-indigo-950 hover:underline"><%= t.title() %></a>
                        </td>
                        <td class="px-6 py-5">
                            <span class="text-xs font-mono text-slate-500"><%= t.slug() %></span>
                        </td>
                        <td class="px-6 py-5">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-700 text-xs font-bold rounded-lg"><%= t.category() %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 bg-slate-100 text-slate-700 text-xs font-black rounded-xl"><%= t.level() %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-semibold text-slate-600"><%= t.sortOrder() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-bold"><%= t.lessonCount() %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <a href="<%= detailUrl %>"
                               class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-base">menu_book</span> Bài học
                            </a>
                            <button type="button"
                                    class="topic-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= t.id() %>"
                                    data-slug="<%= t.slug() %>"
                                    data-category="<%= t.category() %>"
                                    data-level="<%= t.level() %>"
                                    data-title="<%= t.title() %>"
                                    data-sort="<%= t.sortOrder() %>"
                                    data-update-url="<%= updateUrl %>">
                                <span class="material-symbols-outlined text-base">edit</span> Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa chủ đề này? Toàn bộ bài học và bài tập bên trong cũng sẽ bị xóa.')">
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

    <!-- Create topic modal -->
    <div id="topicCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md topic-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Grammar</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm chủ đề ngữ pháp</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface topic-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/grammar/topics">
                <%@ include file="grammar-topic-form-fields.jspf" %>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl topic-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Tạo chủ đề
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit topic modal -->
    <div id="topicEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md topic-edit-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Grammar</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa chủ đề</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface topic-edit-modal-close">close</button>
            </div>
            <form id="topicEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Slug</label>
                    <input type="text" name="slug" id="editSlug" required pattern="[a-z0-9][a-z0-9_\-]*"
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Danh mục</label>
                        <input type="text" name="category" id="editCategory" required
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="level" id="editLevel" required class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="A1">A1</option><option value="A2">A2</option>
                            <option value="B1">B1</option><option value="B2">B2</option>
                            <option value="C1">C1</option><option value="C2">C2</option>
                        </select>
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tiêu đề</label>
                    <input type="text" name="title" id="editTitle" required
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Sort order</label>
                    <input type="number" name="sortOrderRaw" id="editSort"
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl topic-edit-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">Lưu</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Import JSON modal -->
    <div id="importModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md import-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Bulk import</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Import JSON Grammar</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface import-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/grammar/import">
                <div class="text-xs text-slate-500 leading-relaxed bg-slate-50 p-3 rounded-xl">
                    Payload có thể là mảng <code>[ {topic}, ... ]</code> hoặc object <code>{ "topics": [ ... ] }</code>.
                    Mỗi topic gồm <code>slug, category, level, title, sortOrder?, lessons[]</code>.
                    Mỗi lesson gồm <code>sourceId, title, sortOrder?, explanationVi?, whenToUseVi?, tipsVi?, formulas?, keyWords?, examples?, commonMistakes?, exercises[]</code>.
                    Mỗi exercise gồm <code>exerciseOrder?, exerciseType?, content</code> (content là object JSON).
                    Topic/Lesson đã tồn tại (theo slug / sourceId) sẽ được bỏ qua, không ghi đè.
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">JSON payload</label>
                    <textarea name="jsonPayload" rows="14" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"
                              placeholder='{"topics":[{"slug":"tenses-a1","category":"tenses","level":"A1","title":"Tenses A1","lessons":[]}]}'></textarea>
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl import-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">Import</button>
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
        bindModal("#openTopicModal", "topicCreateModal", ".topic-modal-close", ".topic-modal-backdrop");
        bindModal("#openImportModal", "importModal", ".import-modal-close", ".import-modal-backdrop");
        var editCtrl = bindModal(null, "topicEditModal", ".topic-edit-modal-close", ".topic-edit-modal-backdrop");
        document.querySelectorAll(".topic-edit-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("topicEditForm").action = btn.dataset.updateUrl;
                document.getElementById("editSlug").value = btn.dataset.slug || "";
                document.getElementById("editCategory").value = btn.dataset.category || "";
                document.getElementById("editLevel").value = (btn.dataset.level || "A1").toUpperCase();
                document.getElementById("editTitle").value = btn.dataset.title || "";
                document.getElementById("editSort").value = btn.dataset.sort || "";
                if (editCtrl) editCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
