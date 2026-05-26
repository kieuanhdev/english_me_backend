-- =============================================================================
-- V25 — Bổ sung thêm câu hỏi cho mỗi lesson (path 01 — Greetings)
-- =============================================================================
-- Mục tiêu: mỗi lesson hiện chỉ có 1 câu hỏi (lac-01). Bổ sung 3-4 câu nữa
-- cho mỗi lesson của path-01 để có nhiều câu hỏi liên tiếp khi học.
-- Quy ước id: '<lesson-id>-lac-<NN>' bắt đầu từ 02.
-- =============================================================================

-- ── LESSON 01 — Greeting words (vocabulary) ─────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-01-lac-02','a1-path-01-greetings-lesson-01','multiple_choice',2,
 '{"question":"Which word means \"tạm biệt\"?","options":[{"id":"A","text":"Hello"},{"id":"B","text":"Goodbye"},{"id":"C","text":"Thanks"}],"correctOptionId":"B","explanationVi":"Goodbye = tạm biệt."}'::jsonb,null),
('a1-path-01-greetings-lesson-01-lac-03','a1-path-01-greetings-lesson-01','multiple_choice',3,
 '{"question":"What do you say when meeting someone for the first time?","options":[{"id":"A","text":"Bye!"},{"id":"B","text":"Sorry!"},{"id":"C","text":"Nice to meet you!"}],"correctOptionId":"C","explanationVi":"Nice to meet you = rất vui được gặp bạn."}'::jsonb,null),
('a1-path-01-greetings-lesson-01-lac-04','a1-path-01-greetings-lesson-01','multiple_choice',4,
 '{"question":"\"Hi\" có nghĩa gần nhất với từ nào?","options":[{"id":"A","text":"Hello"},{"id":"B","text":"Goodbye"},{"id":"C","text":"Please"}],"correctOptionId":"A","explanationVi":"Hi là cách chào thân mật, đồng nghĩa Hello."}'::jsonb,null);

-- ── LESSON 02 — To be: am / is / are (grammar) ──────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-02-lac-02','a1-path-01-greetings-lesson-02','multiple_choice',2,
 '{"question":"I ___ a student.","options":[{"id":"A","text":"am"},{"id":"B","text":"is"},{"id":"C","text":"are"}],"correctOptionId":"A","explanationVi":"Chủ ngữ I luôn đi với am."}'::jsonb,null),
('a1-path-01-greetings-lesson-02-lac-03','a1-path-01-greetings-lesson-02','multiple_choice',3,
 '{"question":"You ___ my best friend.","options":[{"id":"A","text":"am"},{"id":"B","text":"is"},{"id":"C","text":"are"}],"correctOptionId":"C","explanationVi":"You đi với are."}'::jsonb,null),
('a1-path-01-greetings-lesson-02-lac-04','a1-path-01-greetings-lesson-02','multiple_choice',4,
 '{"question":"They ___ from Vietnam.","options":[{"id":"A","text":"is"},{"id":"B","text":"are"},{"id":"C","text":"am"}],"correctOptionId":"B","explanationVi":"They (số nhiều) đi với are."}'::jsonb,null);

-- ── LESSON 03 — Hello and goodbye (listening) ───────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-03-lac-02','a1-path-01-greetings-lesson-03','multiple_choice',2,
 '{"question":"How does A end the conversation?","options":[{"id":"A","text":"Hello!"},{"id":"B","text":"Goodbye!"},{"id":"C","text":"Sorry!"}],"correctOptionId":"B","explanationVi":"A nói Goodbye! để kết thúc."}'::jsonb,null),
('a1-path-01-greetings-lesson-03-lac-03','a1-path-01-greetings-lesson-03','multiple_choice',3,
 '{"question":"What does B say after \"Hi!\"?","options":[{"id":"A","text":"Nice to meet you."},{"id":"B","text":"Goodbye."},{"id":"C","text":"Please."}],"correctOptionId":"A","explanationVi":"B nói tiếp Nice to meet you."}'::jsonb,null);

-- ── LESSON 04 — A short profile (reading) ───────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-04-lac-02','a1-path-01-greetings-lesson-04','multiple_choice',2,
 '{"question":"What is his name?","options":[{"id":"A","text":"Ben"},{"id":"B","text":"Tom"},{"id":"C","text":"Mai"}],"correctOptionId":"A","explanationVi":"Câu đầu: My name is Ben."}'::jsonb,null),
('a1-path-01-greetings-lesson-04-lac-03','a1-path-01-greetings-lesson-04','multiple_choice',3,
 '{"question":"What is his job?","options":[{"id":"A","text":"Teacher"},{"id":"B","text":"Student"},{"id":"C","text":"Doctor"}],"correctOptionId":"B","explanationVi":"Bài có câu I am a student."}'::jsonb,null);

-- ── LESSON 06 — Write your name and country (writing) ───────────────────────
-- (Lesson 5 là pronunciation và lesson 8 đã có rồi, ta thêm cho lesson 6 và 7)
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-06-lac-02','a1-path-01-greetings-lesson-06','writing_prompt',2,
 '{"prompt":"Write one sentence to introduce your age.","rubric":["Dùng cấu trúc I am ... years old."]}'::jsonb,null),
('a1-path-01-greetings-lesson-06-lac-03','a1-path-01-greetings-lesson-06','writing_prompt',3,
 '{"prompt":"Write one sentence about your job.","rubric":["Dùng cấu trúc I am a/an ..."]}'::jsonb,null);

-- ── LESSON 07 — Meeting new people (listening) ──────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-07-lac-02','a1-path-01-greetings-lesson-07','multiple_choice',2,
 '{"question":"What is the boy''s name?","options":[{"id":"A","text":"Tom"},{"id":"B","text":"Mai"},{"id":"C","text":"Ben"}],"correctOptionId":"A","explanationVi":"Cậu ấy nói Hi, I am Tom."}'::jsonb,null),
('a1-path-01-greetings-lesson-07-lac-03','a1-path-01-greetings-lesson-07','multiple_choice',3,
 '{"question":"How does Mai respond?","options":[{"id":"A","text":"Goodbye"},{"id":"B","text":"Nice to meet you"},{"id":"C","text":"Sorry"}],"correctOptionId":"B","explanationVi":"Mai đáp Nice to meet you."}'::jsonb,null);

-- ── LESSON 08 — Greetings review (review_quiz) ──────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, payload, min_score_to_pass) VALUES
('a1-path-01-greetings-lesson-08-lac-02','a1-path-01-greetings-lesson-08','multiple_choice',2,
 '{"question":"Which greeting is informal?","options":[{"id":"A","text":"Hello"},{"id":"B","text":"Hi"},{"id":"C","text":"Goodbye"}],"correctOptionId":"B","explanationVi":"Hi thân mật hơn Hello."}'::jsonb,null),
('a1-path-01-greetings-lesson-08-lac-03','a1-path-01-greetings-lesson-08','multiple_choice',3,
 '{"question":"\"She ___ from Japan.\" Chọn từ đúng.","options":[{"id":"A","text":"am"},{"id":"B","text":"is"},{"id":"C","text":"are"}],"correctOptionId":"B","explanationVi":"She đi với is."}'::jsonb,null),
('a1-path-01-greetings-lesson-08-lac-04','a1-path-01-greetings-lesson-08','multiple_choice',4,
 '{"question":"Choose the correct introduction.","options":[{"id":"A","text":"My name am Mai."},{"id":"B","text":"My name is Mai."},{"id":"C","text":"My name are Mai."}],"correctOptionId":"B","explanationVi":"\"name\" số ít → dùng is."}'::jsonb,null);
