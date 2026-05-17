-- Module 12: System Configuration

CREATE TABLE app_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    value_type VARCHAR(20) NOT NULL,                -- boolean | integer | string | json
    description TEXT,
    is_secret BOOLEAN NOT NULL DEFAULT FALSE,       -- nếu true: mask khi list, chỉ SUPER_ADMIN xem giá trị thật
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_email VARCHAR(255)
);

-- Seed configs cơ bản
INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('xp.per_study_card_correct', '2', 'integer', 'XP cấp khi trả lời flashcard quality>=3', FALSE),
  ('xp.per_study_card_perfect', '3', 'integer', 'XP cấp khi quality=5', FALSE),
  ('xp.per_exercise_correct', '5', 'integer', 'XP cho mỗi câu exercise đúng', FALSE),
  ('xp.per_test_correct', '10', 'integer', 'XP cho mỗi câu test đúng', FALSE),
  ('streak.grace_hours', '6', 'integer', 'Số giờ ân hạn để giữ streak', FALSE),
  ('pronunciation.rate_limit_per_minute', '30', 'integer', 'Giới hạn request pronunciation / phút / user', FALSE),
  ('pronunciation.provider', 'google', 'string', 'Provider phân tích phát âm: google | azure', FALSE),
  ('chat.daily_limit_free', '20', 'integer', 'Số message chat AI / ngày cho user free', FALSE),
  ('chat.daily_limit_premium', '200', 'integer', 'Số message chat AI / ngày cho user premium', FALSE),
  ('feature.exercise_enabled', 'true', 'boolean', 'Bật/tắt module exercise', FALSE),
  ('feature.chat_enabled', 'true', 'boolean', 'Bật/tắt module chat AI', FALSE),
  ('maintenance.mode', 'false', 'boolean', 'Bật chế độ bảo trì (block mobile API)', FALSE),
  ('maintenance.message', 'Hệ thống đang bảo trì, vui lòng quay lại sau.', 'string', 'Thông báo bảo trì hiển thị cho user', FALSE),
  ('DEEPSEEK_API_KEY', '', 'string', 'API key cho DeepSeek (chat AI)', TRUE),
  ('GOOGLE_CLOUD_PROJECT_ID', '', 'string', 'Project ID GCP (Speech-to-Text)', TRUE),
  ('FIREBASE_SERVICE_ACCOUNT_PATH', '', 'string', 'Đường dẫn file service account Firebase', TRUE);
