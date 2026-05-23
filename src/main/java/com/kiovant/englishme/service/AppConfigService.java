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

    public String getDeepseekApiKey() {
        return getValue("DEEPSEEK_API_KEY");
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
