<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminExerciseQuestionRow" %>
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
        List<AdminExerciseQuestionRow> questions = (List<AdminExerciseQuestionRow>) request.getAttribute("questions");
        int total = questions == null ? 0 : questions.size();
        String selectedCategory = (String) request.getAttribute("selectedCategory");
        String selectedDifficulty = (String) request.getAttribute("selectedDifficulty");
        String selectedLevel = (String) request.getAttribute("selectedLevel");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedCategory == null) selectedCategory = "";
        if (selectedDifficulty == null) selectedDifficulty = "";
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Exercise Bank</h1>
                <p class="text-slate-500 font-medium">Ngân hàng câu hỏi exercise (multiple choice) — <%= total %> câu hỏi.</p>
            </div>
            <div class="flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/exercises/sessions"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">history</span>
                    Sessions
                </a>
                <button type="button" id="openImportModal"
                        class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">upload_file</span>
                    Import JSON
                </button>
                <a href="${pageContext.request.contextPath}/admin/exercises/export?category=<%= selectedCategory %>&difficulty=<%= selectedDifficulty %>&level=<%= selectedLevel %>&q=<%= selectedKeyword %>"
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

        <form method="get" action="${pageContext.request.contextPath}/admin/exercises"
              class="bg-surface-container-lowest rounded-2xl p-4 flex flex-wrap items-end gap-3">
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Category</label>
                <select name="category" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedCategory.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <option value="vocabulary" <%= "vocabulary".equals(selectedCategory) ? "selected" : "" %>>Vocabulary</option>
                    <option value="grammar" <%= "grammar".equals(selectedCategory) ? "selected" : "" %>>Grammar</option>
                </select>
            </div>
            <div class="space-y-1">
                <label class="text-xs font-bold text-slate-500 uppercase">Difficulty</label>
                <select name="difficulty" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedDifficulty.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <option value="easy"   <%= "easy".equals(selectedDifficulty)   ? "selected" : "" %>>Easy</option>
                    <option value="medium" <%= "medium".equals(selectedDifficulty) ? "selected" : "" %>>Medium</option>
                    <option value="hard"   <%= "hard".equals(selectedDifficulty)   ? "selected" : "" %>>Hard</option>
                </select>
            </div>
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
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Category</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Diff</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Câu hỏi</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Đáp án đúng</th>
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
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có câu hỏi nào. Thêm câu hỏi hoặc điều chỉnh bộ lọc.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminExerciseQuestionRow q : questions) {
                                String updateUrl = request.getContextPath() + "/admin/exercises/" + q.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/exercises/" + q.id() + "/delete";
                                String accuracy = q.avgAccuracy() == null ? "—" : (q.avgAccuracy() + "%");
                                String accuracyClass = "bg-slate-100 text-slate-700";
                                if (q.avgAccuracy() != null) {
                                    if (q.avgAccuracy() < 30) accuracyClass = "bg-rose-50 text-rose-700";
                                    else if (q.avgAccuracy() > 95) accuracyClass = "bg-amber-50 text-amber-700";
                                    else accuracyClass = "bg-emerald-50 text-emerald-700";
                                }
                                String difficultyClass;
                                switch (q.difficulty() == null ? "" : q.difficulty()) {
                                    case "easy":   difficultyClass = "bg-emerald-50 text-emerald-700"; break;
                                    case "medium": difficultyClass = "bg-amber-50 text-amber-700"; break;
                                    case "hard":   difficultyClass = "bg-rose-50 text-rose-700"; break;
                                    default:       difficultyClass = "bg-slate-100 text-slate-700";
                                }
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= q.category() %></td>
                        <td class="px-6 py-5">
                            <span class="inline-flex items-center px-2.5 py-1 text-xs font-black rounded-lg <%= difficultyClass %>"><%= q.difficulty() %></span>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= q.level() == null ? "—" : q.level() %></span>
                        </td>
                        <td class="px-6 py-5 text-sm text-slate-700 max-w-md truncate"><%= q.question() %></td>
                        <td class="px-6 py-5 text-sm font-semibold text-emerald-700"><%= q.correctAnswer() %></td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= q.attemptCount() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= accuracyClass %>"><%= accuracy %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap">
                            <button type="button"
                                    class="question-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= q.id() %>"
                                    data-category="<%= q.category() %>"
                                    data-difficulty="<%= q.difficulty() %>"
                                    data-level="<%= q.level() == null ? "" : q.level() %>"
                                    data-question='<%= q.question().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-options='<%= q.optionsJson() == null ? "" : q.optionsJson().replace("'", "&#39;") %>'
                                    data-correct='<%= q.correctAnswer().replace("'", "&#39;") %>'
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

    <!-- Create question modal -->
    <div id="questionCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md create-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Exercise</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm câu hỏi</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface create-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/exercises">
                <%@ include file="exercise-form-fields.jspf" %>
                <div class="flex justify-end gap-3 pt-2">
                    <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl create-modal-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Tạo câu hỏi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit question modal -->
    <div id="questionEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md edit-modal-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Exercise</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa câu hỏi</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface edit-modal-close">close</button>
            </div>
            <form id="questionEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="grid grid-cols-3 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Category</label>
                        <select name="category" id="editCategory" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="vocabulary">vocabulary</option>
                            <option value="grammar">grammar</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Difficulty</label>
                        <select name="difficulty" id="editDifficulty" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="easy">easy</option>
                            <option value="medium">medium</option>
                            <option value="hard">hard</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">CEFR</label>
                        <select name="level" id="editLevel"
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="">—</option>
                            <option value="A1">A1</option><option value="A2">A2</option>
                            <option value="B1">B1</option><option value="B2">B2</option>
                            <option value="C1">C1</option><option value="C2">C2</option>
                        </select>
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Câu hỏi</label>
                    <textarea name="question" id="editQuestion" rows="2" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Options (mảng JSON các chuỗi)</label>
                    <textarea name="optionsJson" id="editOptions" rows="3" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Đáp án đúng (phải khớp 1 option)</label>
                    <input type="text" name="correctAnswer" id="editCorrect" required
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Giải thích</label>
                    <textarea name="explanation" id="editExplanation" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Gợi ý</label>
                    <textarea name="hint" id="editHint" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
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
                        Hỗ trợ payload mảng <code>[{...}, {...}]</code> hoặc <code>{"questions":[...]}</code>.
                        Mỗi item: <code>category</code>, <code>difficulty</code>, <code>question</code>, <code>options</code> (array), <code>correctAnswer</code>, <code>explanation</code>, <code>hint</code>, <code>level</code>.
                    </p>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface import-modal-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/exercises/import">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">JSON payload</label>
                    <textarea name="jsonPayload" rows="12" required
                              placeholder='[{"category":"grammar","difficulty":"easy","level":"A1","question":"She ___ to school.","options":["go","goes","going","gone"],"correctAnswer":"goes"}]'
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
                document.getElementById("editCategory").value = btn.dataset.category || "vocabulary";
                document.getElementById("editDifficulty").value = btn.dataset.difficulty || "easy";
                document.getElementById("editLevel").value = (btn.dataset.level || "").toUpperCase();
                document.getElementById("editQuestion").value = btn.dataset.question || "";
                document.getElementById("editOptions").value = btn.dataset.options || "";
                document.getElementById("editCorrect").value = btn.dataset.correct || "";
                if (editCtrl) editCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
