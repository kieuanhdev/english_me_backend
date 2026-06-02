-- =============================================================================
-- V40 — Seed bổ sung câu hỏi Placement Test (A1–B2, grammar + vocabulary).
-- =============================================================================
-- Bám HE_THONG_KIEM_TRA_TRINH_DO.md §C (Kế hoạch seed dữ liệu):
--   * Bài kiểm tra ĐẦU VÀO chấm tối đa B2 → đề chỉ rút câu A1–B2.
--   * Hiện trạng V16: mỗi cấp A1–B2 chỉ 3 grammar + 2 vocabulary → vocabulary
--     bị dùng hết khi rút 2/cấp, không còn câu để ORDER BY RANDOM() đa dạng.
--   * Migration này thêm +3 grammar và +4 vocabulary mỗi cấp A1–B2
--     → sau seed mỗi cấp ≥ 6 grammar + ≥ 6 vocabulary (pool A1–B2: 20 → 48 câu).
--   * skill_category dùng LOWERCASE ('grammar'/'vocabulary') để khớp query
--     của PlacementTestService (V18 đã chuẩn hoá lowercase).
--   * KHÔNG seed C1/C2 cho đề đầu vào (đã bỏ khỏi đề).
-- =============================================================================

-- ── A1 — grammar (+3) ────────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A1', 'grammar',    'They ___ my friends.',                        '{"A":"am","B":"is","C":"are","D":"be"}'::jsonb,                                        'C', 'They di voi are.',                          CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'grammar',    'I have two ___.',                             '{"A":"book","B":"books","C":"bookes","D":"a book"}'::jsonb,                            'B', 'So nhieu dem duoc -> them -s.',             CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'grammar',    'This is ___ apple.',                          '{"A":"a","B":"an","C":"the","D":"some"}'::jsonb,                                       'B', 'Truoc nguyen am -> an.',                    CURRENT_TIMESTAMP);

-- ── A1 — vocabulary (+4) ─────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A1', 'vocabulary', 'What does "water" mean?',                     '{"A":"lua","B":"nuoc","C":"gio","D":"dat"}'::jsonb,                                    'B', 'Water = nuoc.',                             CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'vocabulary', 'What does "dog" mean?',                       '{"A":"con meo","B":"con cho","C":"con ga","D":"con ca"}'::jsonb,                       'B', 'Dog = con cho.',                            CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'vocabulary', 'What does "red" mean?',                       '{"A":"mau xanh","B":"mau vang","C":"mau do","D":"mau den"}'::jsonb,                    'C', 'Red = mau do.',                             CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'vocabulary', 'What does "house" mean?',                     '{"A":"ngoi nha","B":"con duong","C":"khu vuon","D":"cua hang"}'::jsonb,                'A', 'House = ngoi nha.',                         CURRENT_TIMESTAMP);

-- ── A2 — grammar (+3) ────────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A2', 'grammar',    'She is ___ than her sister.',                 '{"A":"tall","B":"taller","C":"tallest","D":"more tall"}'::jsonb,                       'B', 'So sanh hon tinh tu ngan -> -er.',          CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'grammar',    'We ___ go to the beach tomorrow.',            '{"A":"will","B":"was","C":"were","D":"did"}'::jsonb,                                   'A', 'Tuong lai don -> will + V.',                CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'grammar',    'There aren''t ___ apples left.',              '{"A":"some","B":"any","C":"much","D":"a"}'::jsonb,                                     'B', 'Phu dinh dem duoc -> any.',                 CURRENT_TIMESTAMP);

