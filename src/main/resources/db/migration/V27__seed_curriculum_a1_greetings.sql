-- =============================================================================
-- V27 — Seed Unit A1 "Greetings & Introductions" (mẫu vàng cho luồng giáo trình)
-- =============================================================================
-- Khớp đúng JSON contract mà FE curriculum_models.dart đang parse:
--   theory_content: { warmup, objectives[], vocabBlock[], examples[], commonMistakes[], tips[], grammarHtml? }
--   activity payload: tuỳ activity_type (multiple_choice/grammar_fill_blank/vocabulary_match/...)
--   phase: practice (counts_toward_mastery=false) | quiz (counts_toward_mastery=true)
-- Mỗi lesson đảm bảo 5 BẤT BIẾN (§H): có ≥1 câu quiz tính điểm; quiz chỉ dạng chấm tự động.
-- =============================================================================

-- ── UNIT ─────────────────────────────────────────────────────────────────────
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
    ('a1-unit-greetings', 'A1', 'Greetings & Introductions',
     'Chào hỏi, giới thiệu bản thân và người khác', 'social',
     '["vocabulary","grammar","reading"]'::jsonb, 1);

-- ── LESSON 1 — Hello & Goodbye (vocabulary) ──────────────────────────────────
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content)
VALUES
    ('a1-unit-greetings-l1', 'A1', 'reading', 'a1-unit-greetings', 'normal', 1,
     'Hello & Goodbye', 'Chào hỏi cơ bản', 8, 15, 70, '{}'::jsonb,
     '{
        "warmup":"Hai người đang vẫy tay chào nhau — bạn nghĩ họ đang nói gì?",
        "objectives":["Chào hỏi theo thời điểm trong ngày","Phân biệt Hello / Hi / Good morning","Nói lời tạm biệt phù hợp"],
        "vocabBlock":[
          {"word":"Good morning","ipa":"/ɡʊd ˈmɔːnɪŋ/","meaningVi":"Chào buổi sáng","example":"Good morning, teacher!"},
          {"word":"Good afternoon","ipa":"/ɡʊd ˌɑːftəˈnuːn/","meaningVi":"Chào buổi chiều","example":"Good afternoon, everyone."},
          {"word":"Goodbye","ipa":"/ɡʊdˈbaɪ/","meaningVi":"Tạm biệt","example":"Goodbye! See you tomorrow."},
          {"word":"See you","ipa":"/siː juː/","meaningVi":"Hẹn gặp lại","example":"See you later!"}
        ],
        "examples":[
          {"en":"Good morning! How are you?","vi":"Chào buổi sáng! Bạn khỏe không?"},
          {"en":"Hi, nice to meet you.","vi":"Chào, rất vui được gặp bạn."}
        ],
        "commonMistakes":["\"Good night\" là lời tạm biệt buổi tối, KHÔNG phải lời chào."],
        "tips":["Hi / Hello dùng được mọi lúc, không phụ thuộc thời điểm trong ngày."]
      }'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l1-p1','a1-unit-greetings-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"Lời chào nào dùng vào buổi sáng?","options":[{"id":"a","text":"Good evening"},{"id":"b","text":"Good morning"},{"id":"c","text":"Goodbye"}],"correctOptionId":"b","explanationVi":"Good morning = chào buổi sáng."}'::jsonb),
 ('a1-greet-l1-p2','a1-unit-greetings-l1','grammar_fill_blank',2,'practice','easy',false,
  '{"question":"Điền từ còn thiếu: \"Good ___, teacher!\" (chào buổi sáng)","acceptedAnswers":["morning"],"explanationVi":"Good morning = chào buổi sáng."}'::jsonb),
 ('a1-greet-l1-p3','a1-unit-greetings-l1','vocabulary_match',3,'practice','medium',false,
  '{"question":"Nối lời chào tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"Good morning","right":"Chào buổi sáng"},{"left":"Goodbye","right":"Tạm biệt"},{"left":"See you","right":"Hẹn gặp lại"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-greet-l1-q1','a1-unit-greetings-l1','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn lời chào buổi chiều:","options":[{"id":"a","text":"Good afternoon"},{"id":"b","text":"Good night"},{"id":"c","text":"See you"}],"correctOptionId":"a","explanationVi":"Good afternoon = chào buổi chiều."}'::jsonb),
 ('a1-greet-l1-q2','a1-unit-greetings-l1','multiple_choice',5,'quiz','hard',true,
  '{"question":"Câu nào SAI khi dùng làm lời chào?","options":[{"id":"a","text":"Good morning"},{"id":"b","text":"Good night"},{"id":"c","text":"Hello"}],"correctOptionId":"b","explanationVi":"\"Good night\" là lời tạm biệt buổi tối."}'::jsonb),
 ('a1-greet-l1-q3','a1-unit-greetings-l1','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"Điền từ: \"Good ___\" là lời chào buổi chiều.","acceptedAnswers":["afternoon"],"explanationVi":"Good afternoon = chào buổi chiều."}'::jsonb);

