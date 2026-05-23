-- =============================================================================
-- V16 — Demo seed cho buổi bảo vệ đồ án
-- =============================================================================
-- Phạm vi:
--   * 5 user demo (mỗi CEFR A1/A2/B1/B2/C1), firebaseUid giả `demo_*`.
--   * 1 user có 1000 XP để trigger badge "XP Milestone" (auto-award).
--   * 1 user có streak 7 ngày, 1 user có XP history 7 ngày để hiện chart.
--   * 30 placement test questions (5/CEFR x 6 mức = 30 câu).
-- Lưu ý:
--   * Vocabulary topic + word đã seed ở V9 — không lặp lại.
--   * Pronunciation exercises đã seed ở V7.
--   * Exercise questions đã seed ở V10.
--   * Desks (A1..C2) đã seed ở V2.
--   * Login mobile thật vẫn cần Firebase Auth account thật — đây chỉ là
--     data demo để admin panel có số liệu khi thuyết trình.
-- Flyway chạy migration đúng 1 lần theo version nên không cần ON CONFLICT
-- phức tạp; vẫn dùng ON CONFLICT DO NOTHING ở những bảng có unique để an toàn.
-- =============================================================================

-- ── 1. Demo users ───────────────────────────────────────────────────────────
INSERT INTO users (id, firebase_uid, email, full_name, avatar_url, cefr_level,
                   is_onboarded, account_locked, total_xp, current_streak,
                   longest_streak, last_active_date, created_at)
VALUES
    ('11111111-1111-1111-1111-000000000001', 'demo_a1', 'demo_a1@englishme.local', 'Demo A1 User',
     NULL, 'A1', TRUE, FALSE, 50, 0, 0, NULL, CURRENT_TIMESTAMP),
    ('11111111-1111-1111-1111-000000000002', 'demo_a2', 'demo_a2@englishme.local', 'Demo A2 User',
     NULL, 'A2', TRUE, FALSE, 200, 0, 0, NULL, CURRENT_TIMESTAMP),
    ('11111111-1111-1111-1111-000000000003', 'demo_b1', 'demo_b1@englishme.local', 'Demo B1 User',
     NULL, 'B1', TRUE, FALSE, 500, 7, 7, CURRENT_DATE, CURRENT_TIMESTAMP),
    ('11111111-1111-1111-1111-000000000004', 'demo_b2', 'demo_b2@englishme.local', 'Demo B2 User',
     NULL, 'B2', TRUE, FALSE, 1000, 3, 7, CURRENT_DATE, CURRENT_TIMESTAMP),
    ('11111111-1111-1111-1111-000000000005', 'demo_c1', 'demo_c1@englishme.local', 'Demo C1 User',
     NULL, 'C1', TRUE, FALSE, 2500, 1, 14, CURRENT_DATE, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ── 2. XP history (cho chart 7 ngày gần nhất) ───────────────────────────────
INSERT INTO xp_history (user_id, activity_date, xp)
VALUES
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 6, 100),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 5, 150),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 4,  80),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 3, 200),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 2, 120),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE - 1, 180),
    ('11111111-1111-1111-1111-000000000004', CURRENT_DATE,     170),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 6, 300),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 5, 280),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 4, 350),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 3, 400),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 2, 420),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE - 1, 380),
    ('11111111-1111-1111-1111-000000000005', CURRENT_DATE,     370)
ON CONFLICT (user_id, activity_date) DO NOTHING;

