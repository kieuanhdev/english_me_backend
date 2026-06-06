-- Per-skill XP tracking — nền móng cho recommendation engine theo điểm yếu.
--
-- XpService.grant() là cửa duy nhất cộng XP. Sau khi insert xp_ledger thành công,
-- service cộng dồn vào bảng này theo mapping sourceType -> skill:
--   sm2_review    -> vocabulary
--   pronunciation -> pronunciation
--   lesson        -> grammar
--   exercise      -> grammar
-- test & daily_goal_bonus KHÔNG quy về skill nào (đa kỹ năng / thưởng) -> bị loại.
--
-- listening chưa có nguồn XP -> không có row, đọc ra mặc định 0 (trung thực, không bịa).

CREATE TABLE user_skill_xp (
    user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill      VARCHAR(32)  NOT NULL,
    xp         INTEGER      NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, skill)
);

-- Backfill từ xp_ledger đã có để user cũ không mất dữ liệu kỹ năng.
INSERT INTO user_skill_xp (user_id, skill, xp)
SELECT user_id,
       CASE source_type
           WHEN 'sm2_review'    THEN 'vocabulary'
           WHEN 'pronunciation' THEN 'pronunciation'
           WHEN 'lesson'        THEN 'grammar'
           WHEN 'exercise'      THEN 'grammar'
       END AS skill,
       SUM(amount) AS xp
FROM xp_ledger
WHERE source_type IN ('sm2_review', 'pronunciation', 'lesson', 'exercise')
GROUP BY user_id, skill;
