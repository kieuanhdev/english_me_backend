<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.XpRule" %>
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
        List<XpRule> rules = (List<XpRule>) request.getAttribute("rules");
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(ZoneId.systemDefault());
    %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Cấu hình XP</h1>
            <p class="max-w-3xl text-indigo-100">
                Chỉnh giá trị XP của từng nguồn (test, exercise, các bonus). Thay đổi có hiệu lực ngay sau khi lưu.
                <br>
                <span class="text-indigo-200 text-sm">
                    <strong>Không quản lý ở đây:</strong> XP từng bài học (cột <code>learning_lessons.xp_reward</code>) và
                    XP review flashcard SM-2 (cố định trong code: Again=1, Hard=2, Good=3, Easy=4).
                </span>
            </p>
        </section>

        <% if (successMessage != null) { %>
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl px-6 py-4"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="bg-red-50 border border-red-200 text-red-800 rounded-2xl px-6 py-4"><%= errorMessage %></div>
        <% } %>

        <div class="bg-amber-50 border border-amber-200 text-amber-900 rounded-2xl px-6 py-4 text-sm leading-relaxed">
            <p class="font-bold mb-2">Công thức tính XP</p>
            <ul class="space-y-1 list-disc list-inside">
                <li>
                    <strong>Test / Exercise</strong> (accuracy-based):
                    <code class="bg-white px-2 py-0.5 rounded">XP = base + perCorrect × số câu đúng + (accuracy ≥ threshold ? accuracyBonus : 0)</code>
                </li>
                <li>
                    <strong>Bonus types</strong> (<code>daily_goal_bonus</code>, <code>path_bonus</code>, <code>level_bonus</code>,
                    <code>streak_bonus</code>, <code>pronunciation</code>): chỉ dùng <strong>baseAmount</strong>. Các trường khác bỏ qua.
                </li>
                <li>
                    <strong>Daily cap</strong>: trần XP/ngày cho source này (để trống = không giới hạn). Hiện chưa enforce trong code — chỉ lưu cấu hình.
                </li>
            </ul>
        </div>

        <div class="space-y-4">
            <% if (rules != null) { for (XpRule rule : rules) {
                boolean isAccuracyBased = "test".equals(rule.getSourceType()) || "exercise".equals(rule.getSourceType());
                String displayName;
                String hint;
                switch (rule.getSourceType()) {
                    case "test":             displayName = "Test (Kiểm tra)";              hint = "XP cho mỗi lần làm xong 1 phiên test."; break;
                    case "exercise":         displayName = "Exercise (Bài tập)";           hint = "XP cho mỗi lần làm xong 1 phiên exercise."; break;
                    case "daily_goal_bonus": displayName = "Daily goal bonus";             hint = "Cộng thêm khi user đạt mục tiêu XP/ngày (1 lần/ngày)."; break;
                    case "path_bonus":       displayName = "Path bonus";                   hint = "Cộng khi hoàn thành 1 learning path (CHƯA wire vào BE)."; break;
                    case "level_bonus":      displayName = "Level bonus";                  hint = "Cộng khi hoàn thành 1 CEFR level (CHƯA wire vào BE)."; break;
                    case "streak_bonus":     displayName = "Streak bonus";                 hint = "Cộng khi streak đạt mốc 7/14/21... ngày (CHƯA wire vào BE)."; break;
                    case "pronunciation":    displayName = "Pronunciation";                hint = "Cộng khi luyện phát âm đạt yêu cầu (CHƯA wire vào BE)."; break;
                    default:                 displayName = rule.getSourceType();           hint = ""; break;
                }
            %>
            <form method="post" action="${pageContext.request.contextPath}/admin/xp-rules" class="bg-surface-container-lowest rounded-2xl p-6 space-y-4">
                <input type="hidden" name="sourceType" value="<%= rule.getSourceType() %>">

                <div class="flex items-start justify-between gap-4">
                    <div>
                        <div class="flex items-center gap-2 flex-wrap">
                            <code class="text-sm font-bold text-primary bg-indigo-50 px-2 py-0.5 rounded"><%= rule.getSourceType() %></code>
                            <span class="text-sm font-bold text-slate-700"><%= displayName %></span>
                            <% if (isAccuracyBased) { %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">accuracy-based</span>
                            <% } else { %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-slate-100 text-slate-600 px-2 py-0.5 rounded-full">flat bonus</span>
                            <% } %>
                            <% if (!Boolean.TRUE.equals(rule.getEnabled())) { %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-red-100 text-red-700 px-2 py-0.5 rounded-full">disabled</span>
                            <% } %>
                        </div>
                        <% if (!hint.isEmpty()) { %>
                        <p class="text-sm text-slate-500 mt-1"><%= hint %></p>
                        <% } %>
                    </div>
                    <% if (rule.getUpdatedAt() != null) { %>
                    <p class="text-xs text-slate-400 whitespace-nowrap">Cập nhật: <%= dtf.format(rule.getUpdatedAt()) %></p>
                    <% } %>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Base XP</label>
                        <input type="number" min="0" name="baseAmount" value="<%= rule.getBaseAmount() == null ? 0 : rule.getBaseAmount() %>"
                               class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">XP / câu đúng</label>
                        <input type="number" min="0" name="perCorrect" value="<%= rule.getPerCorrect() == null ? 0 : rule.getPerCorrect() %>"
                               <%= isAccuracyBased ? "" : "disabled" %>
                               class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300 disabled:bg-slate-100 disabled:text-slate-400">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Accuracy bonus</label>
                        <input type="number" min="0" name="accuracyBonus" value="<%= rule.getAccuracyBonus() == null ? 0 : rule.getAccuracyBonus() %>"
                               <%= isAccuracyBased ? "" : "disabled" %>
                               class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300 disabled:bg-slate-100 disabled:text-slate-400">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Threshold %</label>
                        <input type="number" min="0" max="100" name="accuracyThresholdPct" value="<%= rule.getAccuracyThresholdPct() == null ? 0 : rule.getAccuracyThresholdPct() %>"
                               <%= isAccuracyBased ? "" : "disabled" %>
                               class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300 disabled:bg-slate-100 disabled:text-slate-400">
                    </div>
                    <div>
                        <label class="block text-xs font-bold uppercase tracking-widest text-slate-500 mb-1">Daily cap</label>
                        <input type="number" min="0" name="dailyCapRaw" value="<%= rule.getDailyCap() == null ? "" : rule.getDailyCap() %>"
                               placeholder="∞"
                               class="w-full border border-slate-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300">
                    </div>
                </div>

                <div class="flex items-center justify-between pt-2 border-t border-slate-100">
                    <label class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                        <input type="checkbox" name="enabled" value="on" <%= Boolean.TRUE.equals(rule.getEnabled()) ? "checked" : "" %>
                               class="w-4 h-4 rounded border-slate-300 text-primary focus:ring-indigo-300">
                        Bật rule này
                    </label>
                    <button type="submit" class="px-5 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:opacity-90">Lưu thay đổi</button>
                </div>

                <% if (isAccuracyBased) {
                    int base = rule.getBaseAmount() == null ? 0 : rule.getBaseAmount();
                    int per = rule.getPerCorrect() == null ? 0 : rule.getPerCorrect();
                    int bonus = rule.getAccuracyBonus() == null ? 0 : rule.getAccuracyBonus();
                    int threshold = rule.getAccuracyThresholdPct() == null ? 0 : rule.getAccuracyThresholdPct();
                    // Ví dụ: 10 câu, đúng 8 câu
                    int sample10 = base + per * 8 + (80 >= threshold ? bonus : 0);
                    int sampleAll = base + per * 10 + (100 >= threshold ? bonus : 0);
                %>
                <div class="text-xs text-slate-500 bg-slate-50 rounded-xl px-4 py-3">
                    <strong>Ví dụ với giá trị hiện tại:</strong>
                    Làm 10 câu, đúng 8 (accuracy 80%) → <strong><%= sample10 %> XP</strong>.
                    Đúng cả 10 câu (accuracy 100%) → <strong><%= sampleAll %> XP</strong>.
                </div>
                <% } %>
            </form>
            <% } } else { %>
            <div class="bg-slate-50 border border-slate-200 rounded-2xl px-6 py-8 text-center text-slate-500">
                Chưa có rule nào. Hãy chạy migration <code>V22__xp_rules.sql</code>.
            </div>
            <% } %>
        </div>
    </div>
</main>
</body>
</html>
