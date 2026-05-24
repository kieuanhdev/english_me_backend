-- ─────────────────────────────────────────────────────────────────────────────
-- V22 — XP rules (cấu hình động giá trị XP qua DB)
--
-- Thay vì hardcode "3 XP/câu đúng" trong code Java, lưu vào DB để admin chỉnh
-- bằng SQL hoặc admin endpoint mà không cần redeploy.
--
-- Schema mềm dẻo đủ cho:
--   - test/exercise: per_correct + accuracy_bonus khi accuracy ≥ threshold
--   - daily_goal_bonus: chỉ dùng base_amount
--   - các bonus khác (path/level/streak/pronunciation): chỉ dùng base_amount
--
-- KHÔNG áp dụng cho:
--   - lesson XP: vẫn đọc từ learning_lessons.xp_reward (mỗi lesson có XP riêng)
--   - sm2_review XP: vẫn dùng SM2Service.xpForQuality vì phụ thuộc rating cụ thể
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS xp_rules (
    source_type            VARCHAR(40)  PRIMARY KEY,
    base_amount            INT          NOT NULL DEFAULT 0,
    per_correct            INT          NOT NULL DEFAULT 0,
    accuracy_bonus         INT          NOT NULL DEFAULT 0,
    accuracy_threshold_pct SMALLINT     NOT NULL DEFAULT 0,
    daily_cap              INT,
    enabled                BOOLEAN      NOT NULL DEFAULT TRUE,
    description            VARCHAR(255),
    updated_at             TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Seed giá trị mặc định KHỚP chính xác với hardcode hiện tại (không đổi hành vi sau migration).
-- UserTestService.xpForResult: 3 XP/câu + 10 bonus nếu accuracy ≥ 80.
-- ExerciseService.xpForResult: 2 XP/câu + 5 bonus nếu accuracy = 100.
-- XpService.DAILY_GOAL_BONUS = 5.
INSERT INTO xp_rules (source_type, base_amount, per_correct, accuracy_bonus, accuracy_threshold_pct, daily_cap, enabled, description)
VALUES
    ('test',             0,  3,  10, 80,  NULL, TRUE, '3 XP per correct + 10 bonus if accuracy >= 80%'),
    ('exercise',         0,  2,  5,  100, NULL, TRUE, '2 XP per correct + 5 bonus if accuracy = 100%'),
    ('daily_goal_bonus', 5,  0,  0,  0,   NULL, TRUE, '+5 XP one-time when earned_xp first reaches target_xp of the day'),
    ('path_bonus',       30, 0,  0,  0,   NULL, TRUE, '+30 XP one-time when finishing a learning path'),
    ('level_bonus',      100,0,  0,  0,   NULL, TRUE, '+100 XP one-time when finishing a CEFR level'),
    ('streak_bonus',     10, 0,  0,  0,   NULL, TRUE, '+10 XP every 7-day streak milestone'),
    ('pronunciation',    5,  0,  0,  0,   50,   TRUE, '+5 XP per pronunciation practice >= 70 score (capped 50/day)')
ON CONFLICT (source_type) DO NOTHING;
