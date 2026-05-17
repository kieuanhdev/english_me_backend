-- Module 10: Home Dashboard Content
-- Quản lý nội dung động hiển thị trên Home Mobile.

-- ── Word of Day (lên lịch từ vựng theo ngày) ─────────────────────────────────
CREATE TABLE home_word_of_day (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scheduled_date DATE NOT NULL,
    word_id UUID NOT NULL REFERENCES vocabulary_word(id) ON DELETE CASCADE,
    level VARCHAR(10),
    note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_home_word_of_day_date_level UNIQUE (scheduled_date, level)
);

CREATE INDEX idx_home_word_of_day_date ON home_word_of_day(scheduled_date DESC);

-- ── Recommendation theo CEFR (override mặc định trong HomeDashboardService) ─
CREATE TABLE home_recommendation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    level VARCHAR(10) NOT NULL,                  -- A1, A2, B1, B2, C1, C2
    type VARCHAR(50) NOT NULL,                   -- vocabulary | grammar | pronunciation | exercise | test
    title VARCHAR(200) NOT NULL,
    description TEXT,
    action_url VARCHAR(500),
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_home_recommendation_level ON home_recommendation(level, sort_order);

-- ── Banner (lịch hiển thị) ──────────────────────────────────────────────────
CREATE TABLE home_banner (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    image_url TEXT NOT NULL,
    action_url VARCHAR(500),
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_home_banner_active ON home_banner(is_active, start_at DESC);
