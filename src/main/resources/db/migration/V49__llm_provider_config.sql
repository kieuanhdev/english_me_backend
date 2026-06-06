-- Cấu hình LLM dùng chung cho mọi chức năng AI (chat hội thoại, sinh câu hỏi, chấm text).
-- Chuẩn OpenAI-compatible: đổi model = đổi base url + model + key, không build lại.
-- Default = DeepSeek để giữ nguyên hành vi cũ.
INSERT INTO app_config (config_key, config_value, value_type, description, is_secret) VALUES
  ('LLM_BASE_URL', 'https://api.deepseek.com', 'string', 'Gốc API LLM (OpenAI-compatible). VD: https://api.deepseek.com, https://api.openai.com/v1', FALSE),
  ('LLM_MODEL', 'deepseek-chat', 'string', 'Tên model. VD: deepseek-chat, gpt-4o-mini, llama-3.3-70b-versatile', FALSE),
  ('LLM_API_KEY', '', 'string', 'API key cho LLM (Bearer token)', TRUE)
ON CONFLICT (config_key) DO NOTHING;

-- Kế thừa key DeepSeek đã nhập trước đó (nếu có) sang LLM_API_KEY.
UPDATE app_config
SET config_value = (SELECT config_value FROM app_config WHERE config_key = 'DEEPSEEK_API_KEY')
WHERE config_key = 'LLM_API_KEY'
  AND (config_value IS NULL OR config_value = '')
  AND EXISTS (
      SELECT 1 FROM app_config
      WHERE config_key = 'DEEPSEEK_API_KEY'
        AND config_value IS NOT NULL AND config_value <> ''
  );
