-- =============================================================================
-- V68 — Seed câu hỏi Placement Test cấp C1 (grammar + vocabulary).
-- =============================================================================
-- CAT cần pool C1 để chấm tới C1 (đề cương cam kết A1–C1).
--   * 8 grammar + 8 vocabulary, difficulty = 2.0 (b_i của C1 trong IRT 1PL).
--   * skill_category LOWERCASE khớp PlacementTestService (V18 chuẩn hoá).
--   * difficulty đặt tường minh = 2.0 vì cột NOT NULL (V67).
-- =============================================================================

-- ── C1 — grammar (8) ─────────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, difficulty, created_at) VALUES
    (gen_random_uuid(), 'C1', 'grammar', 'Hardly ___ the meeting started when the fire alarm rang.',        '{"A":"had","B":"has","C":"did","D":"have"}'::jsonb,                                  'A', 'Hardly + dao ngu qua khu hoan thanh -> had.',           2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', '___ his wealth, he is far from happy.',                            '{"A":"Despite","B":"Although","C":"However","D":"Because"}'::jsonb,                  'A', 'Despite + danh tu (nhuong bo).',                         2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'It is high time we ___ this problem seriously.',                   '{"A":"take","B":"took","C":"have taken","D":"are taking"}'::jsonb,                   'B', 'It is high time + qua khu don (gia dinh cach).',         2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'Were it not for your help, I ___ failed.',                         '{"A":"would have","B":"will have","C":"had","D":"would"}'::jsonb,                    'A', 'Dao ngu dieu kien loai 3 -> would have + V3.',           2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'The report, ___ by Friday, covers all key findings.',             '{"A":"submitting","B":"submitted","C":"to submit","D":"submits"}'::jsonb,            'B', 'Phan tu qua khu rut gon menh de bi dong.',              2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'Never before ___ such a remarkable performance.',                 '{"A":"I have seen","B":"have I seen","C":"I saw","D":"did I saw"}'::jsonb,            'B', 'Never before + dao ngu -> have I seen.',                2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'She insisted that he ___ present at the ceremony.',                '{"A":"is","B":"was","C":"be","D":"were"}'::jsonb,                                    'C', 'Insist that + gia dinh cach -> be (nguyen mau).',       2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'grammar', 'So complex ___ that few could grasp it.',                          '{"A":"the theory was","B":"was the theory","C":"the theory","D":"theory was"}'::jsonb, 'B', 'So + tinh tu + dao ngu -> was the theory.',            2.0, CURRENT_TIMESTAMP);

-- ── C1 — vocabulary (8) ──────────────────────────────────────────────────────
INSERT INTO questions (id, cefr_level, skill_category, question, options, correct_answer, explanation, difficulty, created_at) VALUES
    (gen_random_uuid(), 'C1', 'vocabulary', 'What does "ubiquitous" mean?',                  '{"A":"hiem co","B":"co mat khap noi","C":"vo hinh","D":"tam thoi"}'::jsonb,           'B', 'Ubiquitous = co mat khap noi.',                          2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'Synonym of "meticulous"?',                      '{"A":"careless","B":"thorough","C":"rapid","D":"vague"}'::jsonb,                      'B', 'Meticulous = thorough (ti mi).',                         2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'What does "alleviate" mean?',                   '{"A":"lam tram trong","B":"giam nhe","C":"keo dai","D":"phot lo"}'::jsonb,            'B', 'Alleviate = giam nhe.',                                  2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'Antonym of "transparent"?',                     '{"A":"clear","B":"obvious","C":"opaque","D":"plain"}'::jsonb,                         'C', 'Transparent <-> opaque (mo duc).',                       2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'What does "pragmatic" mean?',                   '{"A":"ly tuong","B":"thuc te","C":"bi quan","D":"mo ho"}'::jsonb,                     'B', 'Pragmatic = thuc te (thuc dung).',                       2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'Synonym of "scrutinize"?',                      '{"A":"glance","B":"examine","C":"ignore","D":"approve"}'::jsonb,                      'B', 'Scrutinize = examine ky luong.',                         2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'What does "resilient" mean?',                   '{"A":"de vo","B":"kien cuong","C":"yeu duoi","D":"luoi bieng"}'::jsonb,               'B', 'Resilient = kien cuong (phuc hoi nhanh).',               2.0, CURRENT_TIMESTAMP),
    (gen_random_uuid(), 'C1', 'vocabulary', 'Antonym of "concise"?',                         '{"A":"brief","B":"succinct","C":"verbose","D":"terse"}'::jsonb,                       'C', 'Concise <-> verbose (dai dong).',                        2.0, CURRENT_TIMESTAMP);