-- ── LESSON 2 — What's your name? (grammar: đại từ chủ ngữ) ────────────────────
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content)
VALUES
    ('a1-unit-greetings-l2', 'A1', 'reading', 'a1-unit-greetings', 'normal', 2,
     'What''s your name?', 'Hỏi tên & đại từ chủ ngữ', 9, 15, 70, '{}'::jsonb,
     '{
        "warmup":"Khi gặp người mới, câu đầu tiên bạn hỏi là gì?",
        "objectives":["Dùng mẫu What''s your name? – I''m...","Nhận biết đại từ chủ ngữ I/you/he/she"],
        "grammarHtml":"Đại từ chủ ngữ: I (tôi), you (bạn), he (anh ấy), she (cô ấy), it (nó), we (chúng tôi), they (họ).",
        "vocabBlock":[],
        "examples":[
          {"en":"What''s your name? – I''m Nam.","vi":"Bạn tên gì? – Tôi là Nam."},
          {"en":"This is Mai. She is my friend.","vi":"Đây là Mai. Cô ấy là bạn tôi."}
        ],
        "commonMistakes":["❌ \"What your name?\" → ✅ \"What''s your name?\" (thiếu is)"],
        "tips":["What''s = What is (viết tắt)."]
      }'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l2-p1','a1-unit-greetings-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"\"___ your name?\" Điền từ đúng.","options":[{"id":"a","text":"What''s"},{"id":"b","text":"Who''s"},{"id":"c","text":"Where''s"}],"correctOptionId":"a","explanationVi":"Hỏi tên dùng What''s your name?"}'::jsonb),
 ('a1-greet-l2-p2','a1-unit-greetings-l2','sentence_ordering',2,'practice','medium',false,
  '{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["your","What''s","name"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: What''s your name?"}'::jsonb),
 ('a1-greet-l2-p3','a1-unit-greetings-l2','grammar_fill_blank',3,'practice','medium',false,
  '{"question":"Mai is a girl. ___ is my friend. (điền đại từ)","acceptedAnswers":["She","she"],"explanationVi":"Mai là nữ → dùng She."}'::jsonb),
 ('a1-greet-l2-q1','a1-unit-greetings-l2','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn đại từ đúng cho \"Nam\":","options":[{"id":"a","text":"She"},{"id":"b","text":"He"},{"id":"c","text":"It"}],"correctOptionId":"b","explanationVi":"Nam là nam giới → He."}'::jsonb),
 ('a1-greet-l2-q2','a1-unit-greetings-l2','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"Điền: \"___ your name?\" (hỏi tên)","acceptedAnswers":["What''s","Whats","What is"],"explanationVi":"What''s your name?"}'::jsonb),
 ('a1-greet-l2-q3','a1-unit-greetings-l2','sentence_ordering',6,'quiz','hard',true,
  '{"question":"Sắp xếp thành câu đúng:","tokens":["am","I","Nam"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: I am Nam."}'::jsonb);

-- ── LESSON 3 — Verb to be (grammar) ──────────────────────────────────────────
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content)
VALUES
    ('a1-unit-greetings-l3', 'A1', 'reading', 'a1-unit-greetings', 'normal', 3,
     'Verb to be', 'Động từ to be hiện tại', 10, 15, 70, '{}'::jsonb,
     '{
        "warmup":"am / is / are — khi nào dùng từ nào?",
        "objectives":["Chia to be theo chủ ngữ","Viết câu khẳng định / phủ định"],
        "grammarHtml":"I + am · He/She/It + is · We/You/They + are. Phủ định: thêm not (I am not, She is not...).",
        "vocabBlock":[],
        "examples":[
          {"en":"I am a student.","vi":"Tôi là sinh viên."},
          {"en":"She is from Japan.","vi":"Cô ấy đến từ Nhật Bản."}
        ],
        "commonMistakes":["❌ \"She are\" → ✅ \"She is\""],
        "tips":["Chủ ngữ số nhiều (we/you/they) luôn đi với are."]
      }'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l3-p1','a1-unit-greetings-l3','multiple_choice',1,'practice','easy',false,
  '{"question":"I ___ a student.","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"I luôn đi với am."}'::jsonb),
 ('a1-greet-l3-p2','a1-unit-greetings-l3','grammar_fill_blank',2,'practice','medium',false,
  '{"question":"Điền dạng đúng của to be: \"They ___ from Vietnam.\"","acceptedAnswers":["are"],"explanationVi":"They (số nhiều) đi với are."}'::jsonb),
 ('a1-greet-l3-p3','a1-unit-greetings-l3','error_correction',3,'practice','hard',false,
  '{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"She are from Japan.","acceptedAnswers":["She is from Japan.","She is from Japan"],"explanationVi":"She đi với is, không phải are."}'::jsonb),
 ('a1-greet-l3-q1','a1-unit-greetings-l3','multiple_choice',4,'quiz','medium',true,
  '{"question":"She ___ from Japan.","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"b","explanationVi":"She đi với is."}'::jsonb),
 ('a1-greet-l3-q2','a1-unit-greetings-l3','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"Điền to be: \"You ___ my best friend.\"","acceptedAnswers":["are"],"explanationVi":"You đi với are."}'::jsonb),
 ('a1-greet-l3-q3','a1-unit-greetings-l3','multiple_choice',6,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"He are happy."},{"id":"b","text":"He is happy."},{"id":"c","text":"He am happy."}],"correctOptionId":"b","explanationVi":"He đi với is."}'::jsonb);

