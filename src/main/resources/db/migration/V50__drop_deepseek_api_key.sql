-- DEEPSEEK_API_KEY không còn được code đọc sau khi gộp về LLM_API_KEY (V49).
-- Xóa để admin khỏi nhầm nhập vào ô vô dụng.
-- V49 đã copy giá trị cũ sang LLM_API_KEY nên không mất key.
DELETE FROM app_config WHERE config_key = 'DEEPSEEK_API_KEY';
