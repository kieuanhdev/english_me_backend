package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.AppConfigRow;
import com.kiovant.englishme.entity.AppConfig;
import com.kiovant.englishme.repository.AppConfigRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * App-wide runtime config đọc từ bảng `app_config`.
 *
 * Cache giá trị trong-memory (ConcurrentHashMap) để các service khác có thể đọc nhanh,
 * invalidate bằng cách reload entry hoặc full cache mỗi lần update qua admin UI.
 */
@Service
public class AppConfigService {

    public static final Set<String> ALLOWED_TYPES = Set.of("boolean", "integer", "string", "json");

    private final AppConfigRepository repo;
    private final Map<String, String> cache = new ConcurrentHashMap<>();

    public AppConfigService(AppConfigRepository repo) {
        this.repo = repo;
    }

    @PostConstruct
    void warmup() {
        reloadAll();
    }

    // ── Read API cho các service khác ───────────────────────────────────────

    public String getRaw(String key) {
        return cache.get(key);
    }

    public String getString(String key, String fallback) {
        String v = cache.get(key);
        return v == null ? fallback : v;
    }

    public int getInt(String key, int fallback) {
        String v = cache.get(key);
        if (v == null || v.isBlank()) return fallback;
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    public boolean getBoolean(String key, boolean fallback) {
        String v = cache.get(key);
        if (v == null || v.isBlank()) return fallback;
        return "true".equalsIgnoreCase(v.trim()) || "1".equals(v.trim());
    }

    // ── Admin UI: list + update ─────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<AppConfigRow> listAll(boolean revealSecrets) {
        List<AppConfig> all = repo.findAllByOrderByConfigKeyAsc();
        List<AppConfigRow> rows = new ArrayList<>(all.size());
        for (AppConfig c : all) {
            String raw = c.getConfigValue();
            boolean secret = Boolean.TRUE.equals(c.getIsSecret());
            String display = secret && !revealSecrets ? maskSecret(raw) : raw;
            rows.add(new AppConfigRow(
                    c.getConfigKey(), raw, display, c.getValueType(),
                    c.getDescription(), secret, c.getUpdatedAt(), c.getUpdatedByEmail()
            ));
        }
        return rows;
    }

    @Transactional
    public AppConfig update(String key, String newValue, String adminEmail) {
        AppConfig c = repo.findById(key)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Config không tồn tại: " + key));
        String validated = validate(c.getValueType(), newValue);
        c.setConfigValue(validated);
        c.setUpdatedByEmail(blankToNull(adminEmail));
        AppConfig saved = repo.save(c);
        cache.put(key, validated == null ? "" : validated);
        return saved;
    }

    public void reloadAll() {
        Map<String, String> snapshot = new ConcurrentHashMap<>();
        for (AppConfig c : repo.findAll()) {
            snapshot.put(c.getConfigKey(), c.getConfigValue() == null ? "" : c.getConfigValue());
        }
        cache.clear();
        cache.putAll(snapshot);
    }

    // ── Validation ──────────────────────────────────────────────────────────

    private String validate(String type, String value) {
        String t = type == null ? "string" : type.toLowerCase(Locale.ROOT);
        String v = value == null ? "" : value.trim();
        return switch (t) {
            case "boolean" -> {
                if (!v.equalsIgnoreCase("true") && !v.equalsIgnoreCase("false")) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Giá trị boolean phải là 'true' hoặc 'false'.");
                }
                yield v.toLowerCase(Locale.ROOT);
            }
            case "integer" -> {
                if (v.isEmpty()) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Giá trị integer không được trống.");
                }
                try {
                    Integer.parseInt(v);
                } catch (NumberFormatException ex) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Giá trị integer không hợp lệ: " + v);
                }
                yield v;
            }
            case "json" -> {
                if (v.isEmpty()) yield v;
                char first = v.charAt(0);
                char last = v.charAt(v.length() - 1);
                boolean looksJson = (first == '{' && last == '}') || (first == '[' && last == ']');
                if (!looksJson) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Giá trị JSON phải bắt đầu/kết thúc bằng {} hoặc [].");
                }
                yield v;
            }
            default -> v; // string: cho phép rỗng
        };
    }

    private static String maskSecret(String raw) {
        if (raw == null || raw.isEmpty()) return "—";
        int len = raw.length();
        if (len <= 4) return "••••";
        return "••••" + raw.substring(len - 4);
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
