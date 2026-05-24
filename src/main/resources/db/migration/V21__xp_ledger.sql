-- ─────────────────────────────────────────────────────────────────────────────
-- V21 — XP Ledger (per-transaction, idempotent)
--
-- Bổ sung cơ chế chống cộng XP trùng + lịch sử transaction chi tiết.
-- xp_history (cộng dồn theo ngày) vẫn được giữ cho chart streak.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) users.last_xp_date — ngày cuối cùng user kiếm được XP (phục vụ streak chuẩn theo spec)
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_xp_date DATE;

-- 2) user_daily_goals.daily_bonus_granted — chống cộng bonus 5 XP nhiều lần/ngày
ALTER TABLE user_daily_goals
    ADD COLUMN IF NOT EXISTS daily_bonus_granted BOOLEAN NOT NULL DEFAULT FALSE;

-- 3) xp_ledger — sổ cái XP append-only
CREATE TABLE IF NOT EXISTS xp_ledger (
    id              BIGSERIAL    PRIMARY KEY,
    user_id         UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount          INT          NOT NULL,
    source_type     VARCHAR(40)  NOT NULL,
    source_id       VARCHAR(120) NOT NULL,
    idempotency_key VARCHAR(160) NOT NULL,
    metadata        JSONB        NOT NULL DEFAULT '{}'::jsonb,
    occurred_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_xp_ledger_user_idem UNIQUE (user_id, idempotency_key)
);

CREATE INDEX IF NOT EXISTS idx_xpl_user_date ON xp_ledger(user_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_xpl_source    ON xp_ledger(source_type, source_id);

-- 4) Backfill last_xp_date từ last_active_date (legacy) — để streak không bị reset oan với user cũ.
UPDATE users SET last_xp_date = last_active_date WHERE last_xp_date IS NULL AND last_active_date IS NOT NULL;
