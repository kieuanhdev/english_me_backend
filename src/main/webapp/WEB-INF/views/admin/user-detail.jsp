<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.UserDetailDto" %>
<%@ page import="com.kiovant.englishme.entity.Badge" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
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
        UserDetailDto d = (UserDetailDto) request.getAttribute("detail");
        @SuppressWarnings("unchecked")
        List<Badge> allBadges = (List<Badge>) request.getAttribute("allBadges");
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter dt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        DateTimeFormatter da = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        // Max XP để scale biểu đồ
        long maxXp = 1L;
        if (d != null) {
            for (UserDetailDto.XpPoint p : d.xpHistory()) {
                if (p.xp() > maxXp) maxXp = p.xp();
            }
        }

        // Set ngày hoạt động cho streak calendar
        Set<String> activeDaySet = new HashSet<>();
        if (d != null) activeDaySet.addAll(d.activeDays());

        // Set badge ids đã đạt (cho dropdown award)
        Set<String> earnedBadgeIds = new HashSet<>();
        if (d != null) {
            for (UserDetailDto.BadgeRow b : d.badges()) earnedBadgeIds.add(b.badgeId().toString());
        }
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

        <% if (d == null) { %>
        <div class="rounded-2xl bg-rose-50 text-rose-800 px-5 py-3 text-sm font-semibold">Không tìm thấy người dùng.</div>
        <% } else {
            String displayName = d.fullName() != null && !d.fullName().isBlank()
                    ? d.fullName() : "Người dùng chưa cập nhật";
        %>

        <!-- Header / profile -->
        <div class="flex flex-wrap items-start justify-between gap-4">
            <div class="flex items-center gap-5">
                <% if (d.avatarUrl() != null && !d.avatarUrl().isBlank()) { %>
                    <img src="<%= d.avatarUrl() %>" alt="avatar"
                         class="w-20 h-20 rounded-3xl object-cover shadow-md"/>
                <% } else { %>
                    <div class="w-20 h-20 rounded-3xl bg-indigo-100 text-primary font-extrabold text-3xl flex items-center justify-center">
                        <%= displayName.substring(0, 1).toUpperCase() %>
                    </div>
                <% } %>
                <div class="space-y-1">
                    <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline"><%= displayName %></h1>
                    <p class="text-slate-500 text-sm font-medium"><%= d.email() %></p>
                    <p class="text-[11px] text-slate-400 font-medium">UID: <%= d.firebaseUid() %></p>
                    <div class="flex flex-wrap items-center gap-2 pt-1">
                        <span class="inline-flex items-center px-3 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl">
                            <%= d.cefrLevel() == null ? "Chưa xếp lớp" : d.cefrLevel() %>
                        </span>
                        <% if (Boolean.TRUE.equals(d.accountLocked())) { %>
                            <span class="inline-flex items-center px-3 py-1 bg-rose-50 text-rose-700 text-xs font-black rounded-xl">Đã khóa</span>
                        <% } else { %>
                            <span class="inline-flex items-center px-3 py-1 bg-emerald-50 text-emerald-700 text-xs font-black rounded-xl">Hoạt động</span>
                        <% } %>
                        <% if (Boolean.TRUE.equals(d.isOnboarded())) { %>
                            <span class="inline-flex items-center px-3 py-1 bg-slate-100 text-slate-700 text-xs font-bold rounded-xl">Đã onboard</span>
                        <% } %>
                        <% if (d.deletedAt() != null) { %>
                            <span class="inline-flex items-center px-3 py-1 bg-rose-100 text-rose-800 text-xs font-black rounded-xl">Đã xóa</span>
                        <% } %>
                    </div>
                    <p class="text-[11px] text-slate-400 font-medium pt-1">
                        Tạo: <%= d.createdAt() == null ? "—" : d.createdAt().format(dt) %>
                        · Lần học gần nhất: <%= d.lastActiveDate() == null ? "—" : d.lastActiveDate().format(da) %>
                    </p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/admin/users"
               class="bg-slate-100 text-slate-700 px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-2 hover:bg-slate-200">
                <span class="material-symbols-outlined text-lg">arrow_back</span>
                Quay lại danh sách
            </a>
        </div>

        <!-- Stats cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Total XP</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= d.totalXp() %></p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Current streak</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= d.currentStreak() %> ngày</p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Longest streak</p>
                <p class="text-3xl font-extrabold text-indigo-950 mt-2"><%= d.longestStreak() %> ngày</p>
            </div>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-black uppercase tracking-widest text-slate-400">Sessions (study/exer/test/pron)</p>
                <p class="text-2xl font-extrabold text-indigo-950 mt-2">
                    <%= d.studySessions() %> / <%= d.exerciseSessions() %> / <%= d.testSessions() %> / <%= d.pronunciationAttempts() %>
                </p>
            </div>
        </div>

        <!-- Admin actions -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-5">
            <h2 class="text-lg font-headline font-extrabold text-primary">Hành động quản trị</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Grant XP -->
                <form method="post" action="${pageContext.request.contextPath}/admin/users/<%= d.id() %>/grant-xp"
                      class="bg-surface-container-low p-5 rounded-2xl space-y-3">
                    <p class="text-xs font-black uppercase tracking-widest text-slate-500">Cấp thêm XP thủ công</p>
                    <div class="flex gap-2">
                        <input type="number" name="amount" min="1" required placeholder="VD: 100"
                               class="flex-1 bg-surface-container-lowest border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700"/>
                        <button type="submit"
                                class="primary-gradient text-white px-5 py-2.5 rounded-xl font-bold text-sm">
                            Cấp XP
                        </button>
                    </div>
                </form>

                <!-- Change level -->
                <form method="post" action="${pageContext.request.contextPath}/admin/users/<%= d.id() %>/change-level"
                      class="bg-surface-container-low p-5 rounded-2xl space-y-3">
                    <p class="text-xs font-black uppercase tracking-widest text-slate-500">Đổi CEFR level</p>
                    <div class="flex gap-2">
                        <select name="cefrLevel" required
                                class="flex-1 bg-surface-container-lowest border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                            <% for (String lv : new String[]{"A1","A2","B1","B2","C1","C2"}) { %>
                                <option value="<%= lv %>" <%= lv.equalsIgnoreCase(d.cefrLevel()) ? "selected" : "" %>><%= lv %></option>
                            <% } %>
                        </select>
                        <button type="submit"
                                class="primary-gradient text-white px-5 py-2.5 rounded-xl font-bold text-sm">
                            Đổi
                        </button>
                    </div>
                </form>

                <!-- Award badge -->
                <form method="post" action="${pageContext.request.contextPath}/admin/users/<%= d.id() %>/award-badge"
                      class="bg-surface-container-low p-5 rounded-2xl space-y-3">
                    <p class="text-xs font-black uppercase tracking-widest text-slate-500">Gắn badge thủ công</p>
                    <div class="flex gap-2">
                        <select name="badgeId" required
                                class="flex-1 bg-surface-container-lowest border-0 rounded-xl px-4 py-2.5 text-sm font-semibold text-slate-700">
                            <% if (allBadges == null || allBadges.isEmpty()) { %>
                                <option value="">— Chưa có badge nào trong hệ thống —</option>
                            <% } else {
                                   for (Badge b : allBadges) {
                                       boolean owned = earnedBadgeIds.contains(b.getId().toString());
                            %>
                                <option value="<%= b.getId() %>" <%= owned ? "disabled" : "" %>>
                                    <%= b.getName() %><%= owned ? " (đã có)" : "" %>
                                </option>
                            <%     }
                               }
                            %>
                        </select>
                        <button type="submit"
                                class="primary-gradient text-white px-5 py-2.5 rounded-xl font-bold text-sm">
                            Gắn
                        </button>
                    </div>
                </form>

                <!-- Reset progress + soft delete -->
                <div class="bg-surface-container-low p-5 rounded-2xl space-y-3">
                    <p class="text-xs font-black uppercase tracking-widest text-slate-500">Hành động nguy hiểm</p>
                    <div class="flex flex-wrap gap-2">
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/users/<%= d.id() %>/reset-progress"
                              onsubmit="return confirm('Reset toàn bộ session/badge/progress + đưa XP/streak về 0?\nDesk/flashcard sẽ được giữ nguyên.\nTiếp tục?');">
                            <button type="submit"
                                    class="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-xs font-bold bg-amber-50 text-amber-800 hover:bg-amber-100">
                                <span class="material-symbols-outlined text-base">restart_alt</span>
                                Reset progress
                            </button>
                        </form>
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/users/<%= d.id() %>/delete"
                              onsubmit="return confirm('Soft-delete tài khoản này?\nUser sẽ bị ẩn khỏi list và chặn đăng nhập sync Firebase.');">
                            <button type="submit"
                                    class="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-xs font-bold bg-rose-50 text-rose-800 hover:bg-rose-100">
                                <span class="material-symbols-outlined text-base">delete</span>
                                Xóa user (soft)
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- XP 30 ngày -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-4">
            <div>
                <h2 class="text-lg font-headline font-extrabold text-primary">Biểu đồ XP 30 ngày (từ study sessions)</h2>
                <p class="text-xs text-slate-500">Nguồn: <code>study_session.xp_earned</code> gộp theo ngày.</p>
            </div>
            <div class="overflow-x-auto">
                <div class="flex items-end gap-1 h-40 min-w-[600px]">
                    <%
                        for (UserDetailDto.XpPoint p : d.xpHistory()) {
                            int heightPct = (int) Math.max(2, Math.round(p.xp() * 100.0 / maxXp));
                    %>
                    <div class="flex-1 flex flex-col items-center gap-1" title="<%= p.date() %>: <%= p.xp() %> XP">
                        <div class="w-full rounded-t-md bg-indigo-200" style="height: <%= heightPct %>%;"></div>
                    </div>
                    <%
                        }
                    %>
                </div>
                <div class="flex justify-between text-[10px] text-slate-400 font-semibold mt-2">
                    <span><%= d.xpHistory().isEmpty() ? "" : d.xpHistory().get(0).date() %></span>
                    <span>30 ngày gần nhất</span>
                    <span><%= d.xpHistory().isEmpty() ? "" : d.xpHistory().get(d.xpHistory().size() - 1).date() %></span>
                </div>
            </div>
        </div>

        <!-- Streak calendar 90 ngày -->
        <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-4">
            <div>
                <h2 class="text-lg font-headline font-extrabold text-primary">Streak calendar 90 ngày</h2>
                <p class="text-xs text-slate-500">Ô xanh = có hoạt động study trong ngày.</p>
            </div>
            <div class="grid grid-flow-col gap-1 auto-cols-min">
                <%
                    // Hiển thị 90 ngày, theo cột tuần (7 ngày / cột)
                    LocalDate today = LocalDate.now();
                    LocalDate firstDay = today.minusDays(89);
                    // Pad cho khớp tuần
                    int weeks = (int) Math.ceil(90 / 7.0);
                    for (int w = 0; w < weeks; w++) {
                %>
                <div class="flex flex-col gap-1">
                    <%
                        for (int dow = 0; dow < 7; dow++) {
                            int dayIdx = w * 7 + dow;
                            if (dayIdx >= 90) { %>
                                <div class="w-3 h-3 rounded-sm bg-transparent"></div>
                    <%      } else {
                                LocalDate day = firstDay.plusDays(dayIdx);
                                String iso = day.toString();
                                boolean active = activeDaySet.contains(iso);
                                String cls = active ? "bg-emerald-500" : "bg-slate-100";
                    %>
                            <div class="w-3 h-3 rounded-sm <%= cls %>" title="<%= iso %><%= active ? " — có học" : "" %>"></div>
                    <%      }
                        }
                    %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Badges + Desks side-by-side -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-4">
                <h2 class="text-lg font-headline font-extrabold text-primary">Badges đã đạt (<%= d.badges().size() %>)</h2>
                <% if (d.badges().isEmpty()) { %>
                    <p class="text-sm text-slate-500 font-semibold">Chưa đạt badge nào.</p>
                <% } else { %>
                <ul class="space-y-2">
                    <% for (UserDetailDto.BadgeRow b : d.badges()) { %>
                    <li class="flex items-center gap-3 p-3 rounded-xl bg-surface-container-low">
                        <% if (b.iconUrl() != null && !b.iconUrl().isBlank()) { %>
                            <img src="<%= b.iconUrl() %>" alt="" class="w-10 h-10 rounded-xl object-cover"/>
                        <% } else { %>
                            <div class="w-10 h-10 rounded-xl bg-indigo-100 text-primary flex items-center justify-center">
                                <span class="material-symbols-outlined">workspace_premium</span>
                            </div>
                        <% } %>
                        <div class="flex-1">
                            <p class="text-sm font-bold text-indigo-950"><%= b.name() %></p>
                            <p class="text-[11px] text-slate-500"><%= b.conditionType() %> · <%= b.earnedAt() == null ? "—" : b.earnedAt().format(dt) %></p>
                        </div>
                    </li>
                    <% } %>
                </ul>
                <% } %>
            </div>

            <div class="bg-surface-container-lowest rounded-[2rem] p-6 space-y-4">
                <h2 class="text-lg font-headline font-extrabold text-primary">Desks (<%= d.desks().size() %>)</h2>
                <% if (d.desks().isEmpty()) { %>
                    <p class="text-sm text-slate-500 font-semibold">User chưa có desk nào.</p>
                <% } else { %>
                <table class="w-full text-left border-separate border-spacing-0">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-4 py-3 text-[10px] font-black uppercase tracking-widest text-slate-400">CEFR</th>
                        <th class="px-4 py-3 text-[10px] font-black uppercase tracking-widest text-slate-400">Tên desk</th>
                        <th class="px-4 py-3 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Số flashcard</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (UserDetailDto.DeskRow dk : d.desks()) { %>
                    <tr class="hover:bg-white">
                        <td class="px-4 py-3">
                            <span class="inline-flex items-center px-2.5 py-1 bg-indigo-50 text-indigo-800 text-xs font-black rounded-xl"><%= dk.cefrLevel() %></span>
                        </td>
                        <td class="px-4 py-3 text-sm font-bold text-indigo-950"><%= dk.title() %></td>
                        <td class="px-4 py-3 text-right text-sm font-bold text-slate-600"><%= dk.flashcardCount() %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>

        <!-- 50 hoạt động gần nhất -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <div class="px-6 pt-6">
                <h2 class="text-lg font-headline font-extrabold text-primary">50 hoạt động gần nhất</h2>
                <p class="text-xs text-slate-500">Gộp từ study / exercise / placement test / pronunciation.</p>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left border-separate border-spacing-0 mt-2">
                    <thead>
                    <tr class="bg-slate-100/50">
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Loại</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Tóm tắt</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400">Trạng thái</th>
                        <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-slate-400 text-right">Thời điểm</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        if (d.activities().isEmpty()) {
                    %>
                    <tr><td colspan="4" class="px-8 py-10 text-center text-slate-500 font-semibold">Chưa có hoạt động.</td></tr>
                    <%
                        } else {
                            for (UserDetailDto.ActivityRow a : d.activities()) {
                                String typeClass;
                                switch (a.type()) {
                                    case "study":         typeClass = "bg-indigo-50 text-indigo-700"; break;
                                    case "exercise":      typeClass = "bg-emerald-50 text-emerald-700"; break;
                                    case "test":          typeClass = "bg-amber-50 text-amber-700"; break;
                                    case "pronunciation": typeClass = "bg-rose-50 text-rose-700"; break;
                                    default:              typeClass = "bg-slate-100 text-slate-700";
                                }
                    %>
                    <tr class="hover:bg-white">
                        <td class="px-6 py-3">
                            <span class="inline-flex items-center px-2.5 py-1 text-xs font-black rounded-xl <%= typeClass %>"><%= a.type() %></span>
                        </td>
                        <td class="px-6 py-3 text-sm text-slate-700"><%= a.summary() %></td>
                        <td class="px-6 py-3 text-xs text-slate-500 font-semibold"><%= a.status() == null ? "—" : a.status() %></td>
                        <td class="px-6 py-3 text-right text-xs text-slate-500 font-semibold whitespace-nowrap">
                            <%= a.at() == null ? "—" : a.at().format(dt) %>
                        </td>
                    </tr>
                    <%      }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <% } %>
    </div>

    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
