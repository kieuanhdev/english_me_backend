<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.DeskResponse" %>
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
        List<DeskResponse> desks = (List<DeskResponse>) request.getAttribute("desks");
        int n = desks == null ? 0 : desks.size();
        DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quản lý Desk (CEFR)</h1>
                <p class="text-slate-500 font-medium">Bộ thẻ theo trình độ — <%= n %> desk trong hệ thống.</p>
            </div>
            <button type="button" id="openDeskModal"
                    class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2 shadow-lg shadow-primary/20">
                <span class="material-symbols-outlined text-xl">add_circle</span>
                Thêm desk
            </button>
        </div>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tiêu đề</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Thứ tự</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Flashcard</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Tạo lúc</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (desks == null || desks.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="6" class="px-8 py-12 text-center text-slate-500 font-semibold">
                            Chưa có desk nào. Thêm desk mới hoặc chạy migration + import từ JSON.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (DeskResponse d : desks) {
                                String created = d.getCreatedAt() != null ? d.getCreatedAt().format(df) : "—";
                                String detailUrl = request.getContextPath() + "/admin/desks/" + d.getId();
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <span class="inline-flex items-center px-3 py-1.5 bg-indigo-50 text-indigo-800 text-sm font-black rounded-xl"><%= d.getCefrLevel() %></span>
                        </td>
                        <td class="px-6 py-5 text-sm font-bold text-indigo-950"><%= d.getTitle() %></td>
                        <td class="px-6 py-5 text-center text-sm font-semibold text-slate-600"><%= d.getSortOrder() %></td>
                        <td class="px-6 py-5 text-center">
                            <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-700 text-xs font-bold"><%= d.getFlashcardCount() %></span>
                        </td>
                        <td class="px-6 py-5 text-xs font-medium text-slate-500"><%= created %></td>
                        <td class="px-6 py-5 text-right">
                            <a href="<%= detailUrl %>"
                               class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-bold bg-primary text-white hover:opacity-90 transition-opacity">
                                <span class="material-symbols-outlined text-base">style</span>
                                Thẻ &amp; thêm từ
                            </a>
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

    <div id="deskCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div id="deskCreateBackdrop" class="absolute inset-0 bg-slate-900/40 backdrop-blur-md"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4 flex items-start justify-between gap-4">
                <div>
                    <span class="text-xs font-bold text-primary bg-indigo-50 px-3 py-1 rounded-full uppercase tracking-tighter">Vocabulary</span>
                    <h2 class="text-2xl font-headline font-black text-primary mt-3 leading-tight">Thêm desk CEFR</h2>
                    <p class="text-slate-500 text-sm mt-1">Mỗi mức CEFR chỉ có một desk (duy nhất).</p>
                </div>
                <button type="button" id="closeDeskModalIcon" class="material-symbols-outlined text-slate-400 hover:text-on-surface">close</button>
            </div>
            <form class="p-8 pt-2 space-y-5" method="post" action="${pageContext.request.contextPath}/admin/desks">
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Mức CEFR</label>
                    <select name="cefrLevel" required
                            class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        <option value="" disabled selected>Chọn mức</option>
                        <option value="A1">A1</option>
                        <option value="A2">A2</option>
                        <option value="B1">B1</option>
                        <option value="B2">B2</option>
                        <option value="C1">C1</option>
                        <option value="C2">C2</option>
                    </select>
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tiêu đề (tùy chọn)</label>
                    <input type="text" name="title" placeholder="VD: Desk B2 — Upper Intermediate"
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="space-y-2">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Thứ tự hiển thị (tùy chọn)</label>
                    <input type="number" name="sortOrderRaw" placeholder="Để trống = tự động (max + 1)"
                           class="mt-1 w-full bg-surface-container-low border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="flex justify-end gap-3 pt-4">
                    <button type="button" id="closeDeskModalButton"
                            class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl transition-colors">Hủy</button>
                    <button type="submit"
                            class="primary-gradient text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20">
                        Tạo desk
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
<script>
    (function () {
        var openBtn = document.getElementById("openDeskModal");
        var modal = document.getElementById("deskCreateModal");
        var backdrop = document.getElementById("deskCreateBackdrop");
        var closeIcon = document.getElementById("closeDeskModalIcon");
        var closeButton = document.getElementById("closeDeskModalButton");
        if (!openBtn || !modal) return;
        function openModal() {
            modal.classList.remove("hidden");
            modal.classList.add("flex");
        }
        function closeModal() {
            modal.classList.remove("flex");
            modal.classList.add("hidden");
        }
        openBtn.addEventListener("click", openModal);
        if (backdrop) backdrop.addEventListener("click", closeModal);
        if (closeIcon) closeIcon.addEventListener("click", closeModal);
        if (closeButton) closeButton.addEventListener("click", closeModal);
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && modal.classList.contains("flex")) closeModal();
        });
    })();
</script>
</body>
</html>
