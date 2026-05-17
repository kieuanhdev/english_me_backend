<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminRecommendationRow" %>
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
        List<AdminRecommendationRow> rows = (List<AdminRecommendationRow>) request.getAttribute("rows");
        int total = rows == null ? 0 : rows.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        String[] levels = new String[]{"A1", "A2", "B1", "B2", "C1", "C2"};
        String[] types = new String[]{"vocabulary", "grammar", "pronunciation", "exercise", "test"};
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Home Recommendations</h1>
                <p class="text-slate-500 font-medium">Gợi ý hiển thị trên Home theo CEFR — <%= total %> mục.</p>
            </div>
            <div class="flex gap-3 text-sm">
                <a href="${pageContext.request.contextPath}/admin/home-content/word-of-day"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Word of Day</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/recommendations"
                   class="px-4 py-2 rounded-xl bg-indigo-50 text-primary font-bold">Recommendations</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/banners"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Banners</a>
            </div>
        </div>

        <!-- Form tạo mới -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6">
            <h2 class="text-lg font-bold text-indigo-950 mb-4">Tạo recommendation</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin/home-content/recommendations"
                  class="grid grid-cols-1 md:grid-cols-6 gap-3">
                <select name="level" required class="rounded-xl border border-slate-200 px-3 py-2 text-sm">
                    <% for (String l : levels) { %>
                        <option value="<%= l %>"><%= l %></option>
                    <% } %>
                </select>
                <select name="type" required class="rounded-xl border border-slate-200 px-3 py-2 text-sm">
                    <% for (String t : types) { %>
                        <option value="<%= t %>"><%= t %></option>
                    <% } %>
                </select>
                <input type="text" name="title" placeholder="Tiêu đề" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="text" name="actionUrl" placeholder="URL hành động (vd: /api/grammar/topics)"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="text" name="description" placeholder="Mô tả"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-3"/>
                <input type="number" name="sortOrder" placeholder="Thứ tự" value="0" min="0"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <label class="flex items-center gap-2 text-sm font-semibold text-slate-600">
                    <input type="checkbox" name="isActive" value="true" checked
                           class="rounded text-primary"/> Active
                </label>
                <button type="submit" class="primary-gradient text-white px-6 py-2 rounded-xl font-bold">
                    Tạo
                </button>
            </form>
        </div>

        <!-- Bảng -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Level</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Type</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Mô tả</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Action URL</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Sort</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Active</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (rows == null || rows.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="8" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có recommendation nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminRecommendationRow r : rows) {
                                String updateUrl = request.getContextPath() + "/admin/home-content/recommendations/" + r.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/home-content/recommendations/" + r.id() + "/delete";
                    %>
                    <tr class="hover:bg-white transition-all duration-300">
                        <form method="post" action="<%= updateUrl %>" class="contents">
                            <td class="px-4 py-3">
                                <select name="level" class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm">
                                    <% for (String l : levels) { %>
                                        <option value="<%= l %>" <%= l.equalsIgnoreCase(r.level()) ? "selected" : "" %>><%= l %></option>
                                    <% } %>
                                </select>
                            </td>
                            <td class="px-4 py-3">
                                <select name="type" class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm">
                                    <% for (String t : types) { %>
                                        <option value="<%= t %>" <%= t.equalsIgnoreCase(r.type()) ? "selected" : "" %>><%= t %></option>
                                    <% } %>
                                </select>
                            </td>
                            <td class="px-4 py-3">
                                <input type="text" name="title" value="<%= r.title() == null ? "" : r.title() %>" required
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-48"/>
                            </td>
                            <td class="px-4 py-3">
                                <input type="text" name="description" value="<%= r.description() == null ? "" : r.description() %>"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-56"/>
                            </td>
                            <td class="px-4 py-3">
                                <input type="text" name="actionUrl" value="<%= r.actionUrl() == null ? "" : r.actionUrl() %>"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-48"/>
                            </td>
                            <td class="px-4 py-3 text-center">
                                <input type="number" name="sortOrder" value="<%= r.sortOrder() == null ? 0 : r.sortOrder() %>" min="0"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-16 text-center"/>
                            </td>
                            <td class="px-4 py-3 text-center">
                                <input type="checkbox" name="isActive" value="true"
                                       <%= Boolean.TRUE.equals(r.isActive()) ? "checked" : "" %>
                                       class="rounded text-primary"/>
                            </td>
                            <td class="px-4 py-3 text-right space-x-1">
                                <button type="submit"
                                        class="px-3 py-1.5 rounded-lg bg-indigo-50 text-primary text-xs font-bold hover:bg-indigo-100">
                                    Lưu
                                </button>
                        </form>
                                <form method="post" action="<%= deleteUrl %>"
                                      onsubmit="return confirm('Xóa recommendation này?');" class="inline">
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
