<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminPronunciationExerciseRow" %>
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
        List<AdminPronunciationExerciseRow> exercises = (List<AdminPronunciationExerciseRow>) request.getAttribute("exercises");
        int total = exercises == null ? 0 : exercises.size();
        String selectedLevel = (String) request.getAttribute("selectedLevel");
        String selectedDifficulty = (String) request.getAttribute("selectedDifficulty");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedLevel == null) selectedLevel = "";
        if (selectedDifficulty == null) selectedDifficulty = "";
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Pronunciation Exercises</h1>
                <p class="text-slate-500 font-medium">Quản lý bài tập phát âm — <%= total %> bài.</p>
            </div>
            <div class="flex gap-2">
                <a href="${pageContext.request.contextPath}/admin/pronunciation/exercises/analytics"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">analytics</span>
                    Phân tích
                </a>
                <a href="${pageContext.request.contextPath}/admin/pronunciation"
                   class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                    <span class="material-symbols-outlined text-lg">history</span>
                    Attempts
                </a>
                <button type="button" id="openCreateEx"
                        class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-xl">add_circle</span>
                    Thêm bài tập
                </button>
            </div>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/pronunciation/exercises"
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
                <label class="text-xs font-bold text-slate-500 uppercase">Difficulty</label>
                <select name="difficulty" class="bg-surface-container-low border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                    <option value="" <%= selectedDifficulty.isBlank() ? "selected" : "" %>>Tất cả</option>
                    <% for (String d : new String[]{"easy","medium","hard"}) { %>
                        <option value="<%= d %>" <%= d.equalsIgnoreCase(selectedDifficulty) ? "selected" : "" %>><%= d %></option>
                    <% } %>
                </select>
            </div>
            <div class="space-y-1 flex-1 min-w-[220px]">
                <label class="text-xs font-bold text-slate-500 uppercase">Tìm theo text</label>
                <input type="text" name="q" value="<%= selectedKeyword %>"
                       placeholder="VD: Although..."
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
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Level</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Difficulty</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Text</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Phonetic</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Audio</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Lượt</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Avg score</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (exercises == null || exercises.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có bài tập nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminPronunciationExerciseRow e : exercises) {
                                String updateUrl = request.getContextPath() + "/admin/pronunciation/exercises/" + e.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/pronunciation/exercises/" + e.id() + "/delete";
                                String uploadUrl = request.getContextPath() + "/admin/pronunciation/exercises/" + e.id() + "/audio";
                                String audioUrl = e.referenceAudioUrl();
                                String audioFull = audioUrl == null ? null
                                        : (audioUrl.startsWith("http") ? audioUrl : request.getContextPath() + audioUrl);
                                String avg = e.avgScore() == null ? "—" : e.avgScore().toString();
                                String avgClass = "bg-slate-100 text-slate-700";
                                if (e.avgScore() != null) {
                                    if (e.avgScore() < 50) avgClass = "bg-rose-50 text-rose-700";
                                    else if (e.avgScore() > 80) avgClass = "bg-emerald-50 text-emerald-700";
                                    else avgClass = "bg-amber-50 text-amber-700";
                                }
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-center">
                            <% if (e.level() != null) { %>
                                <span class="inline-flex px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= e.level() %></span>
                            <% } else { %>
                                <span class="text-xs text-slate-400">—</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-700"><%= e.difficulty() %></td>
                        <td class="px-6 py-5 text-sm font-semibold text-indigo-950 max-w-md truncate"><%= e.text() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600 font-mono"><%= e.expectedPhonetic() == null ? "—" : e.expectedPhonetic() %></td>
                        <td class="px-6 py-5 text-center">
                            <% if (audioFull != null) { %>
                                <audio src="<%= audioFull %>" controls preload="none" style="height:32px;"></audio>
                            <% } else { %>
                                <span class="text-xs text-slate-400">—</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= e.attemptCount() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center px-3 py-1 text-xs font-black rounded-xl <%= avgClass %>"><%= avg %></span>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap space-x-1">
                            <button type="button"
                                    class="exercise-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= e.id() %>"
                                    data-text='<%= e.text().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-phonetic='<%= e.expectedPhonetic() == null ? "" : e.expectedPhonetic().replace("'", "&#39;") %>'
                                    data-meaning='<%= e.meaning() == null ? "" : e.meaning().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-level='<%= e.level() == null ? "" : e.level() %>'
                                    data-difficulty='<%= e.difficulty() %>'
                                    data-audio='<%= audioUrl == null ? "" : audioUrl %>'
                                    data-tips='<%= e.tips() == null ? "" : e.tips().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-update-url="<%= updateUrl %>"
                                    data-upload-url="<%= uploadUrl %>">
                                <span class="material-symbols-outlined text-base">edit</span>
                                Sửa
                            </button>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa bài tập này?')">
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
    <div id="exerciseCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md exercise-create-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Pronunciation</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm bài tập</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface exercise-create-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/pronunciation/exercises">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Text (câu/từ cần phát âm)</label>
                    <textarea name="text" rows="2" required
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-3 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Level</label>
                        <select name="level" class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="">—</option>
                            <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                                <option value="<%= lv %>"><%= lv %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Difficulty</label>
                        <select name="difficulty" required class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="easy">easy</option>
                            <option value="medium" selected>medium</option>
                            <option value="hard">hard</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Phonetic (IPA)</label>
                        <input type="text" name="expectedPhonetic" placeholder="/ˈeksəmpl/"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700">
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Meaning</label>
                    <input type="text" name="meaning"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Reference Audio URL</label>
                    <input type="text" name="referenceAudioUrl" placeholder="https://… hoặc /uploads/pronunciation/…"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tips</label>
                    <textarea name="tips" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" class="px-5 py-3 rounded-2xl font-bold text-sm bg-slate-100 text-slate-700 exercise-create-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold text-sm">
                        Tạo bài tập
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit modal -->
    <div id="exerciseEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md exercise-edit-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Pronunciation</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa bài tập</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface exercise-edit-close">close</button>
            </div>
            <form id="exerciseEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Text</label>
                    <textarea name="text" rows="2" required id="edit_text"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-3 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Level</label>
                        <select name="level" id="edit_level" class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="">—</option>
                            <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                                <option value="<%= lv %>"><%= lv %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Difficulty</label>
                        <select name="difficulty" required id="edit_difficulty" class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <option value="easy">easy</option>
                            <option value="medium">medium</option>
                            <option value="hard">hard</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Phonetic (IPA)</label>
                        <input type="text" name="expectedPhonetic" id="edit_phonetic"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-mono text-slate-700">
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Meaning</label>
                    <input type="text" name="meaning" id="edit_meaning"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Reference Audio URL</label>
                    <input type="text" name="referenceAudioUrl" id="edit_audio"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tips</label>
                    <textarea name="tips" rows="2" id="edit_tips"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" class="px-5 py-3 rounded-2xl font-bold text-sm bg-slate-100 text-slate-700 exercise-edit-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold text-sm">
                        Lưu thay đổi
                    </button>
                </div>
            </form>

            <div class="px-8 pb-8">
                <hr class="my-4 border-slate-200">
                <p class="text-xs font-bold text-slate-500 uppercase mb-2">Upload audio mẫu (mp3/wav/ogg/m4a/webm, &lt;= 5MB)</p>
                <form id="exerciseAudioForm" method="post" action="" enctype="multipart/form-data" class="flex items-center gap-3">
                    <input type="file" name="audio" accept=".mp3,.wav,.ogg,.m4a,.webm" required
                           class="text-sm font-semibold">
                    <button type="submit" class="bg-slate-100 text-slate-700 px-5 py-2.5 rounded-xl font-bold text-sm">
                        Upload audio
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        (function () {
            function show(id) { var el = document.getElementById(id); el.classList.remove('hidden'); el.classList.add('flex'); }
            function hide(id) { var el = document.getElementById(id); el.classList.add('hidden'); el.classList.remove('flex'); }

            document.getElementById('openCreateEx').addEventListener('click', function () { show('exerciseCreateModal'); });
            document.querySelectorAll('.exercise-create-close, .exercise-create-backdrop').forEach(function (el) {
                el.addEventListener('click', function () { hide('exerciseCreateModal'); });
            });
            document.querySelectorAll('.exercise-edit-close, .exercise-edit-backdrop').forEach(function (el) {
                el.addEventListener('click', function () { hide('exerciseEditModal'); });
            });

            document.querySelectorAll('.exercise-edit-btn').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    document.getElementById('exerciseEditForm').action = btn.dataset.updateUrl;
                    document.getElementById('exerciseAudioForm').action = btn.dataset.uploadUrl;
                    document.getElementById('edit_text').value = btn.dataset.text || '';
                    document.getElementById('edit_phonetic').value = btn.dataset.phonetic || '';
                    document.getElementById('edit_meaning').value = btn.dataset.meaning || '';
                    document.getElementById('edit_level').value = btn.dataset.level || '';
                    document.getElementById('edit_difficulty').value = btn.dataset.difficulty || 'medium';
                    document.getElementById('edit_audio').value = btn.dataset.audio || '';
                    document.getElementById('edit_tips').value = btn.dataset.tips || '';
                    show('exerciseEditModal');
                });
            });
        })();
    </script>
</main>
<%@ include file="layout/footer.jspf" %>
</body>
</html>
