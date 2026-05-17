<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AdminBannerRow" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
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
        List<AdminBannerRow> rows = (List<AdminBannerRow>) request.getAttribute("rows");
        int total = rows == null ? 0 : rows.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter fmtIso = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        DateTimeFormatter fmtDisplay = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Home Banners</h1>
                <p class="text-slate-500 font-medium">Quản lý banner hiển thị trên Home — <%= total %> banner.</p>
            </div>
            <div class="flex gap-3 text-sm">
                <a href="${pageContext.request.contextPath}/admin/home-content/word-of-day"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Word of Day</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/recommendations"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold hover:bg-slate-200">Recommendations</a>
                <a href="${pageContext.request.contextPath}/admin/home-content/banners"
                   class="px-4 py-2 rounded-xl bg-indigo-50 text-primary font-bold">Banners</a>
            </div>
        </div>

        <!-- Form tạo banner -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6">
            <h2 class="text-lg font-bold text-indigo-950 mb-4">Tạo banner mới</h2>
            <form method="post" action="${pageContext.request.contextPath}/admin/home-content/banners"
                  class="grid grid-cols-1 md:grid-cols-4 gap-3">
                <input type="text" name="title" placeholder="Tiêu đề" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="text" name="imageUrl" placeholder="URL ảnh (https://... hoặc /uploads/...)" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="text" name="actionUrl" placeholder="URL hành động (tùy chọn)"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm md:col-span-2"/>
                <input type="datetime-local" name="startAt" required
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <input type="datetime-local" name="endAt"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <input type="number" name="sortOrder" placeholder="Thứ tự" value="0" min="0"
                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm"/>
                <label class="flex items-center gap-2 text-sm font-semibold text-slate-600">
                    <input type="checkbox" name="isActive" value="true" checked
                           class="rounded text-primary"/> Active
                </label>
                <button type="submit"
                        class="primary-gradient text-white px-6 py-2 rounded-xl font-bold md:col-span-2">
                    Tạo banner
                </button>
            </form>
        </div>

        <!-- Bảng -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Ảnh</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Action URL</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Bắt đầu</th>
                        <th class="px-4 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Kết thúc</th>
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
                            Chưa có banner nào.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (AdminBannerRow b : rows) {
                                String updateUrl = request.getContextPath() + "/admin/home-content/banners/" + b.id() + "/update";
                                String deleteUrl = request.getContextPath() + "/admin/home-content/banners/" + b.id() + "/delete";
                                String uploadUrl = request.getContextPath() + "/admin/home-content/banners/" + b.id() + "/image";
                                String img = b.imageUrl();
                                String imgSrc = img == null ? "" : (img.startsWith("http") ? img : request.getContextPath() + img);
                                String startVal = b.startAt() == null ? "" : b.startAt().format(fmtIso);
                                String endVal = b.endAt() == null ? "" : b.endAt().format(fmtIso);
                    %>
                    <tr class="hover:bg-white transition-all duration-300">
                        <form method="post" action="<%= updateUrl %>" class="contents">
                            <td class="px-4 py-3">
                                <% if (img != null && !img.isBlank()) { %>
                                    <img src="<%= imgSrc %>" alt="banner" class="w-24 h-12 object-cover rounded-lg"/>
                                <% } else { %>
                                    <div class="w-24 h-12 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400">
                                        <span class="material-symbols-outlined text-base">image</span>
                                    </div>
                                <% } %>
                            </td>
                            <td class="px-4 py-3">
                                <input type="text" name="title" value="<%= b.title() == null ? "" : b.title() %>" required
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-48"/>
                                <input type="hidden" name="imageUrl" value="<%= b.imageUrl() == null ? "" : b.imageUrl() %>"/>
                            </td>
                            <td class="px-4 py-3">
                                <input type="text" name="actionUrl" value="<%= b.actionUrl() == null ? "" : b.actionUrl() %>"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-44"/>
                            </td>
                            <td class="px-4 py-3">
                                <input type="datetime-local" name="startAt" value="<%= startVal %>" required
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm"/>
                                <p class="text-[11px] text-slate-400 mt-1">
                                    <%= b.startAt() == null ? "" : b.startAt().format(fmtDisplay) %>
                                </p>
                            </td>
                            <td class="px-4 py-3">
                                <input type="datetime-local" name="endAt" value="<%= endVal %>"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm"/>
                            </td>
                            <td class="px-4 py-3 text-center">
                                <input type="number" name="sortOrder" value="<%= b.sortOrder() == null ? 0 : b.sortOrder() %>" min="0"
                                       class="rounded-lg border border-slate-200 px-2 py-1.5 text-sm w-16 text-center"/>
                            </td>
                            <td class="px-4 py-3 text-center">
                                <input type="checkbox" name="isActive" value="true"
                                       <%= Boolean.TRUE.equals(b.isActive()) ? "checked" : "" %>
                                       class="rounded text-primary"/>
                            </td>
                            <td class="px-4 py-3 text-right space-x-1">
                                <button type="submit"
                                        class="px-3 py-1.5 rounded-lg bg-indigo-50 text-primary text-xs font-bold hover:bg-indigo-100">
                                    Lưu
                                </button>
                        </form>
                                <form method="post" action="<%= uploadUrl %>" enctype="multipart/form-data" class="inline">
                                    <label class="px-3 py-1.5 rounded-lg bg-amber-50 text-amber-700 text-xs font-bold hover:bg-amber-100 cursor-pointer">
                                        Upload
                                        <input type="file" name="image" accept="image/*" class="hidden"
                                               onchange="this.form.submit()"/>
                                    </label>
                                </form>
                                <form method="post" action="<%= deleteUrl %>"
                                      onsubmit="return confirm('Xóa banner này?');" class="inline">
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
