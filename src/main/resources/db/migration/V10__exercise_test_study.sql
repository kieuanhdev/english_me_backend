-- Exercise Questions (khác với placement test questions)
CREATE TABLE exercise_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(50) NOT NULL,        -- vocabulary | grammar
    difficulty VARCHAR(20) NOT NULL,      -- easy | medium | hard
    question TEXT NOT NULL,
    options JSONB NOT NULL,               -- ["A", "B", "C", "D"]
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    hint TEXT,
    level VARCHAR(10)                     -- A1-C2 optional filter
);

CREATE INDEX idx_exercise_question_category ON exercise_question(category);
CREATE INDEX idx_exercise_question_level ON exercise_question(level);

-- Exercise Sessions
CREATE TABLE exercise_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active | completed
    question_ids JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_exercise_session_user ON exercise_session(user_id, created_at DESC);

-- Exercise Answers
CREATE TABLE exercise_answer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES exercise_session(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES exercise_question(id),
    selected_answer TEXT,
    is_correct BOOLEAN
);

CREATE INDEX idx_exercise_answer_session ON exercise_answer(session_id);

-- User Test Sessions (user chủ động tạo, khác PlacementTest)
CREATE TABLE user_test_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic VARCHAR(50) NOT NULL,           -- grammar | vocabulary
    level VARCHAR(10) NOT NULL,           -- a1|a2|b1|b2|c1|c2
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    question_ids JSONB NOT NULL,
    duration_seconds INTEGER NOT NULL DEFAULT 900,
    correct INTEGER,
    total INTEGER,
    xp_earned INTEGER,
    time_taken_seconds INTEGER,
    cefr_suggestion VARCHAR(10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_user_test_session_user ON user_test_session(user_id, created_at DESC);

-- Study Sessions (SM-2)
CREATE TABLE study_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    desk_id UUID NOT NULL REFERENCES desk(id),
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active | completed
    card_ids JSONB NOT NULL,
    total_cards INTEGER NOT NULL,
    mastered_cards INTEGER DEFAULT 0,
    again_cards INTEGER DEFAULT 0,
    hard_cards INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    new_words_learned INTEGER DEFAULT 0,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_study_session_user ON study_session(user_id, started_at DESC);

-- Seed exercise questions: vocabulary (easy)
INSERT INTO exercise_question (category, difficulty, question, options, correct_answer, explanation, level) VALUES
('vocabulary', 'easy', 'What does "apple" mean?', '["Quả táo", "Quả cam", "Quả chuối", "Quả nho"]', 'Quả táo', 'Apple = quả táo trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "book" mean?', '["Bàn", "Ghế", "Sách", "Cửa"]', 'Sách', 'Book = sách trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "water" mean?', '["Lửa", "Nước", "Đất", "Gió"]', 'Nước', 'Water = nước trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "house" mean?', '["Trường học", "Bệnh viện", "Nhà", "Chợ"]', 'Nhà', 'House = ngôi nhà', 'A1'),
('vocabulary', 'easy', 'What does "cat" mean?', '["Con chó", "Con mèo", "Con bò", "Con gà"]', 'Con mèo', 'Cat = con mèo', 'A1'),
('vocabulary', 'easy', 'Choose the correct word: "I ___ a student."', '["am", "is", "are", "be"]', 'am', 'Với chủ từ "I" ta dùng "am"', 'A1'),
('vocabulary', 'easy', 'What does "happy" mean?', '["Buồn", "Tức giận", "Vui vẻ", "Sợ hãi"]', 'Vui vẻ', 'Happy = vui vẻ, hạnh phúc', 'A1'),
('vocabulary', 'easy', 'What does "big" mean?', '["Nhỏ", "To lớn", "Dài", "Ngắn"]', 'To lớn', 'Big = to, lớn', 'A1'),
('vocabulary', 'easy', 'What does "beautiful" mean?', '["Xấu", "Đẹp", "Cao", "Thấp"]', 'Đẹp', 'Beautiful = đẹp', 'A1'),
('vocabulary', 'easy', 'What does "fast" mean?', '["Chậm", "Nhanh", "Nhỏ", "Yếu"]', 'Nhanh', 'Fast = nhanh', 'A1'),

-- vocabulary (medium)
('vocabulary', 'medium', 'Which word means "determined to do something"?', '["Lazy", "Ambitious", "Careless", "Shy"]', 'Ambitious', 'Ambitious = có tham vọng, quyết tâm', 'B1'),
('vocabulary', 'medium', 'What is the synonym of "begin"?', '["End", "Finish", "Start", "Stop"]', 'Start', 'Begin và start đều có nghĩa là bắt đầu', 'A2'),
('vocabulary', 'medium', 'What does "frequently" mean?', '["Rarely", "Sometimes", "Often", "Never"]', 'Often', 'Frequently = thường xuyên = often', 'A2'),
('vocabulary', 'medium', 'Which word is an antonym of "ancient"?', '["Old", "Modern", "Historical", "Traditional"]', 'Modern', 'Ancient = cổ xưa, antonym là modern = hiện đại', 'B1'),
('vocabulary', 'medium', 'What does "collaborative" mean?', '["Working alone", "Working together", "Competing", "Disagreeing"]', 'Working together', 'Collaborative = hợp tác, làm việc cùng nhau', 'B1'),

-- grammar (easy)
('grammar', 'easy', 'She ___ to school every day.', '["go", "goes", "going", "gone"]', 'goes', 'Ngôi thứ 3 số ít (she) thêm -s vào động từ', 'A1'),
('grammar', 'easy', 'They ___ watching TV now.', '["is", "am", "are", "be"]', 'are', 'They là số nhiều nên dùng "are"', 'A1'),
('grammar', 'easy', 'I ___ a book yesterday.', '["read", "reads", "reading", "readed"]', 'read', '"Read" là động từ bất quy tắc, quá khứ vẫn là "read"', 'A1'),
('grammar', 'easy', 'There ___ a cat on the table.', '["am", "is", "are", "be"]', 'is', 'There is + danh từ số ít', 'A1'),
('grammar', 'easy', 'She has ___ her homework.', '["do", "did", "done", "does"]', 'done', 'have/has + past participle (done)', 'A2'),
('grammar', 'easy', '___ you speak English?', '["Do", "Does", "Is", "Are"]', 'Do', 'Câu hỏi với "you" dùng Do', 'A1'),

-- grammar (medium)
('grammar', 'medium', 'If I ___ rich, I would travel the world.', '["am", "was", "were", "be"]', 'were', 'Câu điều kiện loại 2 dùng "were" với tất cả chủ từ', 'B1'),
('grammar', 'medium', 'She suggested ___ earlier.', '["leave", "leaving", "to leave", "left"]', 'leaving', 'suggest + V-ing', 'B1'),
('grammar', 'medium', 'The report ___ by the team last week.', '["wrote", "was written", "has written", "is written"]', 'was written', 'Câu bị động thì quá khứ đơn', 'B1'),
('grammar', 'medium', 'He is used to ___ late.', '["work", "works", "working", "worked"]', 'working', 'be used to + V-ing', 'B1'),
('grammar', 'medium', 'No sooner ___ she arrived than it started raining.', '["had", "has", "did", "was"]', 'had', 'No sooner + had + S + V3/V-ed (đảo ngữ)', 'B2');
