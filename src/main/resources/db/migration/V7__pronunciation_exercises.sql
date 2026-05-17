CREATE TABLE IF NOT EXISTS pronunciation_exercises (
    id UUID PRIMARY KEY,
    text TEXT NOT NULL,
    phonetic VARCHAR(512) NULL,
    meaning TEXT NULL,
    audio_url VARCHAR(1024) NULL,
    difficulty VARCHAR(20) NOT NULL
);

ALTER TABLE pronunciation_attempts
    RENAME COLUMN lesson_item_id TO exercise_id;

ALTER TABLE pronunciation_attempts
    ADD COLUMN IF NOT EXISTS completeness_score INTEGER NULL,
    ADD COLUMN IF NOT EXISTS transcription TEXT NULL;

INSERT INTO pronunciation_exercises (id, text, phonetic, meaning, audio_url, difficulty) VALUES
    (gen_random_uuid(), 'Hello, how are you?', 'həˈloʊ, haʊ ɑːr juː', 'Xin chào, bạn khỏe không?', NULL, 'beginner'),
    (gen_random_uuid(), 'Good morning, nice to meet you.', 'ɡʊd ˈmɔːrnɪŋ, naɪs tuː miːt juː', 'Chào buổi sáng, rất vui được gặp bạn.', NULL, 'beginner'),
    (gen_random_uuid(), 'What time is it?', 'wʌt taɪm ɪz ɪt', 'Mấy giờ rồi?', NULL, 'beginner'),
    (gen_random_uuid(), 'I would like a cup of coffee, please.', 'aɪ wʊd laɪk ə kʌp ʌv ˈkɔːfi pliːz', 'Tôi muốn một tách cà phê, làm ơn.', NULL, 'beginner'),
    (gen_random_uuid(), 'Where is the nearest bus station?', 'wɛr ɪz ðə ˈnɪrɪst bʌs ˈsteɪʃən', 'Trạm xe buýt gần nhất ở đâu?', NULL, 'intermediate'),
    (gen_random_uuid(), 'Could you repeat that more slowly, please?', 'kʊd juː rɪˈpiːt ðæt mɔːr ˈsloʊli pliːz', 'Bạn có thể lặp lại chậm hơn được không?', NULL, 'intermediate'),
    (gen_random_uuid(), 'I have been learning English for three years.', 'aɪ hæv biːn ˈlɜːrnɪŋ ˈɪŋɡlɪʃ fɔːr θriː jɪrz', 'Tôi đã học tiếng Anh được ba năm.', NULL, 'intermediate'),
    (gen_random_uuid(), 'The weather is beautiful today, is not it?', 'ðə ˈwɛðər ɪz ˈbjuːtɪfəl təˈdeɪ, ˈɪzənt ɪt', 'Thời tiết hôm nay đẹp nhỉ?', NULL, 'intermediate'),
    (gen_random_uuid(), 'Could you tell me how to get to the museum?', 'kʊd juː tɛl miː haʊ tuː ɡɛt tuː ðə mjuːˈziːəm', 'Bạn có thể chỉ tôi đường đến bảo tàng không?', NULL, 'intermediate'),
    (gen_random_uuid(), 'I would appreciate it if you could help me with this problem.', 'aɪ wʊd əˈpriːʃieɪt ɪt ɪf juː kʊd hɛlp miː wɪð ðɪs ˈprɑːbləm', 'Tôi sẽ rất cảm kích nếu bạn có thể giúp tôi vấn đề này.', NULL, 'advanced'),
    (gen_random_uuid(), 'The presentation was incredibly insightful and well-structured.', 'ðə ˌpriːzɛnˈteɪʃən wʌz ɪnˈkrɛdəbli ˈɪnsaɪtfʊl ænd wɛl ˈstrʌktʃərd', 'Bài thuyết trình vô cùng sâu sắc và có cấu trúc tốt.', NULL, 'advanced'),
    (gen_random_uuid(), 'Nevertheless, we should consider the long-term implications.', 'ˌnɛvərðəˈlɛs, wiː ʃʊd kənˈsɪdər ðə ˈlɔːŋtɜːrm ˌɪmplɪˈkeɪʃənz', 'Tuy nhiên, chúng ta nên cân nhắc những hệ quả lâu dài.', NULL, 'advanced');