-- ── LESSON 4 — Introducing others (reading) ──────────────────────────────────
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content)
VALUES
    ('a1-unit-greetings-l4', 'A1', 'reading', 'a1-unit-greetings', 'normal', 4,
     'Introducing others', 'Giới thiệu người khác', 10, 15, 70, '{}'::jsonb,
     '{
        "warmup":"Làm sao để giới thiệu bạn của mình với người khác?",
        "objectives":["Dùng mẫu This is... / He is...","Đọc hiểu đoạn giới thiệu ngắn"],
        "grammarHtml":"Mẫu giới thiệu: This is my friend, Nam. He is a teacher.",
        "vocabBlock":[
          {"word":"This is","ipa":"/ðɪs ɪz/","meaningVi":"Đây là","example":"This is my friend, Nam."},
          {"word":"teacher","ipa":"/ˈtiːtʃər/","meaningVi":"giáo viên","example":"He is a teacher."}
        ],
        "examples":[
          {"en":"This is my friend, Nam. He is a teacher.","vi":"Đây là bạn tôi, Nam. Anh ấy là giáo viên."},
          {"en":"Where are you from?","vi":"Bạn đến từ đâu?"}
        ],
        "commonMistakes":["❌ \"This is he Nam\" → ✅ \"This is Nam. He is...\""],
        "tips":["Dùng This is khi giới thiệu lần đầu."]
      }'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l4-p1','a1-unit-greetings-l4','multiple_choice',1,'practice','easy',false,
  '{"question":"\"___ is my friend, Nam.\" Điền từ.","options":[{"id":"a","text":"This"},{"id":"b","text":"These"},{"id":"c","text":"That are"}],"correctOptionId":"a","explanationVi":"This is dùng giới thiệu một người."}'::jsonb),
 ('a1-greet-l4-p2','a1-unit-greetings-l4','translation',2,'practice','medium',false,
  '{"question":"Dịch sang tiếng Anh:","sourceText":"Anh ấy là giáo viên.","acceptedAnswers":["He is a teacher.","He is a teacher","He''s a teacher."],"explanationVi":"He is a teacher."}'::jsonb),
 ('a1-greet-l4-p3','a1-unit-greetings-l4','vocabulary_match',3,'practice','medium',false,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"This is","right":"Đây là"},{"left":"teacher","right":"giáo viên"},{"left":"friend","right":"bạn"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-greet-l4-q1','a1-unit-greetings-l4','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn câu giới thiệu ĐÚNG:","options":[{"id":"a","text":"This is Nam. He is a teacher."},{"id":"b","text":"This Nam is teacher."},{"id":"c","text":"He Nam a teacher."}],"correctOptionId":"a","explanationVi":"Đúng mẫu This is... He is a..."}'::jsonb),
 ('a1-greet-l4-q2','a1-unit-greetings-l4','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"Điền: \"___ are you from?\" (hỏi quê quán)","acceptedAnswers":["Where"],"explanationVi":"Where are you from? = Bạn đến từ đâu?"}'::jsonb),
 ('a1-greet-l4-q3','a1-unit-greetings-l4','multiple_choice',6,'quiz','easy',true,
  '{"question":"\"This is my friend\" nghĩa là gì?","options":[{"id":"a","text":"Đây là bạn tôi"},{"id":"b","text":"Tạm biệt bạn tôi"},{"id":"c","text":"Tôi là bạn"}],"correctOptionId":"a","explanationVi":"This is my friend = Đây là bạn tôi."}'::jsonb);
