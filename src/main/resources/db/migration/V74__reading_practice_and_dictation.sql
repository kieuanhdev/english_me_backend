-- =============================================================================
-- V74 — Mở rộng luyện tập: Đọc (Reading, trắc nghiệm) + Nghe (Listening, dictation).
-- =============================================================================
--  * Reading: tái dùng bảng exercise_question (thêm cột passage + audio_url) →
--    ExerciseService chỉ cần mở category 'reading'. Câu = passage + 1 câu hỏi MCQ.
--  * Listening: dictation (nghe TTS → chép chính tả). Luồng riêng, bảng mới
--    dictation_sentence. Không MCQ — chấm so khớp chuẩn hóa ở client.
-- =============================================================================

-- ── 1) exercise_question: thêm passage + audio_url cho reading/listening ──────
ALTER TABLE exercise_question ADD COLUMN IF NOT EXISTS passage TEXT;
ALTER TABLE exercise_question ADD COLUMN IF NOT EXISTS audio_url TEXT;

-- ── 2) Seed câu Reading (A1–C1). passage + câu hỏi đọc hiểu 4 đáp án. ──────────
INSERT INTO exercise_question (category, difficulty, question, options, correct_answer, explanation, level, passage) VALUES
-- A1
('reading', 'easy', 'What is Tom''s pet?',            '{"A":"a cat","B":"a dog","C":"a bird","D":"a fish"}', 'B', 'Đoạn văn: "Tom has a dog."',              'A1', 'Tom has a dog. The dog is brown. It likes to run in the park.'),
('reading', 'easy', 'What color is the dog?',         '{"A":"black","B":"white","C":"brown","D":"red"}', 'C', 'Đoạn văn: "The dog is brown."',           'A1', 'Tom has a dog. The dog is brown. It likes to run in the park.'),
('reading', 'easy', 'Where does Mary go on Monday?',  '{"A":"home","B":"school","C":"shop","D":"park"}', 'B', 'Đoạn văn: "On Monday she goes to school."', 'A1', 'Mary is a student. On Monday she goes to school. She likes English.'),
('reading', 'easy', 'What does Mary like?',           '{"A":"math","B":"music","C":"English","D":"art"}', 'C', 'Đoạn văn: "She likes English."',          'A1', 'Mary is a student. On Monday she goes to school. She likes English.'),
-- A2
('reading', 'easy', 'When did Anna visit her grandmother?', '{"A":"last week","B":"yesterday","C":"last weekend","D":"today"}', 'C', 'Đoạn văn: "Last weekend Anna visited..."', 'A2', 'Last weekend Anna visited her grandmother. They cooked dinner and watched a film together.'),
('reading', 'easy', 'What did they do together?',     '{"A":"cooked and watched a film","B":"played games","C":"went shopping","D":"read books"}', 'A', 'Đoạn văn nêu rõ hai hoạt động.', 'A2', 'Last weekend Anna visited her grandmother. They cooked dinner and watched a film together.'),
('reading', 'medium', 'How does Ben go to work?',     '{"A":"by car","B":"by bus","C":"by bike","D":"on foot"}', 'C', 'Đoạn văn: "Ben rides his bike to work."', 'A2', 'Ben rides his bike to work every day because it is cheap and good for his health.'),
('reading', 'medium', 'Why does Ben cycle?',          '{"A":"it is fast","B":"it is cheap and healthy","C":"he has no car","D":"it is fun"}', 'B', 'Đoạn văn: "cheap and good for his health".', 'A2', 'Ben rides his bike to work every day because it is cheap and good for his health.'),
-- B1
('reading', 'medium', 'Why was the trip delayed?',    '{"A":"bad weather","B":"a strike","C":"a broken bus","D":"illness"}', 'A', 'Đoạn văn: "because of heavy rain".', 'B1', 'The school trip to the mountains was delayed because of heavy rain. Students waited two hours before the buses finally left.'),
('reading', 'medium', 'How long did students wait?',  '{"A":"one hour","B":"two hours","C":"three hours","D":"all day"}', 'B', 'Đoạn văn: "waited two hours".', 'B1', 'The school trip to the mountains was delayed because of heavy rain. Students waited two hours before the buses finally left.'),
('reading', 'medium', 'What is the main idea of the text?', '{"A":"online shopping is growing","B":"shops are closing","C":"prices are rising","D":"delivery is slow"}', 'A', 'Ý chính: online shopping tăng trưởng.', 'B1', 'More and more people buy clothes and food online. Online shopping is growing fast because it saves time and offers many choices.'),
('reading', 'medium', 'Why is online shopping popular?', '{"A":"it is cheaper only","B":"it saves time and offers choices","C":"shops are far","D":"it is safer"}', 'B', 'Đoạn văn: "saves time and offers many choices".', 'B1', 'More and more people buy clothes and food online. Online shopping is growing fast because it saves time and offers many choices.'),
-- B2
('reading', 'hard', 'What does the author suggest about remote work?', '{"A":"it harms productivity","B":"it has both benefits and drawbacks","C":"it should be banned","D":"it suits everyone"}', 'B', 'Tác giả nêu cả lợi và hại.', 'B2', 'Remote work offers flexibility and saves commuting time, yet it can blur the line between professional and personal life, leaving some employees feeling they never truly switch off.'),
('reading', 'hard', 'What is a drawback mentioned?',  '{"A":"lower pay","B":"longer commute","C":"difficulty switching off","D":"less flexibility"}', 'C', 'Đoạn văn: "never truly switch off".', 'B2', 'Remote work offers flexibility and saves commuting time, yet it can blur the line between professional and personal life, leaving some employees feeling they never truly switch off.'),
('reading', 'hard', 'What tone does the writer take towards the festival?', '{"A":"critical","B":"enthusiastic","C":"neutral","D":"sarcastic"}', 'B', 'Từ ngữ "vibrant, unforgettable" → nhiệt tình.', 'B2', 'The annual film festival was a vibrant celebration of independent cinema, drawing crowds from around the world and offering an unforgettable experience for both directors and fans.'),
('reading', 'hard', 'Who attended the festival?',     '{"A":"only directors","B":"only fans","C":"directors and fans","D":"local students"}', 'C', 'Đoạn văn: "both directors and fans".', 'B2', 'The annual film festival was a vibrant celebration of independent cinema, drawing crowds from around the world and offering an unforgettable experience for both directors and fans.'),
-- C1
('reading', 'hard', 'What is the writer''s primary argument?', '{"A":"technology always improves life","B":"unchecked automation may widen inequality","C":"machines cannot replace humans","D":"jobs are increasing"}', 'B', 'Luận điểm chính: automation làm tăng bất bình đẳng.', 'C1', 'While automation promises efficiency, critics caution that, left unchecked, it may concentrate wealth among those who own the technology, thereby widening the gap between rich and poor.'),
('reading', 'hard', 'The word "unchecked" most nearly means:', '{"A":"unverified","B":"unrestrained","C":"unexpected","D":"unpaid"}', 'B', 'Unchecked = không bị kiểm soát (unrestrained).', 'C1', 'While automation promises efficiency, critics caution that, left unchecked, it may concentrate wealth among those who own the technology, thereby widening the gap between rich and poor.'),
('reading', 'hard', 'What can be inferred about the policy?', '{"A":"it was universally praised","B":"it faced nuanced criticism despite good intentions","C":"it was abandoned","D":"it had no effect"}', 'B', 'Suy luận: chính sách bị phê bình tinh tế dù thiện chí.', 'C1', 'Though the reform was introduced with laudable intentions, its implementation proved so convoluted that even its staunchest supporters conceded the outcomes fell short of expectations.'),
('reading', 'hard', 'What does "conceded" imply here?', '{"A":"strongly denied","B":"reluctantly admitted","C":"loudly celebrated","D":"completely ignored"}', 'B', 'Conceded = miễn cưỡng thừa nhận.', 'C1', 'Though the reform was introduced with laudable intentions, its implementation proved so convoluted that even its staunchest supporters conceded the outcomes fell short of expectations.');

