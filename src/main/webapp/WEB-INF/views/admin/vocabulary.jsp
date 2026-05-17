<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminVocabularyTopicRow" %>
<%@ page import="java.util.List" %>
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
        @SuppressWarnings("unchecked")
        List<AdminVocabularyTopicRow> topics = (List<AdminVocabularyTopicRow>) request.getAttribute("topics");
        int total = topics == null ? 0 : topics.size();
        String selectedLevel = (String) request.getAttribute("selectedLevel");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedLevel == null) selectedLevel = "";
        if (selectedKeyword == null) selectedKeyword = "";
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
    %>

    <div class="p-8 space-y-8">
        <% if (successMessage != null) { %>
        <div class="rounded-2xl bg-emerald-50 text-emerald-800 px-5 py-3 text-sm font-semibold border border-emerald-100">
            <%= successMessage %>
        </div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold border border-rose-100">
            <%= errorMessage %>
        </div>
        <% } %>

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quản lý từ vựng</h1>
                <p class="text-slate-500 font-medium">Chủ đề từ vựng theo CEFR — <%= total %> chủ đề trong hệ thống.</p>
            </div>
            <button type="button" id="openTopicModal"
                    class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                <span class="material-symbols-outlined text-xl">add_circle</span>
                Thêm chủ đề
            </button>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/vocabulary"
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
                <label class="text-xs font-bold text-slate-500 uppercase">Tìm theo tên</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       placeholder="VD: Greetings, Du lịch"
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
            </div>
            <button type="submit"
                    class="primary-gradient text-white px-6 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2">
                <span class="material-symbols-outlined text-base">filter_alt</span>
                Lọc
            </button>
        </form>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Icon</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tên</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">EN</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Màu</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Sort</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Từ</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (topics == null || topics.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có chủ đề nào. Thêm chủ đề hoặc điều chỉnh bộ lọc.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminVocabularyTopicRow t : topics) {
                                String icon = t.icon() == null ? "" : t.icon();
                                String color = t.colorHex() == null ? "#e5e7eb" : t.colorHex();
                                String detailUrl = request.getContextPath() + "/admin/vocabulary/topics/" + t.id();
                                String updateUrl = request.getContextPath() + "/admin/vocabulary/topics/" + t.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/vocabulary/topics/" + t.id() + "/delete";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-2xl"><%= icon %></td>
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950">
                            <a href="<%= detailUrl %>" class="hover:underline"><%= t.name() %></a>
                        </td>
                        <td class="px-6 py-5 text-sm font-semibold text-slate-600"><%= t.nameEn() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= t.level() == null ? "—" : t.level() %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-block w-6 h-6 rounded-md border border-slate-200" style="background-color: <%= color %>"></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-semibold text-slate-600"><%= t.sortOrder() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-bold"><%= t.wordCount() %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <a href="<%= detailUrl %>"
                               class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-base">menu_book</span>
                                Từ
                            </a>
                            <button type="button"
                                    class="topic-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= t.id() %>"
                                    data-name="<%= t.name() %>"
                                    data-name-en="<%= t.nameEn() %>"
                                    data-icon="<%= t.icon() == null ? "" : t.icon() %>"
                                    data-level="<%= t.level() == null ? "" : t.level() %>"
                                    data-color="<%= t.colorHex() == null ? "" : t.colorHex() %>"
                                    data-sort="<%= t.sortOrder() %>"
                                    data-update-url="<%= updateUrl %>">
                                <span class="material-symbols-outlined text-base">edit</span>
                                Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa chủ đề này? Toàn bộ từ trong chủ đề cũng sẽ bị xóa.')">
                                <button type="submit"
                                        class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-rose-50 text-rose-700 hover:bg-rose-100">
                                    <span class="material-symbols-outlined text-base">delete</span>
                                    Xóa
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

    <!-- Create topic modal -->
    <div id="topicCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md topic-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Vocabulary</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm chủ đề</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface topic-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/vocabulary/topics">
                <%@ include file="vocabulary-topic-form-fields.jspf" %>
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
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Vocabulary</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa chủ đề</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface topic-edit-modal-close">close</button>
            </div>
            <form id="topicEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tên (VI)</label>
                    <input type="text" name="name" id="editName" required
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tên tiếng Anh</label>
                    <input type="text" name="nameEn" id="editNameEn" required
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Icon (emoji)</label>
                        <input type="text" name="icon" id="editIcon"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="level" id="editLevel" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="">—</option>
                            <option value="A1">A1</option><option value="A2">A2</option>
                            <option value="B1">B1</option><option value="B2">B2</option>
                            <option value="C1">C1</option><option value="C2">C2</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Màu (#RRGGBB)</label>
                        <input type="text" name="colorHex" id="editColor" placeholder="#4CAF50"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Sort order</label>
                        <input type="number" name="sortOrderRaw" id="editSort"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl topic-edit-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Lưu
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
<script>
    (function () {
        function bindModal(openSelector, modalId, closeSelector, backdropSelector) {
            var openBtn = document.querySelector(openSelector);
            var modal = document.getElementById(modalId);
            if (!modal) return;
            function openModal() { modal.classList.remove("hidden"); modal.classList.add("flex"); }
            function closeModal() { modal.classList.remove("flex"); modal.classList.add("hidden"); }
            if (openBtn) openBtn.addEventListener("click", openModal);
            document.querySelectorAll(closeSelector).forEach(function (el) { el.addEventListener("click", closeModal); });
            document.querySelectorAll(backdropSelector).forEach(function (el) { el.addEventListener("click", closeModal); });
            document.addEventListener("keydown", function (e) {
                if (e.key === "Escape" && modal.classList.contains("flex")) closeModal();
            });
            return { open: openModal, close: closeModal };
        }
        bindModal("#openTopicModal", "topicCreateModal", ".topic-modal-close", ".topic-modal-backdrop");
        var editCtrl = bindModal(null, "topicEditModal", ".topic-edit-modal-close", ".topic-edit-modal-backdrop");

        document.querySelectorAll(".topic-edit-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("topicEditForm").action = btn.dataset.updateUrl;
                document.getElementById("editName").value = btn.dataset.name || "";
                document.getElementById("editNameEn").value = btn.dataset.nameEn || "";
                document.getElementById("editIcon").value = btn.dataset.icon || "";
                document.getElementById("editLevel").value = (btn.dataset.level || "").toUpperCase();
                document.getElementById("editColor").value = btn.dataset.color || "";
                document.getElementById("editSort").value = btn.dataset.sort || "";
                if (editCtrl) editCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
