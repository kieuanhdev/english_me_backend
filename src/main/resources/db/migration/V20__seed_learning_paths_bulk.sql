-- =============================================================================
-- V20 — Seed thêm 9 path/level (path 02..10) cho A1..C2
-- =============================================================================
-- Mỗi level có sẵn path 01 từ V19. Migration này thêm path 02..10.
-- Mỗi path có 4 activity (listening, reading, speaking, writing) + 4 lesson
-- + 4 lesson_activity payload tối giản.
--
-- Vì FE _demoPathTemplates đã có topic list cho A1/A2/B1/B2, mình dùng đúng
-- tên topic + slug để FE thấy quen. C1/C2 tự tạo dựa trên mục tiêu CEFR.
--
-- Không dùng DO block để giữ migration đơn giản, idempotent (Flyway chạy 1 lần).
-- =============================================================================

-- ── Hàm trợ giúp tạo path + 4 activity + 4 lesson nội tuyến qua VALUES ──────
-- Idea: 1 INSERT cho learning_paths, 1 INSERT cho learning_lessons (4 row/path),
-- 1 INSERT cho learning_path_activities (4 row/path), 1 INSERT cho
-- learning_lesson_activities (4 row/path).
--
-- Để gọn, ta định nghĩa bảng tạm chứa danh sách (level, order, slug, title, desc)
-- rồi expand qua CTE.

WITH topic_seed (level_code, display_order, slug, title, description) AS (
    VALUES
    -- ── A1: 9 topic (02..10) ────────────────────────────────────────────────
    ('A1', 2, 'family',     'Family and friends',    'Talk about people, relationships, and basic descriptions.'),
    ('A1', 3, 'daily-life', 'Daily life',            'Describe routines, times, and simple habits.'),
    ('A1', 4, 'classroom',  'Classroom English',     'Follow classroom instructions and ask for help.'),
    ('A1', 5, 'food-drink', 'Food and drinks',       'Order simple food and talk about likes.'),
    ('A1', 6, 'home',       'My home',               'Name rooms, furniture, and describe where things are.'),
    ('A1', 7, 'places',     'Places in town',        'Ask about familiar places and simple directions.'),
    ('A1', 8, 'free-time',  'Free time',             'Talk about hobbies, sports, and weekend activities.'),
    ('A1', 9, 'shopping',   'Simple shopping',       'Ask prices, colors, sizes, and quantities.'),
    ('A1',10, 'review',     'A1 mixed review',       'Review core A1 patterns across all skills.'),

    -- ── A2: 9 topic (02..10) ────────────────────────────────────────────────
    ('A2', 2, 'travel',       'Travel basics',         'Ask for directions, book rooms, and handle tickets.'),
    ('A2', 3, 'shopping',     'Shopping choices',      'Compare prices, sizes, and simple product details.'),
    ('A2', 4, 'health',       'Health and appointments','Describe symptoms and arrange a short appointment.'),
    ('A2', 5, 'work',         'Work routines',         'Talk about jobs, tasks, and workplace habits.'),
    ('A2', 6, 'past-events',  'Past events',           'Tell short stories about yesterday or last weekend.'),
    ('A2', 7, 'weather',      'Weather and seasons',   'Understand forecasts and describe seasonal plans.'),
    ('A2', 8, 'city-life',    'City life',             'Use transport, places, and local service language.'),
    ('A2', 9, 'food',         'Eating out',            'Order food, ask about ingredients, and review meals.'),
    ('A2',10, 'review',       'A2 spiral review',      'Mix the strongest patterns from all A2 topics.'),

    -- ── B1: 9 topic (02..10) ────────────────────────────────────────────────
    ('B1', 2, 'opinions',        'Giving opinions',         'Explain preferences, reasons, and simple disagreement.'),
    ('B1', 3, 'stories',         'Personal stories',        'Narrate events with sequence and detail.'),
    ('B1', 4, 'study-work',      'Study and work goals',    'Discuss plans, progress, and challenges.'),
    ('B1', 5, 'media',           'News and media',          'Read short reports and summarize key points.'),
    ('B1', 6, 'problem-solving', 'Solving problems',        'Describe issues and suggest practical solutions.'),
    ('B1', 7, 'culture',         'Culture and customs',     'Compare habits and explain cultural experiences.'),
    ('B1', 8, 'technology',      'Everyday technology',     'Talk about apps, devices, and online safety.'),
    ('B1', 9, 'interviews',      'Interview practice',      'Answer common study and job interview prompts.'),
    ('B1',10, 'review',          'B1 fluency review',       'Combine opinion, story, and problem-solving tasks.'),

    -- ── B2: 9 topic (02..10) ────────────────────────────────────────────────
    ('B2', 2, 'academic',      'Academic reading',        'Extract claims, evidence, and author purpose.'),
    ('B2', 3, 'presentations', 'Short presentations',     'Plan and deliver clear topic presentations.'),
    ('B2', 4, 'workplace',     'Workplace communication', 'Write updates, reports, and meeting notes.'),
    ('B2', 5, 'social-issues', 'Social issues',           'Discuss causes, effects, and possible responses.'),
    ('B2', 6, 'data',          'Charts and data',         'Describe trends, comparisons, and conclusions.'),
    ('B2', 7, 'negotiation',   'Negotiation',             'Make offers, clarify terms, and reach agreement.'),
    ('B2', 8, 'reviews',       'Critical reviews',        'Review films, products, and services with nuance.'),
    ('B2', 9, 'exam',          'B2 exam tasks',           'Practice integrated exam-style tasks.'),
    ('B2',10, 'review',        'B2 integrated review',    'Mix advanced listening, speaking, reading, and writing.'),

    -- ── C1: 9 topic (02..10) ────────────────────────────────────────────────
    ('C1', 2, 'lectures',       'Lectures and seminars',   'Follow extended academic discourse and take notes.'),
    ('C1', 3, 'persuasion',     'Persuasive writing',      'Build essays with claims, evidence, and rebuttal.'),
    ('C1', 4, 'idioms',         'Idioms in context',       'Use idiomatic expressions naturally and accurately.'),
    ('C1', 5, 'science',        'Science and research',    'Read research summaries and explain methodology.'),
    ('C1', 6, 'business-talks', 'Business discussions',    'Lead meetings, pitches, and stakeholder updates.'),
    ('C1', 7, 'literature',     'Literature snippets',     'Interpret tone, imagery, and authorial intent.'),
    ('C1', 8, 'global-issues',  'Global issues',           'Debate complex topics with structured arguments.'),
    ('C1', 9, 'register',       'Register and tone',       'Switch between formal and informal English.'),
    ('C1',10, 'review',         'C1 mastery review',       'Integrated C1 review across all four skills.'),

    -- ── C2: 9 topic (02..10) ────────────────────────────────────────────────
    ('C2', 2, 'analysis',     'Critical analysis',       'Deconstruct texts for nuance, bias, and rhetoric.'),
    ('C2', 3, 'speeches',     'Public speeches',         'Deliver speeches with persuasive sophistication.'),
    ('C2', 4, 'translation',  'Translation craft',       'Translate idiomatic and culturally-loaded texts.'),
    ('C2', 5, 'philosophy',   'Philosophical texts',     'Engage with abstract reasoning and definitions.'),
    ('C2', 6, 'politics',     'Politics and policy',     'Discuss governance, policy, and civic discourse.'),
    ('C2', 7, 'creative',     'Creative writing',        'Compose poetry, short fiction, and essays.'),
    ('C2', 8, 'academic-w',   'Academic writing',        'Produce well-structured academic prose.'),
    ('C2', 9, 'cross-culture','Cross-cultural fluency',  'Navigate cultural nuance with precision.'),
    ('C2',10, 'review',       'C2 mastery review',       'Integrated C2 review across all advanced skills.')
)
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage)
SELECT
    LOWER(level_code) || '-path-' || LPAD(display_order::text, 2, '0') || '-' || slug AS id,
    level_code,
    title,
    description,
    display_order,
    '["listening","reading","speaking","writing"]'::jsonb
