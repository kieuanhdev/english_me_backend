-- Gemini API key cho chấm phát âm (GeminiPronunciationClient).
-- Nghe file audio + câu mẫu -> ước lượng điểm phát âm. Sửa value qua admin panel.
INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('GEMINI_API_KEY', '', 'string', 'API key cho Google Gemini (chấm phát âm qua audio)', TRUE)
ON CONFLICT (config_key) DO NOTHING;
