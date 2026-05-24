-- =============================================================================
-- V23 — Seed nội dung A1 chuẩn (10 path × 8 activity)
-- =============================================================================
-- Mục tiêu:
--   * Thay thế toàn bộ nội dung "generic" của A1 path-02..10 (từ V20) bằng nội
--     dung theo chủ đề thật, và mở rộng path-01 (greetings) từ 4 → 8 activity.
--   * Mỗi path A1 có đúng 8 lesson + 8 path_activity + 8 lesson_activity, tuần tự
--     theo template: vocab → grammar → listening → reading → speaking → writing
--     → listening 2 → review_quiz.
--
-- Quy tắc xóa an toàn:
--   - CASCADE đã có sẵn trên learning_path_activities, learning_lesson_activities.
--   - user_lesson_progress.lesson_id ON DELETE CASCADE, user_path_progress.path_id
--     ON DELETE CASCADE → xóa lesson/path cũ sẽ tự dọn progress test.
--   - Bảng user_lesson_attempts cũng CASCADE theo lesson_id.
-- =============================================================================

-- ── 1) Xóa toàn bộ dữ liệu A1 cũ ─────────────────────────────────────────────
-- Phải xóa theo thứ tự con → cha vì FK trên learning_path_activities.lesson_id
-- KHÔNG có ON DELETE CASCADE (cha là learning_lessons).
DELETE FROM learning_path_activities
WHERE path_id IN (SELECT id FROM learning_paths WHERE level_code = 'A1');

DELETE FROM learning_lesson_activities
WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'A1');

DELETE FROM learning_lessons WHERE level_code = 'A1';
DELETE FROM learning_paths   WHERE level_code = 'A1';

-- ── 2) Tạo 10 path A1 ────────────────────────────────────────────────────────
INSERT INTO learning_paths (id, level_code, title, description, display_order, skills_coverage) VALUES
    ('a1-path-01-greetings', 'A1', 'Greetings & introductions',
     'Chào hỏi, giới thiệu bản thân và làm quen với câu đơn.', 1,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-02-family', 'A1', 'Family and friends',
     'Nói về người thân, bạn bè và mô tả cơ bản bằng sở hữu cách.', 2,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-03-daily-life', 'A1', 'Daily life',
     'Diễn tả thói quen, giờ giấc và sinh hoạt thường ngày.', 3,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-04-classroom', 'A1', 'Classroom English',
     'Theo dõi chỉ dẫn trong lớp và xin phép, đặt câu hỏi cơ bản.', 4,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-05-food-drink', 'A1', 'Food and drinks',
     'Nói về món ăn yêu thích, gọi đồ uống đơn giản.', 5,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-06-home', 'A1', 'My home',
     'Mô tả các phòng, đồ vật và vị trí trong nhà.', 6,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-07-places', 'A1', 'Places in town',
     'Hỏi đường đơn giản và mô tả vị trí quen thuộc.', 7,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-08-free-time', 'A1', 'Free time',
     'Nói về sở thích, hoạt động cuối tuần và tần suất.', 8,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-09-shopping', 'A1', 'Simple shopping',
     'Hỏi giá, màu sắc, kích cỡ và số lượng cơ bản.', 9,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb),
    ('a1-path-10-review', 'A1', 'A1 mixed review',
     'Tổng ôn toàn bộ cấu trúc và từ vựng cốt lõi của A1.', 10,
     '["vocabulary","grammar","listening","reading","speaking","writing"]'::jsonb);

