<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.User" %>
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
        List<User> users = (List<User>) request.getAttribute("users");
        int totalUsers = users == null ? 0 : users.size();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String selectedCefr = (String) request.getAttribute("selectedCefr");
        String selectedStatus = (String) request.getAttribute("selectedStatus");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        if (selectedCefr == null) selectedCefr = "";
        if (selectedStatus == null || selectedStatus.isBlank()) selectedStatus = "all";
        if (selectedKeyword == null) selectedKeyword = "";
    %>

    <div class="p-8 space-y-8">
        <div class="flex justify-between items-end">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quan ly nguoi dung</h1>
                <p class="text-slate-500 font-medium">Theo doi va quan ly <%= totalUsers %> hoc vien trong he thong.</p>
            </div>
            <button type="button" id="openUserModal"
                    class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2">
                <span class="material-symbols-outlined text-xl">person_add</span>
                Them nguoi dung
            </button>
        </div>

        <section class="bg-surface-container-low p-6 rounded-[2rem] space-y-6">
            <form method="get" action="${pageContext.request.contextPath}/admin/users" class="flex flex-wrap items-end gap-4">
                <div class="flex-1 min-w-[220px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Trinh do CEFR</label>
                    <select name="cefr" class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        <option value="" <%= selectedCefr.isEmpty() ? "selected" : "" %>>Tat ca trinh do</option>
                        <option value="A1" <%= "A1".equalsIgnoreCase(selectedCefr) ? "selected" : "" %>>A1 - Beginner</option>
                        <option value="A2" <%= "A2".equalsIgnoreCase(selectedCefr) ? "selected" : "" %>>A2 - Elementary</option>
                        <option value="B1" <%= "B1".equalsIgnoreCase(selectedCefr) ? "selected" : "" %>>B1 - Intermediate</option>
                        <option value="B2" <%= "B2".equalsIgnoreCase(selectedCefr) ? "selected" : "" %>>B2 - Upper Intermediate</option>
                        <option value="C1" <%= "C1".equalsIgnoreCase(selectedCefr) ? "selected" : "" %>>C1 - Advanced</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[220px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Trang thai</label>
                    <select name="status" class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        <option value="all" <%= "all".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Tat ca</option>
                        <option value="active" <%= "active".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Hoat dong</option>
                        <option value="locked" <%= "locked".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Da khoa</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[240px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Tim kiem</label>
                    <input type="text" name="q" value="<%= selectedKeyword %>" placeholder="Ten, email, UID..."
                           class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                </div>
                <div class="flex items-center gap-2">
                    <button type="submit" class="primary-gradient text-white px-5 py-3 rounded-xl text-sm font-bold">
                        Loc
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="bg-white text-slate-600 px-5 py-3 rounded-xl text-sm font-bold">
                        Reset
                    </a>
                </div>
            </form>
        </section>

        <div class="bg-surface-container-low rounded-[2rem] overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-8 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Ho va ten</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Email</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Trinh do CEFR</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400 text-center">Ngay tham gia</th>
                        <th class="px-6 py-5 text-[10px] font-black uppercase tracking-widest text-slate-400">Trang thai</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (users == null || users.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="5" class="px-8 py-10 text-center text-slate-500 font-semibold">
                            Chua co nguoi dung nao trong he thong.
                        </td>
                    </tr>
                    <%
                        } else {
                            for (User user : users) {
                                String displayName = user.getFullName() != null && !user.getFullName().isBlank()
                                        ? user.getFullName() : "Nguoi dung chua cap nhat";
                                String level = user.getCefrLevel() != null ? user.getCefrLevel() : "Chua xep lop";
                                boolean active = user.getIsOnboarded() != null && user.getIsOnboarded();
                                String statusText = active ? "Hoat dong" : "Da khoa";
                                String statusClass = active
                                        ? "bg-green-50 text-green-700"
                                        : "bg-red-50 text-red-700";
                                String createdAt = user.getCreatedAt() != null ? user.getCreatedAt().format(dateFormatter) : "--/--/----";
                    %>
                    <tr class="group hover:bg-white transition-all duration-300">
                        <td class="px-8 py-5">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-2xl bg-indigo-100 text-primary font-bold flex items-center justify-center">
                                    <%= displayName.substring(0, 1).toUpperCase() %>
                                </div>
                                <div class="flex flex-col">
                                    <span class="text-sm font-bold text-indigo-950"><%= displayName %></span>
                                    <span class="text-[10px] text-slate-400 font-medium">UID: <%= user.getFirebaseUid() %></span>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-5"><span class="text-sm font-medium text-slate-600"><%= user.getEmail() %></span></td>
                        <td class="px-6 py-5">
                            <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-700 text-xs font-bold rounded-lg"><%= level %></span>
                        </td>
                        <td class="px-6 py-5 text-center"><span class="text-xs font-medium text-slate-500 italic"><%= createdAt %></span></td>
                        <td class="px-6 py-5">
                            <span class="inline-flex items-center gap-1.5 px-3 py-1 text-[10px] font-bold uppercase tracking-wider rounded-full <%= statusClass %>">
                                <span class="w-1 h-1 rounded-full bg-current"></span><%= statusText %>
                            </span>
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

    <div id="userCreateModal" class="fixed inset-0 z-[60] hidden items-center justify-center p-6">
        <div id="userCreateBackdrop" class="absolute inset-0 bg-slate-900/40 backdrop-blur-md"></div>
        <div class="relative bg-surface-container-lowest w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 pb-4">
                <div class="flex items-center justify-between mb-2">
                    <span class="text-xs font-bold text-tertiary-container bg-orange-100 px-3 py-1 rounded-full uppercase tracking-tighter">
                        System Administration
                    </span>
                    <button type="button" id="closeUserModalIcon"
                            class="material-symbols-outlined text-slate-400 hover:text-on-surface transition-colors">close</button>
                </div>
                <h2 class="text-3xl font-headline font-black text-primary leading-tight">Them nguoi dung moi</h2>
                <p class="text-on-surface-variant text-sm mt-1">
                    Register a new profile to the Scholar ecosystem with specific access credentials.
                </p>
            </div>

            <form class="p-8 pt-4 space-y-8" action="#" method="post">
                <div class="bg-surface-container-low p-6 rounded-xl space-y-5">
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-primary tracking-wide block ml-1">Ho va ten</label>
                        <input class="w-full bg-surface-container-lowest border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary/10"
                               placeholder="e.g. Nguyen Van A" type="text"/>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-primary tracking-wide block ml-1">Email</label>
                        <input class="w-full bg-surface-container-lowest border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary/10"
                               placeholder="nguyenvan@scholar.edu.vn" type="email"/>
                    </div>
                </div>

                <div class="space-y-5">
                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-primary tracking-wide block ml-1">Mat khau</label>
                            <input class="w-full bg-surface-container-high border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary/10"
                                   placeholder="••••••••" type="password"/>
                        </div>
                        <div class="space-y-2">
                            <label class="text-xs font-bold text-primary tracking-wide block ml-1">Quyen han (Role)</label>
                            <select class="w-full bg-surface-container-high border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-primary/10">
                                <option>Student</option>
                                <option>Teacher</option>
                                <option>Admin</option>
                            </select>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="text-xs font-bold text-primary tracking-wide block ml-1">Trinh do CEFR dau vao</label>
                        <div class="bg-surface-container-low p-4 rounded-xl flex items-center justify-between gap-3 flex-wrap">
                            <div class="flex gap-2 flex-wrap">
                                <button class="px-3 py-1 bg-surface-container-lowest rounded-lg text-xs font-bold text-slate-500" type="button">A1</button>
                                <button class="px-3 py-1 bg-surface-container-lowest rounded-lg text-xs font-bold text-slate-500" type="button">A2</button>
                                <button class="px-3 py-1 bg-primary text-white rounded-lg text-xs font-bold shadow-sm" type="button">B1</button>
                                <button class="px-3 py-1 bg-surface-container-lowest rounded-lg text-xs font-bold text-slate-500" type="button">B2</button>
                                <button class="px-3 py-1 bg-surface-container-lowest rounded-lg text-xs font-bold text-slate-500" type="button">C1</button>
                                <button class="px-3 py-1 bg-surface-container-lowest rounded-lg text-xs font-bold text-slate-500" type="button">C2</button>
                            </div>
                            <span class="text-[10px] text-slate-400 italic">Intermediate Proficiency</span>
                        </div>
                    </div>
                </div>

                <div class="flex items-center justify-end gap-4 pt-4">
                    <button type="button" id="closeUserModalButton"
                            class="text-slate-500 font-bold text-sm px-6 py-3 hover:bg-slate-100 rounded-xl transition-colors">Huy</button>
                    <button class="bg-gradient-to-r from-primary to-primary-container text-white px-8 py-3 rounded-2xl font-bold text-sm shadow-lg shadow-primary/20"
                            type="submit">
                        Them thanh vien
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
<script>
    (function () {
        const openBtn = document.getElementById("openUserModal");
        const modal = document.getElementById("userCreateModal");
        const backdrop = document.getElementById("userCreateBackdrop");
        const closeIcon = document.getElementById("closeUserModalIcon");
        const closeButton = document.getElementById("closeUserModalButton");

        if (!openBtn || !modal) return;

        const openModal = function () {
            modal.classList.remove("hidden");
            modal.classList.add("flex");
        };

        const closeModal = function () {
            modal.classList.remove("flex");
            modal.classList.add("hidden");
        };

        openBtn.addEventListener("click", openModal);
        if (backdrop) backdrop.addEventListener("click", closeModal);
        if (closeIcon) closeIcon.addEventListener("click", closeModal);
        if (closeButton) closeButton.addEventListener("click", closeModal);

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && modal.classList.contains("flex")) {
                closeModal();
            }
        });
    })();
</script>
</body>
</html>
