<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.kiovant.englishme.entity.AppConfig" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    // Escape giá trị để nhúng an toàn vào HTML (value/textarea).
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
    // Nhãn nhóm theo tiền tố key.
    private String groupOf(String key) {
        if (key == null) return "Khác";
        if (key.startsWith("LLM_")) return "Mô hình AI (LLM)";
        if (key.startsWith("AI_PROMPT_")) return "Prompt chức năng";
        if (key.startsWith("AI_")) return "Tham số AI & giới hạn";
        return "Khác";
    }
%>
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
        List<AppConfig> configs = (List<AppConfig>) request.getAttribute("configs");
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String[] groupOrder = {"Mô hình AI (LLM)", "Prompt chức năng", "Tham số AI & giới hạn", "Khác"};
    %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Cấu hình AI</h1>
            <p class="max-w-2xl text-indigo-100">Quản lý mô hình AI, prompt từng chức năng và giới hạn sử dụng. Đổi giá trị rồi bấm Lưu từng mục.</p>
        </section>

        <%-- Test kết nối LLM. --%>
        <section class="bg-surface-container-lowest rounded-2xl p-6 border border-indigo-100">
            <div class="flex items-center gap-2 mb-2">
                <h2 class="text-xl font-bold text-on-surface">Kiểm tra kết nối</h2>
                <span class="text-[10px] font-bold uppercase tracking-widest bg-indigo-100 text-primary px-2 py-0.5 rounded-full">OpenAI-compatible</span>
            </div>
            <p class="text-sm text-slate-500 mb-4">Sau khi nhập LLM_BASE_URL, LLM_MODEL, LLM_API_KEY (Lưu hoặc gõ trực tiếp), bấm để kiểm tra key có hoạt động không.</p>
            <button type="button" id="btn-test-llm"
                    class="px-5 py-2 bg-emerald-600 text-white text-sm font-semibold rounded-xl hover:opacity-90">
                Test kết nối LLM
            </button>
            <div id="llm-test-result" class="mt-3 text-sm hidden rounded-xl px-4 py-3"></div>
        </section>

        <% if (successMessage != null) { %>
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl px-6 py-4"><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
        <div class="bg-red-50 border border-red-200 text-red-800 rounded-2xl px-6 py-4"><%= errorMessage %></div>
        <% } %>

        <% if (configs != null) {
            for (String group : groupOrder) {
                boolean hasAny = false;
                for (AppConfig c : configs) { if (groupOf(c.getConfigKey()).equals(group)) { hasAny = true; break; } }
                if (!hasAny) continue;
        %>
        <div class="space-y-4">
            <h2 class="text-lg font-bold text-slate-700 mt-2"><%= group %></h2>
            <% for (AppConfig cfg : configs) {
                if (!groupOf(cfg.getConfigKey()).equals(group)) continue;
                boolean isSecret = cfg.isSecret();
                boolean isPrompt = cfg.getConfigKey() != null && cfg.getConfigKey().startsWith("AI_PROMPT_");
                String rawValue = cfg.getConfigValue() != null ? cfg.getConfigValue() : "";
                String displayValue = (isSecret && !rawValue.isBlank()) ? "••••••••" : rawValue;
                String inputType = isSecret ? "password" : "text";
            %>
            <div class="bg-surface-container-lowest rounded-2xl p-6">
                <div class="flex items-start justify-between gap-4 mb-4">
                    <div>
                        <div class="flex items-center gap-2">
                            <code class="text-sm font-bold text-primary bg-indigo-50 px-2 py-0.5 rounded"><%= cfg.getConfigKey() %></code>
                            <% if (isSecret) { %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">Secret</span>
                            <% } %>
                            <span class="text-[10px] font-bold uppercase tracking-widest bg-slate-100 text-slate-500 px-2 py-0.5 rounded-full"><%= cfg.getValueType() %></span>
                        </div>
                        <% if (cfg.getDescription() != null) { %>
                        <p class="text-sm text-slate-500 mt-1"><%= cfg.getDescription() %></p>
                        <% } %>
                    </div>
                    <% if (cfg.getUpdatedAt() != null) { %>
                    <p class="text-xs text-slate-400 whitespace-nowrap">Cập nhật: <%= cfg.getUpdatedAt().format(dtf) %>
                        <% if (cfg.getUpdatedByEmail() != null) { %> bởi <%= cfg.getUpdatedByEmail() %><% } %>
                    </p>
                    <% } %>
                </div>
                <% if (isPrompt) { %>
                <form method="post" action="${pageContext.request.contextPath}/admin/config" class="space-y-3">
                    <input type="hidden" name="key" value="<%= cfg.getConfigKey() %>">
                    <textarea name="value" rows="10"
                        class="w-full font-mono text-xs border border-slate-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-indigo-300"><%= esc(rawValue) %></textarea>
                    <div class="flex justify-end">
                        <button type="submit" class="px-5 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:opacity-90">Lưu</button>
                    </div>
                </form>
                <% } else { %>
                <form method="post" action="${pageContext.request.contextPath}/admin/config" class="flex gap-3">
                    <input type="hidden" name="key" value="<%= cfg.getConfigKey() %>">
                    <input
                        type="<%= inputType %>"
                        name="value"
                        placeholder="<%= isSecret ? "Nhập giá trị mới..." : esc(displayValue) %>"
                        value="<%= isSecret ? "" : esc(displayValue) %>"
                        class="flex-1 border border-slate-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-300"
                    >
                    <button type="submit" class="px-5 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:opacity-90">Lưu</button>
                </form>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } } %>
    </div>
</main>

<script>
    (function () {
        var btn = document.getElementById('btn-test-llm');
        var box = document.getElementById('llm-test-result');
        if (!btn) return;

        // Lấy giá trị đang gõ trong các ô LLM (nếu admin chưa Lưu). Rỗng -> backend dùng giá trị DB.
        function fieldValue(key) {
            var input = document.querySelector('input[name="key"][value="' + key + '"]');
            if (!input) return '';
            var form = input.closest('form');
            var valInput = form ? form.querySelector('input[name="value"]') : null;
            return valInput ? valInput.value.trim() : '';
        }

        function show(success, message) {
            box.classList.remove('hidden');
            box.className = 'mt-3 text-sm rounded-xl px-4 py-3 '
                + (success ? 'bg-emerald-50 border border-emerald-200 text-emerald-800'
                           : 'bg-red-50 border border-red-200 text-red-800');
            box.textContent = (success ? '✓ ' : '✗ ') + message;
        }

        btn.addEventListener('click', function () {
            btn.disabled = true;
            var original = btn.textContent;
            btn.textContent = 'Đang kiểm tra...';

            var ctx = '${pageContext.request.contextPath}';
            var params = new URLSearchParams();
            params.append('baseUrl', fieldValue('LLM_BASE_URL'));
            params.append('apiKey', fieldValue('LLM_API_KEY'));
            params.append('model', fieldValue('LLM_MODEL'));

            fetch(ctx + '/admin/config/test-llm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(function (r) { return r.json(); })
            .then(function (data) { show(data.success, data.message || ''); })
            .catch(function (e) { show(false, 'Lỗi gọi test: ' + e); })
            .finally(function () {
                btn.disabled = false;
                btn.textContent = original;
            });
        });
    })();
</script>
</body>
</html>
