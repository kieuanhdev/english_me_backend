<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AppConfigRow" %>
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
        List<AppConfigRow> configs = (List<AppConfigRow>) request.getAttribute("configs");
        Boolean reveal = (Boolean) request.getAttribute("revealSecrets");
        boolean revealSecrets = reveal != null && reveal;
        int total = configs == null ? 0 : configs.size();
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <div class="p-8 space-y-6">
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
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">System Configuration</h1>
                <p class="text-slate-500 font-medium">Cấu hình runtime không cần đụng <code class="bg-slate-100 px-1 rounded">application.yaml</code> — <%= total %> key.</p>
            </div>
            <div class="flex gap-2 text-sm">
                <% if (revealSecrets) { %>
                <a href="${pageContext.request.contextPath}/admin/config"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-700 font-semibold hover:bg-slate-200">Ẩn secrets</a>
                <% } else { %>
                <a href="${pageContext.request.contextPath}/admin/config?revealSecrets=true"
                   class="px-4 py-2 rounded-xl bg-amber-50 text-amber-700 font-semibold hover:bg-amber-100">Hiện secrets</a>
                <% } %>
                <form method="post" action="${pageContext.request.contextPath}/admin/config/reload">
                    <button type="submit"
                            class="px-4 py-2 rounded-xl bg-indigo-50 text-primary font-semibold hover:bg-indigo-100">
                        Reload cache
                    </button>
                </form>
            </div>
        </div>

        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 uppercase text-xs tracking-wider">
                <tr>
                    <th class="text-left px-5 py-3">Key</th>
                    <th class="text-left px-5 py-3">Type</th>
                    <th class="text-left px-5 py-3">Giá trị</th>
                    <th class="text-left px-5 py-3">Mô tả</th>
                    <th class="text-left px-5 py-3">Cập nhật lần cuối</th>
                </tr>
                </thead>
                <tbody>
                <% if (configs == null || configs.isEmpty()) { %>
                <tr><td colspan="5" class="px-5 py-8 text-center text-slate-400">Chưa có config nào.</td></tr>
                <% } else for (AppConfigRow c : configs) {
                    String typeColor = switch (c.valueType()) {
                        case "boolean" -> "bg-emerald-50 text-emerald-700";
                        case "integer" -> "bg-sky-50 text-sky-700";
                        case "json" -> "bg-purple-50 text-purple-700";
                        default -> "bg-slate-100 text-slate-600";
                    };
                    String inputValue = c.isSecret() && !revealSecrets ? "" : (c.configValue() == null ? "" : c.configValue());
                    String placeholder = c.isSecret() && !revealSecrets ? c.displayValue() : "";
                %>
                <tr class="border-t border-slate-100 align-top">
                    <td class="px-5 py-3 font-mono text-xs font-semibold text-indigo-950 break-all">
                        <%= c.configKey() %>
                        <% if (c.isSecret()) { %>
                        <span class="ml-1 inline-block px-1.5 py-0.5 rounded bg-amber-50 text-amber-700 text-[10px] font-bold">SECRET</span>
                        <% } %>
                    </td>
                    <td class="px-5 py-3">
                        <span class="inline-block px-2 py-1 rounded-md text-xs font-bold <%= typeColor %>"><%= c.valueType() %></span>
                    </td>
                    <td class="px-5 py-3 w-1/3">
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/config/<%= c.configKey() %>"
                              class="flex items-center gap-2">
                            <% if ("boolean".equals(c.valueType())) { %>
                                <select name="value" class="rounded-xl border border-slate-200 px-3 py-2 text-sm flex-1">
                                    <option value="true"  <%= "true".equalsIgnoreCase(c.configValue()) ? "selected" : "" %>>true</option>
                                    <option value="false" <%= "false".equalsIgnoreCase(c.configValue()) || c.configValue() == null ? "selected" : "" %>>false</option>
                                </select>
                            <% } else if ("integer".equals(c.valueType())) { %>
                                <input type="number" name="value" value="<%= inputValue %>"
                                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm flex-1 font-mono"/>
                            <% } else if ("json".equals(c.valueType())) { %>
                                <textarea name="value" rows="2"
                                          class="rounded-xl border border-slate-200 px-3 py-2 text-xs font-mono flex-1"
                                          placeholder='{} hoặc []'><%= inputValue %></textarea>
                            <% } else { %>
                                <input type="text" name="value" value="<%= inputValue %>"
                                       placeholder="<%= placeholder %>"
                                       class="rounded-xl border border-slate-200 px-3 py-2 text-sm flex-1 <%= c.isSecret() ? "font-mono" : "" %>"/>
                            <% } %>
                            <button type="submit"
                                    class="px-3 py-2 rounded-xl bg-primary text-white text-xs font-semibold hover:opacity-90">
                                Lưu
                            </button>
                        </form>
                    </td>
                    <td class="px-5 py-3 text-slate-600 text-xs"><%= c.description() == null ? "—" : c.description() %></td>
                    <td class="px-5 py-3 text-xs text-slate-500">
                        <% if (c.updatedAt() != null) { %>
                            <div><%= fmt.format(c.updatedAt()) %></div>
                        <% } %>
                        <% if (c.updatedByEmail() != null) { %>
                            <div class="text-[10px] text-slate-400">bởi <%= c.updatedByEmail() %></div>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <div class="text-xs text-slate-500 leading-relaxed">
            <p><strong>Lưu ý:</strong></p>
            <ul class="list-disc list-inside space-y-1">
                <li><code class="bg-slate-100 px-1 rounded">SECRET</code> bị mask khi list — click "Hiện secrets" để xem giá trị thật (chỉ nên dùng từ SUPER_ADMIN).</li>
                <li>Khi đổi config: cache trong-memory được update ngay, các service đọc qua <code class="bg-slate-100 px-1 rounded">AppConfigService.getInt / getBoolean / getString</code> sẽ thấy giá trị mới mà không cần restart.</li>
                <li>Nếu DB bị thay đổi từ ngoài (vd. SQL trực tiếp), bấm "Reload cache" để đồng bộ lại.</li>
                <li>Để dùng giá trị config thay cho <code class="bg-slate-100 px-1 rounded">@Value</code>, inject <code class="bg-slate-100 px-1 rounded">AppConfigService</code> vào service tương ứng (xp / streak / pronunciation / chat).</li>
            </ul>
        </div>
    </div>
</main>
</body>
</html>