-- ── 3. Placement test questions (5/CEFR x 6 mức = 30 câu) ───────────────────
-- A1
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A1', 'Grammar',    'I ___ a student.',                            '{"A":"am","B":"is","C":"are","D":"be"}'::jsonb,                                        'A', 'Chu ngu I -> am.',                          CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'Grammar',    'She ___ to school every day.',                '{"A":"go","B":"goes","C":"going","D":"gone"}'::jsonb,                                  'B', 'Ngoi thu 3 so it -> them -s.',              CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'Vocabulary', 'What does "cat" mean?',                       '{"A":"con cho","B":"con meo","C":"con bo","D":"con ga"}'::jsonb,                        'B', 'Cat = con meo.',                            CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'Vocabulary', 'What does "book" mean?',                      '{"A":"ban","B":"ghe","C":"sach","D":"cua"}'::jsonb,                                     'C', 'Book = sach.',                              CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A1', 'Grammar',    'There ___ a cat on the table.',               '{"A":"am","B":"is","C":"are","D":"be"}'::jsonb,                                        'B', 'There is + danh tu so it.',                 CURRENT_TIMESTAMP);
-- A2
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'A2', 'Grammar',    'I ___ to Paris last year.',                   '{"A":"go","B":"goes","C":"went","D":"gone"}'::jsonb,                                   'C', 'Qua khu don gian -> went.',                 CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'Grammar',    'She has ___ her homework.',                   '{"A":"do","B":"did","C":"done","D":"does"}'::jsonb,                                    'C', 'have/has + past participle.',               CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'Vocabulary', 'Synonym of "begin"?',                         '{"A":"end","B":"finish","C":"start","D":"stop"}'::jsonb,                               'C', 'Begin = start.',                            CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'Vocabulary', 'What does "frequently" mean?',                '{"A":"rarely","B":"sometimes","C":"often","D":"never"}'::jsonb,                        'C', 'Frequently = thuong xuyen.',                CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'A2', 'Grammar',    'They ___ watching TV now.',                   '{"A":"is","B":"am","C":"are","D":"be"}'::jsonb,                                        'C', 'They -> are.',                              CURRENT_TIMESTAMP);
-- B1
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B1', 'Grammar',    'If I ___ rich, I would travel the world.',    '{"A":"am","B":"was","C":"were","D":"be"}'::jsonb,                                      'C', 'Cau dieu kien loai 2 -> were.',             CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'Grammar',    'She suggested ___ earlier.',                  '{"A":"leave","B":"leaving","C":"to leave","D":"left"}'::jsonb,                         'B', 'suggest + V-ing.',                          CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'Vocabulary', 'Antonym of "ancient"?',                       '{"A":"old","B":"modern","C":"historical","D":"traditional"}'::jsonb,                   'B', 'Ancient <-> modern.',                       CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'Vocabulary', 'What does "collaborative" mean?',             '{"A":"working alone","B":"working together","C":"competing","D":"disagreeing"}'::jsonb,'B', 'Collaborative = hop tac.',                   CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B1', 'Grammar',    'The report ___ by the team last week.',       '{"A":"wrote","B":"was written","C":"has written","D":"is written"}'::jsonb,            'B', 'Bi dong qua khu.',                          CURRENT_TIMESTAMP);
-- B2
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'B2', 'Grammar',    'He is used to ___ late.',                     '{"A":"work","B":"works","C":"working","D":"worked"}'::jsonb,                           'C', 'be used to + V-ing.',                       CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'Grammar',    'No sooner ___ she arrived than it started raining.', '{"A":"had","B":"has","C":"did","D":"was"}'::jsonb,                              'A', 'No sooner + had + S + V3.',                 CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'Vocabulary', 'What does "meticulous" mean?',                '{"A":"careless","B":"detailed","C":"lazy","D":"quick"}'::jsonb,                        'B', 'Meticulous = ty my.',                       CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'Vocabulary', 'Synonym of "ambiguous"?',                     '{"A":"clear","B":"unclear","C":"specific","D":"direct"}'::jsonb,                       'B', 'Ambiguous = mo ho.',                        CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'B2', 'Grammar',    'I wish I ___ more time yesterday.',           '{"A":"have","B":"had","C":"had had","D":"have had"}'::jsonb,                           'C', 'wish + past perfect cho qua khu.',          CURRENT_TIMESTAMP);
-- C1
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'C1', 'Grammar',    'Hardly ___ the door when the phone rang.',    '{"A":"I had closed","B":"had I closed","C":"I closed","D":"did I close"}'::jsonb,      'B', 'Hardly + had + S + V3.',                    CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'Grammar',    'Were it not ___ his help, we would have failed.', '{"A":"for","B":"of","C":"to","D":"with"}'::jsonb,                                  'A', 'Were it not FOR his help.',                 CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'Vocabulary', 'What does "ubiquitous" mean?',                '{"A":"rare","B":"everywhere","C":"hidden","D":"old"}'::jsonb,                          'B', 'Ubiquitous = co mat khap noi.',             CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'Vocabulary', 'Antonym of "ephemeral"?',                     '{"A":"brief","B":"temporary","C":"permanent","D":"sudden"}'::jsonb,                    'C', 'Ephemeral <-> permanent.',                  CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'Grammar',    'Not until I saw it ___ I believe it.',        '{"A":"did","B":"do","C":"have","D":"will"}'::jsonb,                                    'A', 'Not until + clause -> dao ngu.',            CURRENT_TIMESTAMP);
-- C2
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, created_at) VALUES
    (gen_random_uuid(), 'C2', 'Vocabulary', 'What does "perspicacious" mean?',             '{"A":"sharply perceptive","B":"slow","C":"foolish","D":"dull"}'::jsonb,                'A', 'Perspicacious = sang suot.',                CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C2', 'Vocabulary', 'Synonym of "obfuscate"?',                     '{"A":"clarify","B":"confuse","C":"explain","D":"reveal"}'::jsonb,                      'B', 'Obfuscate = lam roi ren.',                  CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C2', 'Grammar',    'Such ___ the noise that we could not sleep.', '{"A":"was","B":"is","C":"had","D":"were"}'::jsonb,                                     'A', 'Such + was + S (dao ngu).',                 CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C2', 'Grammar',    '___ all his efforts, the project failed.',    '{"A":"Despite","B":"Although","C":"Because of","D":"Since"}'::jsonb,                   'A', 'Despite + N.',                              CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C2', 'Vocabulary', 'What does "quintessential" mean?',            '{"A":"average","B":"rare","C":"most typical","D":"poor"}'::jsonb,                      'C', 'Quintessential = dac trung nhat.',          CURRENT_TIMESTAMP);