FROM topic_seed;

-- ── Seed lessons cho mỗi path (4 lesson/path × 4 skill) ─────────────────────
WITH path_skill (path_id, level_code, skill_code, idx, title_suffix, duration, xp) AS (
    SELECT
        p.id,
        p.level_code,
        s.code,
        s.idx,
        s.title_suffix,
        s.duration,
        s.xp
    FROM learning_paths p
    CROSS JOIN (VALUES
        (1, 'listening', 'Listen for main ideas',     7, 10),
        (2, 'reading',   'Read a short text',         8, 10),
        (3, 'speaking',  'Speak in the situation',    7, 12),
        (4, 'writing',   'Write a short response',    9, 12)
    ) AS s(idx, code, title_suffix, duration, xp)
    WHERE p.display_order BETWEEN 2 AND 10
)
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content)
SELECT
    path_id || '-lesson-' || LPAD(idx::text, 2, '0') AS id,
    level_code,
    skill_code,
    path_id AS unit_id,
    title_suffix,
    'Bài thực hành ' || skill_code || ' theo chủ đề path.',
    duration,
    xp,
    CASE skill_code
        WHEN 'listening' THEN
            jsonb_build_object(
                'instruction','Nghe đoạn ngắn và chọn ý đúng.',
                'transcript', 'A: Where is the meeting? B: In room 2 at 10 a.m.',
                'translationVi','A: Cuộc họp ở đâu? B: Phòng 2 lúc 10 giờ sáng.'
            )
        WHEN 'reading' THEN
            jsonb_build_object(
                'instruction','Đọc đoạn và trả lời câu hỏi.',
                'passage','The town library opens at 9 a.m. on weekdays and closes at 7 p.m.',
                'translationVi','Thư viện thị trấn mở cửa lúc 9 giờ sáng các ngày trong tuần và đóng cửa lúc 7 giờ tối.'
            )
        WHEN 'speaking' THEN
            jsonb_build_object(
                'instruction','Nghe mẫu rồi ghi âm lại câu của bạn.',
                'sampleText','I would like a cup of coffee, please.',
                'phonetic','aɪ wʊd laɪk ə kʌp əv ˈkɔːfi, pliːz',
                'translationVi','Tôi muốn một cốc cà phê, làm ơn.'
            )
        ELSE
            jsonb_build_object(
                'instruction','Viết câu trả lời ngắn theo gợi ý.',
                'prompt','Describe a place you like and explain why.',
                'exampleAnswer','I love my hometown because the streets are quiet and the food is delicious.'
            )
    END
