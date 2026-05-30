-- =============================================================================
-- V28 — Level Checkpoint Test (cơ chế lên cấp CEFR nội sinh)
-- =============================================================================
-- Bám KE_HOACH_NANG_CAP_HOC_TAP.md §3.4 (đã đơn giản hoá theo phản biện):
--   * Checkpoint RÚT CÂU từ chính các activity phase='quiz' của lesson trong level
--     → KHÔNG cần QuestionAdapter, KHÔNG cần bảng ngân hàng câu hỏi riêng.
--   * Mở khi độ phủ unit ≥ required_unit_progress (mặc định 0.8).
--   * Pass ≥ pass_score (75) → nâng current_level + 100 XP (level_bonus, idempotent).
-- =============================================================================

-- ── Cấu hình bài checkpoint cho mỗi level ────────────────────────────────────
CREATE TABLE level_checkpoint_tests (
    id                     VARCHAR(64)  PRIMARY KEY,
    level_code             VARCHAR(2)   NOT NULL UNIQUE REFERENCES cefr_levels(code),
    title                  VARCHAR(160) NOT NULL,
    question_count         INT          NOT NULL DEFAULT 20,
    pass_score             SMALLINT     NOT NULL DEFAULT 75,
    required_unit_progress NUMERIC(4,3) NOT NULL DEFAULT 0.800,
    is_active              BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at             TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ── Lịch sử nộp checkpoint của user ──────────────────────────────────────────
CREATE TABLE checkpoint_test_attempts (
    id            BIGSERIAL    PRIMARY KEY,
    user_id       UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    test_id       VARCHAR(64)  NOT NULL REFERENCES level_checkpoint_tests(id) ON DELETE CASCADE,
    level_code    VARCHAR(2)   NOT NULL,
    score         SMALLINT     NOT NULL,
    passed        BOOLEAN      NOT NULL,
    leveled_up    BOOLEAN      NOT NULL DEFAULT FALSE,
    answers       JSONB        NOT NULL DEFAULT '[]'::jsonb,
    attempted_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cta_user_level ON checkpoint_test_attempts(user_id, level_code, attempted_at DESC);

-- ── Seed 1 checkpoint cho mỗi level A1–C1 ────────────────────────────────────
-- (C2 là cấp cuối, không cần checkpoint lên cấp.)
INSERT INTO level_checkpoint_tests (id, level_code, title, question_count, pass_score, required_unit_progress) VALUES
    ('checkpoint-A1', 'A1', 'Kiểm tra cuối cấp A1', 15, 75, 0.800),
    ('checkpoint-A2', 'A2', 'Kiểm tra cuối cấp A2', 20, 75, 0.800),
    ('checkpoint-B1', 'B1', 'Kiểm tra cuối cấp B1', 20, 75, 0.800),
    ('checkpoint-B2', 'B2', 'Kiểm tra cuối cấp B2', 20, 75, 0.800),
    ('checkpoint-C1', 'C1', 'Kiểm tra cuối cấp C1', 20, 75, 0.800);