-- ── 3) Dictation: bảng câu nghe-chép ──────────────────────────────────────────
CREATE TABLE dictation_sentence (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cefr_level  VARCHAR(10) NOT NULL,        -- A1..C2
    text        TEXT        NOT NULL,         -- câu gốc = đáp án để chấm
    hint        TEXT,                          -- gợi ý (chủ đề / từ khó), có thể null
    audio_url   TEXT,                          -- để trống → client dùng TTS đọc `text`
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dictation_sentence_level ON dictation_sentence (cefr_level);

-- ── 4) Seed câu dictation (A1–C1), ~6 câu/cấp. Câu ngắn, rõ, hợp nghe-chép. ────
INSERT INTO dictation_sentence (cefr_level, text, hint) VALUES
-- A1
('A1', 'My name is Anna.',                'Giới thiệu bản thân'),
('A1', 'I have two brothers.',            'Gia đình'),
('A1', 'The cat is on the table.',        'Vị trí'),
('A1', 'She goes to school every day.',   'Thói quen'),
('A1', 'We like apples and oranges.',     'Sở thích'),
('A1', 'It is a sunny day.',              'Thời tiết'),
-- A2
('A2', 'Yesterday we visited the museum.',          'Quá khứ'),
('A2', 'He is taller than his sister.',             'So sánh'),
('A2', 'They are going to the beach next weekend.', 'Tương lai gần'),
('A2', 'I have lived here for three years.',         'Hiện tại hoàn thành'),
('A2', 'Could you open the window, please?',         'Đề nghị lịch sự'),
('A2', 'She bought a new dress for the party.',      'Mua sắm'),
-- B1
('B1', 'If it rains tomorrow, we will stay at home.',           'Câu điều kiện'),
('B1', 'The film was more interesting than I expected.',        'Đánh giá'),
('B1', 'He has been working at this company since 2018.',       'Hiện tại hoàn thành tiếp diễn'),
('B1', 'They decided to travel by train instead of by plane.',  'Lựa chọn'),
('B1', 'Could you tell me where the nearest station is?',       'Hỏi đường gián tiếp'),
('B1', 'Although she was tired, she finished the project.',     'Tương phản'),
-- B2
('B2', 'The committee will announce its decision next week.',                  'Trang trọng'),
('B2', 'Despite the heavy traffic, we arrived on time.',                       'Tương phản'),
('B2', 'The new policy is expected to reduce pollution significantly.',        'Bị động'),
('B2', 'She would have passed the exam if she had studied harder.',            'Điều kiện loại 3'),
('B2', 'Renewable energy plays a crucial role in fighting climate change.',    'Chủ đề môi trường'),
('B2', 'The manager emphasized the importance of teamwork.',                   'Công việc'),
-- C1
('C1', 'The proposal was met with considerable skepticism from the board.',            'Học thuật'),
('C1', 'Had the warning been issued earlier, the damage could have been avoided.',     'Đảo ngữ điều kiện'),
('C1', 'Researchers have long debated the underlying causes of the phenomenon.',       'Nghiên cứu'),
('C1', 'The legislation aims to strike a balance between growth and sustainability.',  'Chính sách'),
('C1', 'Her argument, though compelling, overlooked several critical factors.',        'Phản biện'),
('C1', 'The economy showed signs of recovery despite ongoing global uncertainty.',     'Kinh tế');
