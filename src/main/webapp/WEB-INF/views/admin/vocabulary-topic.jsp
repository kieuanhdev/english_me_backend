<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminVocabularyWordRow" %>
<%@ page import="com.kiovant.englishme.entity.VocabularyTopic" %>
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
        VocabularyTopic topic = (VocabularyTopic) request.getAttribute("topic");
        @SuppressWarnings("unchecked")
        List<AdminVocabularyWordRow> words = (List<AdminVocabularyWordRow>) request.getAttribute("words");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedKeyword == null) selectedKeyword = "";
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        int dupCount = 0;
        if (words != null) {
            for (AdminVocabularyWordRow w : words) if (w.duplicate()) dupCount++;
        }
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

        <div class="flex flex-wrap items-end justify-between gap-4">
            <div class="space-y-1">
                <a href="${pageContext.request.contextPath}/admin/vocabulary" class="text-xs font-bold text-primary uppercase tracking-tighter">&larr; Quay lại danh sách chủ đề</a>
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline flex items-center gap-3">
                    <span class="text-3xl"><%= topic.getIcon() == null ? "" : topic.getIcon() %></span>
                    <%= topic.getName() %>
                    <span class="text-base font-semibold text-slate-500">(<%= topic.getNameEn() %>)</span>
                </h1>
                <p class="text-slate-500 font-medium">
                    CEFR: <%= topic.getLevel() == null ? "—" : topic.getLevel() %>
                    · Tổng từ: <%= words == null ? 0 : words.size() %>
                    <% if (dupCount > 0) { %>
                        · <span class="text-rose-600 font-bold">⚠ <%= dupCount %> từ trùng</span>
                    <% } %>
                </p>
            </div>
            <div class="flex gap-2 flex-wrap">
                <button type="button" id="openWordModal"
                        class="primary-gradient text-white px-5 py-2.5 rounded-xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-xl">add_circle</span>
                    Thêm từ
                </button>
                <button type="button" id="openImportModal"
                        class="bg-slate-100 text-slate-700 px-5 py-2.5 rounded-xl font-bold flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-xl">upload</span>
                    Import JSON
                </button>
                <a href="${pageContext.request.contextPath}/admin/vocabulary/topics/<%= topic.getId() %>/export"
                   class="bg-slate-100 text-slate-700 px-5 py-2.5 rounded-xl font-bold flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-xl">download</span>
                    Export CSV
                </a>
            </div>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/vocabulary/topics/<%= topic.getId() %>"
              class="bg-surface-container-lowest rounded-2xl p-4 flex flex-wrap items-end gap-3">
            <div class="space-y-1 flex-1 min-w-[260px]">
                <label class="text-xs font-bold text-slate-500 uppercase">Tìm từ / nghĩa</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       placeholder="VD: hello, gia đình, water"
                       class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
            </div>
            <button type="submit"
                    class="primary-gradient text-white px-6 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2">
                <span class="material-symbols-outlined text-base">search</span>
                Tìm
            </button>
        </form>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Từ</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">IPA</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">POS</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Nghĩa VI</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Audio</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (words == null || words.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có từ nào trong chủ đề này. Thêm từ mới hoặc import JSON.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminVocabularyWordRow w : words) {
                                String updateUrl = request.getContextPath() + "/admin/vocabulary/words/" + w.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/vocabulary/words/" + w.id() + "/delete";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950">
                            <%= w.word() %>
                            <% if (w.duplicate()) { %>
                                <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded-full bg-rose-50 text-rose-700 text-[10px] font-black uppercase">Trùng</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-sm font-mono text-slate-600"><%= w.pronunciation() == null ? "—" : w.pronunciation() %></td>
                        <td class="px-6 py-5 text-xs font-semibold text-slate-500"><%= w.partOfSpeech() == null ? "—" : w.partOfSpeech() %></td>
                        <td class="px-6 py-5 text-sm text-slate-700 max-w-xs truncate" title="<%= w.definitionVi() == null ? "" : w.definitionVi() %>"><%= w.definitionVi() == null ? "—" : w.definitionVi() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-2 py-0.5 bg-indigo-50 text-indigo-800 text-xs font-black rounded"><%= w.level() %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <% if (w.audioUrl() != null && !w.audioUrl().isBlank()) { %>
                                <audio controls preload="none" class="h-8" style="width: 160px;">
                                    <source src="<%= w.audioUrl() %>">
                                </audio>
                            <% } else { %>
                                <span class="text-slate-400 text-xs">—</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <button type="button"
                                    class="word-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-update-url="<%= updateUrl %>"
                                    data-word="<%= w.word() %>"
                                    data-pron="<%= w.pronunciation() == null ? "" : w.pronunciation() %>"
                                    data-pos="<%= w.partOfSpeech() == null ? "" : w.partOfSpeech() %>"
                                    data-def-vi="<%= w.definitionVi() == null ? "" : w.definitionVi() %>"
                                    data-def-en="<%= w.definitionEn() == null ? "" : w.definitionEn() %>"
                                    data-ex="<%= w.exampleSentence() == null ? "" : w.exampleSentence() %>"
                                    data-ex-vi="<%= w.exampleTranslation() == null ? "" : w.exampleTranslation() %>"
                                    data-level="<%= w.level() == null ? "" : w.level() %>"
                                    data-audio="<%= w.audioUrl() == null ? "" : w.audioUrl() %>">
                                <span class="material-symbols-outlined text-base">edit</span>
                                Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa từ này khỏi chủ đề?')">
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

    <!-- Create word modal -->
    <div id="wordCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md word-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Word</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm từ vào chủ đề</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface word-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/vocabulary/topics/<%= topic.getId() %>/words">
                <%@ include file="vocabulary-word-form-fields.jspf" %>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl word-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Thêm từ
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit word modal -->
    <div id="wordEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md word-edit-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Word</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa từ</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface word-edit-modal-close">close</button>
            </div>
            <form id="wordEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2 col-span-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Từ</label>
                        <input type="text" name="word" id="ewWord" required
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">IPA</label>
                        <input type="text" name="pronunciation" id="ewPron"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Part of speech</label>
                        <input type="text" name="partOfSpeech" id="ewPos"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Nghĩa VI</label>
                        <textarea name="definitionVi" id="ewDefVi" rows="2"
                                  class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Nghĩa EN</label>
                        <textarea name="definitionEn" id="ewDefEn" rows="2"
                                  class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Câu ví dụ</label>
                        <textarea name="exampleSentence" id="ewEx" rows="2"
                                  class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Dịch ví dụ</label>
                        <textarea name="exampleTranslation" id="ewExVi" rows="2"
                                  class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="level" id="ewLevel" required class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="A1">A1</option><option value="A2">A2</option>
                            <option value="B1">B1</option><option value="B2">B2</option>
                            <option value="C1">C1</option><option value="C2">C2</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Audio URL</label>
                        <input type="text" name="audioUrl" id="ewAudio"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl word-edit-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Lưu
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Import modal -->
    <div id="importModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md import-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Bulk import</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Import JSON</h2>
                    <p class="text-slate-500 text-sm mt-1">
                        Định dạng: mảng JSON các object có ít nhất trường <code>word</code>. Có thể dùng key snake_case hoặc camelCase.
                        Ví dụ: <code>[{"word":"hello","level":"A1","definitionVi":"xin chào"}]</code>
                    </p>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface import-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/vocabulary/topics/<%= topic.getId() %>/import">
                <textarea name="jsonPayload" rows="14" required
                          placeholder='[{"word":"hello","pronunciation":"/həˈloʊ/","level":"A1","definitionVi":"xin chào"}]'
                          class="w-full font-mono text-xs bg-surface-container-low border-0 rounded-xl px-4 py-3 text-slate-700"></textarea>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl import-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Import
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
            var openBtn = openSelector ? document.querySelector(openSelector) : null;
            var modal = document.getElementById(modalId);
            if (!modal) return null;
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
        bindModal("#openWordModal", "wordCreateModal", ".word-modal-close", ".word-modal-backdrop");
        bindModal("#openImportModal", "importModal", ".import-modal-close", ".import-modal-backdrop");
        var editCtrl = bindModal(null, "wordEditModal", ".word-edit-modal-close", ".word-edit-modal-backdrop");

        document.querySelectorAll(".word-edit-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("wordEditForm").action = btn.dataset.updateUrl;
                document.getElementById("ewWord").value = btn.dataset.word || "";
                document.getElementById("ewPron").value = btn.dataset.pron || "";
                document.getElementById("ewPos").value = btn.dataset.pos || "";
                document.getElementById("ewDefVi").value = btn.dataset.defVi || "";
                document.getElementById("ewDefEn").value = btn.dataset.defEn || "";
                document.getElementById("ewEx").value = btn.dataset.ex || "";
                document.getElementById("ewExVi").value = btn.dataset.exVi || "";
                document.getElementById("ewLevel").value = (btn.dataset.level || "").toUpperCase() || "A1";
                document.getElementById("ewAudio").value = btn.dataset.audio || "";
                if (editCtrl) editCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
