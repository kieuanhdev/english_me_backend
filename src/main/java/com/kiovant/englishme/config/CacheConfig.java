package com.kiovant.englishme.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;

/**
 * Bật Spring Cache (provider Caffeine — cấu hình spec ở application.yaml).
 * Hiện dùng cho app_config: admin đổi giá trị vài lần/tháng nhưng LlmClient /
 * ConversationService đọc nhiều lần mỗi request.
 */
@Configuration
@EnableCaching
public class CacheConfig {
}
