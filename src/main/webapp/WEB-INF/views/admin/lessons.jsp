<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.LearningLesson" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.ZoneId" %>
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
        List<LearningLesson> lessons = (List<LearningLesson>) request.getAttribute("lessons");
        String selectedLevel = (String) request.getAttribute("selectedLevel");
        String selectedSkill = (String) request.getAttribute("selectedSkill");
        String selectedKeyword = (String) request.getAttribute("selectedKeyword");
        Integer totalCount = (Integer) request.getAttribute("totalCount");
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(ZoneId.systemDefault());

        String[] levels = {"A1", "A2", "B1", "B2", "C1", "C2"};
        String[][] skills = {
                {"listening", "Nghe"},
                {"speaking",  "Nói"},
                {"reading",   "Đọc"},
                {"writing",   "Viết"}
        };
    %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Cấu hình XP bài học</h1>
            <p class="max-w-3xl text-indigo-100">
                Chỉnh <code class="bg-white/20 px-2 py-0.5 rounded">xp_reward</code> cho từng bài học trong Learning Hub.
                Giá trị này được cộng cho user khi <strong>pass lần đầu</strong> bài học đó (idempotent — submit lại không cộng đôi).
            </p>
        </section>

        <% if (successMessage != null) { %>
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl px-6 py-4"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="bg-red-50 border border-red-200 text-red-800 rounded-2xl px-6 py-4"><%= errorMessage %></div>
        <% } %>

        <!-- Filter bar -->
        <form method="get" action="${pageContext.request.contextPath}/admin/lessons"
              class="bg-surface-container-lowest rounded-2xl p-6 grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Level</label>
                <select name="level" class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm">
                    <option value="">Tất cả</option>
                    <% for (String lv : levels) { %>
                    <option value="<%= lv %>" <%= lv.equals(selectedLevel) ? "selected" : "" %>><%= lv %></option>
                    <% } %>
                </select>
            </div>
            <div>
                <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Skill</label>
                <select name="skill" class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm">
                    <option value="">Tất cả</option>
                    <% for (String[] sk : skills) { %>
                    <option value="<%= sk[0] %>" <%= sk[0].equals(selectedSkill) ? "selected" : "" %>><%= sk[1] %> (<%= sk[0] %>)</option>
                    <% } %>
                </select>
            </div>
            <div class="md:col-span-1">
                <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Tìm theo tên hoặc id</label>
                <input type="text" name="q" value="<%= selectedKeyword == null ? "" : selectedKeyword %>"
                       placeholder="vd: Travel hoặc a2-path-02..."
                       class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300">
            </div>
            <div class="flex items-end gap-2">
                <button type="submit" class="flex-1 px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:opacity-90">Lọc</button>
                <a href="${pageContext.request.contextPath}/admin/lessons"
                   class="px-4 py-2 bg-slate-100 text-slate-700 text-sm font-semibold rounded-xl hover:bg-slate-200">Reset</a>
            </div>
        </form>

        <!-- Results summary -->
        <div class="flex items-center justify-between">
            <p class="text-sm text-slate-500">
                Tìm thấy <strong class="text-slate-800"><%= totalCount == null ? 0 : totalCount %></strong> bài học.
            </p>
        </div>

        <!-- Lessons table -->
        <div class="bg-surface-container-lowest rounded-2xl overflow-hidden">
            <% if (lessons == null || lessons.isEmpty()) { %>
            <div class="px-6 py-12 text-center text-slate-400">
                Không có bài học nào phù hợp filter.
            </div>
            <% } else { %>
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-xs uppercase tracking-widest text-slate-500">
                <tr>
                    <th class="px-4 py-3 text-left">ID</th>
                    <th class="px-4 py-3 text-left">Level</th>
                    <th class="px-4 py-3 text-left">Skill</th>
                    <th class="px-4 py-3 text-left">Title</th>
                    <th class="px-4 py-3 text-center">Duration</th>
                    <th class="px-4 py-3 text-center">XP reward</th>
                    <th class="px-4 py-3 text-center">Status</th>
                </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                <% for (LearningLesson lesson : lessons) {
                    String skillBadgeColor;
                    switch (lesson.getSkillCode()) {
                        case "listening": skillBadgeColor = "bg-blue-100 text-blue-700"; break;
                        case "speaking":  skillBadgeColor = "bg-orange-100 text-orange-700"; break;
                        case "reading":   skillBadgeColor = "bg-emerald-100 text-emerald-700"; break;
                        case "writing":   skillBadgeColor = "bg-purple-100 text-purple-700"; break;
                        default:          skillBadgeColor = "bg-slate-100 text-slate-700";
                    }
                    int currentXp = lesson.getXpReward() == null ? 0 : lesson.getXpReward();
                %>
                <tr class="hover:bg-slate-50/50">
                    <td class="px-4 py-3 font-mono text-xs text-slate-600 break-all"><%= lesson.getId() %></td>
                    <td class="px-4 py-3">
                        <span class="text-[10px] font-bold uppercase tracking-widest bg-indigo-100 text-primary px-2 py-0.5 rounded"><%= lesson.getLevelCode() %></span>
                    </td>
                    <td class="px-4 py-3">
                        <span class="text-[10px] font-bold uppercase tracking-widest <%= skillBadgeColor %> px-2 py-0.5 rounded"><%= lesson.getSkillCode() %></span>
                    </td>
                    <td class="px-4 py-3">
                        <p class="font-semibold text-slate-800"><%= lesson.getTitle() %></p>
                        <% if (lesson.getSubtitle() != null && !lesson.getSubtitle().isBlank()) { %>
                        <p class="text-xs text-slate-400 mt-0.5"><%= lesson.getSubtitle() %></p>
                        <% } %>
                    </td>
                    <td class="px-4 py-3 text-center text-slate-500"><%= lesson.getDurationMinutes() %> phút</td>
                    <td class="px-4 py-3 text-center">
                        <form method="post" action="${pageContext.request.contextPath}/admin/lessons/<%= lesson.getId() %>/xp"
                              class="flex items-center gap-2 justify-center">
                            <input type="hidden" name="level" value="<%= selectedLevel == null ? "" : selectedLevel %>">
                            <input type="hidden" name="skill" value="<%= selectedSkill == null ? "" : selectedSkill %>">
                            <input type="hidden" name="q"     value="<%= selectedKeyword == null ? "" : selectedKeyword %>">
                            <input type="number" name="xpReward" min="0" max="999" value="<%= currentXp %>"
                                   class="w-20 border border-slate-200 rounded-lg px-2 py-1 text-sm text-center focus:outline-none focus:ring-2 focus:ring-indigo-300">
                            <button type="submit"
                                    class="px-3 py-1 bg-primary text-white text-xs font-semibold rounded-lg hover:opacity-90">
                                Lưu
                            </button>
                        </form>
                    </td>
                    <td class="px-4 py-3 text-center">
                        <% if (Boolean.TRUE.equals(lesson.getIsActive())) { %>
                        <span class="text-[10px] font-bold uppercase tracking-widest bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded">active</span>
                        <% } else { %>
                        <span class="text-[10px] font-bold uppercase tracking-widest bg-slate-100 text-slate-500 px-2 py-0.5 rounded">inactive</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>

        <div class="text-xs text-slate-400 bg-slate-50 rounded-xl px-4 py-3">
            <strong>Lưu ý:</strong> Thay đổi <code>xp_reward</code> chỉ ảnh hưởng các lần pass <strong>tiếp theo</strong>.
            Các user đã pass lesson này từ trước vẫn giữ XP cũ trong <code>xp_ledger</code> (idempotent — không tự cộng bù).
        </div>
    </div>
</main>
</body>
</html>
