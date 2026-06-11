-- Gỡ SpeechAce: phát âm giờ chấm bằng Levenshtein Distance trên transcript STT (client),
-- không còn cloud provider nào để cấu hình. Xóa row config thừa.
DELETE FROM app_config WHERE config_key = 'pronunciation.provider';
