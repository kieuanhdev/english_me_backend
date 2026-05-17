-- XP và streak tracking cho users
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_xp INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS current_streak INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS longest_streak INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_active_date DATE;

-- Lịch sử XP theo ngày (cho chart)
CREATE TABLE xp_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    xp INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT uq_xp_history_user_date UNIQUE (user_id, activity_date)
);

CREATE INDEX idx_xp_history_user_date ON xp_history(user_id, activity_date DESC);

-- Badges
CREATE TABLE badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    condition_type VARCHAR(50) NOT NULL
);

CREATE TABLE user_badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badge(id),
    earned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_badge UNIQUE (user_id, badge_id)
);

-- Seed badges cơ bản
INSERT INTO badge (name, description, icon_url, condition_type) VALUES
    ('First Step', 'Hoàn thành bài học đầu tiên', null, 'first_lesson'),
    ('Week Streak', '7 ngày liên tiếp học', null, 'streak_7'),
    ('Month Streak', '30 ngày liên tiếp học', null, 'streak_30'),
    ('XP Milestone', 'Đạt 1000 XP', null, 'xp_1000'),
    ('Grammar Pro', 'Hoàn thành 10 bài ngữ pháp', null, 'grammar_10');
