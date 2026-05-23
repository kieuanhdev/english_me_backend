-- Bảng questions được tạo bởi Hibernate ddl-auto=update trước khi dùng Flyway
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cefr_level VARCHAR(255) NOT NULL,
    skill_category VARCHAR(255) NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer VARCHAR(1) NOT NULL,
    explanation TEXT,
    audio_url TEXT,
    passage TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