FROM path_skill;

-- ── Seed path activities (4/path) ───────────────────────────────────────────
WITH path_skill (path_id, level_code, skill_code, idx, title_suffix, duration, xp, activity_type) AS (
    SELECT
        p.id, p.level_code, s.code, s.idx, s.title_suffix, s.duration, s.xp, s.activity_type
    FROM learning_paths p
    CROSS JOIN (VALUES
        (1, 'listening', 'Listen for main ideas',     7, 10, 'listening_choice'),
        (2, 'reading',   'Read a short text',         8, 10, 'reading_question'),
        (3, 'speaking',  'Speak in the situation',    7, 12, 'pronunciation'),
        (4, 'writing',   'Write a short response',    9, 12, 'writing_prompt')
    ) AS s(idx, code, title_suffix, duration, xp, activity_type)
    WHERE p.display_order BETWEEN 2 AND 10
)
INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward)
SELECT
    path_id || '-act-' || LPAD(idx::text, 2, '0') AS id,
    path_id,
    path_id || '-lesson-' || LPAD(idx::text, 2, '0') AS lesson_id,
    skill_code,
    activity_type,
    title_suffix,
    'Hoạt động ' || skill_code || ' trong path.',
    idx,
    duration,
    xp
FROM path_skill;

-- ── Seed lesson_activities (1/lesson) ───────────────────────────────────────
WITH path_skill (path_id, skill_code, idx) AS (
    SELECT p.id, s.code, s.idx
    FROM learning_paths p
    CROSS JOIN (VALUES
        (1, 'listening'),
        (2, 'reading'),
        (3, 'speaking'),
        (4, 'writing')
    ) AS s(idx, code)
    WHERE p.display_order BETWEEN 2 AND 10
)
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload)
SELECT
    path_id || '-l' || idx || '-a1' AS id,
    path_id || '-lesson-' || LPAD(idx::text, 2, '0') AS lesson_id,
    CASE skill_code
        WHEN 'listening' THEN 'multiple_choice'
        WHEN 'reading'   THEN 'multiple_choice'
        WHEN 'speaking'  THEN 'pronunciation'
        ELSE                  'writing_prompt'
    END AS activity_type,
    1,
    CASE skill_code
        WHEN 'listening' THEN
            jsonb_build_object(
                'question','What time does the meeting start?',
                'options', jsonb_build_array(
                    jsonb_build_object('id','A','text','9 a.m.'),
                    jsonb_build_object('id','B','text','10 a.m.'),
                    jsonb_build_object('id','C','text','11 a.m.')
                ),
                'correctOptionId','B',
                'explanationVi','Trong hội thoại có câu in room 2 at 10 a.m.'
            )
        WHEN 'reading' THEN
            jsonb_build_object(
                'question','When does the library close on weekdays?',
                'options', jsonb_build_array(
                    jsonb_build_object('id','A','text','5 p.m.'),
                    jsonb_build_object('id','B','text','7 p.m.'),
                    jsonb_build_object('id','C','text','9 p.m.')
                ),
                'correctOptionId','B',
                'explanationVi','Đoạn nói closes at 7 p.m.'
            )
        WHEN 'speaking' THEN
            jsonb_build_object(
                'expectedText','I would like a cup of coffee, please.',
                'minScoreToPass',70
            )
        ELSE
            jsonb_build_object(
                'prompt','Describe a place you like and explain why.',
                'rubric', jsonb_build_array(
                    'Tên một địa điểm cụ thể.',
                    'Đưa ít nhất 1 lý do.',
                    'Viết 3-4 câu.'
                )
            )
    END AS payload
FROM path_skill;
