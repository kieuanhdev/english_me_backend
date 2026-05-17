<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminGrammarLessonDetail" %>
<%@ page import="com.kiovant.englishme.dto.AdminGrammarExerciseRow" %>
<%@ page import="java.util.List" %>
<%
    AdminGrammarLessonDetail lesson = (AdminGrammarLessonDetail) request.getAttribute("lesson");
    List<AdminGrammarExerciseRow> exercises = lesson != null ? lesson.exercises() : List.of();
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
                <span class="material-symbols-outlined text-sm">arrow_back</span> Danh sách bài học (<%= lesson.topicTitle() %>)
            </a>
        </div>

        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline"><%= lesson.title() %></h1>
                <p class="text-slate-500 font-medium">Source ID: <span class="font-mono"><%= lesson.sourceId() != null ? lesson.sourceId() : "—" %></span> &middot; Sort: <%= lesson.sortOrder() %></p>
            </div>
            <div class="flex gap-2">
                <button type="button" id="openLessonEdit"
                        class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-base">edit</span> Sửa bài học
                </button>
                <form method="post" action="${pageContext.request.contextPath}/admin/grammar/lessons/<%= lesson.id() %>/delete"
                      onsubmit="return confirm('Xóa bài học này? Bài tập đi kèm cũng sẽ bị xóa.')">
                    <button type="submit" class="bg-rose-50 text-rose-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-rose-100">
                        <span class="material-symbols-outlined text-base">delete</span> Xóa bài học
                    </button>
                </form>
            </div>
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

        <% if (lesson.formulasJson() != null) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">function</span> Công thức (JSON)
            </h2>
            <pre class="bg-slate-50 rounded-xl p-4 text-xs font-mono text-slate-700 overflow-x-auto"><%= lesson.formulasJson() %></pre>
        </section>
        <% } %>

        <% if (lesson.keyWordsJson() != null) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">vpn_key</span> Từ khóa nhận biết (JSON)
            </h2>
            <pre class="bg-slate-50 rounded-xl p-4 text-xs font-mono text-slate-700 overflow-x-auto"><%= lesson.keyWordsJson() %></pre>
        </section>
        <% } %>

        <% if (lesson.examplesJson() != null) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">format_quote</span> Ví dụ (JSON)
            </h2>
            <pre class="bg-slate-50 rounded-xl p-4 text-xs font-mono text-slate-700 overflow-x-auto"><%= lesson.examplesJson() %></pre>
        </section>
        <% } %>

        <% if (lesson.commonMistakesJson() != null) { %>
        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                <span class="material-symbols-outlined">warning</span> Lỗi thường gặp (JSON)
            </h2>
            <pre class="bg-slate-50 rounded-xl p-4 text-xs font-mono text-slate-700 overflow-x-auto"><%= lesson.commonMistakesJson() %></pre>
        </section>
        <% } %>

        <section class="bg-surface-container-low rounded-2xl p-8 space-y-4">
            <div class="flex justify-between items-center">
                <h2 class="text-lg font-headline font-black text-primary flex items-center gap-2">
                    <span class="material-symbols-outlined">quiz</span> Bài tập (<%= exercises.size() %>)
                </h2>
                <button type="button" id="openExerciseModal"
                        class="primary-gradient text-white px-5 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-base">add_circle</span> Thêm bài tập
                </button>
            </div>
            <% if (exercises.isEmpty()) { %>
            <p class="text-slate-500 text-sm">Chưa có bài tập cho bài học này.</p>
            <% } else { %>
            <div class="space-y-4">
                <% for (int i = 0; i < exercises.size(); i++) {
                    AdminGrammarExerciseRow ex = exercises.get(i);
                    String updateUrl = request.getContextPath() + "/admin/grammar/exercises/" + ex.id() + "/update";
                    String deleteUrl = request.getContextPath() + "/admin/grammar/exercises/" + ex.id() + "/delete";
                %>
                <div class="bg-white rounded-xl p-5 space-y-3">
                    <div class="flex items-center justify-between gap-2">
                        <div class="flex items-center gap-2">
                            <span class="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-indigo-100 text-primary text-xs font-bold">#<%= ex.exerciseOrder() %></span>
                            <span class="text-[10px] font-black uppercase tracking-wider text-slate-400"><%= ex.exerciseType() != null ? ex.exerciseType() : "—" %></span>
                        </div>
                        <div class="flex items-center gap-2">
                            <button type="button"
                                    class="exercise-edit-btn inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= ex.id() %>"
                                    data-order="<%= ex.exerciseOrder() %>"
                                    data-type="<%= ex.exerciseType() != null ? ex.exerciseType() : "" %>"
                                    data-content="<%= ex.contentJson() == null ? "" : ex.contentJson().replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;") %>"
                                    data-update-url="<%= updateUrl %>">
                                <span class="material-symbols-outlined text-sm">edit</span> Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa bài tập này?')">
                                <button type="submit" class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-bold bg-rose-50 text-rose-700 hover:bg-rose-100">
                                    <span class="material-symbols-outlined text-sm">delete</span> Xóa
                                </button>
                            </form>
                        </div>
                    </div>
                    <pre class="bg-slate-50 rounded-lg p-3 text-xs font-mono text-slate-700 overflow-x-auto whitespace-pre-wrap"><%= ex.contentJson() %></pre>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>

        <!-- Edit lesson modal -->
        <div id="lessonEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
            <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md lesson-edit-modal-backdrop"></div>
            <div class="relative bg-surface-container-lowest w-full max-w-3xl rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
                <div class="p-8 pb-4 flex items-start justify-between gap-4">
                    <div>
                        <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Grammar lesson</span>
                        <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa bài học</h2>
                    </div>
                    <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface lesson-edit-modal-close">close</button>
                </div>
                <form class="p-8 pt-2 space-y-4 overflow-y-auto" method="post" action="${pageContext.request.contextPath}/admin/grammar/lessons/<%= lesson.id() %>/update">
                    <div class="grid grid-cols-3 gap-3">
                        <div class="space-y-2 col-span-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Source ID</label>
                            <input type="text" name="sourceId" required maxlength="120" value="<%= lesson.sourceId() %>"
                                   class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700">
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Sort order</label>
                            <input type="number" name="sortOrderRaw" value="<%= lesson.sortOrder() %>"
                                   class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Tiêu đề</label>
                        <input type="text" name="title" required value="<%= lesson.title() %>"
                               class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Giải thích (VI)</label>
                        <textarea name="explanationVi" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm text-slate-700"><%= lesson.explanationVi() == null ? "" : lesson.explanationVi() %></textarea>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Khi nào dùng (VI)</label>
                            <textarea name="whenToUseVi" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm text-slate-700"><%= lesson.whenToUseVi() == null ? "" : lesson.whenToUseVi() %></textarea>
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Mẹo (VI)</label>
                            <textarea name="tipsVi" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm text-slate-700"><%= lesson.tipsVi() == null ? "" : lesson.tipsVi() %></textarea>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Formulas (JSON array of objects)</label>
                        <textarea name="formulasJson" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"><%= lesson.formulasJson() == null ? "" : lesson.formulasJson() %></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Key words (JSON array of strings)</label>
                        <textarea name="keyWordsJson" rows="2" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"><%= lesson.keyWordsJson() == null ? "" : lesson.keyWordsJson() %></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Examples (JSON array)</label>
                        <textarea name="examplesJson" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"><%= lesson.examplesJson() == null ? "" : lesson.examplesJson() %></textarea>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Common mistakes (JSON array)</label>
                        <textarea name="commonMistakesJson" rows="3" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"><%= lesson.commonMistakesJson() == null ? "" : lesson.commonMistakesJson() %></textarea>
                    </div>
                    <div class="flex justify-end gap-3 pt-2">
                        <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl lesson-edit-modal-close">Hủy</button>
                        <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">Lưu</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Create / edit exercise modal (shared form, action swapped) -->
        <div id="exerciseModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
            <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md exercise-modal-backdrop"></div>
            <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
                <div class="p-8 pb-4 flex items-start justify-between gap-4">
                    <div>
                        <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Exercise</span>
                        <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight" id="exerciseModalTitle">Thêm bài tập</h2>
                    </div>
                    <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface exercise-modal-close">close</button>
                </div>
                <form id="exerciseForm" class="p-8 pt-2 space-y-4 overflow-y-auto" method="post"
                      action="${pageContext.request.contextPath}/admin/grammar/lessons/<%= lesson.id() %>/exercises">
                    <input type="hidden" name="lessonId" value="<%= lesson.id() %>">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Order</label>
                            <input type="number" name="exerciseOrderRaw" id="exerciseOrder"
                                   class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-slate-500 uppercase px-1">Type</label>
                            <select name="exerciseType" id="exerciseType" class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                                <option value="">— Tự nhập —</option>
                                <option value="multiple_choice">multiple_choice</option>
                                <option value="fill_blank">fill_blank</option>
                                <option value="rearrange">rearrange</option>
                                <option value="translate">translate</option>
                                <option value="match">match</option>
                                <option value="true_false">true_false</option>
                                <option value="free_text">free_text</option>
                            </select>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Content (JSON object) <span class="text-rose-500">*</span></label>
                        <textarea name="contentJson" id="exerciseContent" rows="10" required
                                  class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-xs font-mono text-slate-700"
                                  placeholder='{"question":"She ___ here.","options":["work","works"],"answer":"works"}'></textarea>
                    </div>
                    <div class="flex justify-end gap-3 pt-2">
                        <button type="button" class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl exercise-modal-close">Hủy</button>
                        <button type="submit" class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">Lưu</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>
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
        bindModal("#openLessonEdit", "lessonEditModal", ".lesson-edit-modal-close", ".lesson-edit-modal-backdrop");

        var createExerciseUrl = document.getElementById("exerciseForm") ? document.getElementById("exerciseForm").action : "";
        var exerciseCtrl = bindModal("#openExerciseModal", "exerciseModal", ".exercise-modal-close", ".exercise-modal-backdrop");
        var openExerciseBtn = document.getElementById("openExerciseModal");
        if (openExerciseBtn) {
            openExerciseBtn.addEventListener("click", function () {
                document.getElementById("exerciseModalTitle").textContent = "Thêm bài tập";
                document.getElementById("exerciseForm").action = createExerciseUrl;
                document.getElementById("exerciseOrder").value = "";
                document.getElementById("exerciseType").value = "";
                document.getElementById("exerciseContent").value = "";
            });
        }
        document.querySelectorAll(".exercise-edit-btn").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.getElementById("exerciseModalTitle").textContent = "Sửa bài tập";
                document.getElementById("exerciseForm").action = btn.dataset.updateUrl;
                document.getElementById("exerciseOrder").value = btn.dataset.order || "";
                document.getElementById("exerciseType").value = btn.dataset.type || "";
                document.getElementById("exerciseContent").value = btn.dataset.content || "";
                if (exerciseCtrl) exerciseCtrl.open();
            });
        });
    })();
</script>
</body>
</html>
