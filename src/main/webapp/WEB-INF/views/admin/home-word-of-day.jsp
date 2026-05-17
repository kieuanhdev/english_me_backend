<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminWordOfDayRow" %>
<%@ page import="com.kiovant.englishme.entity.VocabularyWord" %>
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
        List<AdminWordOfDayRow> rows = (List<AdminWordOfDayRow>) request.getAttribute("rows");
        @SuppressWarnings("unchecked")
        List<VocabularyWord> words = (List<VocabularyWord>) request.getAttribute("words");
        String levelFilter = (String) request.getAttribute("levelFilter");
        if (levelFilter == null) levelFilter = "";
        int total = rows == null ? 0 : rows.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        String[] levels = new String[]{"A1", "A2", "B1", "B2", "C1", "C2"};
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Word of Day</h1>
                <p class="text-slate-500 font-medium">Lên lịch từ vựng hiển thị trên Home — <%= total %> mục.</p>
            </div>
            <div class="flex gap-3 text-sm">
                <a href="${pageContext.request.contextPath}/admin/home-content/word-of-day"
                   class="px-4 py-2 rounded-xl bg-indigo-50 text-primary font-bold">Word of Day</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/recommendations"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Recommendations</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/banners"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Banners</a>
            </div>
        </div>

        <!-- Form lên lịch -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6">
            <h2 class="text-lg font-bold text-indigo-950 mb-4">Lên lịch từ mới</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin/home-content/word-of-day"
                  class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div>
                    <label class="text-xs font-bold uppercase tracking-widest text-slate-500">Ngày</label>
                    <input type="date" name="scheduledDate" required
                           class="w-full mt-1 rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                </div>
                <div>
                    <label class="text-xs font-bold uppercase tracking-widest text-slate-500">Level (tùy chọn)</label>
                    <select name="level" class="w-full mt-1 rounded-xl border border-slate-200 px-3 py-2 text-sm">
                        <option value="">— Áp dụng cho tất cả —</option>
                        <% for (String l : levels) { %>
                            <option value="<%= l %>"><%= l %></option>
                        <% } %>
                    </select>
                </div>
                <div class="md:col-span-2">
                    <label class="text-xs font-bold uppercase tracking-widest text-slate-500">Từ vựng</label>
                    <select name="wordId" required
                            class="w-full mt-1 rounded-xl border border-slate-200 px-3 py-2 text-sm">
                        <option value="">— Chọn từ —</option>
                        <%
                            if (words != null) {
                                for (VocabularyWord w : words) {
                        %>
                            <option value="<%= w.getId() %>">
                                <%= w.getWord() %>
                                <%= w.getLevel() == null ? "" : "(" + w.getLevel().toUpperCase() + ")" %>
                                — <%= w.getDefinitionVi() == null ? "" : w.getDefinitionVi() %>
                            </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="md:col-span-3">
                    <label class="text-xs font-bold uppercase tracking-widest text-slate-500">Ghi chú</label>
                    <input type="text" name="note" maxlength="500"
                           class="w-full mt-1 rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                </div>
                <div class="flex items-end">
                    <button type="submit"
                            class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold w-full">
                        Lên lịch
                    </button>
                </div>
            </form>
        </div>

        <!-- Bảng -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Ngày</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Level</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Từ</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Phát âm</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Nghĩa</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Ghi chú</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (rows == null || rows.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có Word of Day nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminWordOfDayRow r : rows) {
                                String deleteUrl = request.getContextPath() + "/admin/home-content/word-of-day/" + r.id() + "/delete";
                    %>
                    <tr class="hover:bg-white transition-all duration-300">
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= r.scheduledDate() %></td>
                        <td class="px-6 py-5 text-sm">
                            <span class="px-2 py-1 rounded-lg bg-indigo-50 text-primary text-xs font-bold">
                                <%= r.level() == null ? "ALL" : r.level() %>
                            </span>
                        </td>
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= r.word() %></td>
                        <td class="px-6 py-5 text-sm text-slate-500"><%= r.pronunciation() == null ? "—" : r.pronunciation() %></td>
                        <td class="px-6 py-5 text-sm text-slate-600 max-w-md truncate"><%= r.definitionVi() == null ? "—" : r.definitionVi() %></td>
                        <td class="px-6 py-5 text-sm text-slate-500 max-w-xs truncate"><%= r.note() == null ? "—" : r.note() %></td>
                        <td class="px-6 py-5 text-right">
                            <form method="post" action="<%= deleteUrl %>"
                                  onsubmit="return confirm('Xóa lịch này?');" class="inline">
                                <button type="submit"
                                        class="px-3 py-1.5 rounded-lg bg-rose-50 text-rose-700 text-xs font-bold hover:bg-rose-100">
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
</main>
</body>
</html>
