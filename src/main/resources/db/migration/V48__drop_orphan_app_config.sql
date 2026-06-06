-- Xóa các config key mồ côi: chưa wire vào logic nào đang chạy (sửa không có tác dụng).
-- Chừa lại DEEPSEEK_API_KEY (dùng bởi PracticeGenerationService, ConversationService,
-- DeepSeekPronunciationScorer). Pronunciation provider thật chọn qua application.properties
-- (englishme.ai.pronunciation.provider), không phải row app_config này.
DELETE FROM app_config WHERE config_key IN (
    'xp.per_study_card_correct',
    'xp.per_study_card_perfect',
    'xp.per_exercise_correct',
    'xp.per_test_correct',
    'streak.grace_hours',
    'pronunciation.rate_limit_per_minute',
    'pronunciation.provider',
    'feature.exercise_enabled',
    'feature.chat_enabled',
    'maintenance.mode',
    'maintenance.message'
);
