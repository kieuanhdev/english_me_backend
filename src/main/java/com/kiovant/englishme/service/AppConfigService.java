package com.kiovant.englishme.service;

import com.kiovant.englishme.entity.AppConfig;
import com.kiovant.englishme.repository.AppConfigRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AppConfigService {

    private final AppConfigRepository repo;

    public AppConfigService(AppConfigRepository repo) {
        this.repo = repo;
    }

    public List<AppConfig> findAll() {
        return repo.findAll();
    }

    public String getValue(String key) {
        return repo.findById(key).map(AppConfig::getConfigValue).orElse(null);
    }

    /** Lấy chuỗi, rỗng/null -> trả default. Dùng cho prompt/cấu hình có giá trị mặc định. */
    public String getOr(String key, String defaultValue) {
        String v = getValue(key);
        return (v == null || v.isBlank()) ? defaultValue : v;
    }

    /** Lấy int, parse lỗi/rỗng -> default. */
    public int getIntOr(String key, int defaultValue) {
        String v = getValue(key);
        if (v == null || v.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    /** Lấy double, parse lỗi/rỗng -> default. */
    public double getDoubleOr(String key, double defaultValue) {
        String v = getValue(key);
        if (v == null || v.isBlank()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(v.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    @Transactional
    public void setValue(String key, String value, String updatedByEmail) {
        AppConfig config = repo.findById(key)
                .orElseThrow(() -> new IllegalArgumentException("Config key không tồn tại: " + key));
        config.setConfigValue(value);
        config.setUpdatedAt(LocalDateTime.now());
        config.setUpdatedByEmail(updatedByEmail);
        repo.save(config);
    }
}
