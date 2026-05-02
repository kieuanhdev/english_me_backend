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
    %>

    <div class="p-8 space-y-8">
        <div class="flex justify-between items-end">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Quan ly nguoi dung</h1>
                <p class="text-slate-500 font-medium">Theo doi va quan ly <%= totalUsers %> hoc vien trong he thong.</p>
            </div>
            <button class="primary-gradient text-white px-6 py-3 rounded-2xl font-bold flex items-center gap-2">
                <span class="material-symbols-outlined text-xl">person_add</span>
                Them nguoi dung
            </button>
        </div>

        <section class="bg-surface-container-low p-6 rounded-[2rem] space-y-6">
            <div class="flex flex-wrap items-center gap-4">
                <div class="flex-1 min-w-[220px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Trinh do CEFR</label>
                    <select class="mt-1.5 w-full bg-white border-0 rounded-xl px-4 py-3 text-sm font-semibold text-slate-700">
                        <option>Tat ca trinh do</option>
                        <option>A1 - Beginner</option>
                        <option>A2 - Elementary</option>
                        <option>B1 - Intermediate</option>
                        <option>B2 - Upper Intermediate</option>
                        <option>C1 - Advanced</option>
                    </select>
                </div>
                <div class="flex-1 min-w-[220px]">
                    <label class="text-xs font-bold text-slate-500 uppercase px-1">Trang thai</label>
                    <div class="mt-1.5 flex bg-white p-1 rounded-xl">
                        <button class="flex-1 py-2 text-xs font-bold bg-indigo-50 text-indigo-900 rounded-lg">Tat ca</button>
                        <button class="flex-1 py-2 text-xs font-bold text-slate-500 rounded-lg">Hoat dong</button>
                        <button class="flex-1 py-2 text-xs font-bold text-slate-500 rounded-lg">Da khoa</button>
                    </div>
                </div>
            </div>
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
    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
