-- ============================================================================
-- V72 — Chuẩn hóa điều kiện badge + seed thêm mốc thành tựu (auto-award).
--
-- Trước: condition_type gộp cả loại + ngưỡng ('streak_7', 'xp_1000'), condition_value NULL
--        -> code khó parse, không award được.
-- Sau:   condition_type = LOẠI thuần ('streak' | 'total_xp' | 'cefr_level' | 'first_lesson')
--        condition_value = ngưỡng số (streak: số ngày; total_xp: XP; cefr_level: bậc 1..6).
--
-- cefr_level bậc: A1=1, A2=2, B1=3, B2=4, C1=5, C2=6 (BadgeService map ngược lại).
-- first_lesson: condition_value bỏ qua (NULL/0).
-- ============================================================================

-- 1) Chuyển 5 badge seed cũ sang format mới (idempotent theo tên).
UPDATE badge SET condition_type = 'first_lesson', condition_value = NULL
    WHERE condition_type = 'first_lesson';
UPDATE badge SET condition_type = 'streak', condition_value = 7
    WHERE condition_type = 'streak_7';
UPDATE badge SET condition_type = 'streak', condition_value = 30
    WHERE condition_type = 'streak_30';
UPDATE badge SET condition_type = 'total_xp', condition_value = 1000
    WHERE condition_type = 'xp_1000';
-- 'grammar_10' chưa hỗ trợ auto-award (đếm bài grammar) -> tắt để không hiện badge chết.
UPDATE badge SET is_active = false
    WHERE condition_type = 'grammar_10';

-- 2) Seed thêm mốc thành tựu. Chỉ chèn nếu CHƯA tồn tại badge cùng (type,value)
--    -> chạy lại migration / trùng seed không nhân đôi.
INSERT INTO badge (name, description, icon_url, condition_type, condition_value, is_active)
SELECT v.name, v.description, NULL, v.ctype, v.cvalue, true
FROM (VALUES
    -- Streak (user yêu cầu 10/20/40)
    ('Kiên trì 3 ngày',   'Học 3 ngày liên tiếp',   'streak',     3),
    ('Streak 10 ngày',    'Học 10 ngày liên tiếp',  'streak',    10),
    ('Streak 20 ngày',    'Học 20 ngày liên tiếp',  'streak',    20),
    ('Streak 40 ngày',    'Học 40 ngày liên tiếp',  'streak',    40),
    -- Tổng XP
    ('Tân binh 100 XP',   'Tích lũy 100 XP',        'total_xp',  100),
    ('500 XP',            'Tích lũy 500 XP',        'total_xp',  500),
    ('5000 XP',           'Tích lũy 5000 XP',       'total_xp', 5000),
    -- Qua CEFR level
    ('Đạt A2',            'Lên trình độ A2',        'cefr_level',  2),
    ('Đạt B1',            'Lên trình độ B1',        'cefr_level',  3),
    ('Đạt B2',            'Lên trình độ B2',        'cefr_level',  4),
    ('Đạt C1',            'Lên trình độ C1',        'cefr_level',  5)
) AS v(name, description, ctype, cvalue)
WHERE NOT EXISTS (
    SELECT 1 FROM badge b
    WHERE b.condition_type = v.ctype AND b.condition_value = v.cvalue
);
