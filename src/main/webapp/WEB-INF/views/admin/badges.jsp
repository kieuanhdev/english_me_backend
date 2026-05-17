<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminBadgeRow" %>
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
        List<AdminBadgeRow> badges = (List<AdminBadgeRow>) request.getAttribute("badges");
        int total = badges == null ? 0 : badges.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");

        String[] conditionTypes = new String[]{
                "streak_7", "streak_30", "streak_custom",
                "xp_1000", "xp_5000", "xp_custom",
                "first_lesson", "grammar_10", "pronunciation_50"
        };
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Badge Management</h1>
                <p class="text-slate-500 font-medium">Quản lý huy hiệu và điều kiện đạt — <%= total %> badge.</p>
            </div>
            <div class="flex gap-2">
                <button type="button" id="openCreateBadge"
                        class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                    <span class="material-symbols-outlined text-xl">add_circle</span>
                    Thêm badge
                </button>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Icon</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tên</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Mô tả</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Điều kiện</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Value</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Trạng thái</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Đã đạt</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (badges == null || badges.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có badge nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminBadgeRow b : badges) {
                                String updateUrl = request.getContextPath() + "/admin/badges/" + b.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/badges/" + b.id() + "/delete";
                                String iconUrl = b.iconUrl();
                                String usersUrl = request.getContextPath() + "/admin/badges/" + b.id() + "/users";
                                String reevalUrl = request.getContextPath() + "/admin/badges/" + b.id() + "/reevaluate";
                                String iconUploadUrl = request.getContextPath() + "/admin/badges/" + b.id() + "/icon";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5">
                            <% if (iconUrl != null && !iconUrl.isBlank()) { %>
                                <img src="<%= iconUrl.startsWith("http") ? iconUrl : request.getContextPath() + iconUrl %>"
                                     class="w-10 h-10 rounded-xl object-cover" alt="icon"/>
                            <% } else { %>
                                <div class="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400">
                                    <span class="material-symbols-outlined">emoji_events</span>
                                </div>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= b.name() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600 max-w-md truncate"><%= b.description() == null ? "—" : b.description() %></td>
                        <td class="px-6 py-5 text-xs font-semibold text-slate-700">
                            <span class="inline-flex px-3 py-1 bg-indigo-50 text-indigo-800 rounded-xl"><%= b.conditionType() %></span>
                        </td>
                        <td class="px-6 py-5 text-center text-sm font-bold text-slate-600"><%= b.conditionValue() == null ? "—" : b.conditionValue() %></td>
                        <td class="px-6 py-5 text-center">
                            <% if (Boolean.TRUE.equals(b.isActive())) { %>
                                <span class="inline-flex px-3 py-1 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-xl">Active</span>
                            <% } else { %>
                                <span class="inline-flex px-3 py-1 bg-slate-100 text-slate-600 text-xs font-bold rounded-xl">Inactive</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-5 text-center">
                            <a href="<%= usersUrl %>" class="inline-flex px-3 py-1 bg-amber-50 text-amber-700 text-xs font-black rounded-xl hover:bg-amber-100">
                                <%= b.awardedCount() %> user
                            </a>
                        </td>
                        <td class="px-6 py-5 text-right whitespace-nowrap space-x-1">
                            <button type="button"
                                    class="badge-edit-btn inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-slate-100 text-slate-700 hover:bg-slate-200"
                                    data-id="<%= b.id() %>"
                                    data-name='<%= b.name().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-description='<%= b.description() == null ? "" : b.description().replace("'", "&#39;").replace("<", "&lt;") %>'
                                    data-icon='<%= iconUrl == null ? "" : iconUrl %>'
                                    data-condition='<%= b.conditionType() %>'
                                    data-value='<%= b.conditionValue() == null ? "" : b.conditionValue() %>'
                                    data-active='<%= Boolean.TRUE.equals(b.isActive()) ? "true" : "false" %>'
                                    data-update-url="<%= updateUrl %>"
                                    data-upload-url="<%= iconUploadUrl %>">
                                <span class="material-symbols-outlined text-base">edit</span>
                                Sửa
                            </button>
                            <form method="post" action="<%= reevalUrl %>" class="inline">
                                <button type="submit"
                                        class="inline-flex items-center gap-1 px-3 py-2 rounded-xl text-xs font-bold bg-indigo-50 text-indigo-700 hover:bg-indigo-100">
                                    <span class="material-symbols-outlined text-base">refresh</span>
                                    Quét
                                </button>
                            </form>
                            <form method="post" action="<%= deleteUrl %>" class="inline"
                                  onsubmit="return confirm('Xóa badge này? Toàn bộ user_badge liên quan cũng sẽ bị xóa.')">
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
    <div id="badgeCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md badge-create-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Badge</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm badge</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface badge-create-close">close</button>
            </div>
            <form class="p-8 pt-2 space-y-4" method="post" action="${pageContext.request.contextPath}/admin/badges">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tên</label>
                    <input type="text" name="name" required
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Mô tả</label>
                    <textarea name="description" rows="2"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Condition Type</label>
                        <select name="conditionType" required
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <% for (String ct : conditionTypes) { %>
                                <option value="<%= ct %>"><%= ct %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Condition Value (numeric)</label>
                        <input type="number" name="conditionValue" min="0"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Icon URL (hoặc upload sau khi tạo)</label>
                    <input type="text" name="iconUrl" placeholder="https://… hoặc /uploads/badges/…"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <label class="flex items-center gap-3 text-sm font-semibold text-slate-700">
                    <input type="checkbox" name="isActive" value="true" checked
                           class="w-4 h-4 accent-indigo-600">
                    Kích hoạt badge
                </label>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" class="px-5 py-3 rounded-2xl font-bold text-sm bg-slate-100 text-slate-700 badge-create-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold text-sm">
                        Tạo badge
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit modal -->
    <div id="badgeEditModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div class="absolute inset-0 bg-slate-900/40 backdrop-blur-md badge-edit-backdrop"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-2xl shadow-2xl">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Badge</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Sửa badge</h2>
                </div>
                <button type="button" class="material-symbols-outlined text-slate-400 hover:text-on-surface badge-edit-close">close</button>
            </div>
            <form id="badgeEditForm" class="p-8 pt-2 space-y-4" method="post" action="">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tên</label>
                    <input type="text" name="name" required id="edit_name"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Mô tả</label>
                    <textarea name="description" rows="2" id="edit_description"
                              class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700"></textarea>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Condition Type</label>
                        <select name="conditionType" required id="edit_conditionType"
                                class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                            <% for (String ct : conditionTypes) { %>
                                <option value="<%= ct %>"><%= ct %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-slate-500 uppercase px-1">Condition Value</label>
                        <input type="number" name="conditionValue" min="0" id="edit_conditionValue"
                               class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                    </div>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Icon URL</label>
                    <input type="text" name="iconUrl" id="edit_iconUrl"
                           class="w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <label class="flex items-center gap-3 text-sm font-semibold text-slate-700">
                    <input type="checkbox" name="isActive" value="true" id="edit_isActive"
                           class="w-4 h-4 accent-indigo-600">
                    Kích hoạt badge
                </label>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" class="px-5 py-3 rounded-2xl font-bold text-sm bg-slate-100 text-slate-700 badge-edit-close">Hủy</button>
                    <button type="submit" class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold text-sm">
                        Lưu thay đổi
                    </button>
                </div>
            </form>

            <div class="px-8 pb-8">
                <hr class="my-4 border-slate-200">
                <p class="text-xs font-bold text-slate-500 uppercase mb-2">Upload icon (png/jpg/svg/webp, &lt;= 1MB)</p>
                <form id="badgeIconForm" method="post" action="" enctype="multipart/form-data" class="flex items-center gap-3">
                    <input type="file" name="icon" accept=".png,.jpg,.jpeg,.svg,.webp" required
                           class="text-sm font-semibold">
                    <button type="submit" class="bg-slate-100 text-slate-700 px-5 py-2.5 rounded-xl font-bold text-sm">
                        Upload icon
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        (function () {
            function show(id) { document.getElementById(id).classList.remove('hidden'); document.getElementById(id).classList.add('flex'); }
            function hide(id) { document.getElementById(id).classList.add('hidden'); document.getElementById(id).classList.remove('flex'); }

            document.getElementById('openCreateBadge').addEventListener('click', function () { show('badgeCreateModal'); });
            document.querySelectorAll('.badge-create-close, .badge-create-backdrop').forEach(function (el) {
                el.addEventListener('click', function () { hide('badgeCreateModal'); });
            });
            document.querySelectorAll('.badge-edit-close, .badge-edit-backdrop').forEach(function (el) {
                el.addEventListener('click', function () { hide('badgeEditModal'); });
            });

            document.querySelectorAll('.badge-edit-btn').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    document.getElementById('badgeEditForm').action = btn.dataset.updateUrl;
                    document.getElementById('badgeIconForm').action = btn.dataset.uploadUrl;
                    document.getElementById('edit_name').value = btn.dataset.name || '';
                    document.getElementById('edit_description').value = btn.dataset.description || '';
                    document.getElementById('edit_iconUrl').value = btn.dataset.icon || '';
                    document.getElementById('edit_conditionType').value = btn.dataset.condition || '';
                    document.getElementById('edit_conditionValue').value = btn.dataset.value || '';
                    document.getElementById('edit_isActive').checked = btn.dataset.active === 'true';
                    show('badgeEditModal');
                });
            });
        })();
    </script>
</main>
<%@ include file="layout/footer.jspf" %>
</body>
</html>
