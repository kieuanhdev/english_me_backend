-- Module 11: Announcement & Push Notification

-- ── Device tokens (1 user có thể có nhiều device) ───────────────────────────
CREATE TABLE user_device_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL DEFAULT 'unknown',  -- android | ios | web | unknown
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_device_token UNIQUE (token)
);

CREATE INDEX idx_user_device_token_user ON user_device_token(user_id);

-- ── Push notification history ───────────────────────────────────────────────
CREATE TABLE admin_notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    image_url TEXT,
    action_url VARCHAR(500),
    segment_type VARCHAR(50) NOT NULL,        -- broadcast | cefr | inactive | custom
    segment_value VARCHAR(200),               -- e.g. "A1" cho cefr, "14" cho inactive >14 ngày
    target_count INTEGER NOT NULL DEFAULT 0,
    success_count INTEGER NOT NULL DEFAULT 0,
    failure_count INTEGER NOT NULL DEFAULT 0,
    sent_by_email VARCHAR(255),
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_notification_sent_at ON admin_notification(sent_at DESC);

-- ── Announcement (banner trong app, không push) ─────────────────────────────
CREATE TABLE app_announcement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'info',  -- info | warning | success
    start_at TIMESTAMP NOT NULL,
    end_at TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by_email VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_app_announcement_active ON app_announcement(is_active, start_at DESC);