-- =============================================================================
-- Helper: mỗi path có 8 row trong learning_lessons, learning_path_activities và
-- learning_lesson_activities. Để dễ review, mỗi path được chèn thành 1 block.
-- Quy ước id:
--   lesson_id              = '<path-id>-lesson-<NN>'
--   path_activity_id       = '<path-id>-act-<NN>'
--   lesson_activity_id     = '<path-id>-lac-<NN>'
-- Template 8 step:
--   01 vocabulary_match (4', 8 xp)
--   02 grammar_fill_blank (5', 10 xp)
--   03 listening_choice  (6', 10 xp)
--   04 reading_question  (6', 10 xp)
--   05 pronunciation     (5', 12 xp)
--   06 writing_prompt    (7', 12 xp)
--   07 listening_choice  (6', 10 xp)
--   08 review_quiz       (8', 18 xp)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 01 — Greetings & introductions
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-01-greetings-lesson-01','A1','reading','a1-path-01-greetings','Greeting words','Học các từ chào hỏi cơ bản.',4,8,
 '{"instruction":"Chọn từ chào hỏi phù hợp.","passage":"hello, hi, bye, goodbye, nice to meet you","translationVi":"Các cách chào và tạm biệt phổ biến."}'::jsonb),
('a1-path-01-greetings-lesson-02','A1','reading','a1-path-01-greetings','To be: am / is / are','Cấu trúc cơ bản với động từ to be.',5,10,
 '{"instruction":"Chọn dạng to be đúng.","passage":"I am Linh. You are a student. She is my friend.","translationVi":"Tôi là Linh. Bạn là học sinh. Cô ấy là bạn tôi."}'::jsonb),
('a1-path-01-greetings-lesson-03','A1','listening','a1-path-01-greetings','Hello and goodbye','Nghe hội thoại chào hỏi.',6,10,
 '{"instruction":"Nghe và chọn đáp án đúng.","transcript":"A: Hello! B: Hi! Nice to meet you. A: Goodbye!","audioUrl":"https://cdn.example.com/a1/p01-l03.mp3","translationVi":"A: Xin chào! B: Chào bạn! Rất vui được gặp. A: Tạm biệt!"}'::jsonb),
('a1-path-01-greetings-lesson-04','A1','reading','a1-path-01-greetings','A short profile','Đọc hồ sơ cá nhân ngắn.',6,10,
 '{"instruction":"Đọc đoạn văn và trả lời câu hỏi.","passage":"My name is Ben. I am from Canada. I am a student.","translationVi":"Tên tôi là Ben. Tôi đến từ Canada. Tôi là học sinh."}'::jsonb),
('a1-path-01-greetings-lesson-05','A1','speaking','a1-path-01-greetings','Introduce yourself','Phát âm câu giới thiệu tên.',5,12,
 '{"instruction":"Nghe mẫu rồi ghi âm lại.","sampleText":"Hello, my name is Linh.","phonetic":"həˈloʊ, maɪ neɪm ɪz lɪn","translationVi":"Xin chào, tôi tên là Linh."}'::jsonb),
('a1-path-01-greetings-lesson-06','A1','writing','a1-path-01-greetings','Write your name and country','Viết câu giới thiệu cơ bản.',7,12,
 '{"instruction":"Viết 2 câu giới thiệu tên và quốc gia.","prompt":"Write your name and where you are from.","exampleAnswer":"My name is Mai. I am from Vietnam."}'::jsonb),
('a1-path-01-greetings-lesson-07','A1','listening','a1-path-01-greetings','Meeting new people','Nghe hội thoại làm quen.',6,10,
 '{"instruction":"Nghe đoạn và chọn ý đúng.","transcript":"A: Hi, I am Tom. What is your name? B: I am Mai. Nice to meet you.","translationVi":"A: Chào, tôi là Tom. Bạn tên gì? B: Tôi là Mai. Rất vui được gặp."}'::jsonb),
('a1-path-01-greetings-lesson-08','A1','reading','a1-path-01-greetings','Greetings review','Ôn tập cuối chủ đề.',8,18,
 '{"instruction":"Trả lời 3 câu hỏi tổng hợp.","passage":"Review: greetings, to be, introduce.","translationVi":"Ôn lại chào hỏi, to be, và giới thiệu."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-01-greetings-act-01','a1-path-01-greetings','a1-path-01-greetings-lesson-01','reading','vocabulary_match','Greeting words','Khởi động từ vựng chào hỏi.',1,4,8),
('a1-path-01-greetings-act-02','a1-path-01-greetings','a1-path-01-greetings-lesson-02','reading','grammar_fill_blank','To be: am / is / are','Điền dạng to be đúng.',2,5,10),
('a1-path-01-greetings-act-03','a1-path-01-greetings','a1-path-01-greetings-lesson-03','listening','listening_choice','Listen for greetings','Nghe và chọn lời chào.',3,6,10),
('a1-path-01-greetings-act-04','a1-path-01-greetings','a1-path-01-greetings-lesson-04','reading','reading_question','Read a short profile','Đọc và trả lời.',4,6,10),
('a1-path-01-greetings-act-05','a1-path-01-greetings','a1-path-01-greetings-lesson-05','speaking','pronunciation','Introduce yourself','Phát âm câu giới thiệu.',5,5,12),
('a1-path-01-greetings-act-06','a1-path-01-greetings','a1-path-01-greetings-lesson-06','writing','writing_prompt','Write about yourself','Viết giới thiệu bản thân.',6,7,12),
('a1-path-01-greetings-act-07','a1-path-01-greetings','a1-path-01-greetings-lesson-07','listening','listening_choice','Meeting new people','Nghe hội thoại làm quen.',7,6,10),
('a1-path-01-greetings-act-08','a1-path-01-greetings','a1-path-01-greetings-lesson-08','reading','review_quiz','Greetings review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lac-01','a1-path-01-greetings-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"xin chào\"?","options":[{"id":"A","text":"Bye"},{"id":"B","text":"Hello"},{"id":"C","text":"Sorry"}],"correctOptionId":"B","explanationVi":"Hello = xin chào."}'::jsonb,null),
('a1-path-01-greetings-lac-02','a1-path-01-greetings-lesson-02','multiple_choice',1,
 '{"question":"She ___ my friend.","options":[{"id":"A","text":"am"},{"id":"B","text":"is"},{"id":"C","text":"are"}],"correctOptionId":"B","explanationVi":"Chủ ngữ She đi với is."}'::jsonb,null),
('a1-path-01-greetings-lac-03','a1-path-01-greetings-lesson-03','multiple_choice',1,
 '{"question":"What does B say to greet A?","options":[{"id":"A","text":"Hi!"},{"id":"B","text":"Bye"},{"id":"C","text":"Sorry"}],"correctOptionId":"A","explanationVi":"B đáp Hi! để chào lại."}'::jsonb,null),
('a1-path-01-greetings-lac-04','a1-path-01-greetings-lesson-04','multiple_choice',1,
 '{"question":"Where is Ben from?","options":[{"id":"A","text":"Canada"},{"id":"B","text":"Japan"},{"id":"C","text":"Vietnam"}],"correctOptionId":"A","explanationVi":"Bài có câu I am from Canada."}'::jsonb,null),
('a1-path-01-greetings-lac-05','a1-path-01-greetings-lesson-05','pronunciation',1,
 '{"expectedText":"Hello, my name is Linh.","minScoreToPass":70}'::jsonb,70),
('a1-path-01-greetings-lac-06','a1-path-01-greetings-lesson-06','writing_prompt',1,
 '{"prompt":"Write your name and where you are from.","rubric":["Có câu giới thiệu tên.","Có câu giới thiệu quốc gia.","Dùng My name is... / I am from..."]}'::jsonb,null),
('a1-path-01-greetings-lac-07','a1-path-01-greetings-lesson-07','multiple_choice',1,
 '{"question":"What is the girl''s name?","options":[{"id":"A","text":"Tom"},{"id":"B","text":"Mai"},{"id":"C","text":"Linh"}],"correctOptionId":"B","explanationVi":"Cô ấy nói I am Mai."}'::jsonb,null),
('a1-path-01-greetings-lac-08','a1-path-01-greetings-lesson-08','multiple_choice',1,
 '{"question":"Which sentence is correct?","options":[{"id":"A","text":"I are a student."},{"id":"B","text":"I am a student."},{"id":"C","text":"I is a student."}],"correctOptionId":"B","explanationVi":"I luôn đi với am."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 02 — Family and friends
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-02-family-lesson-01','A1','reading','a1-path-02-family','Family words','Học từ vựng người thân.',4,8,
 '{"instruction":"Chọn nghĩa đúng cho từ chỉ người thân.","passage":"mother, father, sister, brother, friend","translationVi":"mẹ, bố, chị/em gái, anh/em trai, bạn."}'::jsonb),
('a1-path-02-family-lesson-02','A1','reading','a1-path-02-family','Possessives: my / your / his / her','Tính từ sở hữu cơ bản.',5,10,
 '{"instruction":"Chọn tính từ sở hữu đúng.","passage":"This is my mother. That is his sister.","translationVi":"Đây là mẹ tôi. Kia là chị của anh ấy."}'::jsonb),
('a1-path-02-family-lesson-03','A1','listening','a1-path-02-family','Family photo','Nghe hội thoại giới thiệu gia đình.',6,10,
 '{"instruction":"Nghe và chọn người được nhắc tới.","transcript":"This is my family. My father is a teacher. My mother is a nurse.","translationVi":"Đây là gia đình tôi. Bố tôi là giáo viên. Mẹ tôi là y tá."}'::jsonb),
('a1-path-02-family-lesson-04','A1','reading','a1-path-02-family','My best friend','Đọc đoạn mô tả bạn thân.',6,10,
 '{"instruction":"Đọc và trả lời câu hỏi.","passage":"My best friend is Lan. She is 12 years old. She likes music.","translationVi":"Bạn thân tôi là Lan. Cô ấy 12 tuổi. Cô ấy thích âm nhạc."}'::jsonb),
('a1-path-02-family-lesson-05','A1','speaking','a1-path-02-family','Introduce my family','Phát âm câu giới thiệu gia đình.',5,12,
 '{"instruction":"Nghe mẫu rồi nói lại.","sampleText":"This is my sister. Her name is Mai.","phonetic":"ðɪs ɪz maɪ ˈsɪstər. hɜːr neɪm ɪz maɪ.","translationVi":"Đây là em gái tôi. Cô ấy tên là Mai."}'::jsonb),
('a1-path-02-family-lesson-06','A1','writing','a1-path-02-family','Write about a family member','Viết 2 câu về một người thân.',7,12,
 '{"instruction":"Viết 2 câu về một người trong gia đình.","prompt":"Describe one person in your family.","exampleAnswer":"My mother is kind. She is a doctor."}'::jsonb),
('a1-path-02-family-lesson-07','A1','listening','a1-path-02-family','Meet my brother','Nghe đoạn giới thiệu anh trai.',6,10,
 '{"instruction":"Nghe và chọn đáp án đúng.","transcript":"My brother is Nam. He is a student. He likes football.","translationVi":"Anh tôi tên Nam. Anh ấy là học sinh. Anh ấy thích bóng đá."}'::jsonb),
('a1-path-02-family-lesson-08','A1','reading','a1-path-02-family','Family review','Ôn tập cuối chủ đề gia đình.',8,18,
 '{"instruction":"Trả lời 3 câu ôn tập.","passage":"Review: family members and possessives.","translationVi":"Ôn lại người thân và tính từ sở hữu."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-02-family-act-01','a1-path-02-family','a1-path-02-family-lesson-01','reading','vocabulary_match','Family words','Khởi động từ vựng.',1,4,8),
('a1-path-02-family-act-02','a1-path-02-family','a1-path-02-family-lesson-02','reading','grammar_fill_blank','Possessives','Điền tính từ sở hữu.',2,5,10),
('a1-path-02-family-act-03','a1-path-02-family','a1-path-02-family-lesson-03','listening','listening_choice','Family photo','Nghe và chọn người.',3,6,10),
('a1-path-02-family-act-04','a1-path-02-family','a1-path-02-family-lesson-04','reading','reading_question','My best friend','Đọc và trả lời.',4,6,10),
('a1-path-02-family-act-05','a1-path-02-family','a1-path-02-family-lesson-05','speaking','pronunciation','Introduce my family','Phát âm câu mẫu.',5,5,12),
('a1-path-02-family-act-06','a1-path-02-family','a1-path-02-family-lesson-06','writing','writing_prompt','Write about a family member','Viết 2 câu mô tả.',6,7,12),
('a1-path-02-family-act-07','a1-path-02-family','a1-path-02-family-lesson-07','listening','listening_choice','Meet my brother','Nghe đoạn ngắn.',7,6,10),
('a1-path-02-family-act-08','a1-path-02-family','a1-path-02-family-lesson-08','reading','review_quiz','Family review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-02-family-lac-01','a1-path-02-family-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"mẹ\"?","options":[{"id":"A","text":"father"},{"id":"B","text":"mother"},{"id":"C","text":"sister"}],"correctOptionId":"B","explanationVi":"mother = mẹ."}'::jsonb,null),
('a1-path-02-family-lac-02','a1-path-02-family-lesson-02','multiple_choice',1,
 '{"question":"This is ___ mother. (tôi)","options":[{"id":"A","text":"my"},{"id":"B","text":"your"},{"id":"C","text":"his"}],"correctOptionId":"A","explanationVi":"\"của tôi\" = my."}'::jsonb,null),
('a1-path-02-family-lac-03','a1-path-02-family-lesson-03','multiple_choice',1,
 '{"question":"What is the mother''s job?","options":[{"id":"A","text":"Teacher"},{"id":"B","text":"Nurse"},{"id":"C","text":"Doctor"}],"correctOptionId":"B","explanationVi":"Trong bài: My mother is a nurse."}'::jsonb,null),
('a1-path-02-family-lac-04','a1-path-02-family-lesson-04','multiple_choice',1,
 '{"question":"How old is Lan?","options":[{"id":"A","text":"10"},{"id":"B","text":"12"},{"id":"C","text":"14"}],"correctOptionId":"B","explanationVi":"Bài có: She is 12 years old."}'::jsonb,null),
('a1-path-02-family-lac-05','a1-path-02-family-lesson-05','pronunciation',1,
 '{"expectedText":"This is my sister. Her name is Mai.","minScoreToPass":70}'::jsonb,70),
('a1-path-02-family-lac-06','a1-path-02-family-lesson-06','writing_prompt',1,
 '{"prompt":"Describe one person in your family.","rubric":["Nêu rõ là người nào.","Nêu 1 đặc điểm hoặc nghề.","Dùng My ... is ..."]}'::jsonb,null),
('a1-path-02-family-lac-07','a1-path-02-family-lesson-07','multiple_choice',1,
 '{"question":"What does Nam like?","options":[{"id":"A","text":"Music"},{"id":"B","text":"Football"},{"id":"C","text":"Cooking"}],"correctOptionId":"B","explanationVi":"Bài có: He likes football."}'::jsonb,null),
('a1-path-02-family-lac-08','a1-path-02-family-lesson-08','multiple_choice',1,
 '{"question":"Which is correct?","options":[{"id":"A","text":"This is she sister."},{"id":"B","text":"This is her sister."},{"id":"C","text":"This is hers sister."}],"correctOptionId":"B","explanationVi":"Trước danh từ dùng tính từ sở hữu her."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 03 — Daily life
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-03-daily-life-lesson-01','A1','reading','a1-path-03-daily-life','Daily activities','Học từ vựng sinh hoạt hằng ngày.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"wake up, eat, work, study, sleep","translationVi":"thức dậy, ăn, làm việc, học, ngủ."}'::jsonb),
('a1-path-03-daily-life-lesson-02','A1','reading','a1-path-03-daily-life','Present simple + time','Thì hiện tại đơn với giờ giấc.',5,10,
 '{"instruction":"Chọn dạng động từ đúng.","passage":"I wake up at 6. She works at 8 a.m.","translationVi":"Tôi thức dậy lúc 6 giờ. Cô ấy làm việc lúc 8 giờ sáng."}'::jsonb),
('a1-path-03-daily-life-lesson-03','A1','listening','a1-path-03-daily-life','My morning','Nghe đoạn nói về buổi sáng.',6,10,
 '{"instruction":"Nghe và chọn giờ đúng.","transcript":"I wake up at 6 a.m. I eat breakfast at 7. I go to school at 8.","translationVi":"Tôi dậy lúc 6 giờ. Tôi ăn sáng lúc 7. Tôi đi học lúc 8."}'::jsonb),
('a1-path-03-daily-life-lesson-04','A1','reading','a1-path-03-daily-life','A working day','Đọc đoạn về ngày làm việc.',6,10,
 '{"instruction":"Đọc và trả lời câu hỏi.","passage":"Mr. Lam works in an office. He starts at 9 a.m. and finishes at 5 p.m.","translationVi":"Ông Lâm làm việc trong văn phòng. Ông bắt đầu lúc 9 giờ và kết thúc lúc 5 giờ."}'::jsonb),
('a1-path-03-daily-life-lesson-05','A1','speaking','a1-path-03-daily-life','Talk about your day','Phát âm câu mô tả ngày của bạn.',5,12,
 '{"instruction":"Nghe và lặp lại.","sampleText":"I go to school at seven thirty.","phonetic":"aɪ ɡoʊ tuː skuːl æt ˈsɛvən ˈθɜːrti.","translationVi":"Tôi đi học lúc 7 giờ 30."}'::jsonb),
('a1-path-03-daily-life-lesson-06','A1','writing','a1-path-03-daily-life','Write your routine','Viết 2 câu về thói quen.',7,12,
 '{"instruction":"Viết 2 câu về thói quen buổi sáng.","prompt":"Write 2 things you do in the morning.","exampleAnswer":"I wake up at 6. I eat breakfast at 7."}'::jsonb),
('a1-path-03-daily-life-lesson-07','A1','listening','a1-path-03-daily-life','Evening routine','Nghe đoạn về buổi tối.',6,10,
 '{"instruction":"Nghe và chọn việc đúng.","transcript":"In the evening, I do homework. Then I watch TV. I go to bed at 10.","translationVi":"Buổi tối, tôi làm bài tập. Sau đó xem TV. Tôi đi ngủ lúc 10 giờ."}'::jsonb),
('a1-path-03-daily-life-lesson-08','A1','reading','a1-path-03-daily-life','Daily life review','Ôn tập sinh hoạt hằng ngày.',8,18,
 '{"instruction":"Trả lời 3 câu hỏi ôn.","passage":"Review: routines, time, present simple.","translationVi":"Ôn lại thói quen, giờ giấc, hiện tại đơn."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-03-daily-life-act-01','a1-path-03-daily-life','a1-path-03-daily-life-lesson-01','reading','vocabulary_match','Daily activities','Khởi động từ vựng.',1,4,8),
('a1-path-03-daily-life-act-02','a1-path-03-daily-life','a1-path-03-daily-life-lesson-02','reading','grammar_fill_blank','Present simple + time','Điền dạng đúng.',2,5,10),
('a1-path-03-daily-life-act-03','a1-path-03-daily-life','a1-path-03-daily-life-lesson-03','listening','listening_choice','My morning','Nghe và chọn giờ.',3,6,10),
('a1-path-03-daily-life-act-04','a1-path-03-daily-life','a1-path-03-daily-life-lesson-04','reading','reading_question','A working day','Đọc và trả lời.',4,6,10),
('a1-path-03-daily-life-act-05','a1-path-03-daily-life','a1-path-03-daily-life-lesson-05','speaking','pronunciation','Talk about your day','Phát âm câu mẫu.',5,5,12),
('a1-path-03-daily-life-act-06','a1-path-03-daily-life','a1-path-03-daily-life-lesson-06','writing','writing_prompt','Write your routine','Viết thói quen sáng.',6,7,12),
('a1-path-03-daily-life-act-07','a1-path-03-daily-life','a1-path-03-daily-life-lesson-07','listening','listening_choice','Evening routine','Nghe buổi tối.',7,6,10),
('a1-path-03-daily-life-act-08','a1-path-03-daily-life','a1-path-03-daily-life-lesson-08','reading','review_quiz','Daily life review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-03-daily-life-lac-01','a1-path-03-daily-life-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"ngủ\"?","options":[{"id":"A","text":"eat"},{"id":"B","text":"sleep"},{"id":"C","text":"work"}],"correctOptionId":"B","explanationVi":"sleep = ngủ."}'::jsonb,null),
('a1-path-03-daily-life-lac-02','a1-path-03-daily-life-lesson-02','multiple_choice',1,
 '{"question":"She ___ at 8 a.m.","options":[{"id":"A","text":"work"},{"id":"B","text":"works"},{"id":"C","text":"working"}],"correctOptionId":"B","explanationVi":"She + works (thêm s)."}'::jsonb,null),
('a1-path-03-daily-life-lac-03','a1-path-03-daily-life-lesson-03','multiple_choice',1,
 '{"question":"What time does the speaker eat breakfast?","options":[{"id":"A","text":"6 a.m."},{"id":"B","text":"7 a.m."},{"id":"C","text":"8 a.m."}],"correctOptionId":"B","explanationVi":"Bài có: I eat breakfast at 7."}'::jsonb,null),
('a1-path-03-daily-life-lac-04','a1-path-03-daily-life-lesson-04','multiple_choice',1,
 '{"question":"What time does Mr. Lam finish work?","options":[{"id":"A","text":"9 a.m."},{"id":"B","text":"5 p.m."},{"id":"C","text":"7 p.m."}],"correctOptionId":"B","explanationVi":"Bài có: finishes at 5 p.m."}'::jsonb,null),
('a1-path-03-daily-life-lac-05','a1-path-03-daily-life-lesson-05','pronunciation',1,
 '{"expectedText":"I go to school at seven thirty.","minScoreToPass":70}'::jsonb,70),
('a1-path-03-daily-life-lac-06','a1-path-03-daily-life-lesson-06','writing_prompt',1,
 '{"prompt":"Write 2 things you do in the morning.","rubric":["Có ít nhất 2 hoạt động.","Có chỉ giờ (at ...).","Dùng hiện tại đơn."]}'::jsonb,null),
('a1-path-03-daily-life-lac-07','a1-path-03-daily-life-lesson-07','multiple_choice',1,
 '{"question":"What time does the speaker go to bed?","options":[{"id":"A","text":"9"},{"id":"B","text":"10"},{"id":"C","text":"11"}],"correctOptionId":"B","explanationVi":"Bài có: I go to bed at 10."}'::jsonb,null),
('a1-path-03-daily-life-lac-08','a1-path-03-daily-life-lesson-08','multiple_choice',1,
 '{"question":"Which sentence is correct?","options":[{"id":"A","text":"He go to school at 7."},{"id":"B","text":"He goes to school at 7."},{"id":"C","text":"He going to school at 7."}],"correctOptionId":"B","explanationVi":"Ngôi thứ 3 số ít: goes."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 04 — Classroom English
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-04-classroom-lesson-01','A1','reading','a1-path-04-classroom','Classroom objects','Từ vựng đồ vật trong lớp.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"book, pen, pencil, board, desk","translationVi":"sách, bút, bút chì, bảng, bàn học."}'::jsonb),
('a1-path-04-classroom-lesson-02','A1','reading','a1-path-04-classroom','Imperatives & Can I...?','Câu mệnh lệnh và xin phép.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"Open your book. Can I ask a question? Please listen carefully.","translationVi":"Mở sách ra. Tôi hỏi được không? Hãy nghe kỹ."}'::jsonb),
('a1-path-04-classroom-lesson-03','A1','listening','a1-path-04-classroom','In the classroom','Nghe chỉ dẫn của giáo viên.',6,10,
 '{"instruction":"Nghe và chọn việc cần làm.","transcript":"Good morning class. Open your book to page 10. Please read with me.","translationVi":"Chào lớp. Mở sách trang 10. Đọc theo cô."}'::jsonb),
('a1-path-04-classroom-lesson-04','A1','reading','a1-path-04-classroom','School notice','Đọc thông báo trên lớp.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"Tomorrow we have an English test. Bring a pen and a dictionary.","translationVi":"Ngày mai có kiểm tra tiếng Anh. Mang bút và từ điển."}'::jsonb),
('a1-path-04-classroom-lesson-05','A1','speaking','a1-path-04-classroom','Ask politely','Phát âm câu xin phép.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"Can I ask a question, please?","phonetic":"kæn aɪ æsk ə ˈkwɛs.tʃən, pliːz","translationVi":"Tôi xin phép đặt một câu hỏi được không?"}'::jsonb),
('a1-path-04-classroom-lesson-06','A1','writing','a1-path-04-classroom','Write a classroom rule','Viết 1 nội quy lớp học.',7,12,
 '{"instruction":"Viết 1 nội quy bằng câu mệnh lệnh.","prompt":"Write one classroom rule.","exampleAnswer":"Please be quiet in class."}'::jsonb),
('a1-path-04-classroom-lesson-07','A1','listening','a1-path-04-classroom','Asking the teacher','Nghe học sinh hỏi giáo viên.',6,10,
 '{"instruction":"Nghe và chọn yêu cầu đúng.","transcript":"Excuse me. Can you repeat that, please? I don''t understand.","translationVi":"Xin lỗi. Cô nói lại được không ạ? Em không hiểu."}'::jsonb),
('a1-path-04-classroom-lesson-08','A1','reading','a1-path-04-classroom','Classroom review','Ôn tập câu lớp học.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: classroom objects + imperative + Can I...?","translationVi":"Ôn lại từ vựng lớp học và câu xin phép."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-04-classroom-act-01','a1-path-04-classroom','a1-path-04-classroom-lesson-01','reading','vocabulary_match','Classroom objects','Khởi động từ vựng.',1,4,8),
('a1-path-04-classroom-act-02','a1-path-04-classroom','a1-path-04-classroom-lesson-02','reading','grammar_fill_blank','Imperatives & Can I...?','Điền câu đúng.',2,5,10),
('a1-path-04-classroom-act-03','a1-path-04-classroom','a1-path-04-classroom-lesson-03','listening','listening_choice','In the classroom','Nghe chỉ dẫn.',3,6,10),
('a1-path-04-classroom-act-04','a1-path-04-classroom','a1-path-04-classroom-lesson-04','reading','reading_question','School notice','Đọc thông báo.',4,6,10),
('a1-path-04-classroom-act-05','a1-path-04-classroom','a1-path-04-classroom-lesson-05','speaking','pronunciation','Ask politely','Phát âm câu xin phép.',5,5,12),
('a1-path-04-classroom-act-06','a1-path-04-classroom','a1-path-04-classroom-lesson-06','writing','writing_prompt','Write a classroom rule','Viết nội quy.',6,7,12),
('a1-path-04-classroom-act-07','a1-path-04-classroom','a1-path-04-classroom-lesson-07','listening','listening_choice','Asking the teacher','Nghe học sinh hỏi.',7,6,10),
('a1-path-04-classroom-act-08','a1-path-04-classroom','a1-path-04-classroom-lesson-08','reading','review_quiz','Classroom review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-04-classroom-lac-01','a1-path-04-classroom-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"bảng\"?","options":[{"id":"A","text":"book"},{"id":"B","text":"board"},{"id":"C","text":"pen"}],"correctOptionId":"B","explanationVi":"board = bảng."}'::jsonb,null),
('a1-path-04-classroom-lac-02','a1-path-04-classroom-lesson-02','multiple_choice',1,
 '{"question":"___ your book to page 10.","options":[{"id":"A","text":"Open"},{"id":"B","text":"Opens"},{"id":"C","text":"Opening"}],"correctOptionId":"A","explanationVi":"Câu mệnh lệnh: dùng V nguyên thể."}'::jsonb,null),
('a1-path-04-classroom-lac-03','a1-path-04-classroom-lesson-03','multiple_choice',1,
 '{"question":"What page does the teacher mention?","options":[{"id":"A","text":"10"},{"id":"B","text":"12"},{"id":"C","text":"20"}],"correctOptionId":"A","explanationVi":"Bài có: Open your book to page 10."}'::jsonb,null),
('a1-path-04-classroom-lac-04','a1-path-04-classroom-lesson-04','multiple_choice',1,
 '{"question":"What should students bring?","options":[{"id":"A","text":"A pen and a dictionary"},{"id":"B","text":"A book and a laptop"},{"id":"C","text":"Only a pencil"}],"correctOptionId":"A","explanationVi":"Bài có: Bring a pen and a dictionary."}'::jsonb,null),
('a1-path-04-classroom-lac-05','a1-path-04-classroom-lesson-05','pronunciation',1,
 '{"expectedText":"Can I ask a question, please?","minScoreToPass":70}'::jsonb,70),
('a1-path-04-classroom-lac-06','a1-path-04-classroom-lesson-06','writing_prompt',1,
 '{"prompt":"Write one classroom rule.","rubric":["Dùng câu mệnh lệnh.","Bắt đầu bằng động từ.","Lịch sự với please nếu cần."]}'::jsonb,null),
('a1-path-04-classroom-lac-07','a1-path-04-classroom-lesson-07','multiple_choice',1,
 '{"question":"What does the student ask?","options":[{"id":"A","text":"To repeat"},{"id":"B","text":"To leave"},{"id":"C","text":"To stop"}],"correctOptionId":"A","explanationVi":"Học sinh nói: Can you repeat that?"}'::jsonb,null),
('a1-path-04-classroom-lac-08','a1-path-04-classroom-lesson-08','multiple_choice',1,
 '{"question":"Which is most polite?","options":[{"id":"A","text":"Repeat!"},{"id":"B","text":"Repeat, please."},{"id":"C","text":"You repeat now."}],"correctOptionId":"B","explanationVi":"Thêm please làm câu lịch sự."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 05 — Food and drinks
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-05-food-drink-lesson-01','A1','reading','a1-path-05-food-drink','Food & drink words','Từ vựng đồ ăn, đồ uống.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"rice, bread, water, coffee, tea, milk","translationVi":"cơm, bánh mì, nước, cà phê, trà, sữa."}'::jsonb),
('a1-path-05-food-drink-lesson-02','A1','reading','a1-path-05-food-drink','I like / I don''t like','Diễn tả sở thích.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"I like coffee. I don''t like tea. Do you like milk?","translationVi":"Tôi thích cà phê. Tôi không thích trà. Bạn có thích sữa không?"}'::jsonb),
('a1-path-05-food-drink-lesson-03','A1','listening','a1-path-05-food-drink','At a café','Nghe gọi đồ uống.',6,10,
 '{"instruction":"Nghe và chọn đồ uống được gọi.","transcript":"A: I would like a coffee, please. B: With milk? A: Yes, please.","translationVi":"A: Cho tôi một cốc cà phê. B: Có sữa không? A: Có ạ."}'::jsonb),
('a1-path-05-food-drink-lesson-04','A1','reading','a1-path-05-food-drink','My favorite meal','Đọc đoạn về bữa ăn yêu thích.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"My favorite meal is breakfast. I have bread and milk every day.","translationVi":"Bữa yêu thích của tôi là bữa sáng. Tôi ăn bánh mì và uống sữa mỗi ngày."}'::jsonb),
('a1-path-05-food-drink-lesson-05','A1','speaking','a1-path-05-food-drink','Order a drink','Phát âm câu gọi đồ uống.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"I would like a cup of coffee, please.","phonetic":"aɪ wʊd laɪk ə kʌp əv ˈkɔːfi, pliːz","translationVi":"Cho tôi một cốc cà phê, làm ơn."}'::jsonb),
('a1-path-05-food-drink-lesson-06','A1','writing','a1-path-05-food-drink','Write what you like','Viết 2 câu về sở thích ăn uống.',7,12,
 '{"instruction":"Viết 2 câu: thích và không thích.","prompt":"Write 1 food you like and 1 food you don''t like.","exampleAnswer":"I like rice. I don''t like fish."}'::jsonb),
('a1-path-05-food-drink-lesson-07','A1','listening','a1-path-05-food-drink','Asking about food','Nghe hỏi về món ăn.',6,10,
 '{"instruction":"Nghe và chọn ý đúng.","transcript":"A: Do you like noodles? B: Yes, I love them. A: Me too.","translationVi":"A: Bạn có thích mì không? B: Có, tôi rất thích. A: Tôi cũng vậy."}'::jsonb),
('a1-path-05-food-drink-lesson-08','A1','reading','a1-path-05-food-drink','Food review','Ôn tập đồ ăn, đồ uống.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: food vocabulary + like / don''t like.","translationVi":"Ôn lại từ vựng và câu thích."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-05-food-drink-act-01','a1-path-05-food-drink','a1-path-05-food-drink-lesson-01','reading','vocabulary_match','Food & drink words','Khởi động từ vựng.',1,4,8),
('a1-path-05-food-drink-act-02','a1-path-05-food-drink','a1-path-05-food-drink-lesson-02','reading','grammar_fill_blank','Like / don''t like','Điền câu đúng.',2,5,10),
('a1-path-05-food-drink-act-03','a1-path-05-food-drink','a1-path-05-food-drink-lesson-03','listening','listening_choice','At a café','Nghe gọi đồ uống.',3,6,10),
('a1-path-05-food-drink-act-04','a1-path-05-food-drink','a1-path-05-food-drink-lesson-04','reading','reading_question','My favorite meal','Đọc và trả lời.',4,6,10),
('a1-path-05-food-drink-act-05','a1-path-05-food-drink','a1-path-05-food-drink-lesson-05','speaking','pronunciation','Order a drink','Phát âm câu mẫu.',5,5,12),
('a1-path-05-food-drink-act-06','a1-path-05-food-drink','a1-path-05-food-drink-lesson-06','writing','writing_prompt','Write what you like','Viết sở thích.',6,7,12),
('a1-path-05-food-drink-act-07','a1-path-05-food-drink','a1-path-05-food-drink-lesson-07','listening','listening_choice','Asking about food','Nghe hỏi về món ăn.',7,6,10),
('a1-path-05-food-drink-act-08','a1-path-05-food-drink','a1-path-05-food-drink-lesson-08','reading','review_quiz','Food review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-05-food-drink-lac-01','a1-path-05-food-drink-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"sữa\"?","options":[{"id":"A","text":"water"},{"id":"B","text":"milk"},{"id":"C","text":"tea"}],"correctOptionId":"B","explanationVi":"milk = sữa."}'::jsonb,null),
('a1-path-05-food-drink-lac-02','a1-path-05-food-drink-lesson-02','multiple_choice',1,
 '{"question":"I ___ like fish.","options":[{"id":"A","text":"don''t"},{"id":"B","text":"doesn''t"},{"id":"C","text":"not"}],"correctOptionId":"A","explanationVi":"I + don''t + V."}'::jsonb,null),
('a1-path-05-food-drink-lac-03','a1-path-05-food-drink-lesson-03','multiple_choice',1,
 '{"question":"What does A order?","options":[{"id":"A","text":"Tea"},{"id":"B","text":"Coffee"},{"id":"C","text":"Water"}],"correctOptionId":"B","explanationVi":"A nói: I would like a coffee."}'::jsonb,null),
('a1-path-05-food-drink-lac-04','a1-path-05-food-drink-lesson-04','multiple_choice',1,
 '{"question":"What does the writer have for breakfast?","options":[{"id":"A","text":"Rice and tea"},{"id":"B","text":"Bread and milk"},{"id":"C","text":"Noodles and water"}],"correctOptionId":"B","explanationVi":"Bài có: bread and milk."}'::jsonb,null),
('a1-path-05-food-drink-lac-05','a1-path-05-food-drink-lesson-05','pronunciation',1,
 '{"expectedText":"I would like a cup of coffee, please.","minScoreToPass":70}'::jsonb,70),
('a1-path-05-food-drink-lac-06','a1-path-05-food-drink-lesson-06','writing_prompt',1,
 '{"prompt":"Write 1 food you like and 1 food you don''t like.","rubric":["Có 1 câu I like ...","Có 1 câu I don''t like ...","Dùng món ăn cụ thể."]}'::jsonb,null),
('a1-path-05-food-drink-lac-07','a1-path-05-food-drink-lesson-07','multiple_choice',1,
 '{"question":"Does B like noodles?","options":[{"id":"A","text":"Yes"},{"id":"B","text":"No"},{"id":"C","text":"Not sure"}],"correctOptionId":"A","explanationVi":"B nói: Yes, I love them."}'::jsonb,null),
('a1-path-05-food-drink-lac-08','a1-path-05-food-drink-lesson-08','multiple_choice',1,
 '{"question":"Which is correct?","options":[{"id":"A","text":"He don''t like tea."},{"id":"B","text":"He doesn''t like tea."},{"id":"C","text":"He not like tea."}],"correctOptionId":"B","explanationVi":"Ngôi 3 số ít: doesn''t."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 06 — My home
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-06-home-lesson-01','A1','reading','a1-path-06-home','Rooms & furniture','Từ vựng phòng và đồ đạc.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"room, bed, table, chair, kitchen, bathroom","translationVi":"phòng, giường, bàn, ghế, bếp, phòng tắm."}'::jsonb),
('a1-path-06-home-lesson-02','A1','reading','a1-path-06-home','There is / There are + in/on/under','Mẫu câu mô tả vị trí.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"There is a book on the table. There are two chairs in the kitchen.","translationVi":"Có một quyển sách trên bàn. Có hai cái ghế trong bếp."}'::jsonb),
('a1-path-06-home-lesson-03','A1','listening','a1-path-06-home','At home','Nghe đoạn tả ngôi nhà.',6,10,
 '{"instruction":"Nghe và chọn đáp án đúng.","transcript":"My home has two bedrooms, one kitchen and one bathroom.","translationVi":"Nhà tôi có hai phòng ngủ, một bếp và một phòng tắm."}'::jsonb),
('a1-path-06-home-lesson-04','A1','reading','a1-path-06-home','In my room','Đọc đoạn tả phòng.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"In my room, there is a bed, a desk and a small chair. My books are on the desk.","translationVi":"Trong phòng tôi có một giường, một bàn và một ghế nhỏ. Sách của tôi để trên bàn."}'::jsonb),
('a1-path-06-home-lesson-05','A1','speaking','a1-path-06-home','Describe a room','Phát âm câu mô tả phòng.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"There is a bed in my room.","phonetic":"ðɛr ɪz ə bɛd ɪn maɪ ruːm.","translationVi":"Có một cái giường trong phòng tôi."}'::jsonb),
('a1-path-06-home-lesson-06','A1','writing','a1-path-06-home','Describe your home','Viết 2 câu về nhà bạn.',7,12,
 '{"instruction":"Viết 2 câu mô tả nhà của bạn.","prompt":"Write 2 sentences about your home.","exampleAnswer":"My home has three rooms. There is a small garden."}'::jsonb),
('a1-path-06-home-lesson-07','A1','listening','a1-path-06-home','Where is it?','Nghe hỏi vị trí đồ vật.',6,10,
 '{"instruction":"Nghe và chọn vị trí đúng.","transcript":"A: Where is my phone? B: It is on the table, next to the book.","translationVi":"A: Điện thoại của tôi đâu? B: Ở trên bàn, cạnh quyển sách."}'::jsonb),
('a1-path-06-home-lesson-08','A1','reading','a1-path-06-home','Home review','Ôn tập về nhà ở.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: rooms + there is/are + prepositions.","translationVi":"Ôn lại phòng ốc và mẫu câu vị trí."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-06-home-act-01','a1-path-06-home','a1-path-06-home-lesson-01','reading','vocabulary_match','Rooms & furniture','Khởi động từ vựng.',1,4,8),
('a1-path-06-home-act-02','a1-path-06-home','a1-path-06-home-lesson-02','reading','grammar_fill_blank','There is / are','Điền mẫu câu đúng.',2,5,10),
('a1-path-06-home-act-03','a1-path-06-home','a1-path-06-home-lesson-03','listening','listening_choice','At home','Nghe tả nhà.',3,6,10),
('a1-path-06-home-act-04','a1-path-06-home','a1-path-06-home-lesson-04','reading','reading_question','In my room','Đọc và trả lời.',4,6,10),
('a1-path-06-home-act-05','a1-path-06-home','a1-path-06-home-lesson-05','speaking','pronunciation','Describe a room','Phát âm câu mẫu.',5,5,12),
('a1-path-06-home-act-06','a1-path-06-home','a1-path-06-home-lesson-06','writing','writing_prompt','Describe your home','Viết mô tả nhà.',6,7,12),
('a1-path-06-home-act-07','a1-path-06-home','a1-path-06-home-lesson-07','listening','listening_choice','Where is it?','Nghe vị trí đồ.',7,6,10),
('a1-path-06-home-act-08','a1-path-06-home','a1-path-06-home-lesson-08','reading','review_quiz','Home review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-06-home-lac-01','a1-path-06-home-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"bếp\"?","options":[{"id":"A","text":"bedroom"},{"id":"B","text":"kitchen"},{"id":"C","text":"bathroom"}],"correctOptionId":"B","explanationVi":"kitchen = bếp."}'::jsonb,null),
('a1-path-06-home-lac-02','a1-path-06-home-lesson-02','multiple_choice',1,
 '{"question":"There ___ two chairs in the kitchen.","options":[{"id":"A","text":"is"},{"id":"B","text":"are"},{"id":"C","text":"be"}],"correctOptionId":"B","explanationVi":"Số nhiều dùng there are."}'::jsonb,null),
('a1-path-06-home-lac-03','a1-path-06-home-lesson-03','multiple_choice',1,
 '{"question":"How many bedrooms?","options":[{"id":"A","text":"One"},{"id":"B","text":"Two"},{"id":"C","text":"Three"}],"correctOptionId":"B","explanationVi":"Bài có: two bedrooms."}'::jsonb,null),
('a1-path-06-home-lac-04','a1-path-06-home-lesson-04','multiple_choice',1,
 '{"question":"Where are the books?","options":[{"id":"A","text":"On the bed"},{"id":"B","text":"On the desk"},{"id":"C","text":"Under the chair"}],"correctOptionId":"B","explanationVi":"Bài có: books are on the desk."}'::jsonb,null),
('a1-path-06-home-lac-05','a1-path-06-home-lesson-05','pronunciation',1,
 '{"expectedText":"There is a bed in my room.","minScoreToPass":70}'::jsonb,70),
('a1-path-06-home-lac-06','a1-path-06-home-lesson-06','writing_prompt',1,
 '{"prompt":"Write 2 sentences about your home.","rubric":["Nêu số phòng hoặc đồ vật.","Dùng there is / there are.","Viết 2 câu trở lên."]}'::jsonb,null),
('a1-path-06-home-lac-07','a1-path-06-home-lesson-07','multiple_choice',1,
 '{"question":"Where is the phone?","options":[{"id":"A","text":"Under the table"},{"id":"B","text":"On the table"},{"id":"C","text":"In the bag"}],"correctOptionId":"B","explanationVi":"Bài có: on the table."}'::jsonb,null),
('a1-path-06-home-lac-08','a1-path-06-home-lesson-08','multiple_choice',1,
 '{"question":"Which is correct?","options":[{"id":"A","text":"There is two books."},{"id":"B","text":"There are two books."},{"id":"C","text":"There be two books."}],"correctOptionId":"B","explanationVi":"Số nhiều: there are."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 07 — Places in town
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-07-places-lesson-01','A1','reading','a1-path-07-places','Places in town','Từ vựng địa điểm.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"shop, school, park, hospital, bank","translationVi":"cửa hàng, trường, công viên, bệnh viện, ngân hàng."}'::jsonb),
('a1-path-07-places-lesson-02','A1','reading','a1-path-07-places','Where is...? / near, next to','Hỏi đường đơn giản.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"Where is the bank? It is near the school, next to the park.","translationVi":"Ngân hàng ở đâu? Ở gần trường, cạnh công viên."}'::jsonb),
('a1-path-07-places-lesson-03','A1','listening','a1-path-07-places','Asking directions','Nghe hỏi đường ngắn.',6,10,
 '{"instruction":"Nghe và chọn vị trí đúng.","transcript":"A: Excuse me, where is the bus stop? B: It is over there, next to the shop.","translationVi":"A: Xin lỗi, bến xe ở đâu? B: Ở kia kìa, cạnh cửa hàng."}'::jsonb),
('a1-path-07-places-lesson-04','A1','reading','a1-path-07-places','My neighborhood','Đọc đoạn tả khu phố.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"There is a school near my house. The park is next to the school. The shop is in front of the park.","translationVi":"Có một trường gần nhà tôi. Công viên ở cạnh trường. Cửa hàng ở trước công viên."}'::jsonb),
('a1-path-07-places-lesson-05','A1','speaking','a1-path-07-places','Ask the way','Phát âm câu hỏi đường.',5,12,
 '{"instruction":"Nghe và lặp lại.","sampleText":"Excuse me, where is the bus stop?","phonetic":"ɪkˈskjuːz miː, wɛr ɪz ðə bʌs stɑːp?","translationVi":"Xin lỗi, bến xe buýt ở đâu?"}'::jsonb),
('a1-path-07-places-lesson-06','A1','writing','a1-path-07-places','Describe a place','Viết 2 câu về một địa điểm.',7,12,
 '{"instruction":"Viết 2 câu về một địa điểm gần nhà.","prompt":"Describe one place near your home.","exampleAnswer":"There is a small park near my home. It is next to the school."}'::jsonb),
('a1-path-07-places-lesson-07','A1','listening','a1-path-07-places','Where to meet','Nghe hẹn gặp.',6,10,
 '{"instruction":"Nghe và chọn nơi gặp.","transcript":"A: Where will we meet? B: At the park, next to the gate.","translationVi":"A: Mình gặp ở đâu? B: Ở công viên, cạnh cổng."}'::jsonb),
('a1-path-07-places-lesson-08','A1','reading','a1-path-07-places','Places review','Ôn tập địa điểm.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: places + Where is...? + near/next to.","translationVi":"Ôn lại địa điểm và câu hỏi vị trí."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-07-places-act-01','a1-path-07-places','a1-path-07-places-lesson-01','reading','vocabulary_match','Places in town','Khởi động từ vựng.',1,4,8),
('a1-path-07-places-act-02','a1-path-07-places','a1-path-07-places-lesson-02','reading','grammar_fill_blank','Where is...? / near','Điền câu đúng.',2,5,10),
('a1-path-07-places-act-03','a1-path-07-places','a1-path-07-places-lesson-03','listening','listening_choice','Asking directions','Nghe hỏi đường.',3,6,10),
('a1-path-07-places-act-04','a1-path-07-places','a1-path-07-places-lesson-04','reading','reading_question','My neighborhood','Đọc và trả lời.',4,6,10),
('a1-path-07-places-act-05','a1-path-07-places','a1-path-07-places-lesson-05','speaking','pronunciation','Ask the way','Phát âm câu mẫu.',5,5,12),
('a1-path-07-places-act-06','a1-path-07-places','a1-path-07-places-lesson-06','writing','writing_prompt','Describe a place','Viết mô tả địa điểm.',6,7,12),
('a1-path-07-places-act-07','a1-path-07-places','a1-path-07-places-lesson-07','listening','listening_choice','Where to meet','Nghe hẹn gặp.',7,6,10),
('a1-path-07-places-act-08','a1-path-07-places','a1-path-07-places-lesson-08','reading','review_quiz','Places review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-07-places-lac-01','a1-path-07-places-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"công viên\"?","options":[{"id":"A","text":"shop"},{"id":"B","text":"park"},{"id":"C","text":"bank"}],"correctOptionId":"B","explanationVi":"park = công viên."}'::jsonb,null),
('a1-path-07-places-lac-02','a1-path-07-places-lesson-02','multiple_choice',1,
 '{"question":"The bank is ___ the park.","options":[{"id":"A","text":"next to"},{"id":"B","text":"on"},{"id":"C","text":"under"}],"correctOptionId":"A","explanationVi":"next to = bên cạnh."}'::jsonb,null),
('a1-path-07-places-lac-03','a1-path-07-places-lesson-03','multiple_choice',1,
 '{"question":"Where is the bus stop?","options":[{"id":"A","text":"In front of the school"},{"id":"B","text":"Next to the shop"},{"id":"C","text":"Behind the park"}],"correctOptionId":"B","explanationVi":"Bài có: next to the shop."}'::jsonb,null),
('a1-path-07-places-lac-04','a1-path-07-places-lesson-04','multiple_choice',1,
 '{"question":"Where is the park?","options":[{"id":"A","text":"In front of the shop"},{"id":"B","text":"Next to the school"},{"id":"C","text":"Far from the school"}],"correctOptionId":"B","explanationVi":"Bài có: The park is next to the school."}'::jsonb,null),
('a1-path-07-places-lac-05','a1-path-07-places-lesson-05','pronunciation',1,
 '{"expectedText":"Excuse me, where is the bus stop?","minScoreToPass":70}'::jsonb,70),
('a1-path-07-places-lac-06','a1-path-07-places-lesson-06','writing_prompt',1,
 '{"prompt":"Describe one place near your home.","rubric":["Tên địa điểm cụ thể.","Vị trí (near / next to ...).","Viết 2 câu."]}'::jsonb,null),
('a1-path-07-places-lac-07','a1-path-07-places-lesson-07','multiple_choice',1,
 '{"question":"Where will they meet?","options":[{"id":"A","text":"At the school"},{"id":"B","text":"At the park"},{"id":"C","text":"At the shop"}],"correctOptionId":"B","explanationVi":"Bài có: At the park, next to the gate."}'::jsonb,null),
('a1-path-07-places-lac-08','a1-path-07-places-lesson-08','multiple_choice',1,
 '{"question":"Which question asks for location?","options":[{"id":"A","text":"What is your name?"},{"id":"B","text":"Where is the bank?"},{"id":"C","text":"How are you?"}],"correctOptionId":"B","explanationVi":"Where = ở đâu."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 08 — Free time
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-08-free-time-lesson-01','A1','reading','a1-path-08-free-time','Hobbies & activities','Từ vựng sở thích.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"play, watch, read, listen, music","translationVi":"chơi, xem, đọc, nghe, âm nhạc."}'::jsonb),
('a1-path-08-free-time-lesson-02','A1','reading','a1-path-08-free-time','Frequency: often / usually / sometimes','Trạng từ tần suất.',5,10,
 '{"instruction":"Chọn vị trí trạng từ đúng.","passage":"I often play football. She usually reads books. We sometimes watch movies.","translationVi":"Tôi hay chơi bóng đá. Cô ấy thường đọc sách. Chúng tôi đôi khi xem phim."}'::jsonb),
('a1-path-08-free-time-lesson-03','A1','listening','a1-path-08-free-time','Weekend talk','Nghe nói về cuối tuần.',6,10,
 '{"instruction":"Nghe và chọn hoạt động.","transcript":"On weekends, I play tennis with my friends. We sometimes go to the park.","translationVi":"Cuối tuần, tôi chơi tennis với bạn. Chúng tôi thỉnh thoảng đi công viên."}'::jsonb),
('a1-path-08-free-time-lesson-04','A1','reading','a1-path-08-free-time','My free time','Đọc đoạn về sở thích.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"In my free time, I usually listen to music and read books. I don''t like watching TV.","translationVi":"Lúc rảnh, tôi thường nghe nhạc và đọc sách. Tôi không thích xem TV."}'::jsonb),
('a1-path-08-free-time-lesson-05','A1','speaking','a1-path-08-free-time','Talk about hobbies','Phát âm câu nói sở thích.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"I often play football on Sunday.","phonetic":"aɪ ˈɒfn pleɪ ˈfʊtbɔːl ɒn ˈsʌndeɪ.","translationVi":"Tôi hay chơi bóng đá vào Chủ nhật."}'::jsonb),
('a1-path-08-free-time-lesson-06','A1','writing','a1-path-08-free-time','Write your hobby','Viết 2 câu về sở thích.',7,12,
 '{"instruction":"Viết 2 câu về sở thích.","prompt":"Write 2 sentences about your hobby.","exampleAnswer":"I usually read books in the evening. I love stories about animals."}'::jsonb),
('a1-path-08-free-time-lesson-07','A1','listening','a1-path-08-free-time','Sport plan','Nghe hẹn chơi thể thao.',6,10,
 '{"instruction":"Nghe và chọn ý đúng.","transcript":"A: Do you play badminton? B: Yes, sometimes. A: Let''s play this Saturday.","translationVi":"A: Bạn có chơi cầu lông không? B: Có, đôi khi. A: Thứ Bảy này mình chơi nhé."}'::jsonb),
('a1-path-08-free-time-lesson-08','A1','reading','a1-path-08-free-time','Free time review','Ôn tập sở thích.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: hobbies + present simple + frequency.","translationVi":"Ôn lại sở thích và trạng từ tần suất."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-08-free-time-act-01','a1-path-08-free-time','a1-path-08-free-time-lesson-01','reading','vocabulary_match','Hobbies & activities','Khởi động từ vựng.',1,4,8),
('a1-path-08-free-time-act-02','a1-path-08-free-time','a1-path-08-free-time-lesson-02','reading','grammar_fill_blank','Frequency adverbs','Điền trạng từ.',2,5,10),
('a1-path-08-free-time-act-03','a1-path-08-free-time','a1-path-08-free-time-lesson-03','listening','listening_choice','Weekend talk','Nghe cuối tuần.',3,6,10),
('a1-path-08-free-time-act-04','a1-path-08-free-time','a1-path-08-free-time-lesson-04','reading','reading_question','My free time','Đọc và trả lời.',4,6,10),
('a1-path-08-free-time-act-05','a1-path-08-free-time','a1-path-08-free-time-lesson-05','speaking','pronunciation','Talk about hobbies','Phát âm câu mẫu.',5,5,12),
('a1-path-08-free-time-act-06','a1-path-08-free-time','a1-path-08-free-time-lesson-06','writing','writing_prompt','Write your hobby','Viết về sở thích.',6,7,12),
('a1-path-08-free-time-act-07','a1-path-08-free-time','a1-path-08-free-time-lesson-07','listening','listening_choice','Sport plan','Nghe hẹn chơi.',7,6,10),
('a1-path-08-free-time-act-08','a1-path-08-free-time','a1-path-08-free-time-lesson-08','reading','review_quiz','Free time review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-08-free-time-lac-01','a1-path-08-free-time-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"nghe\"?","options":[{"id":"A","text":"read"},{"id":"B","text":"listen"},{"id":"C","text":"watch"}],"correctOptionId":"B","explanationVi":"listen = nghe."}'::jsonb,null),
('a1-path-08-free-time-lac-02','a1-path-08-free-time-lesson-02','multiple_choice',1,
 '{"question":"I ___ play football on Sunday.","options":[{"id":"A","text":"often"},{"id":"B","text":"often the"},{"id":"C","text":"the often"}],"correctOptionId":"A","explanationVi":"often đứng giữa chủ ngữ và động từ."}'::jsonb,null),
('a1-path-08-free-time-lac-03','a1-path-08-free-time-lesson-03','multiple_choice',1,
 '{"question":"What does the speaker play on weekends?","options":[{"id":"A","text":"Tennis"},{"id":"B","text":"Football"},{"id":"C","text":"Chess"}],"correctOptionId":"A","explanationVi":"Bài có: play tennis with my friends."}'::jsonb,null),
('a1-path-08-free-time-lac-04','a1-path-08-free-time-lesson-04','multiple_choice',1,
 '{"question":"What does the writer NOT like?","options":[{"id":"A","text":"Reading"},{"id":"B","text":"Music"},{"id":"C","text":"Watching TV"}],"correctOptionId":"C","explanationVi":"Bài có: I don''t like watching TV."}'::jsonb,null),
('a1-path-08-free-time-lac-05','a1-path-08-free-time-lesson-05','pronunciation',1,
 '{"expectedText":"I often play football on Sunday.","minScoreToPass":70}'::jsonb,70),
('a1-path-08-free-time-lac-06','a1-path-08-free-time-lesson-06','writing_prompt',1,
 '{"prompt":"Write 2 sentences about your hobby.","rubric":["Nêu sở thích cụ thể.","Có trạng từ tần suất (often/usually/...).","Viết 2 câu."]}'::jsonb,null),
('a1-path-08-free-time-lac-07','a1-path-08-free-time-lesson-07','multiple_choice',1,
 '{"question":"When will they play badminton?","options":[{"id":"A","text":"Friday"},{"id":"B","text":"Saturday"},{"id":"C","text":"Sunday"}],"correctOptionId":"B","explanationVi":"Bài có: Let''s play this Saturday."}'::jsonb,null),
('a1-path-08-free-time-lac-08','a1-path-08-free-time-lesson-08','multiple_choice',1,
 '{"question":"Choose the correct sentence.","options":[{"id":"A","text":"I play often tennis."},{"id":"B","text":"I often play tennis."},{"id":"C","text":"Often I tennis play."}],"correctOptionId":"B","explanationVi":"Trạng từ tần suất đứng trước động từ thường."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 09 — Simple shopping
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-09-shopping-lesson-01','A1','reading','a1-path-09-shopping','Shopping words','Từ vựng mua sắm.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"buy, sell, price, big, small, color","translationVi":"mua, bán, giá, to, nhỏ, màu sắc."}'::jsonb),
('a1-path-09-shopping-lesson-02','A1','reading','a1-path-09-shopping','How much / How many','Mẫu câu hỏi giá và số lượng.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"How much is this shirt? How many apples do you want?","translationVi":"Áo này bao nhiêu tiền? Bạn muốn mấy quả táo?"}'::jsonb),
('a1-path-09-shopping-lesson-03','A1','listening','a1-path-09-shopping','At the shop','Nghe hỏi giá.',6,10,
 '{"instruction":"Nghe và chọn giá đúng.","transcript":"A: How much is this T-shirt? B: It is 150,000 dong.","translationVi":"A: Áo này bao nhiêu? B: 150 nghìn đồng."}'::jsonb),
('a1-path-09-shopping-lesson-04','A1','reading','a1-path-09-shopping','A shopping list','Đọc danh sách mua.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"Mai needs 2 apples, 1 bottle of water and 1 small bag.","translationVi":"Mai cần 2 quả táo, 1 chai nước và 1 cái túi nhỏ."}'::jsonb),
('a1-path-09-shopping-lesson-05','A1','speaking','a1-path-09-shopping','Ask the price','Phát âm câu hỏi giá.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"How much is this, please?","phonetic":"haʊ mʌtʃ ɪz ðɪs, pliːz?","translationVi":"Cái này bao nhiêu tiền ạ?"}'::jsonb),
('a1-path-09-shopping-lesson-06','A1','writing','a1-path-09-shopping','Write a shopping list','Viết 2-3 món cần mua.',7,12,
 '{"instruction":"Viết 2-3 món cần mua hôm nay.","prompt":"Write your shopping list.","exampleAnswer":"I need 1 small bag, 2 bottles of water and 3 apples."}'::jsonb),
('a1-path-09-shopping-lesson-07','A1','listening','a1-path-09-shopping','Choosing color & size','Nghe chọn màu và size.',6,10,
 '{"instruction":"Nghe và chọn đáp án.","transcript":"A: What color do you like? B: I like blue. Do you have a bigger size?","translationVi":"A: Bạn thích màu gì? B: Tôi thích màu xanh. Có cỡ to hơn không?"}'::jsonb),
('a1-path-09-shopping-lesson-08','A1','reading','a1-path-09-shopping','Shopping review','Ôn tập mua sắm.',8,18,
 '{"instruction":"Trả lời 3 câu ôn.","passage":"Review: shopping + how much + colors & sizes.","translationVi":"Ôn lại mua sắm, hỏi giá, màu sắc."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-09-shopping-act-01','a1-path-09-shopping','a1-path-09-shopping-lesson-01','reading','vocabulary_match','Shopping words','Khởi động từ vựng.',1,4,8),
('a1-path-09-shopping-act-02','a1-path-09-shopping','a1-path-09-shopping-lesson-02','reading','grammar_fill_blank','How much / How many','Điền câu hỏi đúng.',2,5,10),
('a1-path-09-shopping-act-03','a1-path-09-shopping','a1-path-09-shopping-lesson-03','listening','listening_choice','At the shop','Nghe hỏi giá.',3,6,10),
('a1-path-09-shopping-act-04','a1-path-09-shopping','a1-path-09-shopping-lesson-04','reading','reading_question','A shopping list','Đọc danh sách mua.',4,6,10),
('a1-path-09-shopping-act-05','a1-path-09-shopping','a1-path-09-shopping-lesson-05','speaking','pronunciation','Ask the price','Phát âm câu mẫu.',5,5,12),
('a1-path-09-shopping-act-06','a1-path-09-shopping','a1-path-09-shopping-lesson-06','writing','writing_prompt','Write a shopping list','Viết danh sách mua.',6,7,12),
('a1-path-09-shopping-act-07','a1-path-09-shopping','a1-path-09-shopping-lesson-07','listening','listening_choice','Choosing color & size','Nghe chọn màu, size.',7,6,10),
('a1-path-09-shopping-act-08','a1-path-09-shopping','a1-path-09-shopping-lesson-08','reading','review_quiz','Shopping review','Bài ôn cuối chủ đề.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-09-shopping-lac-01','a1-path-09-shopping-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"giá\"?","options":[{"id":"A","text":"buy"},{"id":"B","text":"price"},{"id":"C","text":"color"}],"correctOptionId":"B","explanationVi":"price = giá."}'::jsonb,null),
('a1-path-09-shopping-lac-02','a1-path-09-shopping-lesson-02','multiple_choice',1,
 '{"question":"___ apples do you want?","options":[{"id":"A","text":"How much"},{"id":"B","text":"How many"},{"id":"C","text":"How long"}],"correctOptionId":"B","explanationVi":"Danh từ đếm được dùng how many."}'::jsonb,null),
('a1-path-09-shopping-lac-03','a1-path-09-shopping-lesson-03','multiple_choice',1,
 '{"question":"How much is the T-shirt?","options":[{"id":"A","text":"100,000 dong"},{"id":"B","text":"150,000 dong"},{"id":"C","text":"200,000 dong"}],"correctOptionId":"B","explanationVi":"Bài có: 150,000 dong."}'::jsonb,null),
('a1-path-09-shopping-lac-04','a1-path-09-shopping-lesson-04','multiple_choice',1,
 '{"question":"How many apples does Mai need?","options":[{"id":"A","text":"1"},{"id":"B","text":"2"},{"id":"C","text":"3"}],"correctOptionId":"B","explanationVi":"Bài có: 2 apples."}'::jsonb,null),
('a1-path-09-shopping-lac-05','a1-path-09-shopping-lesson-05','pronunciation',1,
 '{"expectedText":"How much is this, please?","minScoreToPass":70}'::jsonb,70),
('a1-path-09-shopping-lac-06','a1-path-09-shopping-lesson-06','writing_prompt',1,
 '{"prompt":"Write your shopping list.","rubric":["Có 2-3 món.","Có số lượng (1, 2, 3...).","Dùng I need ..."]}'::jsonb,null),
('a1-path-09-shopping-lac-07','a1-path-09-shopping-lesson-07','multiple_choice',1,
 '{"question":"What color does B like?","options":[{"id":"A","text":"Red"},{"id":"B","text":"Blue"},{"id":"C","text":"Green"}],"correctOptionId":"B","explanationVi":"B nói: I like blue."}'::jsonb,null),
('a1-path-09-shopping-lac-08','a1-path-09-shopping-lesson-08','multiple_choice',1,
 '{"question":"Which is correct?","options":[{"id":"A","text":"How much apples?"},{"id":"B","text":"How many apples?"},{"id":"C","text":"How long apples?"}],"correctOptionId":"B","explanationVi":"Đếm được + how many."}'::jsonb,70);

-- ─────────────────────────────────────────────────────────────────────────────
-- PATH 10 — A1 mixed review (tổng ôn)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, title, subtitle, duration_minutes, xp_reward, content) VALUES
('a1-path-10-review-lesson-01','A1','reading','a1-path-10-review','Core A1 words','Tổng ôn từ vựng cốt lõi.',4,8,
 '{"instruction":"Chọn nghĩa đúng.","passage":"home, family, friend, food, school","translationVi":"nhà, gia đình, bạn, đồ ăn, trường."}'::jsonb),
('a1-path-10-review-lesson-02','A1','reading','a1-path-10-review','To be vs. present simple','Phân biệt to be và động từ thường.',5,10,
 '{"instruction":"Chọn câu đúng.","passage":"She is a student. She studies English every day.","translationVi":"Cô ấy là học sinh. Cô ấy học tiếng Anh mỗi ngày."}'::jsonb),
('a1-path-10-review-lesson-03','A1','listening','a1-path-10-review','A day in a life','Nghe đoạn tổng ôn.',6,10,
 '{"instruction":"Nghe và chọn ý đúng.","transcript":"Hi, I am Lan. I am 12. I live in Hanoi. I go to school at 7 a.m.","translationVi":"Chào, tôi là Lan. Tôi 12 tuổi. Tôi sống ở Hà Nội. Tôi đi học lúc 7 giờ."}'::jsonb),
('a1-path-10-review-lesson-04','A1','reading','a1-path-10-review','About a student','Đọc đoạn tổng hợp.',6,10,
 '{"instruction":"Đọc và trả lời.","passage":"Minh is a student. He has 2 sisters. He often plays football on Sunday. He likes rice and water.","translationVi":"Minh là học sinh. Cậu có 2 chị em gái. Cậu hay đá bóng Chủ nhật. Cậu thích cơm và nước."}'::jsonb),
('a1-path-10-review-lesson-05','A1','speaking','a1-path-10-review','Self introduction','Phát âm bài tự giới thiệu.',5,12,
 '{"instruction":"Nghe và nói lại.","sampleText":"Hi, my name is Linh. I am from Vietnam. I like coffee.","phonetic":"haɪ, maɪ neɪm ɪz lɪn. aɪ æm frəm vjɛt.nɑːm. aɪ laɪk ˈkɔːfi.","translationVi":"Chào, tôi là Linh. Tôi đến từ Việt Nam. Tôi thích cà phê."}'::jsonb),
('a1-path-10-review-lesson-06','A1','writing','a1-path-10-review','Write about yourself','Viết 3-4 câu giới thiệu.',7,12,
 '{"instruction":"Viết 3-4 câu về bản thân.","prompt":"Write about yourself (name, country, hobby, food).","exampleAnswer":"My name is Mai. I am from Vietnam. I like reading books. I love rice."}'::jsonb),
('a1-path-10-review-lesson-07','A1','listening','a1-path-10-review','Two friends talking','Nghe hội thoại tổng ôn.',6,10,
 '{"instruction":"Nghe và chọn đáp án.","transcript":"A: Where do you live? B: I live in Da Nang. A: Do you like the city? B: Yes, I love it.","translationVi":"A: Bạn sống ở đâu? B: Tôi sống ở Đà Nẵng. A: Bạn thích thành phố này không? B: Có, tôi rất thích."}'::jsonb),
('a1-path-10-review-lesson-08','A1','reading','a1-path-10-review','A1 final quiz','Bài kiểm tra cuối level.',8,18,
 '{"instruction":"Trả lời 3 câu hỏi tổng hợp.","passage":"Final review across all A1 patterns.","translationVi":"Kiểm tra tổng hợp toàn bộ A1."}'::jsonb);

INSERT INTO learning_path_activities (id, path_id, lesson_id, skill_code, activity_type, title, subtitle, display_order, duration_minutes, xp_reward) VALUES
('a1-path-10-review-act-01','a1-path-10-review','a1-path-10-review-lesson-01','reading','vocabulary_match','Core A1 words','Tổng ôn từ vựng.',1,4,8),
('a1-path-10-review-act-02','a1-path-10-review','a1-path-10-review-lesson-02','reading','grammar_fill_blank','To be vs. present simple','Phân biệt cấu trúc.',2,5,10),
('a1-path-10-review-act-03','a1-path-10-review','a1-path-10-review-lesson-03','listening','listening_choice','A day in a life','Nghe tổng ôn.',3,6,10),
('a1-path-10-review-act-04','a1-path-10-review','a1-path-10-review-lesson-04','reading','reading_question','About a student','Đọc tổng hợp.',4,6,10),
('a1-path-10-review-act-05','a1-path-10-review','a1-path-10-review-lesson-05','speaking','pronunciation','Self introduction','Phát âm tự giới thiệu.',5,5,12),
('a1-path-10-review-act-06','a1-path-10-review','a1-path-10-review-lesson-06','writing','writing_prompt','Write about yourself','Viết tự giới thiệu.',6,7,12),
('a1-path-10-review-act-07','a1-path-10-review','a1-path-10-review-lesson-07','listening','listening_choice','Two friends talking','Nghe hội thoại.',7,6,10),
('a1-path-10-review-act-08','a1-path-10-review','a1-path-10-review-lesson-08','reading','review_quiz','A1 final quiz','Kiểm tra cuối level.',8,8,18);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-10-review-lac-01','a1-path-10-review-lesson-01','multiple_choice',1,
 '{"question":"Which word means \"gia đình\"?","options":[{"id":"A","text":"friend"},{"id":"B","text":"family"},{"id":"C","text":"school"}],"correctOptionId":"B","explanationVi":"family = gia đình."}'::jsonb,null),
('a1-path-10-review-lac-02','a1-path-10-review-lesson-02','multiple_choice',1,
 '{"question":"She ___ English every day.","options":[{"id":"A","text":"is"},{"id":"B","text":"study"},{"id":"C","text":"studies"}],"correctOptionId":"C","explanationVi":"Ngôi 3 số ít + động từ thường: studies."}'::jsonb,null),
('a1-path-10-review-lac-03','a1-path-10-review-lesson-03','multiple_choice',1,
 '{"question":"How old is Lan?","options":[{"id":"A","text":"10"},{"id":"B","text":"12"},{"id":"C","text":"15"}],"correctOptionId":"B","explanationVi":"Bài có: I am 12."}'::jsonb,null),
('a1-path-10-review-lac-04','a1-path-10-review-lesson-04','multiple_choice',1,
 '{"question":"When does Minh play football?","options":[{"id":"A","text":"Monday"},{"id":"B","text":"Sunday"},{"id":"C","text":"Saturday"}],"correctOptionId":"B","explanationVi":"Bài có: plays football on Sunday."}'::jsonb,null),
('a1-path-10-review-lac-05','a1-path-10-review-lesson-05','pronunciation',1,
 '{"expectedText":"Hi, my name is Linh. I am from Vietnam. I like coffee.","minScoreToPass":70}'::jsonb,70),
('a1-path-10-review-lac-06','a1-path-10-review-lesson-06','writing_prompt',1,
 '{"prompt":"Write about yourself (name, country, hobby, food).","rubric":["Nêu tên.","Nêu quốc gia / thành phố.","Nêu 1 sở thích và 1 món ăn yêu thích.","Viết 3-4 câu."]}'::jsonb,null),
('a1-path-10-review-lac-07','a1-path-10-review-lesson-07','multiple_choice',1,
 '{"question":"Where does B live?","options":[{"id":"A","text":"Hanoi"},{"id":"B","text":"Da Nang"},{"id":"C","text":"Hue"}],"correctOptionId":"B","explanationVi":"B nói: I live in Da Nang."}'::jsonb,null),
('a1-path-10-review-lac-08','a1-path-10-review-lesson-08','multiple_choice',1,
 '{"question":"Which sentence is correct?","options":[{"id":"A","text":"He are my friend."},{"id":"B","text":"He is my friend."},{"id":"C","text":"He am my friend."}],"correctOptionId":"B","explanationVi":"He + is."}'::jsonb,70);

-- =============================================================================
-- KẾT QUẢ KỲ VỌNG SAU KHI CHẠY V23:
--   SELECT COUNT(*) FROM learning_paths              WHERE level_code='A1';  -- 10
--   SELECT COUNT(*) FROM learning_path_activities    WHERE path_id LIKE 'a1-%'; -- 80
--   SELECT COUNT(*) FROM learning_lessons            WHERE level_code='A1';  -- 80
--   SELECT COUNT(*) FROM learning_lesson_activities  WHERE lesson_id LIKE 'a1-%'; -- 80
-- =============================================================================
