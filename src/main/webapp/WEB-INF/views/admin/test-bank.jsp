<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminTestBankQuestionRow" %>
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
        List<AdminTestBankQuestionRow> questions = (List<AdminTestBankQuestionRow>) request.getAttribute("questions");
        int total = questions == null ? 0 : questions.size();
        String selectedLevel = (String) request.getAttribute("selectedLevel");
        String selectedSkill = (String) request.getAttribute("selectedSkill");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedLevel == null) selectedLevel = "";
        if (selectedSkill == null) selectedSkill = "";
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Test Bank</h1>
                <p class="text-slate-500 font-medium">Ngân hàng câu hỏi placement test (CEFR A1–C2) — <%= total %> câu hỏi.</p>
            </div>
            <div class="flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/test-bank/stats"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">analytics</span>
                    Thống kê
                </a>
                <button type="button" id="openImportModal"
                        class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">upload_file</span>
                    Import JSON
                </button>
                <a href="${pageContext.request.contextPath}/admin/test-bank/export?level=<%= selectedLevel %>&skill=<%= selectedSkill %>&q=<%= selectedKeyword %>"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">download</span>
                    Export CSV
                </a>
                <button type="button" id="openCreateModal"
                        class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-xl">add_circle</span>
                    Thêm câu hỏi
                </button>
            </div>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/test-bank"
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
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Skill</label>
                <select name="skill" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedSkill.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <% for (String sk : new String[]{"grammar","vocabulary","reading","listening"}) { %>
                        <option value="<%= sk %>" <%= sk.equalsIgnoreCase(selectedSkill) ? "selected" : "" %>><%= sk %></option>
                    <% } %>
                </select>
            </div>
            <div class="space-y-1 flex-1 min-w-[220px]">
                <label class="text-xs font-bold text-slate-500 uppercase">Tìm theo nội dung câu hỏi</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       placeholder="VD: She ___ to school..."
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
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Skill</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Câu hỏi</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đáp án</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Lượt</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đúng %</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (questions == null || questions.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có câu hỏi nào. Thêm câu hỏi hoặc điều chỉnh bộ lọc.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminTestBankQuestionRow q : questions) {
                                String updateUrl = request.getContextPath() + "/admin/test-bank/" + q.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/test-bank/" + q.id() + "/delete";
                                String accuracy = q.avgAccuracy() == null ? "—" : (q.avgAccuracy() + "%");
                                String accuracyClass = "bg-slate-100 text-slate-700";
                                if (q.avgAccuracy() != null) {
                                    if (q.avgAccuracy() < 30) accuracyClass = "bg-rose-50 text-rose-700";
                                    else if (q.avgAccuracy() > 95) accuracyClass = "bg-amber-50 text-amber-700";
                                    else accuracyClass = "bg-emerald-50 text-emerald-700";
                                }
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= q.cefrLevel() %></span>
                        </td>
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= q.skillCategory() %></td>
                        <td class="px-6 py-5 text-sm text-slate-700 max-w-md truncate"><%= q.question() %></td>
                        <td class="px-6 py-5 text-center text-sm font-semibold text-emerald-700"><%= q.correctAnswer() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= q.attemptCount() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= accuracyClass %>"><%= accuracy %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <button type="button"
                                    class="question-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= q.id() %>"
                                    data-level="<%= q.cefrLevel() %>"
                                    data-skill="<%= q.skillCategory() %>"
                                    data-question='<%= q.question().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-options='<%= q.optionsJson() == null ? "" : q.optionsJson().replace("'", "&#39;") %>'
                                    data-correct='<%= q.correctAnswer() %>'
                                    data-explanation='<%= q.explanation() == null ? "" : q.explanation().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-audio='<%= q.audioUrl() == null ? "" : q.audioUrl().replace("'", "&#39;") %>'
                                    data-passage='<%= q.passage() == null ? "" : q.passage().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-update-url="<%= updateUrl %>">
                                <span class="material-symbols-outlined text-base">edit</span>
                                Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa câu hỏi này?')">
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

    <!-- Create modal -->
    <div id="questionCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md create-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Test Bank</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm câu hỏi</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface create-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/test-bank">
                <div class="grid grid-cols-3 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="cefrLevel" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                                <option value="<%= lv %>"><%= lv %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Skill</label>
                        <select name="skillCategory" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="grammar">grammar</option>
                            <option value="vocabulary">vocabulary</option>
                            <option value="reading">reading</option>
                            <option value="listening">listening</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Đáp án đúng</label>
                        <select name="correctAnswer" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="A">A</option><option value="B">B</option>
                            <option value="C">C</option><option value="D">D</option>
                        </select>
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Câu hỏi</label>
                    <textarea name="question" rows="2" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Options (JSON object {"A":"...","B":"...","C":"...","D":"..."})</label>
                    <textarea name="optionsJson" rows="4" required
                              placeholder='{"A":"go","B":"goes","C":"going","D":"gone"}'
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Giải thích</label>
                    <textarea name="explanation" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Audio URL (cho listening)</label>
                        <input type="text" name="audioUrl"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Passage (cho reading)</label>
                        <textarea name="passage" rows="1"
                                  class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl create-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Tạo câu hỏi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit modal -->
    <div id="questionEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md edit-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Test Bank</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa câu hỏi</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface edit-modal-close">close</button>
            </div>
            <form id="questionEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="grid grid-cols-3 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="cefrLevel" id="editLevel" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                                <option value="<%= lv %>"><%= lv %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Skill</label>
                        <select name="skillCategory" id="editSkill" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="grammar">grammar</option>
                            <option value="vocabulary">vocabulary</option>
                            <option value="reading">reading</option>
                            <option value="listening">listening</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Đáp án đúng</label>
                        <select name="correctAnswer" id="editCorrect" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="A">A</option><option value="B">B</option>
                            <option value="C">C</option><option value="D">D</option>
                        </select>
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Câu hỏi</label>
                    <textarea name="question" id="editQuestion" rows="2" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Options (JSON object)</label>
                    <textarea name="optionsJson" id="editOptions" rows="4" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Giải thích</label>
                    <textarea name="explanation" id="editExplanation" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Audio URL</label>
                        <input type="text" name="audioUrl" id="editAudio"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Passage</label>
                        <textarea name="passage" id="editPassage" rows="1"
                                  class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                    </div>
                </div>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl edit-modal-close">Hủy</button>
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
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Bulk import</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Import câu hỏi từ JSON</h2>
                    <p class="text-xs text-slate-500 mt-2">
                        Hỗ trợ payload mảng <code>[{...}]</code> hoặc <code>{"questions":[...]}</code>.
                        Trường: <code>cefr_level</code>, <code>skill_category</code>, <code>question</code>,
                        <code>options</code> (object A/B/C/D), <code>correct_answer</code>, <code>explanation</code>,
                        <code>audio_url</code>, <code>passage</code>.
                    </p>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface import-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/test-bank/import">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">JSON payload</label>
                    <textarea name="jsonPayload" rows="12" required
                              placeholder='[{"cefr_level":"A1","skill_category":"grammar","question":"She ___ to school.","options":{"A":"go","B":"goes","C":"going","D":"gone"},"correct_answer":"B","explanation":"..."}]'
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"></textarea>
                </div>
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
        bindModal("#openCreateModal", "questionCreateModal", ".create-modal-close", ".create-modal-backdrop");
        bindModal("#openImportModal", "importModal", ".import-modal-close", ".import-modal-backdrop");
        var editCtrl = bindModal(null, "questionEditModal", ".edit-modal-close", ".edit-modal-backdrop");

        document.querySelectorAll(".question-edit-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("questionEditForm").action = btn.dataset.updateUrl;
                document.getElementById("editLevel").value = (btn.dataset.level || "A1").toUpperCase();
                document.getElementById("editSkill").value = (btn.dataset.skill || "grammar").toLowerCase();
                document.getElementById("editCorrect").value = (btn.dataset.correct || "A").toUpperCase();
                document.getElementById("editQuestion").value = btn.dataset.question || "";
                document.getElementById("editOptions").value = btn.dataset.options || "";
                document.getElementById("editExplanation").value = btn.dataset.explanation || "";
                document.getElementById("editAudio").value = btn.dataset.audio || "";
                document.getElementById("editPassage").value = btn.dataset.passage || "";
                if (editCtrl) editCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
