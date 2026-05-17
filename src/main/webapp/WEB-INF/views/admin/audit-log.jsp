<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.dto.AuditLogRow" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
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
        List<AuditLogRow> logs = (List<AuditLogRow>) request.getAttribute("logs");
        String fEmail = (String) request.getAttribute("filterEmail");
        String fAction = (String) request.getAttribute("filterAction");
        LocalDate fFrom = (LocalDate) request.getAttribute("filterFrom");
        LocalDate fTo = (LocalDate) request.getAttribute("filterTo");
        int total = logs == null ? 0 : logs.size();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    %>

    <div class="p-8 space-y-6">
        <div class="flex justify-between items-end flex-wrap gap-4">
            <div class="space-y-1">
                <h1 class="text-3xl font-extrabold tracking-tight text-indigo-950 font-headline">Audit log</h1>
                <p class="text-slate-500 font-medium">Lịch sử thao tác POST/PUT/DELETE trong /admin — <%= total %> dòng.</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/admins"
               class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold text-sm hover:bg-slate-200">
                Admin accounts
            </a>
        </div>

        <!-- Filter -->
        <form method="get" action="${pageContext.request.contextPath}/admin/audit-log"
              class="bg-surface-container-lowest rounded-2xl p-4 grid grid-cols-1 md:grid-cols-5 gap-3 text-sm">
            <input type="text" name="email" placeholder="email chứa..."
                   value="<%= fEmail == null ? "" : fEmail %>"
                   class="rounded-xl border border-slate-200 px-3 py-2"/>
            <select name="action" class="rounded-xl border border-slate-200 px-3 py-2">
                <option value="">Tất cả action</option>
                <% for (String act : new String[]{"POST", "PUT", "DELETE", "PATCH"}) { %>
                    <option value="<%= act %>" <%= act.equals(fAction) ? "selected" : "" %>><%= act %></option>
                <% } %>
            </select>
            <input type="date" name="from" value="<%= fFrom == null ? "" : fFrom %>"
                   class="rounded-xl border border-slate-200 px-3 py-2"/>
            <input type="date" name="to" value="<%= fTo == null ? "" : fTo %>"
                   class="rounded-xl border border-slate-200 px-3 py-2"/>
            <div class="flex gap-2">
                <button type="submit" class="flex-1 px-4 py-2 rounded-xl bg-primary text-white font-semibold">Lọc</button>
                <a href="${pageContext.request.contextPath}/admin/audit-log"
                   class="px-4 py-2 rounded-xl bg-slate-100 text-slate-600 font-semibold">Reset</a>
            </div>
        </form>

        <!-- Bảng log -->
        <div class="bg-surface-container-lowest rounded-[2rem] overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 uppercase text-xs tracking-wider">
                <tr>
                    <th class="text-left px-5 py-3">Thời gian</th>
                    <th class="text-left px-5 py-3">Admin</th>
                    <th class="text-left px-5 py-3">Action</th>
                    <th class="text-left px-5 py-3">URI</th>
                    <th class="text-left px-5 py-3">Entity</th>
                    <th class="text-left px-5 py-3">Status</th>
                    <th class="text-left px-5 py-3">IP</th>
                </tr>
                </thead>
                <tbody>
                <% if (logs == null || logs.isEmpty()) { %>
                <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Không có log nào.</td></tr>
                <% } else for (AuditLogRow r : logs) {
                    String actionColor = switch (r.action()) {
                        case "POST" -> "bg-emerald-50 text-emerald-700";
                        case "PUT", "PATCH" -> "bg-amber-50 text-amber-700";
                        case "DELETE" -> "bg-rose-50 text-rose-700";
                        default -> "bg-slate-100 text-slate-600";
                    };
                    Integer sc = r.statusCode();
                    String scColor = sc == null ? "text-slate-400"
                            : sc < 300 ? "text-emerald-700"
                            : sc < 400 ? "text-sky-700"
                            : sc < 500 ? "text-amber-700"
                            : "text-rose-700";
                %>
                <tr class="border-t border-slate-100">
                    <td class="px-5 py-3 text-slate-600 whitespace-nowrap"><%= r.createdAt() == null ? "—" : fmt.format(r.createdAt()) %></td>
                    <td class="px-5 py-3 font-semibold text-indigo-950"><%= r.adminEmail() == null ? "—" : r.adminEmail() %></td>
                    <td class="px-5 py-3">
                        <span class="inline-block px-2 py-1 rounded-md text-xs font-bold <%= actionColor %>"><%= r.action() %></span>
                    </td>
                    <td class="px-5 py-3 text-slate-700 font-mono text-xs break-all"><%= r.requestUri() %></td>
                    <td class="px-5 py-3 text-slate-600 text-xs">
                        <% if (r.entityType() != null) { %><%= r.entityType() %><% } else { %>—<% } %>
                        <% if (r.entityId() != null) { %> · <span class="font-mono"><%= r.entityId() %></span><% } %>
                    </td>
                    <td class="px-5 py-3 font-bold <%= scColor %>"><%= sc == null ? "—" : sc %></td>
                    <td class="px-5 py-3 text-slate-500 text-xs font-mono"><%= r.ipAddress() == null ? "—" : r.ipAddress() %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>
</body>
</html>
