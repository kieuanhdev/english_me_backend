-- V43 — In-app notification (polling, no FCM). Source of truth cho chuông.
-- Row hoặc seed (demo/system) hoặc sinh lazy từ state người dùng (thẻ đến hạn,
-- streak, placement) với dedup_key để is_read sống sót, không trùng trong cửa sổ.
CREATE TABLE notification (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type         VARCHAR(40) NOT NULL,          -- REVIEW_DUE | STREAK_RISK | LESSON_UNLOCKED | PLACEMENT_SUGGESTION | SYSTEM
    title        VARCHAR(200) NOT NULL,
    body         TEXT NOT NULL,
    action_route VARCHAR(200),                  -- deep-link path cho app (nullable)
    dedup_key    VARCHAR(120) NOT NULL,         -- idempotency key per-user cho row sinh tự động
    is_read      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at      TIMESTAMP,
    CONSTRAINT uq_notification_user_dedup UNIQUE (user_id, dedup_key)
);

CREATE INDEX idx_notification_user_unread  ON notification(user_id, is_read);
CREATE INDEX idx_notification_user_created ON notification(user_id, created_at DESC);
