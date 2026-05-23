-- Tái tạo app_config cho AppConfigService (admin web cấu hình API keys)
CREATE TABLE IF NOT EXISTS app_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    value_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_secret BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_email VARCHAR(255)
);

INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('xp.per_study_card_correct', '2', 'integer', 'XP cấp khi trả lời flashcard quality>=3', FALSE),
  ('xp.per_study_card_perfect', '3', 'integer', 'XP cấp khi quality=5', FALSE),
  ('xp.per_exercise_correct', '5', 'integer', 'XP cho mỗi câu exercise đúng', FALSE),
  ('xp.per_test_correct', '10', 'integer', 'XP cho mỗi câu test đúng', FALSE),
  ('streak.grace_hours', '6', 'integer', 'Số giờ ân hạn để giữ streak', FALSE),
  ('pronunciation.rate_limit_per_minute', '30', 'integer', 'Giới hạn request pronunciation / phút / user', FALSE),
  ('pronunciation.provider', 'speechace', 'string', 'Provider phân tích phát âm: speechace | mock', FALSE),
  ('feature.exercise_enabled', 'true', 'boolean', 'Bật/tắt module exercise', FALSE),
  ('feature.chat_enabled', 'true', 'boolean', 'Bật/tắt module chat AI', FALSE),
  ('maintenance.mode', 'false', 'boolean', 'Bật chế độ bảo trì (block mobile API)', FALSE),
  ('maintenance.message', 'Hệ thống đang bảo trì, vui lòng quay lại sau.', 'string', 'Thông báo bảo trì hiển thị cho user', FALSE),
  ('DEEPSEEK_API_KEY', '', 'string', 'API key cho DeepSeek (chat AI)', TRUE)
ON CONFLICT (config_key) DO NOTHING;