-- ── A2 — vocabulary (+4) ─────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A2', 'vocabulary', 'Synonym of "big"?',                           '{"A":"small","B":"large","C":"tiny","D":"short"}'::jsonb,                              'B', 'Big = large.',                              CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'vocabulary', 'Antonym of "happy"?',                         '{"A":"glad","B":"sad","C":"kind","D":"nice"}'::jsonb,                                  'B', 'Happy <-> sad.',                            CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'vocabulary', 'What does "buy" mean?',                       '{"A":"ban","B":"mua","C":"cho","D":"muon"}'::jsonb,                                    'B', 'Buy = mua.',                                CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'vocabulary', 'What does "quickly" mean?',                   '{"A":"cham rai","B":"nhanh chong","C":"yen lang","D":"can than"}'::jsonb,              'B', 'Quickly = nhanh chong.',                    CURRENT_TIMESTAMP);

-- ── B1 — grammar (+3) ────────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B1', 'grammar',    'I have lived here ___ 2010.',                 '{"A":"for","B":"since","C":"from","D":"in"}'::jsonb,                                   'B', 'Since + moc thoi gian.',                    CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'grammar',    'The man ___ lives next door is a doctor.',    '{"A":"which","B":"who","C":"whom","D":"whose"}'::jsonb,                                'B', 'Dai tu quan he chi nguoi lam chu ngu -> who.', CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'grammar',    'If it rains, we ___ stay home.',              '{"A":"will","B":"would","C":"had","D":"have"}'::jsonb,                                 'A', 'Cau dieu kien loai 1 -> will + V.',         CURRENT_TIMESTAMP);

-- ── B1 — vocabulary (+4) ─────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B1', 'vocabulary', 'What does "improve" mean?',                   '{"A":"lam te hon","B":"cai thien","C":"giu nguyen","D":"pha huy"}'::jsonb,             'B', 'Improve = cai thien.',                      CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'vocabulary', 'Synonym of "difficult"?',                     '{"A":"easy","B":"simple","C":"hard","D":"clear"}'::jsonb,                              'C', 'Difficult = hard.',                         CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'vocabulary', 'What does "decision" mean?',                  '{"A":"cau hoi","B":"quyet dinh","C":"loi khuyen","D":"ke hoach"}'::jsonb,              'B', 'Decision = quyet dinh.',                    CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'vocabulary', 'Antonym of "increase"?',                      '{"A":"rise","B":"grow","C":"decrease","D":"expand"}'::jsonb,                           'C', 'Increase <-> decrease.',                    CURRENT_TIMESTAMP);

-- ── B2 — grammar (+3) ────────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B2', 'grammar',    'If I had known, I ___ have come earlier.',    '{"A":"will","B":"would","C":"can","D":"may"}'::jsonb,                                  'B', 'Dieu kien loai 3 -> would have + V3.',      CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'grammar',    'The project must ___ by Friday.',             '{"A":"finish","B":"finishes","C":"be finished","D":"finished"}'::jsonb,               'C', 'Modal + bi dong -> be + V3.',               CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'grammar',    'Not only ___ late, but he also forgot the keys.', '{"A":"he was","B":"was he","C":"he is","D":"is he"}'::jsonb,                       'B', 'Not only + dao ngu -> was he.',             CURRENT_TIMESTAMP);

-- ── B2 — vocabulary (+4) ─────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B2', 'vocabulary', 'What does "inevitable" mean?',                '{"A":"tranh duoc","B":"khong the tranh khoi","C":"hiem co","D":"bat ngo"}'::jsonb,     'B', 'Inevitable = khong the tranh khoi.',        CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'vocabulary', 'Synonym of "reluctant"?',                     '{"A":"eager","B":"willing","C":"unwilling","D":"happy"}'::jsonb,                       'C', 'Reluctant = unwilling (mien cuong).',       CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'vocabulary', 'What does "deteriorate" mean?',               '{"A":"cai thien","B":"xau di","C":"on dinh","D":"phat trien"}'::jsonb,                 'B', 'Deteriorate = xau di.',                     CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'vocabulary', 'Antonym of "abundant"?',                      '{"A":"plentiful","B":"scarce","C":"rich","D":"ample"}'::jsonb,                         'B', 'Abundant <-> scarce (khan hiem).',          CURRENT_TIMESTAMP);
