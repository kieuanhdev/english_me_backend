-- =============================================================================
-- V19 — Learning Hub schema (theo LEARNING_PATH_BACKEND_SPEC.md)
-- =============================================================================
-- Tạo 12 bảng:
--   Master (3): cefr_levels, skills, support_tracks
--   Cấu trúc (4): learning_paths, learning_path_activities,
--                 learning_lessons, learning_lesson_activities
--   User progress (5): user_levels, user_path_progress,
--                      user_lesson_progress, user_lesson_attempts,
--                      user_daily_goals
-- Lưu ý:
--   * users.id trong dự án này là UUID (spec ghi BIGINT là không khớp) — FK dùng UUID.
--   * Mọi bảng quan hệ ON DELETE CASCADE để FE xoá user demo không vướng.
-- =============================================================================

-- ── Master data ──────────────────────────────────────────────────────────────
CREATE TABLE cefr_levels (
    code           VARCHAR(2)  PRIMARY KEY,
    title          VARCHAR(80) NOT NULL,
    description    TEXT        NOT NULL,
    display_order  SMALLINT    NOT NULL UNIQUE,
    is_active      BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE skills (
    code           VARCHAR(20) PRIMARY KEY,
    title          VARCHAR(80) NOT NULL,
    description    TEXT        NOT NULL,
    icon           VARCHAR(40),
    accent_color   VARCHAR(7),
    display_order  SMALLINT    NOT NULL
);

CREATE TABLE support_tracks (
    type           VARCHAR(20) PRIMARY KEY,
    title          VARCHAR(80) NOT NULL,
    description    TEXT        NOT NULL,
    route          VARCHAR(120) NOT NULL,
    display_order  SMALLINT    NOT NULL,
    enabled        BOOLEAN     NOT NULL DEFAULT TRUE
);

-- ── Learning structure ───────────────────────────────────────────────────────
CREATE TABLE learning_paths (
    id              VARCHAR(64)  PRIMARY KEY,
    level_code      VARCHAR(2)   NOT NULL REFERENCES cefr_levels(code),
    title           VARCHAR(160) NOT NULL,
    description     TEXT         NOT NULL,
    display_order   INT          NOT NULL,
    required_score_to_pass  SMALLINT NOT NULL DEFAULT 70,
    skills_coverage JSONB        NOT NULL DEFAULT '[]'::jsonb,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (level_code, display_order)
);
CREATE INDEX idx_paths_level_order ON learning_paths(level_code, display_order);

CREATE TABLE learning_lessons (
    id              VARCHAR(64)  PRIMARY KEY,
    level_code      VARCHAR(2)   NOT NULL REFERENCES cefr_levels(code),
    skill_code      VARCHAR(20)  NOT NULL REFERENCES skills(code),
    unit_id         VARCHAR(64),
    title           VARCHAR(160) NOT NULL,
    subtitle        VARCHAR(255),
    duration_minutes SMALLINT    NOT NULL DEFAULT 5,
    xp_reward       SMALLINT     NOT NULL DEFAULT 10,
    content         JSONB        NOT NULL DEFAULT '{}'::jsonb,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_lesson_level_skill ON learning_lessons(level_code, skill_code);

CREATE TABLE learning_path_activities (
    id              VARCHAR(64)  PRIMARY KEY,
    path_id         VARCHAR(64)  NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    lesson_id       VARCHAR(64)  NOT NULL REFERENCES learning_lessons(id),
    skill_code      VARCHAR(20)  NOT NULL REFERENCES skills(code),
    activity_type   VARCHAR(40)  NOT NULL,
    title           VARCHAR(160) NOT NULL,
    subtitle        VARCHAR(255),
    display_order   INT          NOT NULL,
    duration_minutes SMALLINT    NOT NULL DEFAULT 5,
    xp_reward       SMALLINT     NOT NULL DEFAULT 10,
    UNIQUE (path_id, display_order)
);
CREATE INDEX idx_activity_path ON learning_path_activities(path_id, display_order);

CREATE TABLE learning_lesson_activities (
    id              VARCHAR(64)  PRIMARY KEY,
    lesson_id       VARCHAR(64)  NOT NULL REFERENCES learning_lessons(id) ON DELETE CASCADE,
    activity_type   VARCHAR(40)  NOT NULL,
    display_order   SMALLINT     NOT NULL,
    payload         JSONB        NOT NULL,
    min_score_to_pass SMALLINT,
    UNIQUE (lesson_id, display_order)
);

-- ── User progress ────────────────────────────────────────────────────────────
CREATE TABLE user_levels (
    user_id         UUID         PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_level   VARCHAR(2)   NOT NULL REFERENCES cefr_levels(code),
    selected_level  VARCHAR(2)   NOT NULL REFERENCES cefr_levels(code),
    current_path_id VARCHAR(64)  REFERENCES learning_paths(id) ON DELETE SET NULL,
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE user_path_progress (
    user_id           UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    path_id           VARCHAR(64)  NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    status            VARCHAR(20)  NOT NULL DEFAULT 'locked',
    completed_count   INT          NOT NULL DEFAULT 0,
    total_count       INT          NOT NULL DEFAULT 0,
    best_score        SMALLINT,
    started_at        TIMESTAMPTZ,
    completed_at      TIMESTAMPTZ,
    PRIMARY KEY (user_id, path_id)
);
CREATE INDEX idx_upp_user_status ON user_path_progress(user_id, status);

CREATE TABLE user_lesson_progress (
    user_id          UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id        VARCHAR(64)  NOT NULL REFERENCES learning_lessons(id) ON DELETE CASCADE,
    path_id          VARCHAR(64)  REFERENCES learning_paths(id) ON DELETE SET NULL,
    status           VARCHAR(20)  NOT NULL DEFAULT 'locked',
    best_score       SMALLINT,
    last_score       SMALLINT,
    attempts         INT          NOT NULL DEFAULT 0,
    xp_earned        INT          NOT NULL DEFAULT 0,
    time_spent_seconds INT        NOT NULL DEFAULT 0,
    completed_at     TIMESTAMPTZ,
    PRIMARY KEY (user_id, lesson_id)
);
CREATE INDEX idx_ulp_user_path ON user_lesson_progress(user_id, path_id);

CREATE TABLE user_lesson_attempts (
    id               BIGSERIAL    PRIMARY KEY,
    user_id          UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id        VARCHAR(64)  NOT NULL REFERENCES learning_lessons(id) ON DELETE CASCADE,
    score            SMALLINT     NOT NULL,
    xp_earned        SMALLINT     NOT NULL,
    time_spent_seconds INT        NOT NULL,
    answers          JSONB        NOT NULL,
    submitted_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_ula_user_lesson ON user_lesson_attempts(user_id, lesson_id, submitted_at DESC);

CREATE TABLE user_daily_goals (
    user_id          UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_date        DATE         NOT NULL,
    target_xp        SMALLINT     NOT NULL DEFAULT 30,
    earned_xp        SMALLINT     NOT NULL DEFAULT 0,
    completed_activities SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, goal_date)
);

-- ── Seed master data ─────────────────────────────────────────────────────────
INSERT INTO cefr_levels (code, title, description, display_order) VALUES
    ('A1', 'Sơ cấp - A1',        'Làm quen câu đơn, từ vựng hằng ngày và phản xạ cơ bản.', 1),
    ('A2', 'Sơ cấp - A2',        'Mở rộng giao tiếp thường ngày và mô tả trải nghiệm đơn giản.', 2),
    ('B1', 'Trung cấp - B1',     'Xử lý hầu hết tình huống du lịch. Diễn đạt ý kiến và kể chuyện.', 3),
    ('B2', 'Trung cấp - B2',     'Tương tác trôi chảy với người bản xứ. Trình bày quan điểm chi tiết.', 4),
    ('C1', 'Cao cấp - C1',       'Diễn đạt linh hoạt trong xã hội, học thuật và công việc.', 5),
    ('C2', 'Thành thạo - C2',    'Hiểu hầu hết mọi thứ nghe/đọc. Tóm tắt thông tin từ nhiều nguồn.', 6);

INSERT INTO skills (code, title, description, icon, accent_color, display_order) VALUES
    ('listening', 'Nghe', 'Bài nghe ngắn, hội thoại đời sống.',          'headphones',         '#3B82F6', 1),
    ('speaking',  'Nói',  'Phát âm, câu mẫu và trả lời theo ngữ cảnh.',  'record_voice_over',  '#E67E22', 2),
    ('reading',   'Đọc',  'Đọc đoạn văn và trả lời câu hỏi.',            'menu_book',          '#43A047', 3),
    ('writing',   'Viết', 'Viết câu và đoạn theo chủ đề.',               'edit',               '#1E88E5', 4);

INSERT INTO support_tracks (type, title, description, route, display_order, enabled) VALUES
    ('grammar',    'Ngữ pháp',  'Mẫu câu và quy tắc cần cho từng chặng học.',          '/learn/grammar',   1, TRUE),
    ('vocabulary', 'Từ vựng',   'Từ nền tảng cho nghe, nói, đọc và viết.',             '/vocabulary',      2, TRUE),
    ('flashcard',  'Flashcard', 'Ôn lại từ và cụm từ đã học bằng spaced repetition.', '/learn/flashcards', 3, TRUE),
    ('test',       'Kiểm tra',  'Tự kiểm tra kiến thức theo chủ đề.',                  '/test',            4, TRUE);

-- ── Seed 1 path mẫu cho mỗi level (đủ để FE không phải fallback demo) ────────
-- Mỗi level seed 1 path "starter" + 4 activity + 4 lesson tương ứng.
-- (Phase tiếp theo có thể seed thêm 9 path/level theo demo template FE.)

-- A1
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('a1-path-01-greetings', 'A1', 'Greetings & introductions',
     'Chào hỏi, giới thiệu bản thân và làm quen với câu đơn.', 1,
     '["vocabulary","listening","speaking","writing"]'::jsonb);

-- A2
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('a2-path-01-plans', 'A2', 'Plans and invitations',
     'Lập kế hoạch, mời người khác và trao đổi lịch trình đơn giản.', 1,
     '["vocabulary","listening","reading","grammar","speaking","writing"]'::jsonb);

-- B1
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('b1-path-01-experiences', 'B1', 'Talking about experiences',
     'Kể lại trải nghiệm, mô tả sự kiện và đưa ra ý kiến ngắn.', 1,
     '["vocabulary","listening","reading","speaking","writing"]'::jsonb);

-- B2
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('b2-path-01-opinions', 'B2', 'Opinions and debates',
     'Trình bày quan điểm, phản biện và thảo luận chi tiết.', 1,
     '["vocabulary","listening","reading","speaking","writing"]'::jsonb);

-- C1
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('c1-path-01-academic', 'C1', 'Academic & professional',
     'Nghe-đọc tài liệu học thuật và giao tiếp công việc linh hoạt.', 1,
     '["listening","reading","speaking","writing"]'::jsonb);

-- C2
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('c2-path-01-mastery', 'C2', 'Mastery essentials',
     'Tổng hợp ý từ nhiều nguồn, sử dụng ngôn ngữ tinh tế.', 1,
     '["listening","reading","writing"]'::jsonb);

-- ── Seed lessons + path activities cho A1 path-01 ────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
    ('a1-path-01-lesson-01', 'A1', 'listening', 'a1-path-01-greetings',
     'Hello and goodbye', 'Nghe hội thoại chào hỏi và tạm biệt.', 6, 10,
     '{"instruction":"Nghe đoạn hội thoại và chọn đáp án đúng.","transcript":"A: Hello! B: Hi! Nice to meet you.","audioUrl":"https://cdn.example.com/a1/greetings-01.mp3","translationVi":"A: Xin chào! B: Chào bạn! Rất vui được gặp bạn."}'::jsonb),
    ('a1-path-01-lesson-02', 'A1', 'speaking', 'a1-path-01-greetings',
     'Introduce yourself', 'Luyện câu giới thiệu tên và quốc tịch.', 7, 12,
     '{"instruction":"Nghe mẫu rồi ghi âm lại câu của bạn.","sampleText":"Hello, my name is Linh.","phonetic":"həˈloʊ, maɪ neɪm ɪz lɪn","translationVi":"Xin chào, tên tôi là Linh."}'::jsonb),
    ('a1-path-01-lesson-03', 'A1', 'reading', 'a1-path-01-greetings',
     'A short profile', 'Đọc hồ sơ cá nhân ngắn.', 5, 10,
     '{"instruction":"Đọc đoạn văn và trả lời câu hỏi.","passage":"My name is Ben. I am from Canada. I am a student.","translationVi":"Tên tôi là Ben. Tôi đến từ Canada. Tôi là học sinh."}'::jsonb),
    ('a1-path-01-lesson-04', 'A1', 'writing', 'a1-path-01-greetings',
     'Write your name and country', 'Viết câu giới thiệu cơ bản.', 8, 12,
     '{"instruction":"Viết 2 câu giới thiệu tên và quốc gia của bạn.","prompt":"Write your name and where you are from.","exampleAnswer":"My name is Mai. I am from Vietnam."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
    ('a1-path-01-act-01', 'a1-path-01-greetings', 'a1-path-01-lesson-01', 'listening', 'listening_choice',
     'Listen for greetings', 'Nghe và chọn đáp án phù hợp.', 1, 6, 10),
    ('a1-path-01-act-02', 'a1-path-01-greetings', 'a1-path-01-lesson-02', 'speaking',  'pronunciation',
     'Introduce yourself',  'Phát âm câu giới thiệu cơ bản.', 2, 7, 12),
    ('a1-path-01-act-03', 'a1-path-01-greetings', 'a1-path-01-lesson-03', 'reading',   'reading_question',
     'Read a short profile','Đọc và trả lời câu hỏi.', 3, 5, 10),
    ('a1-path-01-act-04', 'a1-path-01-greetings', 'a1-path-01-lesson-04', 'writing',   'writing_prompt',
     'Write about yourself','Viết câu giới thiệu bản thân.', 4, 8, 12);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload) VALUES
    ('a1-p1-l1-a1', 'a1-path-01-lesson-01', 'multiple_choice', 1,
     '{"question":"What does B say to greet A?","options":[{"id":"A","text":"Hi!"},{"id":"B","text":"Bye"},{"id":"C","text":"Sorry"}],"correctOptionId":"A","explanationVi":"B đáp lại bằng \"Hi!\" để chào lại A."}'::jsonb),
    ('a1-p1-l2-a1', 'a1-path-01-lesson-02', 'pronunciation', 1,
     '{"expectedText":"Hello, my name is Linh.","minScoreToPass":70}'::jsonb),
    ('a1-p1-l3-a1', 'a1-path-01-lesson-03', 'multiple_choice', 1,
     '{"question":"Where is Ben from?","options":[{"id":"A","text":"Canada"},{"id":"B","text":"Japan"},{"id":"C","text":"Vietnam"}],"correctOptionId":"A","explanationVi":"Trong bài có câu I am from Canada."}'::jsonb),
    ('a1-p1-l4-a1', 'a1-path-01-lesson-04', 'writing_prompt', 1,
     '{"prompt":"Write your name and where you are from.","rubric":["Có câu giới thiệu tên.","Có câu giới thiệu quốc gia.","Dùng đúng cấu trúc My name is... / I am from..."]}'::jsonb);

-- ── Seed tối giản cho A2..C2 (1 lesson + 1 activity/level, đủ FE hiển thị) ───
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
    ('a2-path-01-lesson-01', 'A2', 'listening', 'a2-path-01-plans',
     'Make a plan', 'Nghe hội thoại lập kế hoạch cuối tuần.', 7, 10,
     '{"instruction":"Nghe và chọn lịch hẹn đúng.","transcript":"A: What about Saturday morning? B: Sure, let''s meet at 9.","translationVi":"A: Sáng thứ Bảy được không? B: Được, gặp lúc 9 giờ nhé."}'::jsonb),
    ('b1-path-01-lesson-01', 'B1', 'reading', 'b1-path-01-experiences',
     'A travel story', 'Đọc đoạn kể chuyện du lịch ngắn.', 8, 12,
     '{"instruction":"Đọc và chọn ý chính.","passage":"Last summer I visited Da Nang. The beach was beautiful and the food was great.","translationVi":"Mùa hè trước tôi đi Đà Nẵng. Bãi biển đẹp và đồ ăn ngon."}'::jsonb),
    ('b2-path-01-lesson-01', 'B2', 'writing', 'b2-path-01-opinions',
     'Express your opinion', 'Viết đoạn ngắn bày tỏ ý kiến.', 10, 15,
     '{"instruction":"Viết 4-5 câu nêu ý kiến.","prompt":"Should students learn a second language at school?","exampleAnswer":"I think students should learn a second language because..."}'::jsonb),
    ('c1-path-01-lesson-01', 'C1', 'listening', 'c1-path-01-academic',
     'Academic lecture intro', 'Nghe đoạn mở đầu bài giảng học thuật.', 10, 15,
     '{"instruction":"Nghe và tóm tắt ý chính.","transcript":"Today we will explore three approaches to language acquisition.","translationVi":"Hôm nay chúng ta sẽ tìm hiểu ba cách tiếp cận trong việc tiếp thu ngôn ngữ."}'::jsonb),
    ('c2-path-01-lesson-01', 'C2', 'reading', 'c2-path-01-mastery',
     'Editorial overview', 'Đọc đoạn xã luận tóm tắt sự kiện toàn cầu.', 12, 18,
     '{"instruction":"Đọc và xác định luận điểm.","passage":"In recent years, climate policy has shifted from voluntary commitments to binding regulations.","translationVi":"Trong những năm gần đây, chính sách khí hậu đã chuyển từ cam kết tự nguyện sang quy định bắt buộc."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
    ('a2-path-01-act-01', 'a2-path-01-plans',       'a2-path-01-lesson-01', 'listening', 'listening_choice', 'Listen for plans',    'Nghe và chọn lịch hẹn.',          1,  7, 10),
    ('b1-path-01-act-01', 'b1-path-01-experiences', 'b1-path-01-lesson-01', 'reading',   'reading_question', 'Read a travel story', 'Đọc và chọn ý chính.',            1,  8, 12),
    ('b2-path-01-act-01', 'b2-path-01-opinions',    'b2-path-01-lesson-01', 'writing',   'writing_prompt',   'Write your opinion',  'Viết đoạn nêu ý kiến.',           1, 10, 15),
    ('c1-path-01-act-01', 'c1-path-01-academic',    'c1-path-01-lesson-01', 'listening', 'listening_choice', 'Lecture intro',       'Nghe đoạn mở đầu bài giảng.',     1, 10, 15),
    ('c2-path-01-act-01', 'c2-path-01-mastery',     'c2-path-01-lesson-01', 'reading',   'reading_question', 'Editorial overview',  'Đọc và xác định luận điểm.',      1, 12, 18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload) VALUES
    ('a2-p1-l1-a1', 'a2-path-01-lesson-01', 'multiple_choice', 1,
     '{"question":"What time will they meet?","options":[{"id":"A","text":"At 8"},{"id":"B","text":"At 9"},{"id":"C","text":"At 10"}],"correctOptionId":"B","explanationVi":"B nói let''s meet at 9."}'::jsonb),
    ('b1-p1-l1-a1', 'b1-path-01-lesson-01', 'multiple_choice', 1,
     '{"question":"Where did the writer go last summer?","options":[{"id":"A","text":"Hanoi"},{"id":"B","text":"Da Nang"},{"id":"C","text":"Hue"}],"correctOptionId":"B","explanationVi":"Đoạn nói I visited Da Nang."}'::jsonb),
    ('b2-p1-l1-a1', 'b2-path-01-lesson-01', 'writing_prompt', 1,
     '{"prompt":"Should students learn a second language at school?","rubric":["Nêu rõ ý kiến.","Đưa ít nhất 1 lý do.","Viết 4-5 câu."]}'::jsonb),
    ('c1-p1-l1-a1', 'c1-path-01-lesson-01', 'multiple_choice', 1,
     '{"question":"How many approaches will be explored?","options":[{"id":"A","text":"Two"},{"id":"B","text":"Three"},{"id":"C","text":"Four"}],"correctOptionId":"B","explanationVi":"Giảng viên nói three approaches."}'::jsonb),
    ('c2-p1-l1-a1', 'c2-path-01-lesson-01', 'multiple_choice', 1,
     '{"question":"Climate policy has shifted toward what?","options":[{"id":"A","text":"Voluntary commitments"},{"id":"B","text":"Binding regulations"},{"id":"C","text":"No change"}],"correctOptionId":"B","explanationVi":"Đoạn nói shifted ... to binding regulations."}'::jsonb);
