-- Đưa toàn bộ cấu hình Google STT vào app_config để quản lý runtime trên admin
-- (giống LLM_*). Trước đây STT đọc qua @Value từ application.properties/env, đổi
-- key phải sửa file + restart. Nay admin bật/tắt + dán service account JSON ngay
-- trên /admin/config, GoogleSttService đọc DB và rebuild SpeechClient khi key đổi.
INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('STT_ENABLED', 'false', 'boolean', 'Bật Google Speech-to-Text (chấm phát âm từ audio). Tắt -> fallback assess-text (mobile gửi transcript on-device).', FALSE),
  ('STT_CREDENTIALS_JSON', '', 'json', 'Nội dung service account JSON của Google Cloud (dán cả file). Để trống -> dùng Application Default Credentials (env GOOGLE_APPLICATION_CREDENTIALS).', TRUE),
  ('STT_LANGUAGE', 'en-US', 'string', 'Mã ngôn ngữ nhận diện. VD: en-US, en-GB.', FALSE),
  ('STT_SAMPLE_RATE', '16000', 'int', 'Sample rate (Hz) client gửi. Phải khớp audio mobile thu (mặc định 16000).', FALSE)
ON CONFLICT (config_key) DO NOTHING;
