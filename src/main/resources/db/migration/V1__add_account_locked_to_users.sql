-- Tạo bảng users gốc
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    avatar_url TEXT,
    cefr_level VARCHAR(10),
    is_onboarded BOOLEAN NOT NULL DEFAULT false,
    total_xp INTEGER NOT NULL DEFAULT 0,
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_active_date DATE,
    created_at TIMESTAMP
);

-- Khoa tai khoan (admin), tach biet voi is_onboarded (placement test)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS account_locked BOOLEAN NOT NULL DEFAULT false;
