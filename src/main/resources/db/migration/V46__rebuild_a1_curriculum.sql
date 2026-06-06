-- =============================================================================
-- V46 — TÁI THIẾT TOÀN BỘ CẤP A1 theo KHUNG_GIAO_TRINH_CEFR.md §4
-- =============================================================================
-- Mục tiêu: thay nội dung A1 cũ (8 unit rời, không Unit Review) bằng bộ giáo
-- trình A1 hoàn chỉnh: 10 Unit × 5 Lesson (4 nội dung + 1 Unit Review) = 50 lesson.
-- Mỗi lesson chạy 3 bước Lý thuyết → Luyện tập → Mini-quiz (PPP vi mô).
--
-- Quyết định đã chốt với chủ dự án: TẠO LẠI A1 TỪ ĐẦU (drop seed A1 cũ rồi seed sạch)
-- → id unit/lesson đặt mới có hệ thống: a1-u{NN} / a1-u{NN}-l{N} / a1-u{NN}-l{N}-{p|q}{N}.
--
-- Bám đúng JSON contract FE curriculum_models.dart + chấm server CurriculumGradingService:
--   theory_content: { warmup, objectives[], grammarHtml?, vocabBlock[], examples[], commonMistakes[], tips[] }
--   activity payload theo type:
--     multiple_choice / listening_choice : { question, options[{id,text}], correctOptionId, explanationVi }
--     grammar_fill_blank/translation/error_correction : { question, [sourceText], acceptedAnswers[], explanationVi }
--     vocabulary_match : { question, pairs[{left,right}], explanationVi }
--     sentence_ordering : { question, tokens[], correctOrder[], explanationVi }
--     listening_choice còn cần: audioText (text để FE TTS đọc, KHÔNG cần file audio)
--   phase: practice (counts_toward_mastery=false) | quiz (counts_toward_mastery=true)
--
-- 5 BẤT BIẾN mỗi lesson (§H): có ≥1 câu quiz tính điểm; quiz chỉ dùng 5 dạng chấm tự
--   động (multiple_choice/grammar_fill_blank/vocabulary_match/sentence_ordering/listening_choice).
--   translation + error_correction CHỈ dùng ở phase=practice (sản sinh, không tính mastery).
-- Unit Review: lesson_type='unit_review', 10 câu quiz trộn, required_score_to_pass=75.
-- Cơ chế lên cấp: recomputeUnitProgress coi unit completed khi PASS HẾT lesson (gồm review);
--   checkpoint-A1 (V28) rút câu từ activity phase='quiz' → 50 lesson dưới đây cấp đủ ngân hàng.
-- skill_code chỉ dùng: listening|speaking|reading|writing (FK skills, seed V19).
-- =============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 0 — DỌN SẠCH A1 CŨ (đúng thứ tự FK; idempotent)                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- review_lesson_id trỏ tới lesson A1 → gỡ trước khi xoá lesson (dù FK đã ON DELETE SET NULL).
UPDATE learning_units SET review_lesson_id = NULL WHERE level_code = 'A1';

-- Xoá activity của mọi lesson A1 curriculum (gắn unit a1-unit-*). CASCADE cũng tự xoá,
-- nhưng xoá tường minh cho rõ ý đồ & an toàn.
DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (
   SELECT id FROM learning_lessons
    WHERE level_code = 'A1' AND unit_id LIKE 'a1-unit-%'
 );

-- Xoá lesson A1 curriculum cũ (user_lesson_progress / user_lesson_attempts CASCADE).
DELETE FROM learning_lessons
 WHERE level_code = 'A1' AND unit_id LIKE 'a1-unit-%';

-- Xoá toàn bộ unit A1 cũ (user_unit_progress CASCADE).
DELETE FROM learning_units WHERE level_code = 'A1';

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 1 — 10 UNIT A1 (display_order 1..10 liên tục, mở khoá tuần tự)         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order, required_review_score) VALUES
 ('a1-u01','A1','Nice to Meet You',            'Chào hỏi, giới thiệu bản thân',          'social',   '["vocabulary","grammar","reading"]'::jsonb, 1, 75),
 ('a1-u02','A1','My Family & People',          'Gia đình và miêu tả người',              'people',   '["vocabulary","grammar"]'::jsonb,           2, 75),
 ('a1-u03','A1','My Day, My Routine',          'Một ngày của tôi, thì hiện tại đơn',     'routine',  '["vocabulary","grammar","reading"]'::jsonb, 3, 75),
 ('a1-u04','A1','Food & Drink',                'Đồ ăn thức uống, gọi món, hỏi giá',      'food',     '["vocabulary","grammar","reading"]'::jsonb, 4, 75),
 ('a1-u05','A1','Numbers & Time',              'Số đếm, giờ giấc, ngày trong tuần',      'time',     '["vocabulary","grammar","listening"]'::jsonb, 5, 75),
 ('a1-u06','A1','This, That & My Things',      'Đồ vật, this/that, số nhiều, mạo từ',    'objects',  '["vocabulary","grammar"]'::jsonb,           6, 75),
 ('a1-u07','A1','What Can You Do?',            'Khả năng với can, mệnh lệnh, sở thích',  'ability',  '["grammar","vocabulary","speaking"]'::jsonb, 7, 75),
 ('a1-u08','A1','Places & Directions',        'Nơi chốn, giới từ, hỏi đường',           'places',   '["vocabulary","grammar","reading"]'::jsonb, 8, 75),
 ('a1-u09','A1','My Home & Where I Live',      'Nhà ở, phòng, đồ đạc, there is/are',     'home',     '["vocabulary","grammar","reading"]'::jsonb, 9, 75),
 ('a1-u10','A1','Weather, Clothes & Going Out','Thời tiết, quần áo, mua sắm, kế hoạch',   'everyday', '["vocabulary","grammar","listening"]'::jsonb, 10, 75);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 1 — Nice to Meet You / Rất vui được gặp bạn                            ║
-- ║ Can-do: chào hỏi & tạm biệt · giới thiệu bản thân (I'm...) · to be · wh-Q   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u01-l1','A1','reading','a1-u01','normal',1,'Hello & Goodbye','Chào hỏi cơ bản',8,15,70,'{}'::jsonb,
  '{"warmup":"Hai người gặp nhau buổi sáng — họ chào nhau thế nào?",
    "objectives":["Chào hỏi theo thời điểm trong ngày","Phân biệt Hello / Hi / Good morning","Nói lời tạm biệt phù hợp"],
    "vocabBlock":[
      {"word":"Good morning","ipa":"/ɡʊd ˈmɔːnɪŋ/","meaningVi":"Chào buổi sáng","example":"Good morning, teacher!"},
      {"word":"Good afternoon","ipa":"/ɡʊd ˌɑːftəˈnuːn/","meaningVi":"Chào buổi chiều","example":"Good afternoon, everyone."},
      {"word":"Good evening","ipa":"/ɡʊd ˈiːvnɪŋ/","meaningVi":"Chào buổi tối","example":"Good evening, sir."},
      {"word":"Goodbye","ipa":"/ɡʊdˈbaɪ/","meaningVi":"Tạm biệt","example":"Goodbye! See you tomorrow."},
      {"word":"See you","ipa":"/siː juː/","meaningVi":"Hẹn gặp lại","example":"See you later!"}],
    "examples":[
      {"en":"Good morning! How are you?","vi":"Chào buổi sáng! Bạn khỏe không?"},
      {"en":"Hi, nice to meet you.","vi":"Chào, rất vui được gặp bạn."},
      {"en":"Goodbye, see you tomorrow.","vi":"Tạm biệt, hẹn gặp ngày mai."}],
    "commonMistakes":["\"Good night\" là lời tạm biệt buổi tối (khi đi ngủ), KHÔNG phải lời chào gặp mặt."],
    "tips":["Hi / Hello dùng được mọi lúc, không phụ thuộc thời điểm trong ngày."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u01-l1-p1','a1-u01-l1','multiple_choice',1,'practice','easy',false,'{"question":"Lời chào nào dùng vào buổi sáng?","options":[{"id":"a","text":"Good evening"},{"id":"b","text":"Good morning"},{"id":"c","text":"Goodbye"}],"correctOptionId":"b","explanationVi":"Good morning = chào buổi sáng."}'::jsonb),
 ('a1-u01-l1-p2','a1-u01-l1','vocabulary_match',2,'practice','easy',false,'{"question":"Nối lời chào với thời điểm trong ngày:","pairs":[{"left":"Good morning","right":"buổi sáng"},{"left":"Good afternoon","right":"buổi chiều"},{"left":"Good evening","right":"buổi tối"}],"explanationVi":"Mỗi lời chào theo thời điểm."}'::jsonb),
 ('a1-u01-l1-p3','a1-u01-l1','grammar_fill_blank',3,'practice','easy',false,'{"question":"Điền từ còn thiếu: \"Good ___, teacher!\" (chào buổi sáng)","acceptedAnswers":["morning"],"explanationVi":"Good morning = chào buổi sáng."}'::jsonb),
 ('a1-u01-l1-q1','a1-u01-l1','multiple_choice',4,'quiz','easy',true,'{"question":"Chọn lời chào buổi chiều:","options":[{"id":"a","text":"Good afternoon"},{"id":"b","text":"Good night"},{"id":"c","text":"See you"}],"correctOptionId":"a","explanationVi":"Good afternoon = chào buổi chiều."}'::jsonb),
 ('a1-u01-l1-q2','a1-u01-l1','vocabulary_match',5,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"Hello","right":"Xin chào"},{"left":"Goodbye","right":"Tạm biệt"},{"left":"See you","right":"Hẹn gặp lại"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-u01-l1-q3','a1-u01-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền từ: \"Good ___\" là lời chào buổi chiều.","acceptedAnswers":["afternoon"],"explanationVi":"Good afternoon = chào buổi chiều."}'::jsonb),
 ('a1-u01-l1-q4','a1-u01-l1','multiple_choice',7,'quiz','hard',true,'{"question":"Câu nào KHÔNG dùng để chào khi gặp mặt?","options":[{"id":"a","text":"Good morning"},{"id":"b","text":"Good night"},{"id":"c","text":"Hello"}],"correctOptionId":"b","explanationVi":"\"Good night\" là lời tạm biệt buổi tối."}'::jsonb),
 ('a1-u01-l1-q5','a1-u01-l1','multiple_choice',8,'quiz','medium',true,'{"question":"\"Hi\" là cách chào thế nào?","options":[{"id":"a","text":"Thân mật"},{"id":"b","text":"Chỉ trang trọng"},{"id":"c","text":"Lời tạm biệt"}],"correctOptionId":"a","explanationVi":"Hi thân mật, dùng với bạn bè."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u01-l2','A1','reading','a1-u01','normal',2,'What''s your name?','Hỏi tên & đại từ chủ ngữ',9,15,70,'{}'::jsonb,
  '{"warmup":"Khi gặp người mới, câu đầu tiên bạn hỏi là gì?",
    "objectives":["Dùng mẫu What''s your name? – I''m...","Nhận biết đại từ chủ ngữ I/you/he/she/it/we/they"],
    "grammarHtml":"Đại từ chủ ngữ: I (tôi), you (bạn), he (anh ấy), she (cô ấy), it (nó), we (chúng tôi), they (họ). What''s = What is.",
    "vocabBlock":[
      {"word":"name","ipa":"/neɪm/","meaningVi":"tên","example":"My name is Mai."},
      {"word":"I","ipa":"/aɪ/","meaningVi":"tôi","example":"I am a student."},
      {"word":"you","ipa":"/juː/","meaningVi":"bạn","example":"You are my friend."}],
    "examples":[
      {"en":"What''s your name? – I''m Nam.","vi":"Bạn tên gì? – Tôi là Nam."},
      {"en":"This is Mai. She is my friend.","vi":"Đây là Mai. Cô ấy là bạn tôi."}],
    "commonMistakes":["❌ \"What your name?\" → ✅ \"What''s your name?\" (thiếu is)"],
    "tips":["What''s = What is (viết tắt). Trả lời: I''m + tên."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u01-l2-p1','a1-u01-l2','multiple_choice',1,'practice','easy',false,'{"question":"\"___ your name?\" Điền từ đúng.","options":[{"id":"a","text":"What''s"},{"id":"b","text":"Who''s"},{"id":"c","text":"Where''s"}],"correctOptionId":"a","explanationVi":"Hỏi tên dùng What''s your name?"}'::jsonb),
 ('a1-u01-l2-p2','a1-u01-l2','vocabulary_match',2,'practice','easy',false,'{"question":"Nối đại từ với nghĩa:","pairs":[{"left":"I","right":"tôi"},{"left":"you","right":"bạn"},{"left":"he","right":"anh ấy"},{"left":"she","right":"cô ấy"}],"explanationVi":"Ghép đúng đại từ."}'::jsonb),
 ('a1-u01-l2-p3','a1-u01-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"Mai is a girl. ___ is my friend. (điền đại từ)","acceptedAnswers":["She","she"],"explanationVi":"Mai là nữ → dùng She."}'::jsonb),
 ('a1-u01-l2-p4','a1-u01-l2','translation',4,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi tên là Nam.","acceptedAnswers":["I am Nam.","I''m Nam.","My name is Nam.","I am Nam","My name is Nam"],"explanationVi":"I am Nam. / My name is Nam."}'::jsonb),
 ('a1-u01-l2-q1','a1-u01-l2','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn đại từ đúng cho \"Nam\":","options":[{"id":"a","text":"She"},{"id":"b","text":"He"},{"id":"c","text":"It"}],"correctOptionId":"b","explanationVi":"Nam là nam giới → He."}'::jsonb),
 ('a1-u01-l2-q2','a1-u01-l2','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền: \"___ your name?\" (hỏi tên)","acceptedAnswers":["What''s","Whats","What is"],"explanationVi":"What''s your name?"}'::jsonb),
 ('a1-u01-l2-q3','a1-u01-l2','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["your","What''s","name"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: What''s your name?"}'::jsonb),
 ('a1-u01-l2-q4','a1-u01-l2','multiple_choice',8,'quiz','easy',true,'{"question":"Đại từ nào chỉ một nhóm người (họ)?","options":[{"id":"a","text":"they"},{"id":"b","text":"it"},{"id":"c","text":"she"}],"correctOptionId":"a","explanationVi":"they = họ (số nhiều)."}'::jsonb),
 ('a1-u01-l2-q5','a1-u01-l2','sentence_ordering',9,'quiz','hard',true,'{"question":"Sắp xếp thành câu trả lời:","tokens":["am","I","Nam"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: I am Nam."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u01-l3','A1','reading','a1-u01','normal',3,'Verb to be','Động từ to be hiện tại',10,15,70,'{}'::jsonb,
  '{"warmup":"am / is / are — khi nào dùng từ nào?",
    "objectives":["Chia to be theo chủ ngữ","Viết câu khẳng định / phủ định / nghi vấn với to be"],
    "grammarHtml":"I + am · He/She/It + is · We/You/They + are. Phủ định: thêm not (I am not, She is not). Câu hỏi: đảo to be lên đầu (Are you...? Is she...?).",
    "vocabBlock":[
      {"word":"student","ipa":"/ˈstjuːdnt/","meaningVi":"học sinh/sinh viên","example":"I am a student."},
      {"word":"happy","ipa":"/ˈhæpi/","meaningVi":"vui","example":"She is happy."}],
    "examples":[
      {"en":"I am a student.","vi":"Tôi là sinh viên."},
      {"en":"She is from Japan.","vi":"Cô ấy đến từ Nhật Bản."},
      {"en":"Are you a teacher? – Yes, I am.","vi":"Bạn là giáo viên à? – Vâng, đúng vậy."}],
    "commonMistakes":["❌ \"She are\" → ✅ \"She is\"","❌ \"You is\" → ✅ \"You are\""],
    "tips":["Chủ ngữ số nhiều (we/you/they) luôn đi với are."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u01-l3-p1','a1-u01-l3','multiple_choice',1,'practice','easy',false,'{"question":"I ___ a student.","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"I luôn đi với am."}'::jsonb),
 ('a1-u01-l3-p2','a1-u01-l3','grammar_fill_blank',2,'practice','medium',false,'{"question":"Điền dạng đúng của to be: \"They ___ from Vietnam.\"","acceptedAnswers":["are"],"explanationVi":"They (số nhiều) đi với are."}'::jsonb),
 ('a1-u01-l3-p3','a1-u01-l3','error_correction',3,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"She are from Japan.","acceptedAnswers":["She is from Japan.","She is from Japan"],"explanationVi":"She đi với is, không phải are."}'::jsonb),
 ('a1-u01-l3-q1','a1-u01-l3','multiple_choice',4,'quiz','medium',true,'{"question":"She ___ from Japan.","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"b","explanationVi":"She đi với is."}'::jsonb),
 ('a1-u01-l3-q2','a1-u01-l3','grammar_fill_blank',5,'quiz','medium',true,'{"question":"Điền to be: \"You ___ my best friend.\"","acceptedAnswers":["are"],"explanationVi":"You đi với are."}'::jsonb),
 ('a1-u01-l3-q3','a1-u01-l3','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn câu hỏi ĐÚNG với to be:","options":[{"id":"a","text":"Are you a student?"},{"id":"b","text":"You are student?"},{"id":"c","text":"You student are?"}],"correctOptionId":"a","explanationVi":"Câu hỏi to be: đảo to be lên đầu."}'::jsonb),
 ('a1-u01-l3-q4','a1-u01-l3','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Phủ định: \"I ___ not a teacher.\" (to be)","acceptedAnswers":["am"],"explanationVi":"I am not."}'::jsonb),
 ('a1-u01-l3-q5','a1-u01-l3','multiple_choice',8,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"He are happy."},{"id":"b","text":"He is happy."},{"id":"c","text":"He am happy."}],"correctOptionId":"b","explanationVi":"He đi với is."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u01-l4','A1','reading','a1-u01','normal',4,'Meet my friends','Đọc đoạn giới thiệu ngắn',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn dưới và xem có mấy người được giới thiệu.",
    "objectives":["Dùng mẫu This is... / He is a...","Đọc hiểu đoạn giới thiệu ngắn (4 câu)"],
    "grammarHtml":"Mẫu giới thiệu người khác: This is + tên. He/She is + nghề. VD: This is Nam. He is a teacher.",
    "vocabBlock":[
      {"word":"This is","ipa":"/ðɪs ɪz/","meaningVi":"Đây là","example":"This is my friend, Nam."},
      {"word":"teacher","ipa":"/ˈtiːtʃər/","meaningVi":"giáo viên","example":"He is a teacher."},
      {"word":"friend","ipa":"/frend/","meaningVi":"bạn","example":"She is my friend."}],
    "examples":[
      {"en":"This is my friend, Mai. She is a student. She is from Hanoi.","vi":"Đây là bạn tôi, Mai. Cô ấy là sinh viên. Cô ấy đến từ Hà Nội."},
      {"en":"Where are you from?","vi":"Bạn đến từ đâu?"}],
    "commonMistakes":["❌ \"This is he Nam\" → ✅ \"This is Nam. He is...\""],
    "tips":["Đọc kỹ đoạn văn rồi trả lời câu hỏi bên dưới."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u01-l4-p1','a1-u01-l4','multiple_choice',1,'practice','easy',false,'{"question":"\"___ is my friend, Nam.\" Điền từ.","options":[{"id":"a","text":"This"},{"id":"b","text":"These"},{"id":"c","text":"Those"}],"correctOptionId":"a","explanationVi":"This is dùng giới thiệu một người."}'::jsonb),
 ('a1-u01-l4-p2','a1-u01-l4','vocabulary_match',2,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"This is","right":"Đây là"},{"left":"teacher","right":"giáo viên"},{"left":"friend","right":"bạn"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-u01-l4-p3','a1-u01-l4','translation',3,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Anh ấy là giáo viên.","acceptedAnswers":["He is a teacher.","He is a teacher","He''s a teacher."],"explanationVi":"He is a teacher."}'::jsonb),
 ('a1-u01-l4-q1','a1-u01-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Đọc: \"This is Mai. She is a student. She is from Hanoi.\" → Mai làm gì?","options":[{"id":"a","text":"giáo viên"},{"id":"b","text":"sinh viên"},{"id":"c","text":"bác sĩ"}],"correctOptionId":"b","explanationVi":"She is a student = cô ấy là sinh viên."}'::jsonb),
 ('a1-u01-l4-q2','a1-u01-l4','multiple_choice',5,'quiz','medium',true,'{"question":"Theo đoạn trên, Mai đến từ đâu?","options":[{"id":"a","text":"Hanoi"},{"id":"b","text":"Japan"},{"id":"c","text":"Hue"}],"correctOptionId":"a","explanationVi":"She is from Hanoi."}'::jsonb),
 ('a1-u01-l4-q3','a1-u01-l4','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền: \"___ are you from?\" (hỏi quê quán)","acceptedAnswers":["Where"],"explanationVi":"Where are you from? = Bạn đến từ đâu?"}'::jsonb),
 ('a1-u01-l4-q4','a1-u01-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu giới thiệu ĐÚNG:","options":[{"id":"a","text":"This is Nam. He is a teacher."},{"id":"b","text":"This Nam is teacher."},{"id":"c","text":"He Nam a teacher."}],"correctOptionId":"a","explanationVi":"Đúng mẫu This is... He is a..."}'::jsonb),
 ('a1-u01-l4-q5','a1-u01-l4','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp câu giới thiệu:","tokens":["is","This","my","friend"],"correctOrder":[1,0,2,3],"explanationVi":"This is my friend."}'::jsonb);

-- ── UNIT 1 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u01-l5','A1','reading','a1-u01','unit_review',5,'Unit 1 Review','Ôn tập Unit 1: chào hỏi, đại từ, to be',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại toàn bộ Unit 1: chào hỏi, giới thiệu, đại từ, động từ to be.",
    "objectives":["Tổng hợp can-do Unit 1","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Bài ôn 10 câu — cần đúng ≥ 8/10 (75%) để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u01-l5-q1','a1-u01-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Lời chào buổi sáng:","options":[{"id":"a","text":"Good morning"},{"id":"b","text":"Good night"},{"id":"c","text":"Goodbye"}],"correctOptionId":"a","explanationVi":"Good morning = chào buổi sáng."}'::jsonb),
 ('a1-u01-l5-q2','a1-u01-l5','multiple_choice',2,'quiz','easy',true,'{"question":"Đại từ đúng cho \"Mai\" (nữ):","options":[{"id":"a","text":"He"},{"id":"b","text":"She"},{"id":"c","text":"It"}],"correctOptionId":"b","explanationVi":"Mai là nữ → She."}'::jsonb),
 ('a1-u01-l5-q3','a1-u01-l5','grammar_fill_blank',3,'quiz','easy',true,'{"question":"\"I ___ a student.\" (to be)","acceptedAnswers":["am"],"explanationVi":"I + am."}'::jsonb),
 ('a1-u01-l5-q4','a1-u01-l5','multiple_choice',4,'quiz','medium',true,'{"question":"\"She ___ from Japan.\"","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"b","explanationVi":"She + is."}'::jsonb),
 ('a1-u01-l5-q5','a1-u01-l5','grammar_fill_blank',5,'quiz','medium',true,'{"question":"\"They ___ my friends.\" (to be)","acceptedAnswers":["are"],"explanationVi":"They + are."}'::jsonb),
 ('a1-u01-l5-q6','a1-u01-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"Hello","right":"Xin chào"},{"left":"Goodbye","right":"Tạm biệt"},{"left":"teacher","right":"giáo viên"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u01-l5-q7','a1-u01-l5','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp câu hỏi tên:","tokens":["your","What''s","name"],"correctOrder":[1,0,2],"explanationVi":"What''s your name?"}'::jsonb),
 ('a1-u01-l5-q8','a1-u01-l5','multiple_choice',8,'quiz','medium',true,'{"question":"Chọn câu giới thiệu ĐÚNG:","options":[{"id":"a","text":"This is Nam. He is a teacher."},{"id":"b","text":"This Nam teacher."},{"id":"c","text":"He is Nam a teacher."}],"correctOptionId":"a","explanationVi":"This is... He is a..."}'::jsonb),
 ('a1-u01-l5-q9','a1-u01-l5','multiple_choice',9,'quiz','medium',true,'{"question":"\"Are you a student?\" — trả lời khẳng định:","options":[{"id":"a","text":"Yes, I am."},{"id":"b","text":"Yes, I do."},{"id":"c","text":"Yes, I is."}],"correctOptionId":"a","explanationVi":"Yes, I am."}'::jsonb),
 ('a1-u01-l5-q10','a1-u01-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"\"___ are you from?\" (hỏi quê quán)","acceptedAnswers":["Where"],"explanationVi":"Where are you from?"}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 2 — My Family & People / Gia đình và mọi người                        ║
-- ║ Can-do: nói về gia đình · tả người (tall/short/young/old) · sở hữu         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u02-l1','A1','reading','a1-u02','normal',1,'Family members','Thành viên gia đình',8,15,70,'{}'::jsonb,
  '{"warmup":"Gia đình bạn có những ai?",
    "objectives":["Gọi tên các thành viên gia đình","Dùng I have + thành viên"],
    "vocabBlock":[
      {"word":"father","ipa":"/ˈfɑːðər/","meaningVi":"bố","example":"My father is a doctor."},
      {"word":"mother","ipa":"/ˈmʌðər/","meaningVi":"mẹ","example":"My mother is a teacher."},
      {"word":"sister","ipa":"/ˈsɪstər/","meaningVi":"chị/em gái","example":"I have one sister."},
      {"word":"brother","ipa":"/ˈbrʌðər/","meaningVi":"anh/em trai","example":"He is my brother."},
      {"word":"parents","ipa":"/ˈpeərənts/","meaningVi":"bố mẹ","example":"My parents are at home."}],
    "examples":[
      {"en":"This is my family.","vi":"Đây là gia đình tôi."},
      {"en":"I have one brother and one sister.","vi":"Tôi có một anh trai và một em gái."}],
    "commonMistakes":["❌ \"my father he is\" → ✅ \"my father is\""],
    "tips":["father + mother = parents (bố mẹ)."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u02-l1-p1','a1-u02-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"father","right":"bố"},{"left":"mother","right":"mẹ"},{"left":"sister","right":"chị/em gái"},{"left":"brother","right":"anh/em trai"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-u02-l1-p2','a1-u02-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"My ___ is a doctor. (bố)","acceptedAnswers":["father"],"explanationVi":"father = bố."}'::jsonb),
 ('a1-u02-l1-p3','a1-u02-l1','multiple_choice',3,'practice','medium',false,'{"question":"Bố và mẹ gọi chung là gì?","options":[{"id":"a","text":"parents"},{"id":"b","text":"children"},{"id":"c","text":"friends"}],"correctOptionId":"a","explanationVi":"parents = bố mẹ."}'::jsonb),
 ('a1-u02-l1-q1','a1-u02-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"mother\" nghĩa là gì?","options":[{"id":"a","text":"bố"},{"id":"b","text":"mẹ"},{"id":"c","text":"chị"}],"correctOptionId":"b","explanationVi":"mother = mẹ."}'::jsonb),
 ('a1-u02-l1-q2','a1-u02-l1','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn từ chỉ anh/em trai:","options":[{"id":"a","text":"sister"},{"id":"b","text":"brother"},{"id":"c","text":"father"}],"correctOptionId":"b","explanationVi":"brother = anh/em trai."}'::jsonb),
 ('a1-u02-l1-q3','a1-u02-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"My ___ is a teacher. (mẹ)","acceptedAnswers":["mother"],"explanationVi":"mother = mẹ."}'::jsonb),
 ('a1-u02-l1-q4','a1-u02-l1','vocabulary_match',7,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"brother","right":"anh/em trai"},{"left":"parents","right":"bố mẹ"},{"left":"sister","right":"chị/em gái"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l1-q5','a1-u02-l1','multiple_choice',8,'quiz','hard',true,'{"question":"\"I have one ___.\" — chọn từ ĐÚNG ngữ pháp:","options":[{"id":"a","text":"sister"},{"id":"b","text":"sisters"},{"id":"c","text":"a sisters"}],"correctOptionId":"a","explanationVi":"one + danh từ số ít: one sister."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u02-l2','A1','reading','a1-u02','normal',2,'Possessive: my/your/his/her','Tính từ sở hữu',9,15,70,'{}'::jsonb,
  '{"warmup":"\"My\" và \"your\" khác nhau thế nào?",
    "objectives":["Dùng my/your/his/her/its/our/their","Đặt tính từ sở hữu trước danh từ"],
    "grammarHtml":"Tính từ sở hữu đứng TRƯỚC danh từ: my (của tôi), your (của bạn), his (của anh ấy), her (của cô ấy), its (của nó), our (của chúng tôi), their (của họ). VD: my book, her mother.",
    "vocabBlock":[],
    "examples":[
      {"en":"This is her mother.","vi":"Đây là mẹ của cô ấy."},
      {"en":"Their house is big.","vi":"Nhà của họ thì to."}],
    "commonMistakes":["❌ \"she book\" → ✅ \"her book\"","❌ \"they house\" → ✅ \"their house\""],
    "tips":["his đi với nam, her đi với nữ."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u02-l2-p1','a1-u02-l2','multiple_choice',1,'practice','easy',false,'{"question":"This is ___ book. (của tôi)","options":[{"id":"a","text":"my"},{"id":"b","text":"your"},{"id":"c","text":"her"}],"correctOptionId":"a","explanationVi":"my = của tôi."}'::jsonb),
 ('a1-u02-l2-p2','a1-u02-l2','grammar_fill_blank',2,'practice','medium',false,'{"question":"She loves ___ mother. (của cô ấy)","acceptedAnswers":["her"],"explanationVi":"her = của cô ấy."}'::jsonb),
 ('a1-u02-l2-p3','a1-u02-l2','vocabulary_match',3,'practice','medium',false,'{"question":"Nối tính từ sở hữu với nghĩa:","pairs":[{"left":"my","right":"của tôi"},{"left":"your","right":"của bạn"},{"left":"his","right":"của anh ấy"},{"left":"their","right":"của họ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l2-q1','a1-u02-l2','multiple_choice',4,'quiz','medium',true,'{"question":"He loves ___ father. (của anh ấy)","options":[{"id":"a","text":"her"},{"id":"b","text":"his"},{"id":"c","text":"my"}],"correctOptionId":"b","explanationVi":"his = của anh ấy."}'::jsonb),
 ('a1-u02-l2-q2','a1-u02-l2','grammar_fill_blank',5,'quiz','medium',true,'{"question":"Is this ___ name? (của bạn)","acceptedAnswers":["your"],"explanationVi":"your = của bạn."}'::jsonb),
 ('a1-u02-l2-q3','a1-u02-l2','multiple_choice',6,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"This is she book."},{"id":"b","text":"This is her book."},{"id":"c","text":"This is hers book."}],"correctOptionId":"b","explanationVi":"her + danh từ."}'::jsonb),
 ('a1-u02-l2-q4','a1-u02-l2','multiple_choice',7,'quiz','hard',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"Their house is big."},{"id":"b","text":"They house is big."},{"id":"c","text":"Them house is big."}],"correctOptionId":"a","explanationVi":"their = của họ."}'::jsonb),
 ('a1-u02-l2-q5','a1-u02-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"We love ___ school. (của chúng tôi)","acceptedAnswers":["our"],"explanationVi":"our = của chúng tôi."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u02-l3','A1','reading','a1-u02','normal',3,'Describing people','Miêu tả người (tall/short/young/old)',8,15,70,'{}'::jsonb,
  '{"warmup":"Bạn miêu tả người thân của mình thế nào?",
    "objectives":["Dùng tính từ miêu tả ngoại hình","Cấu trúc He/She is + adj (không có a/an)"],
    "grammarHtml":"He/She is + tính từ. VD: She is tall. He is young. Tính từ KHÔNG đổi theo số nhiều: They are tall. Không dùng a/an trước tính từ: ❌ She is a tall.",
    "vocabBlock":[
      {"word":"tall","ipa":"/tɔːl/","meaningVi":"cao","example":"My father is tall."},
      {"word":"short","ipa":"/ʃɔːt/","meaningVi":"thấp/ngắn","example":"She is short."},
      {"word":"young","ipa":"/jʌŋ/","meaningVi":"trẻ","example":"My sister is young."},
      {"word":"old","ipa":"/əʊld/","meaningVi":"già/cũ","example":"My grandfather is old."}],
    "examples":[
      {"en":"My mother is tall and young.","vi":"Mẹ tôi cao và trẻ."},
      {"en":"They are short.","vi":"Họ thấp."}],
    "commonMistakes":["❌ \"She is a tall\" → ✅ \"She is tall\" (không có a trước tính từ)"],
    "tips":["Tính từ đứng sau to be, không cần mạo từ a/an."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u02-l3-p1','a1-u02-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối tính từ với nghĩa:","pairs":[{"left":"tall","right":"cao"},{"left":"short","right":"thấp"},{"left":"young","right":"trẻ"},{"left":"old","right":"già"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l3-p2','a1-u02-l3','multiple_choice',2,'practice','easy',false,'{"question":"My father is ___. (cao)","options":[{"id":"a","text":"tall"},{"id":"b","text":"short"},{"id":"c","text":"old"}],"correctOptionId":"a","explanationVi":"tall = cao."}'::jsonb),
 ('a1-u02-l3-p3','a1-u02-l3','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"He is a tall.","acceptedAnswers":["He is tall.","He is tall"],"explanationVi":"Bỏ a trước tính từ."}'::jsonb),
 ('a1-u02-l3-q1','a1-u02-l3','multiple_choice',4,'quiz','easy',true,'{"question":"\"young\" nghĩa là gì?","options":[{"id":"a","text":"già"},{"id":"b","text":"trẻ"},{"id":"c","text":"cao"}],"correctOptionId":"b","explanationVi":"young = trẻ."}'::jsonb),
 ('a1-u02-l3-q2','a1-u02-l3','grammar_fill_blank',5,'quiz','medium',true,'{"question":"They ___ tall. (to be, số nhiều)","acceptedAnswers":["are"],"explanationVi":"They + are."}'::jsonb),
 ('a1-u02-l3-q3','a1-u02-l3','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She is tall."},{"id":"b","text":"She is a tall."},{"id":"c","text":"She tall is."}],"correctOptionId":"a","explanationVi":"He/She is + adj (không có a)."}'::jsonb),
 ('a1-u02-l3-q4','a1-u02-l3','vocabulary_match',7,'quiz','hard',true,'{"question":"Nối từ trái nghĩa:","pairs":[{"left":"tall","right":"short"},{"left":"young","right":"old"}],"explanationVi":"tall↔short, young↔old."}'::jsonb),
 ('a1-u02-l3-q5','a1-u02-l3','multiple_choice',8,'quiz','medium',true,'{"question":"\"old\" có thể nghĩa là gì?","options":[{"id":"a","text":"già hoặc cũ"},{"id":"b","text":"chỉ trẻ"},{"id":"c","text":"chỉ cao"}],"correctOptionId":"a","explanationVi":"old = già (người) / cũ (vật)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u02-l4','A1','reading','a1-u02','normal',4,'Possessive ''s','Sở hữu cách với ''s',9,15,70,'{}'::jsonb,
  '{"warmup":"\"Sách của Nam\" nói trong tiếng Anh thế nào?",
    "objectives":["Dùng danh từ + ''s để chỉ sở hữu","Phân biệt Nam''s book vs my book"],
    "grammarHtml":"Thêm ''s sau tên/danh từ chỉ người để chỉ sở hữu: Nam''s book = sách của Nam. Mary''s mother = mẹ của Mary.",
    "vocabBlock":[],
    "examples":[
      {"en":"This is Nam''s book.","vi":"Đây là sách của Nam."},
      {"en":"Mary''s mother is a doctor.","vi":"Mẹ của Mary là bác sĩ."}],
    "commonMistakes":["❌ \"the book of Nam\" → ✅ \"Nam''s book\"","❌ \"Nams book\" → ✅ \"Nam''s book\""],
    "tips":["Dùng ''s với người; thêm dấu '' (apostrophe) + s."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u02-l4-p1','a1-u02-l4','multiple_choice',1,'practice','easy',false,'{"question":"\"Sách của Nam\" =","options":[{"id":"a","text":"Nam''s book"},{"id":"b","text":"Nam book"},{"id":"c","text":"book Nam"}],"correctOptionId":"a","explanationVi":"Nam''s book = sách của Nam."}'::jsonb),
 ('a1-u02-l4-p2','a1-u02-l4','grammar_fill_blank',2,'practice','medium',false,'{"question":"Điền ''s đúng chỗ: \"This is Mary___ bag.\" (chỉ cần phần thêm)","acceptedAnswers":["''s","s"],"explanationVi":"Mary''s bag = túi của Mary."}'::jsonb),
 ('a1-u02-l4-p3','a1-u02-l4','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"This is the book of Nam.","acceptedAnswers":["This is Nam''s book.","This is Nam''s book"],"explanationVi":"Dùng ''s: Nam''s book."}'::jsonb),
 ('a1-u02-l4-q1','a1-u02-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Chọn cách nói ĐÚNG \"mẹ của Mary\":","options":[{"id":"a","text":"Mary''s mother"},{"id":"b","text":"Mary mother"},{"id":"c","text":"mother''s Mary"}],"correctOptionId":"a","explanationVi":"Mary''s mother."}'::jsonb),
 ('a1-u02-l4-q2','a1-u02-l4','sentence_ordering',5,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["Nam''s","This","book","is"],"correctOrder":[1,3,0,2],"explanationVi":"This is Nam''s book."}'::jsonb),
 ('a1-u02-l4-q3','a1-u02-l4','grammar_fill_blank',6,'quiz','medium',true,'{"question":"\"Đây là túi của bố tôi\": This is my ___ bag. (bố)","acceptedAnswers":["father''s","fathers"],"explanationVi":"father''s bag."}'::jsonb),
 ('a1-u02-l4-q4','a1-u02-l4','multiple_choice',7,'quiz','medium',true,'{"question":"''s dùng để chỉ gì?","options":[{"id":"a","text":"sở hữu (của ai đó)"},{"id":"b","text":"số nhiều"},{"id":"c","text":"thì quá khứ"}],"correctOptionId":"a","explanationVi":"''s = sở hữu."}'::jsonb),
 ('a1-u02-l4-q5','a1-u02-l4','multiple_choice',8,'quiz','hard',true,'{"question":"\"Phòng của Mai\" dịch ĐÚNG là:","options":[{"id":"a","text":"Mai''s room"},{"id":"b","text":"Mai room"},{"id":"c","text":"room of Mai''s"}],"correctOptionId":"a","explanationVi":"Mai''s room = phòng của Mai."}'::jsonb);

-- ── UNIT 2 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u02-l5','A1','reading','a1-u02','unit_review',5,'Unit 2 Review','Ôn tập Unit 2: gia đình, sở hữu, tả người',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 2: thành viên gia đình, tính từ sở hữu, ''s, tả người.",
    "objectives":["Tổng hợp can-do Unit 2","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u02-l5-q1','a1-u02-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"father\" nghĩa là:","options":[{"id":"a","text":"bố"},{"id":"b","text":"mẹ"},{"id":"c","text":"anh"}],"correctOptionId":"a","explanationVi":"father = bố."}'::jsonb),
 ('a1-u02-l5-q2','a1-u02-l5','vocabulary_match',2,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"mother","right":"mẹ"},{"left":"sister","right":"chị/em gái"},{"left":"parents","right":"bố mẹ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l5-q3','a1-u02-l5','grammar_fill_blank',3,'quiz','easy',true,'{"question":"This is ___ book. (của tôi)","acceptedAnswers":["my"],"explanationVi":"my = của tôi."}'::jsonb),
 ('a1-u02-l5-q4','a1-u02-l5','multiple_choice',4,'quiz','medium',true,'{"question":"He loves ___ mother. (của anh ấy)","options":[{"id":"a","text":"his"},{"id":"b","text":"her"},{"id":"c","text":"their"}],"correctOptionId":"a","explanationVi":"his = của anh ấy."}'::jsonb),
 ('a1-u02-l5-q5','a1-u02-l5','multiple_choice',5,'quiz','medium',true,'{"question":"\"Sách của Nam\" =","options":[{"id":"a","text":"Nam''s book"},{"id":"b","text":"Nam book"},{"id":"c","text":"book of Nam''s"}],"correctOptionId":"a","explanationVi":"Nam''s book."}'::jsonb),
 ('a1-u02-l5-q6','a1-u02-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"They ___ tall. (to be)","acceptedAnswers":["are"],"explanationVi":"They + are."}'::jsonb),
 ('a1-u02-l5-q7','a1-u02-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She is tall."},{"id":"b","text":"She is a tall."},{"id":"c","text":"She a tall."}],"correctOptionId":"a","explanationVi":"He/She is + adj."}'::jsonb),
 ('a1-u02-l5-q8','a1-u02-l5','vocabulary_match',8,'quiz','hard',true,'{"question":"Nối trái nghĩa:","pairs":[{"left":"tall","right":"short"},{"left":"young","right":"old"}],"explanationVi":"tall↔short, young↔old."}'::jsonb),
 ('a1-u02-l5-q9','a1-u02-l5','grammar_fill_blank',9,'quiz','hard',true,'{"question":"\"Mẹ của Mary\": ___ mother. (điền Mary + ''s)","acceptedAnswers":["Mary''s","Marys"],"explanationVi":"Mary''s mother."}'::jsonb),
 ('a1-u02-l5-q10','a1-u02-l5','multiple_choice',10,'quiz','medium',true,'{"question":"\"our\" nghĩa là:","options":[{"id":"a","text":"của chúng tôi"},{"id":"b","text":"của họ"},{"id":"c","text":"của bạn"}],"correctOptionId":"a","explanationVi":"our = của chúng tôi."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 3 — My Day, My Routine / Một ngày của tôi                             ║
-- ║ Can-do: kể thói quen hằng ngày · present simple (3 dạng) · at + giờ        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u03-l1','A1','reading','a1-u03','normal',1,'Daily actions','Hành động hằng ngày',8,15,70,'{}'::jsonb,
  '{"warmup":"Mỗi sáng bạn làm gì đầu tiên?",
    "objectives":["Gọi tên động từ chỉ hoạt động hằng ngày"],
    "vocabBlock":[
      {"word":"wake up","ipa":"/weɪk ʌp/","meaningVi":"thức dậy","example":"I wake up at 6."},
      {"word":"eat breakfast","ipa":"/iːt ˈbrekfəst/","meaningVi":"ăn sáng","example":"I eat breakfast at 7."},
      {"word":"go to school","ipa":"/ɡəʊ tə skuːl/","meaningVi":"đi học","example":"I go to school at 8."},
      {"word":"go to bed","ipa":"/ɡəʊ tə bed/","meaningVi":"đi ngủ","example":"I go to bed at 10."}],
    "examples":[
      {"en":"I wake up early.","vi":"Tôi thức dậy sớm."},
      {"en":"She goes to bed late.","vi":"Cô ấy đi ngủ muộn."}],
    "commonMistakes":["❌ \"I wakes up\" → ✅ \"I wake up\""],
    "tips":["Chủ ngữ I đi với động từ nguyên thể."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u03-l1-p1','a1-u03-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối hành động với nghĩa:","pairs":[{"left":"wake up","right":"thức dậy"},{"left":"eat breakfast","right":"ăn sáng"},{"left":"go to school","right":"đi học"},{"left":"go to bed","right":"đi ngủ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l1-p2','a1-u03-l1','sentence_ordering',2,'practice','medium',false,'{"question":"Sắp xếp câu:","tokens":["up","I","wake","early"],"correctOrder":[1,2,0,3],"explanationVi":"I wake up early."}'::jsonb),
 ('a1-u03-l1-p3','a1-u03-l1','multiple_choice',3,'practice','easy',false,'{"question":"Buổi tối đi ngủ là:","options":[{"id":"a","text":"go to bed"},{"id":"b","text":"wake up"},{"id":"c","text":"go to school"}],"correctOptionId":"a","explanationVi":"go to bed = đi ngủ."}'::jsonb),
 ('a1-u03-l1-q1','a1-u03-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"wake up\" nghĩa là gì?","options":[{"id":"a","text":"đi ngủ"},{"id":"b","text":"thức dậy"},{"id":"c","text":"ăn sáng"}],"correctOptionId":"b","explanationVi":"wake up = thức dậy."}'::jsonb),
 ('a1-u03-l1-q2','a1-u03-l1','grammar_fill_blank',5,'quiz','medium',true,'{"question":"I ___ breakfast at 7. (ăn)","acceptedAnswers":["eat"],"explanationVi":"eat breakfast = ăn sáng."}'::jsonb),
 ('a1-u03-l1-q3','a1-u03-l1','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn cụm \"đi học\":","options":[{"id":"a","text":"go to school"},{"id":"b","text":"go to bed"},{"id":"c","text":"wake up"}],"correctOptionId":"a","explanationVi":"go to school = đi học."}'::jsonb),
 ('a1-u03-l1-q4','a1-u03-l1','vocabulary_match',7,'quiz','hard',true,'{"question":"Nối hành động:","pairs":[{"left":"wake up","right":"thức dậy"},{"left":"go to bed","right":"đi ngủ"},{"left":"have lunch","right":"ăn trưa"}],"explanationVi":"Ghép đúng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u03-l2','A1','reading','a1-u03','normal',2,'Present simple','Thì hiện tại đơn (3 dạng)',10,15,70,'{}'::jsonb,
  '{"warmup":"Vì sao \"He plays\" có thêm s?",
    "objectives":["Chia động từ thì hiện tại đơn","Dùng phủ định don''t/doesn''t và câu hỏi Do/Does"],
    "grammarHtml":"Khẳng định: I/you/we/they + V; he/she/it + V-s. Phủ định: I/you/we/they + don''t + V; he/she/it + doesn''t + V. Câu hỏi: Do/Does + S + V? VD: She goes / She doesn''t go / Does she go?",
    "vocabBlock":[],
    "examples":[
      {"en":"She goes to school every day.","vi":"Cô ấy đi học mỗi ngày."},
      {"en":"He doesn''t like coffee.","vi":"Anh ấy không thích cà phê."},
      {"en":"Do you play football?","vi":"Bạn có chơi bóng đá không?"}],
    "commonMistakes":["❌ \"He go\" → ✅ \"He goes\"","❌ \"She don''t\" → ✅ \"She doesn''t\""],
    "tips":["Ngôi thứ 3 số ít (he/she/it) thêm -s/-es; phủ định/hỏi dùng does."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u03-l2-p1','a1-u03-l2','multiple_choice',1,'practice','easy',false,'{"question":"He ___ football. (chơi)","options":[{"id":"a","text":"play"},{"id":"b","text":"plays"},{"id":"c","text":"playing"}],"correctOptionId":"b","explanationVi":"He + plays (thêm s)."}'::jsonb),
 ('a1-u03-l2-p2','a1-u03-l2','error_correction',2,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"She go to school.","acceptedAnswers":["She goes to school.","She goes to school"],"explanationVi":"She + goes."}'::jsonb),
 ('a1-u03-l2-p3','a1-u03-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"Phủ định: \"He ___ like tea.\" (doesn''t/don''t)","acceptedAnswers":["doesn''t","does not","doesnt"],"explanationVi":"He + doesn''t."}'::jsonb),
 ('a1-u03-l2-q1','a1-u03-l2','multiple_choice',4,'quiz','medium',true,'{"question":"She ___ to school. (đi)","options":[{"id":"a","text":"go"},{"id":"b","text":"goes"},{"id":"c","text":"going"}],"correctOptionId":"b","explanationVi":"She + goes."}'::jsonb),
 ('a1-u03-l2-q2','a1-u03-l2','grammar_fill_blank',5,'quiz','medium',true,'{"question":"They ___ football every day. (chơi)","acceptedAnswers":["play"],"explanationVi":"They + play (không thêm s)."}'::jsonb),
 ('a1-u03-l2-q3','a1-u03-l2','grammar_fill_blank',6,'quiz','hard',true,'{"question":"Phủ định: \"She ___ not like coffee.\" (does/do)","acceptedAnswers":["does"],"explanationVi":"Ngôi 3 số ít: does not."}'::jsonb),
 ('a1-u03-l2-q4','a1-u03-l2','multiple_choice',7,'quiz','medium',true,'{"question":"Câu hỏi ĐÚNG ở hiện tại đơn:","options":[{"id":"a","text":"Does she go to school?"},{"id":"b","text":"Do she goes to school?"},{"id":"c","text":"She does go school?"}],"correctOptionId":"a","explanationVi":"Does + S + V(nguyên thể)?"}'::jsonb),
 ('a1-u03-l2-q5','a1-u03-l2','multiple_choice',8,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"He go home."},{"id":"b","text":"He goes home."},{"id":"c","text":"He going home."}],"correctOptionId":"b","explanationVi":"He + goes."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u03-l3','A1','reading','a1-u03','normal',3,'My daily routine','Kể thói quen kèm giờ (at + giờ)',9,15,70,'{}'::jsonb,
  '{"warmup":"Một ngày của bạn diễn ra thế nào?",
    "objectives":["Kể chuỗi thói quen kèm giờ","Dùng at + giờ"],
    "grammarHtml":"Dùng \"at + giờ\" để chỉ thời điểm. VD: I wake up at 6. I go to school at 7. Nối chuỗi bằng then/and.",
    "vocabBlock":[
      {"word":"have breakfast","ipa":"/hæv ˈbrekfəst/","meaningVi":"ăn sáng","example":"I have breakfast at 7."},
      {"word":"have lunch","ipa":"/hæv lʌntʃ/","meaningVi":"ăn trưa","example":"I have lunch at 12."},
      {"word":"go home","ipa":"/ɡəʊ həʊm/","meaningVi":"về nhà","example":"I go home at 5."}],
    "examples":[
      {"en":"I have lunch at twelve.","vi":"Tôi ăn trưa lúc 12 giờ."},
      {"en":"I wake up at 6, then I have breakfast.","vi":"Tôi dậy lúc 6 giờ, rồi ăn sáng."}],
    "commonMistakes":["❌ \"in 6 o''clock\" → ✅ \"at 6 o''clock\""],
    "tips":["Dùng at với giờ cụ thể."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u03-l3-p1','a1-u03-l3','grammar_fill_blank',1,'practice','easy',false,'{"question":"I wake up ___ 6. (giới từ chỉ giờ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-u03-l3-p2','a1-u03-l3','vocabulary_match',2,'practice','medium',false,'{"question":"Nối hành động:","pairs":[{"left":"have breakfast","right":"ăn sáng"},{"left":"have lunch","right":"ăn trưa"},{"left":"go home","right":"về nhà"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l3-p3','a1-u03-l3','sentence_ordering',3,'practice','medium',false,'{"question":"Sắp xếp câu:","tokens":["at","I","breakfast","seven","have"],"correctOrder":[1,4,2,0,3],"explanationVi":"I have breakfast at seven."}'::jsonb),
 ('a1-u03-l3-q1','a1-u03-l3','grammar_fill_blank',4,'quiz','easy',true,'{"question":"I go to school ___ 7. (giới từ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-u03-l3-q2','a1-u03-l3','multiple_choice',5,'quiz','medium',true,'{"question":"\"have lunch\" nghĩa là gì?","options":[{"id":"a","text":"ăn trưa"},{"id":"b","text":"ăn sáng"},{"id":"c","text":"ăn tối"}],"correctOptionId":"a","explanationVi":"have lunch = ăn trưa."}'::jsonb),
 ('a1-u03-l3-q3','a1-u03-l3','sentence_ordering',6,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["home","go","at","I","five"],"correctOrder":[3,1,0,2,4],"explanationVi":"I go home at five."}'::jsonb),
 ('a1-u03-l3-q4','a1-u03-l3','multiple_choice',7,'quiz','medium',true,'{"question":"Giới từ ĐÚNG: \"I get up ___ 6 o''clock.\"","options":[{"id":"a","text":"at"},{"id":"b","text":"in"},{"id":"c","text":"on"}],"correctOptionId":"a","explanationVi":"at + giờ cụ thể."}'::jsonb),
 ('a1-u03-l3-q5','a1-u03-l3','multiple_choice',8,'quiz','hard',true,'{"question":"\"Tôi đi ngủ lúc 10 giờ\" dịch ĐÚNG là:","options":[{"id":"a","text":"I go to bed at ten."},{"id":"b","text":"I go to bed in ten."},{"id":"c","text":"I go bed at ten."}],"correctOptionId":"a","explanationVi":"go to bed at + giờ."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u03-l4','A1','reading','a1-u03','normal',4,'A typical morning','Đọc về một buổi sáng',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn dưới về buổi sáng của Lan rồi trả lời.",
    "objectives":["Đọc hiểu đoạn mô tả thói quen (present simple)"],
    "grammarHtml":"Đoạn văn dùng present simple ngôi thứ 3 (she + V-s) để kể thói quen.",
    "vocabBlock":[
      {"word":"get up","ipa":"/ɡet ʌp/","meaningVi":"thức dậy / ra khỏi giường","example":"She gets up at 6."},
      {"word":"every day","ipa":"/ˈevri deɪ/","meaningVi":"mỗi ngày","example":"She studies every day."}],
    "examples":[
      {"en":"Lan gets up at six. She has breakfast at seven. Then she goes to school at half past seven.","vi":"Lan dậy lúc 6 giờ. Cô ấy ăn sáng lúc 7 giờ. Rồi cô ấy đi học lúc 7 giờ rưỡi."}],
    "commonMistakes":["❌ \"She get up\" → ✅ \"She gets up\""],
    "tips":["Đọc kỹ thứ tự thời gian: at six → at seven → half past seven."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u03-l4-p1','a1-u03-l4','multiple_choice',1,'practice','easy',false,'{"question":"Đọc: \"Lan gets up at six.\" → Lan dậy lúc mấy giờ?","options":[{"id":"a","text":"6 giờ"},{"id":"b","text":"7 giờ"},{"id":"c","text":"8 giờ"}],"correctOptionId":"a","explanationVi":"gets up at six = dậy lúc 6 giờ."}'::jsonb),
 ('a1-u03-l4-p2','a1-u03-l4','vocabulary_match',2,'practice','medium',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"get up","right":"thức dậy"},{"left":"every day","right":"mỗi ngày"},{"left":"breakfast","right":"bữa sáng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l4-q1','a1-u03-l4','multiple_choice',3,'quiz','medium',true,'{"question":"Đọc đoạn: Lan ăn sáng lúc mấy giờ?","options":[{"id":"a","text":"6 giờ"},{"id":"b","text":"7 giờ"},{"id":"c","text":"7 giờ rưỡi"}],"correctOptionId":"b","explanationVi":"She has breakfast at seven."}'::jsonb),
 ('a1-u03-l4-q2','a1-u03-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Lan đi học lúc mấy giờ?","options":[{"id":"a","text":"7 giờ"},{"id":"b","text":"7 giờ rưỡi"},{"id":"c","text":"8 giờ"}],"correctOptionId":"b","explanationVi":"goes to school at half past seven = 7 giờ 30."}'::jsonb),
 ('a1-u03-l4-q3','a1-u03-l4','grammar_fill_blank',5,'quiz','medium',true,'{"question":"\"She ___ up at six.\" (get, ngôi 3 số ít)","acceptedAnswers":["gets"],"explanationVi":"She + gets up."}'::jsonb),
 ('a1-u03-l4-q4','a1-u03-l4','multiple_choice',6,'quiz','hard',true,'{"question":"\"half past seven\" là mấy giờ?","options":[{"id":"a","text":"6 giờ 30"},{"id":"b","text":"7 giờ 30"},{"id":"c","text":"7 giờ"}],"correctOptionId":"b","explanationVi":"half past seven = 7 giờ 30."}'::jsonb);

-- ── UNIT 3 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u03-l5','A1','reading','a1-u03','unit_review',5,'Unit 3 Review','Ôn tập Unit 3: thói quen, present simple, at + giờ',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 3: động từ hằng ngày, present simple 3 dạng, at + giờ.",
    "objectives":["Tổng hợp can-do Unit 3","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u03-l5-q1','a1-u03-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"wake up\" nghĩa là:","options":[{"id":"a","text":"thức dậy"},{"id":"b","text":"đi ngủ"},{"id":"c","text":"ăn trưa"}],"correctOptionId":"a","explanationVi":"wake up = thức dậy."}'::jsonb),
 ('a1-u03-l5-q2','a1-u03-l5','vocabulary_match',2,'quiz','easy',true,'{"question":"Nối hành động:","pairs":[{"left":"eat breakfast","right":"ăn sáng"},{"left":"go to school","right":"đi học"},{"left":"go to bed","right":"đi ngủ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l5-q3','a1-u03-l5','multiple_choice',3,'quiz','easy',true,'{"question":"He ___ football. (chơi)","options":[{"id":"a","text":"play"},{"id":"b","text":"plays"},{"id":"c","text":"playing"}],"correctOptionId":"b","explanationVi":"He + plays."}'::jsonb),
 ('a1-u03-l5-q4','a1-u03-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"They ___ to school every day. (đi)","acceptedAnswers":["go"],"explanationVi":"They + go."}'::jsonb),
 ('a1-u03-l5-q5','a1-u03-l5','grammar_fill_blank',5,'quiz','medium',true,'{"question":"I have lunch ___ 12. (giới từ chỉ giờ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-u03-l5-q6','a1-u03-l5','multiple_choice',6,'quiz','medium',true,'{"question":"Câu hỏi ĐÚNG:","options":[{"id":"a","text":"Does she go to school?"},{"id":"b","text":"Do she go to school?"},{"id":"c","text":"She go to school?"}],"correctOptionId":"a","explanationVi":"Does + S + V?"}'::jsonb),
 ('a1-u03-l5-q7','a1-u03-l5','multiple_choice',7,'quiz','hard',true,'{"question":"Phủ định ĐÚNG:","options":[{"id":"a","text":"He doesn''t like tea."},{"id":"b","text":"He don''t like tea."},{"id":"c","text":"He not like tea."}],"correctOptionId":"a","explanationVi":"He + doesn''t + V."}'::jsonb),
 ('a1-u03-l5-q8','a1-u03-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["at","I","up","wake","six"],"correctOrder":[1,3,2,0,4],"explanationVi":"I wake up at six."}'::jsonb),
 ('a1-u03-l5-q9','a1-u03-l5','multiple_choice',9,'quiz','medium',true,'{"question":"\"half past seven\" là:","options":[{"id":"a","text":"7 giờ 30"},{"id":"b","text":"6 giờ 30"},{"id":"c","text":"7 giờ"}],"correctOptionId":"a","explanationVi":"half past seven = 7 giờ 30."}'::jsonb),
 ('a1-u03-l5-q10','a1-u03-l5','multiple_choice',10,'quiz','hard',true,'{"question":"\"Cô ấy đi học mỗi ngày\" dịch ĐÚNG là:","options":[{"id":"a","text":"She goes to school every day."},{"id":"b","text":"She go to school every day."},{"id":"c","text":"She going to school every day."}],"correctOptionId":"a","explanationVi":"She + goes (ngôi 3 số ít)."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 4 — Food & Drink / Đồ ăn & thức uống                                  ║
-- ║ Can-do: gọi tên đồ ăn · I like/don't like · a/an vs some · gọi món, hỏi giá║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u04-l1','A1','reading','a1-u04','normal',1,'Food vocabulary','Từ vựng đồ ăn thức uống',8,15,70,'{}'::jsonb,
  '{"warmup":"Món bạn thích nhất là gì?",
    "objectives":["Gọi tên đồ ăn thức uống cơ bản"],
    "vocabBlock":[
      {"word":"rice","ipa":"/raɪs/","meaningVi":"cơm","example":"I eat rice every day."},
      {"word":"water","ipa":"/ˈwɔːtər/","meaningVi":"nước","example":"I drink water."},
      {"word":"apple","ipa":"/ˈæpl/","meaningVi":"táo","example":"An apple a day."},
      {"word":"bread","ipa":"/bred/","meaningVi":"bánh mì","example":"I eat bread for breakfast."},
      {"word":"milk","ipa":"/mɪlk/","meaningVi":"sữa","example":"She drinks milk."},
      {"word":"fish","ipa":"/fɪʃ/","meaningVi":"cá","example":"I like fish."}],
    "examples":[
      {"en":"I like rice and fish.","vi":"Tôi thích cơm và cá."},
      {"en":"I drink some milk every morning.","vi":"Tôi uống chút sữa mỗi sáng."}],
    "commonMistakes":["❌ \"a water\" → ✅ \"some water\" (không đếm được)"],
    "tips":["water/milk/rice là danh từ không đếm được → dùng some, không dùng a/an."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u04-l1-p1','a1-u04-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"rice","right":"cơm"},{"left":"water","right":"nước"},{"left":"apple","right":"táo"},{"left":"fish","right":"cá"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u04-l1-p2','a1-u04-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"I drink ___ every day. (nước)","acceptedAnswers":["water"],"explanationVi":"water = nước."}'::jsonb),
 ('a1-u04-l1-p3','a1-u04-l1','multiple_choice',3,'practice','medium',false,'{"question":"\"bread\" nghĩa là:","options":[{"id":"a","text":"bánh mì"},{"id":"b","text":"sữa"},{"id":"c","text":"cá"}],"correctOptionId":"a","explanationVi":"bread = bánh mì."}'::jsonb),
 ('a1-u04-l1-q1','a1-u04-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"rice\" nghĩa là gì?","options":[{"id":"a","text":"cơm"},{"id":"b","text":"nước"},{"id":"c","text":"táo"}],"correctOptionId":"a","explanationVi":"rice = cơm."}'::jsonb),
 ('a1-u04-l1-q2','a1-u04-l1','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn từ chỉ trái táo:","options":[{"id":"a","text":"water"},{"id":"b","text":"apple"},{"id":"c","text":"rice"}],"correctOptionId":"b","explanationVi":"apple = táo."}'::jsonb),
 ('a1-u04-l1-q3','a1-u04-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"I eat ___ every day. (cơm)","acceptedAnswers":["rice"],"explanationVi":"rice = cơm."}'::jsonb),
 ('a1-u04-l1-q4','a1-u04-l1','vocabulary_match',7,'quiz','hard',true,'{"question":"Nối đồ ăn với nghĩa:","pairs":[{"left":"bread","right":"bánh mì"},{"left":"milk","right":"sữa"},{"left":"fish","right":"cá"}],"explanationVi":"Ghép đúng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u04-l2','A1','reading','a1-u04','normal',2,'I like / I don''t like','Diễn đạt sở thích ăn uống',8,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao nói bạn không thích món gì?",
    "objectives":["Dùng I like / I don''t like + danh từ","Dùng like + V-ing"],
    "grammarHtml":"I like + N: I like tea. Phủ định: I don''t like + N: I don''t like coffee. Có thể dùng like + V-ing: I like cooking.",
    "vocabBlock":[],
    "examples":[
      {"en":"I don''t like coffee.","vi":"Tôi không thích cà phê."},
      {"en":"She likes apples.","vi":"Cô ấy thích táo."}],
    "commonMistakes":["❌ \"I no like\" → ✅ \"I don''t like\""],
    "tips":["don''t = do not. Ngôi 3 số ít: doesn''t like / likes."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u04-l2-p1','a1-u04-l2','multiple_choice',1,'practice','easy',false,'{"question":"I ___ tea. (thích)","options":[{"id":"a","text":"like"},{"id":"b","text":"likes"},{"id":"c","text":"liking"}],"correctOptionId":"a","explanationVi":"I + like."}'::jsonb),
 ('a1-u04-l2-p2','a1-u04-l2','error_correction',2,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"I no like coffee.","acceptedAnswers":["I don''t like coffee.","I do not like coffee.","I dont like coffee"],"explanationVi":"I don''t like + N."}'::jsonb),
 ('a1-u04-l2-p3','a1-u04-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"She ___ apples. (thích — ngôi 3 số ít)","acceptedAnswers":["likes"],"explanationVi":"She + likes."}'::jsonb),
 ('a1-u04-l2-q1','a1-u04-l2','multiple_choice',4,'quiz','medium',true,'{"question":"Chọn câu phủ định ĐÚNG:","options":[{"id":"a","text":"I no like fish."},{"id":"b","text":"I don''t like fish."},{"id":"c","text":"I not like fish."}],"correctOptionId":"b","explanationVi":"I don''t like + N."}'::jsonb),
 ('a1-u04-l2-q2','a1-u04-l2','grammar_fill_blank',5,'quiz','medium',true,'{"question":"I ___ rice. (thích)","acceptedAnswers":["like"],"explanationVi":"I + like."}'::jsonb),
 ('a1-u04-l2-q3','a1-u04-l2','grammar_fill_blank',6,'quiz','medium',true,'{"question":"\"___ you like tea?\" (Do/Does)","acceptedAnswers":["Do"],"explanationVi":"Do you like...?"}'::jsonb),
 ('a1-u04-l2-q4','a1-u04-l2','multiple_choice',7,'quiz','easy',true,'{"question":"\"I don''t like\" nghĩa là gì?","options":[{"id":"a","text":"Tôi thích"},{"id":"b","text":"Tôi không thích"},{"id":"c","text":"Tôi rất thích"}],"correctOptionId":"b","explanationVi":"don''t like = không thích."}'::jsonb),
 ('a1-u04-l2-q5','a1-u04-l2','multiple_choice',8,'quiz','hard',true,'{"question":"Câu nào ĐÚNG (ngôi 3 số ít)?","options":[{"id":"a","text":"She like fish."},{"id":"b","text":"She likes fish."},{"id":"c","text":"She liking fish."}],"correctOptionId":"b","explanationVi":"She + likes."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u04-l3','A1','reading','a1-u04','normal',3,'A/an vs some','Đếm được & không đếm được',9,15,70,'{}'::jsonb,
  '{"warmup":"\"an apple\" và \"some water\" — khác nhau chỗ nào?",
    "objectives":["Phân biệt danh từ đếm được / không đếm được","Dùng a/an với số ít đếm được, some với không đếm được & số nhiều"],
    "grammarHtml":"Đếm được số ít: a/an (a banana, an apple — an trước nguyên âm). Không đếm được (water, rice, milk): dùng some, KHÔNG dùng a/an. Số nhiều/lượng chung: some apples, some water.",
    "vocabBlock":[],
    "examples":[
      {"en":"I have an apple and some water.","vi":"Tôi có một quả táo và một ít nước."},
      {"en":"She wants some rice.","vi":"Cô ấy muốn một ít cơm."}],
    "commonMistakes":["❌ \"a water\" → ✅ \"some water\"","❌ \"a apple\" → ✅ \"an apple\""],
    "tips":["an đứng trước từ bắt đầu bằng nguyên âm (a, e, i, o, u)."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u04-l3-p1','a1-u04-l3','multiple_choice',1,'practice','easy',false,'{"question":"___ apple (điền a/an)","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"some"}],"correctOptionId":"b","explanationVi":"apple bắt đầu bằng nguyên âm → an apple."}'::jsonb),
 ('a1-u04-l3-p2','a1-u04-l3','multiple_choice',2,'practice','medium',false,'{"question":"I drink ___ water. (a/an/some)","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"some"}],"correctOptionId":"c","explanationVi":"water không đếm được → some water."}'::jsonb),
 ('a1-u04-l3-p3','a1-u04-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"___ banana (điền a/an)","acceptedAnswers":["a"],"explanationVi":"banana bắt đầu bằng phụ âm → a banana."}'::jsonb),
 ('a1-u04-l3-q1','a1-u04-l3','multiple_choice',4,'quiz','medium',true,'{"question":"Chọn ĐÚNG: \"I have ___ egg.\"","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"some"}],"correctOptionId":"b","explanationVi":"egg bắt đầu bằng nguyên âm → an egg."}'::jsonb),
 ('a1-u04-l3-q2','a1-u04-l3','grammar_fill_blank',5,'quiz','medium',true,'{"question":"She wants ___ rice. (a/an/some — không đếm được)","acceptedAnswers":["some"],"explanationVi":"rice không đếm được → some rice."}'::jsonb),
 ('a1-u04-l3-q3','a1-u04-l3','multiple_choice',6,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I want a water."},{"id":"b","text":"I want some water."},{"id":"c","text":"I want an water."}],"correctOptionId":"b","explanationVi":"water không đếm được → some water."}'::jsonb),
 ('a1-u04-l3-q4','a1-u04-l3','multiple_choice',7,'quiz','medium',true,'{"question":"Khi nào dùng \"an\"?","options":[{"id":"a","text":"trước nguyên âm (a,e,i,o,u)"},{"id":"b","text":"trước phụ âm"},{"id":"c","text":"trước danh từ không đếm được"}],"correctOptionId":"a","explanationVi":"an + nguyên âm."}'::jsonb),
 ('a1-u04-l3-q5','a1-u04-l3','vocabulary_match',8,'quiz','hard',true,'{"question":"Nối từ với mạo từ/lượng đúng:","pairs":[{"left":"apple","right":"an apple"},{"left":"water","right":"some water"},{"left":"banana","right":"a banana"}],"explanationVi":"an + nguyên âm, some + không đếm được, a + phụ âm."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u04-l4','A1','reading','a1-u04','normal',4,'At a café','Gọi món & hỏi giá (I''d like / How much)',10,15,70,'{}'::jsonb,
  '{"warmup":"Vào quán café, bạn gọi món thế nào?",
    "objectives":["Dùng I''d like... để gọi món","Hỏi giá bằng How much is it?"],
    "grammarHtml":"Gọi món lịch sự: I''d like + N (I''d like = I would like). Hỏi giá: How much is it? Trả lời: It''s + giá. VD: I''d like a coffee. – How much is it? – It''s two dollars.",
    "vocabBlock":[
      {"word":"I''d like","ipa":"/aɪd laɪk/","meaningVi":"tôi muốn (lịch sự)","example":"I''d like a tea, please."},
      {"word":"How much","ipa":"/haʊ mʌtʃ/","meaningVi":"bao nhiêu tiền","example":"How much is it?"},
      {"word":"coffee","ipa":"/ˈkɒfi/","meaningVi":"cà phê","example":"A coffee, please."}],
    "examples":[
      {"en":"I''d like a coffee, please. – How much is it? – It''s three dollars.","vi":"Cho tôi một cà phê. – Bao nhiêu tiền? – Ba đô la."}],
    "commonMistakes":["❌ \"How much it is?\" → ✅ \"How much is it?\""],
    "tips":["I''d like lịch sự hơn I want khi gọi món."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u04-l4-p1','a1-u04-l4','multiple_choice',1,'practice','easy',false,'{"question":"Gọi món lịch sự: \"___ a coffee, please.\"","options":[{"id":"a","text":"I''d like"},{"id":"b","text":"I am"},{"id":"c","text":"I do"}],"correctOptionId":"a","explanationVi":"I''d like = tôi muốn (lịch sự)."}'::jsonb),
 ('a1-u04-l4-p2','a1-u04-l4','vocabulary_match',2,'practice','medium',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"I''d like","right":"tôi muốn"},{"left":"How much","right":"bao nhiêu tiền"},{"left":"coffee","right":"cà phê"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u04-l4-p3','a1-u04-l4','translation',3,'practice','medium',false,'{"question":"Dịch: \"Bao nhiêu tiền?\"","sourceText":"Bao nhiêu tiền?","acceptedAnswers":["How much is it?","How much is it"],"explanationVi":"How much is it?"}'::jsonb),
 ('a1-u04-l4-q1','a1-u04-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Đọc: \"I''d like a tea.\" — người nói đang làm gì?","options":[{"id":"a","text":"gọi món"},{"id":"b","text":"hỏi đường"},{"id":"c","text":"chào hỏi"}],"correctOptionId":"a","explanationVi":"I''d like = gọi món."}'::jsonb),
 ('a1-u04-l4-q2','a1-u04-l4','multiple_choice',5,'quiz','medium',true,'{"question":"Câu hỏi giá ĐÚNG:","options":[{"id":"a","text":"How much is it?"},{"id":"b","text":"How much it is?"},{"id":"c","text":"How is much it?"}],"correctOptionId":"a","explanationVi":"How much is it?"}'::jsonb),
 ('a1-u04-l4-q3','a1-u04-l4','sentence_ordering',6,'quiz','hard',true,'{"question":"Sắp xếp câu gọi món:","tokens":["like","a","I''d","coffee"],"correctOrder":[2,0,1,3],"explanationVi":"I''d like a coffee."}'::jsonb),
 ('a1-u04-l4-q4','a1-u04-l4','grammar_fill_blank',7,'quiz','medium',true,'{"question":"\"It''s three ___.\" (đơn vị tiền)","acceptedAnswers":["dollars","dollar"],"explanationVi":"It''s three dollars."}'::jsonb),
 ('a1-u04-l4-q5','a1-u04-l4','multiple_choice',8,'quiz','easy',true,'{"question":"\"How much\" hỏi về cái gì?","options":[{"id":"a","text":"giá tiền"},{"id":"b","text":"thời gian"},{"id":"c","text":"nơi chốn"}],"correctOptionId":"a","explanationVi":"How much = hỏi giá."}'::jsonb);

-- ── UNIT 4 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u04-l5','A1','reading','a1-u04','unit_review',5,'Unit 4 Review','Ôn tập Unit 4: đồ ăn, like, a/some, gọi món',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 4: từ vựng đồ ăn, like/don''t like, a/an/some, gọi món & hỏi giá.",
    "objectives":["Tổng hợp can-do Unit 4","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u04-l5-q1','a1-u04-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"water\" nghĩa là:","options":[{"id":"a","text":"nước"},{"id":"b","text":"cơm"},{"id":"c","text":"sữa"}],"correctOptionId":"a","explanationVi":"water = nước."}'::jsonb),
 ('a1-u04-l5-q2','a1-u04-l5','vocabulary_match',2,'quiz','easy',true,'{"question":"Nối đồ ăn:","pairs":[{"left":"rice","right":"cơm"},{"left":"bread","right":"bánh mì"},{"left":"fish","right":"cá"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u04-l5-q3','a1-u04-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Câu phủ định ĐÚNG:","options":[{"id":"a","text":"I don''t like coffee."},{"id":"b","text":"I no like coffee."},{"id":"c","text":"I not like coffee."}],"correctOptionId":"a","explanationVi":"I don''t like."}'::jsonb),
 ('a1-u04-l5-q4','a1-u04-l5','multiple_choice',4,'quiz','medium',true,'{"question":"___ apple (a/an)","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"some"}],"correctOptionId":"b","explanationVi":"an apple (nguyên âm)."}'::jsonb),
 ('a1-u04-l5-q5','a1-u04-l5','grammar_fill_blank',5,'quiz','medium',true,'{"question":"I drink ___ water. (không đếm được)","acceptedAnswers":["some"],"explanationVi":"some water."}'::jsonb),
 ('a1-u04-l5-q6','a1-u04-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"\"___ you like tea?\" (Do/Does)","acceptedAnswers":["Do"],"explanationVi":"Do you like...?"}'::jsonb),
 ('a1-u04-l5-q7','a1-u04-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Câu hỏi giá ĐÚNG:","options":[{"id":"a","text":"How much is it?"},{"id":"b","text":"How much it is?"},{"id":"c","text":"How is it much?"}],"correctOptionId":"a","explanationVi":"How much is it?"}'::jsonb),
 ('a1-u04-l5-q8','a1-u04-l5','multiple_choice',8,'quiz','hard',true,'{"question":"Gọi món lịch sự:","options":[{"id":"a","text":"I''d like a tea."},{"id":"b","text":"I tea."},{"id":"c","text":"Me tea."}],"correctOptionId":"a","explanationVi":"I''d like + N."}'::jsonb),
 ('a1-u04-l5-q9','a1-u04-l5','sentence_ordering',9,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["like","I''d","coffee","a"],"correctOrder":[1,0,3,2],"explanationVi":"I''d like a coffee."}'::jsonb),
 ('a1-u04-l5-q10','a1-u04-l5','multiple_choice',10,'quiz','medium',true,'{"question":"Câu nào ĐÚNG (ngôi 3 số ít)?","options":[{"id":"a","text":"She likes fish."},{"id":"b","text":"She like fish."},{"id":"c","text":"She liking fish."}],"correctOptionId":"a","explanationVi":"She + likes."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 5 — Numbers & Time / Số đếm & giờ giấc                                ║
-- ║ Can-do: đếm 1–100 · hỏi-đáp giờ · How many · ngày trong tuần (có nghe)     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u05-l1','A1','reading','a1-u05','normal',1,'Numbers 1–100','Số đếm 1–100',8,15,70,'{}'::jsonb,
  '{"warmup":"Đếm từ 1 đến 5 bằng tiếng Anh?",
    "objectives":["Đếm số 1–100","Nhận biết số chục (twenty, thirty...)"],
    "grammarHtml":"1–10: one→ten. 11–20: eleven, twelve, thirteen... twenty. Số chục: twenty, thirty, forty, fifty... hundred. Số ghép: twenty-one, thirty-five.",
    "vocabBlock":[
      {"word":"one","ipa":"/wʌn/","meaningVi":"một","example":"I have one book."},
      {"word":"ten","ipa":"/ten/","meaningVi":"mười","example":"There are ten students."},
      {"word":"twenty","ipa":"/ˈtwenti/","meaningVi":"hai mươi","example":"She is twenty."},
      {"word":"hundred","ipa":"/ˈhʌndrəd/","meaningVi":"một trăm","example":"one hundred"}],
    "examples":[
      {"en":"I have twenty-one books.","vi":"Tôi có hai mươi mốt cuốn sách."},
      {"en":"There are fifty students.","vi":"Có năm mươi học sinh."}],
    "commonMistakes":["❌ \"to\" và \"two\" khác nghĩa.","❌ \"twenty one\" → ✅ \"twenty-one\" (có gạch nối)"],
    "tips":["three bắt đầu bằng âm /θ/; số ghép có gạch nối: thirty-five."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u05-l1-p1','a1-u05-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối số với chữ:","pairs":[{"left":"one","right":"1"},{"left":"ten","right":"10"},{"left":"twenty","right":"20"},{"left":"hundred","right":"100"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u05-l1-p2','a1-u05-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Số sau \"nineteen\" là ___. (viết chữ)","acceptedAnswers":["twenty"],"explanationVi":"19 → 20 = twenty."}'::jsonb),
 ('a1-u05-l1-p3','a1-u05-l1','multiple_choice',3,'practice','medium',false,'{"question":"\"35\" viết là:","options":[{"id":"a","text":"thirty-five"},{"id":"b","text":"three-five"},{"id":"c","text":"thirteen-five"}],"correctOptionId":"a","explanationVi":"35 = thirty-five."}'::jsonb),
 ('a1-u05-l1-q1','a1-u05-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"three\" là số mấy?","options":[{"id":"a","text":"2"},{"id":"b","text":"3"},{"id":"c","text":"4"}],"correctOptionId":"b","explanationVi":"three = 3."}'::jsonb),
 ('a1-u05-l1-q2','a1-u05-l1','grammar_fill_blank',5,'quiz','medium',true,'{"question":"I have ___ apples. (hai)","acceptedAnswers":["two"],"explanationVi":"two = hai."}'::jsonb),
 ('a1-u05-l1-q3','a1-u05-l1','multiple_choice',6,'quiz','medium',true,'{"question":"\"fifty\" là số mấy?","options":[{"id":"a","text":"15"},{"id":"b","text":"50"},{"id":"c","text":"5"}],"correctOptionId":"b","explanationVi":"fifty = 50."}'::jsonb),
 ('a1-u05-l1-q4','a1-u05-l1','multiple_choice',7,'quiz','hard',true,'{"question":"Phân biệt: \"13\" viết là:","options":[{"id":"a","text":"thirteen"},{"id":"b","text":"thirty"},{"id":"c","text":"three"}],"correctOptionId":"a","explanationVi":"13 = thirteen (khác 30 = thirty)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u05-l2','A1','reading','a1-u05','normal',2,'What time is it?','Hỏi giờ',9,15,70,'{}'::jsonb,
  '{"warmup":"Bây giờ là mấy giờ?",
    "objectives":["Hỏi và trả lời giờ","Dùng o''clock / half past"],
    "grammarHtml":"What time is it? – It''s + giờ. Giờ chẵn: It''s seven o''clock. Giờ rưỡi: It''s half past seven (7:30).",
    "vocabBlock":[
      {"word":"o''clock","ipa":"/əˈklɒk/","meaningVi":"giờ (chẵn)","example":"It''s nine o''clock."},
      {"word":"half past","ipa":"/hɑːf pɑːst/","meaningVi":"giờ rưỡi","example":"It''s half past six."}],
    "examples":[
      {"en":"What time is it? – It''s nine o''clock.","vi":"Mấy giờ rồi? – 9 giờ."},
      {"en":"It''s half past ten.","vi":"10 giờ rưỡi."}],
    "commonMistakes":["❌ \"What time is?\" → ✅ \"What time is it?\""],
    "tips":["o''clock dùng cho giờ chẵn; half past = giờ + 30 phút."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u05-l2-p1','a1-u05-l2','sentence_ordering',1,'practice','medium',false,'{"question":"Sắp xếp câu hỏi giờ:","tokens":["time","What","it","is"],"correctOrder":[1,0,3,2],"explanationVi":"What time is it?"}'::jsonb),
 ('a1-u05-l2-p2','a1-u05-l2','multiple_choice',2,'practice','easy',false,'{"question":"\"It''s seven ___.\"","options":[{"id":"a","text":"o''clock"},{"id":"b","text":"hour"},{"id":"c","text":"time"}],"correctOptionId":"a","explanationVi":"seven o''clock = 7 giờ."}'::jsonb),
 ('a1-u05-l2-p3','a1-u05-l2','multiple_choice',3,'practice','medium',false,'{"question":"\"half past six\" là mấy giờ?","options":[{"id":"a","text":"6:30"},{"id":"b","text":"6:00"},{"id":"c","text":"5:30"}],"correctOptionId":"a","explanationVi":"half past six = 6 giờ 30."}'::jsonb),
 ('a1-u05-l2-q1','a1-u05-l2','grammar_fill_blank',4,'quiz','medium',true,'{"question":"What ___ is it? (giờ)","acceptedAnswers":["time"],"explanationVi":"What time is it?"}'::jsonb),
 ('a1-u05-l2-q2','a1-u05-l2','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu hỏi giờ ĐÚNG:","options":[{"id":"a","text":"What time is?"},{"id":"b","text":"What time is it?"},{"id":"c","text":"What is time?"}],"correctOptionId":"b","explanationVi":"What time is it?"}'::jsonb),
 ('a1-u05-l2-q3','a1-u05-l2','sentence_ordering',6,'quiz','hard',true,'{"question":"Sắp xếp câu trả lời:","tokens":["nine","It''s","o''clock"],"correctOrder":[1,0,2],"explanationVi":"It''s nine o''clock."}'::jsonb),
 ('a1-u05-l2-q4','a1-u05-l2','multiple_choice',7,'quiz','medium',true,'{"question":"\"It''s half past six\" nghĩa là mấy giờ?","options":[{"id":"a","text":"6 giờ rưỡi"},{"id":"b","text":"6 giờ"},{"id":"c","text":"5 giờ rưỡi"}],"correctOptionId":"a","explanationVi":"half past six = 6 giờ 30."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u05-l3','A1','reading','a1-u05','normal',3,'How many...?','Hỏi số lượng',9,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao hỏi \"có bao nhiêu cái bàn?\"",
    "objectives":["Dùng How many + danh từ số nhiều","Trả lời số lượng với There is/are"],
    "grammarHtml":"How many + danh từ SỐ NHIỀU + are there? VD: How many books are there? – There are five. Lưu ý: How many dùng với đếm được; How much dùng với không đếm được.",
    "vocabBlock":[],
    "examples":[
      {"en":"How many students are there? – There are thirty.","vi":"Có bao nhiêu học sinh? – Ba mươi."},
      {"en":"How many apples do you have?","vi":"Bạn có bao nhiêu quả táo?"}],
    "commonMistakes":["❌ \"How many book\" → ✅ \"How many books\" (số nhiều)","❌ \"How much apples\" → ✅ \"How many apples\""],
    "tips":["How many + danh từ đếm được số nhiều."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u05-l3-p1','a1-u05-l3','multiple_choice',1,'practice','easy',false,'{"question":"\"___ books are there?\" (hỏi số lượng)","options":[{"id":"a","text":"How many"},{"id":"b","text":"How much"},{"id":"c","text":"How old"}],"correctOptionId":"a","explanationVi":"How many + đếm được."}'::jsonb),
 ('a1-u05-l3-p2','a1-u05-l3','grammar_fill_blank',2,'practice','medium',false,'{"question":"How many ___ are there? (book → số nhiều)","acceptedAnswers":["books"],"explanationVi":"How many + danh từ số nhiều."}'::jsonb),
 ('a1-u05-l3-p3','a1-u05-l3','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"How much apples are there?","acceptedAnswers":["How many apples are there?","How many apples are there"],"explanationVi":"apples đếm được → How many."}'::jsonb),
 ('a1-u05-l3-q1','a1-u05-l3','multiple_choice',4,'quiz','medium',true,'{"question":"Hỏi số lượng (đếm được) dùng:","options":[{"id":"a","text":"How many"},{"id":"b","text":"How much"},{"id":"c","text":"How long"}],"correctOptionId":"a","explanationVi":"How many + đếm được."}'::jsonb),
 ('a1-u05-l3-q2','a1-u05-l3','grammar_fill_blank',5,'quiz','medium',true,'{"question":"How many ___ are there? (student → số nhiều)","acceptedAnswers":["students"],"explanationVi":"How many students."}'::jsonb),
 ('a1-u05-l3-q3','a1-u05-l3','multiple_choice',6,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"How many chairs are there?"},{"id":"b","text":"How many chair are there?"},{"id":"c","text":"How much chairs are there?"}],"correctOptionId":"a","explanationVi":"How many + danh từ số nhiều."}'::jsonb),
 ('a1-u05-l3-q4','a1-u05-l3','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp câu hỏi:","tokens":["many","How","books","are","there"],"correctOrder":[1,0,2,3,4],"explanationVi":"How many books are there?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u05-l4','A1','listening','a1-u05','normal',4,'Days & listening','Ngày trong tuần & luyện nghe',10,15,70,'{}'::jsonb,
  '{"warmup":"Một tuần có mấy ngày? Kể tên bằng tiếng Anh.",
    "objectives":["Gọi tên các ngày trong tuần","Nghe và chọn số/giờ"],
    "grammarHtml":"Days: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday. Dùng on + thứ: on Monday.",
    "vocabBlock":[
      {"word":"Monday","ipa":"/ˈmʌndeɪ/","meaningVi":"thứ Hai","example":"I go to school on Monday."},
      {"word":"Sunday","ipa":"/ˈsʌndeɪ/","meaningVi":"Chủ nhật","example":"I rest on Sunday."},
      {"word":"week","ipa":"/wiːk/","meaningVi":"tuần","example":"There are seven days in a week."}],
    "examples":[
      {"en":"I have English on Monday.","vi":"Tôi học tiếng Anh vào thứ Hai."},
      {"en":"See you on Friday.","vi":"Hẹn gặp thứ Sáu."}],
    "commonMistakes":["❌ \"in Monday\" → ✅ \"on Monday\""],
    "tips":["Dùng on với thứ/ngày. Tên thứ viết hoa chữ cái đầu."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u05-l4-p1','a1-u05-l4','vocabulary_match',1,'practice','easy',false,'{"question":"Nối thứ với nghĩa:","pairs":[{"left":"Monday","right":"thứ Hai"},{"left":"Friday","right":"thứ Sáu"},{"left":"Sunday","right":"Chủ nhật"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u05-l4-p2','a1-u05-l4','grammar_fill_blank',2,'practice','medium',false,'{"question":"I go to school ___ Monday. (giới từ)","acceptedAnswers":["on"],"explanationVi":"on + thứ."}'::jsonb),
 ('a1-u05-l4-p3','a1-u05-l4','listening_choice',3,'practice','medium',false,'{"question":"Nghe và chọn số bạn nghe được:","audioText":"thirteen","options":[{"id":"a","text":"13"},{"id":"b","text":"30"},{"id":"c","text":"3"}],"correctOptionId":"a","explanationVi":"thirteen = 13."}'::jsonb),
 ('a1-u05-l4-q1','a1-u05-l4','listening_choice',4,'quiz','medium',true,'{"question":"Nghe và chọn giờ bạn nghe được:","audioText":"It is seven o''clock.","options":[{"id":"a","text":"7:00"},{"id":"b","text":"7:30"},{"id":"c","text":"6:00"}],"correctOptionId":"a","explanationVi":"seven o''clock = 7:00."}'::jsonb),
 ('a1-u05-l4-q2','a1-u05-l4','listening_choice',5,'quiz','hard',true,'{"question":"Nghe và chọn số:","audioText":"forty","options":[{"id":"a","text":"40"},{"id":"b","text":"14"},{"id":"c","text":"4"}],"correctOptionId":"a","explanationVi":"forty = 40."}'::jsonb),
 ('a1-u05-l4-q3','a1-u05-l4','multiple_choice',6,'quiz','easy',true,'{"question":"Một tuần có mấy ngày?","options":[{"id":"a","text":"seven"},{"id":"b","text":"five"},{"id":"c","text":"ten"}],"correctOptionId":"a","explanationVi":"7 ngày = seven days."}'::jsonb),
 ('a1-u05-l4-q4','a1-u05-l4','grammar_fill_blank',7,'quiz','medium',true,'{"question":"See you ___ Friday. (giới từ)","acceptedAnswers":["on"],"explanationVi":"on Friday."}'::jsonb);

-- ── UNIT 5 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u05-l5','A1','listening','a1-u05','unit_review',5,'Unit 5 Review','Ôn tập Unit 5: số, giờ, How many, ngày (có nghe)',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 5: số đếm, hỏi giờ, How many, ngày trong tuần.",
    "objectives":["Tổng hợp can-do Unit 5","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u05-l5-q1','a1-u05-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"ten\" là số mấy?","options":[{"id":"a","text":"10"},{"id":"b","text":"2"},{"id":"c","text":"100"}],"correctOptionId":"a","explanationVi":"ten = 10."}'::jsonb),
 ('a1-u05-l5-q2','a1-u05-l5','multiple_choice',2,'quiz','medium',true,'{"question":"\"35\" viết là:","options":[{"id":"a","text":"thirty-five"},{"id":"b","text":"thirteen-five"},{"id":"c","text":"three-five"}],"correctOptionId":"a","explanationVi":"35 = thirty-five."}'::jsonb),
 ('a1-u05-l5-q3','a1-u05-l5','grammar_fill_blank',3,'quiz','easy',true,'{"question":"What ___ is it? (giờ)","acceptedAnswers":["time"],"explanationVi":"What time is it?"}'::jsonb),
 ('a1-u05-l5-q4','a1-u05-l5','multiple_choice',4,'quiz','medium',true,'{"question":"\"half past six\" =","options":[{"id":"a","text":"6:30"},{"id":"b","text":"6:00"},{"id":"c","text":"7:30"}],"correctOptionId":"a","explanationVi":"6 giờ 30."}'::jsonb),
 ('a1-u05-l5-q5','a1-u05-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Hỏi số lượng (đếm được):","options":[{"id":"a","text":"How many"},{"id":"b","text":"How much"},{"id":"c","text":"How old"}],"correctOptionId":"a","explanationVi":"How many + đếm được."}'::jsonb),
 ('a1-u05-l5-q6','a1-u05-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"How many ___ are there? (chair → số nhiều)","acceptedAnswers":["chairs"],"explanationVi":"How many chairs."}'::jsonb),
 ('a1-u05-l5-q7','a1-u05-l5','vocabulary_match',7,'quiz','medium',true,'{"question":"Nối thứ với nghĩa:","pairs":[{"left":"Monday","right":"thứ Hai"},{"left":"Sunday","right":"Chủ nhật"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u05-l5-q8','a1-u05-l5','listening_choice',8,'quiz','hard',true,'{"question":"Nghe và chọn số:","audioText":"fifty","options":[{"id":"a","text":"50"},{"id":"b","text":"15"},{"id":"c","text":"5"}],"correctOptionId":"a","explanationVi":"fifty = 50."}'::jsonb),
 ('a1-u05-l5-q9','a1-u05-l5','grammar_fill_blank',9,'quiz','medium',true,'{"question":"I go to school ___ Monday. (giới từ)","acceptedAnswers":["on"],"explanationVi":"on Monday."}'::jsonb),
 ('a1-u05-l5-q10','a1-u05-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp câu trả lời giờ:","tokens":["o''clock","It''s","ten"],"correctOrder":[1,2,0],"explanationVi":"It''s ten o''clock."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 6 — This, That & My Things / Đồ vật của tôi                           ║
-- ║ Can-do: gọi tên đồ vật (this/that) · số nhiều · màu sắc · a/an/the         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u06-l1','A1','reading','a1-u06','normal',1,'This & That','this / that / these / those',8,15,70,'{}'::jsonb,
  '{"warmup":"Chỉ vào vật gần và vật xa — bạn nói gì?",
    "objectives":["Phân biệt this/that/these/those theo khoảng cách & số lượng"],
    "grammarHtml":"this (này – gần, số ít) · that (kia – xa, số ít) · these (những...này – gần, số nhiều) · those (những...kia – xa, số nhiều).",
    "vocabBlock":[
      {"word":"book","ipa":"/bʊk/","meaningVi":"quyển sách","example":"This is a book."},
      {"word":"pen","ipa":"/pen/","meaningVi":"cây bút","example":"That is a pen."},
      {"word":"chair","ipa":"/tʃeər/","meaningVi":"cái ghế","example":"These are chairs."}],
    "examples":[
      {"en":"This is my book. That is your pen.","vi":"Đây là sách của tôi. Kia là bút của bạn."},
      {"en":"These are my pens.","vi":"Đây là những cây bút của tôi."}],
    "commonMistakes":["❌ \"this are books\" → ✅ \"these are books\""],
    "tips":["this/that số ít; these/those số nhiều."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u06-l1-p1','a1-u06-l1','multiple_choice',1,'practice','easy',false,'{"question":"Vật ở GẦN, số ít: \"___ is a book.\"","options":[{"id":"a","text":"This"},{"id":"b","text":"These"},{"id":"c","text":"Those"}],"correctOptionId":"a","explanationVi":"this = này (gần, số ít)."}'::jsonb),
 ('a1-u06-l1-p2','a1-u06-l1','multiple_choice',2,'practice','medium',false,'{"question":"Vật ở XA, số nhiều: \"___ are pens.\"","options":[{"id":"a","text":"This"},{"id":"b","text":"That"},{"id":"c","text":"Those"}],"correctOptionId":"c","explanationVi":"those = những...kia."}'::jsonb),
 ('a1-u06-l1-p3','a1-u06-l1','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"This are books.","acceptedAnswers":["These are books.","These are books"],"explanationVi":"Số nhiều dùng these."}'::jsonb),
 ('a1-u06-l1-q1','a1-u06-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"this\" dùng cho:","options":[{"id":"a","text":"vật gần, số ít"},{"id":"b","text":"vật xa, số nhiều"},{"id":"c","text":"vật xa, số ít"}],"correctOptionId":"a","explanationVi":"this = gần, số ít."}'::jsonb),
 ('a1-u06-l1-q2','a1-u06-l1','multiple_choice',5,'quiz','medium',true,'{"question":"\"___ is a pen.\" (xa, số ít)","options":[{"id":"a","text":"That"},{"id":"b","text":"These"},{"id":"c","text":"Those"}],"correctOptionId":"a","explanationVi":"that = kia (xa, số ít)."}'::jsonb),
 ('a1-u06-l1-q3','a1-u06-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"___ are my books. (gần, số nhiều)","acceptedAnswers":["These","these"],"explanationVi":"these = những...này."}'::jsonb),
 ('a1-u06-l1-q4','a1-u06-l1','multiple_choice',7,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"Those is books."},{"id":"b","text":"Those are books."},{"id":"c","text":"That are books."}],"correctOptionId":"b","explanationVi":"those + are + danh từ số nhiều."}'::jsonb),
 ('a1-u06-l1-q5','a1-u06-l1','multiple_choice',8,'quiz','hard',true,'{"question":"\"Đây là cây bút\" dịch ĐÚNG là:","options":[{"id":"a","text":"This is a pen."},{"id":"b","text":"These is a pen."},{"id":"c","text":"This a pen."}],"correctOptionId":"a","explanationVi":"This is a pen."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u06-l2','A1','reading','a1-u06','normal',2,'Plural nouns','Danh từ số nhiều (-s/-es)',8,15,70,'{}'::jsonb,
  '{"warmup":"Một cuốn sách là book, hai cuốn là gì?",
    "objectives":["Tạo danh từ số nhiều (-s/-es)","Nhận biết số nhiều bất quy tắc"],
    "grammarHtml":"Thêm -s: book→books. Thêm -es sau s/x/ch/sh: box→boxes, watch→watches. Bất quy tắc: man→men, woman→women, child→children, foot→feet.",
    "vocabBlock":[],
    "examples":[
      {"en":"I have two books.","vi":"Tôi có hai cuốn sách."},
      {"en":"There are three boxes.","vi":"Có ba cái hộp."}],
    "commonMistakes":["❌ \"two book\" → ✅ \"two books\"","❌ \"childs\" → ✅ \"children\""],
    "tips":["Số nhiều thường thêm -s; sau s/x/ch/sh thêm -es."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u06-l2-p1','a1-u06-l2','grammar_fill_blank',1,'practice','easy',false,'{"question":"Số nhiều của \"book\":","acceptedAnswers":["books"],"explanationVi":"book → books."}'::jsonb),
 ('a1-u06-l2-p2','a1-u06-l2','grammar_fill_blank',2,'practice','medium',false,'{"question":"Số nhiều của \"box\":","acceptedAnswers":["boxes"],"explanationVi":"box → boxes (thêm -es)."}'::jsonb),
 ('a1-u06-l2-p3','a1-u06-l2','multiple_choice',3,'practice','medium',false,'{"question":"Số nhiều của \"man\":","options":[{"id":"a","text":"mans"},{"id":"b","text":"men"},{"id":"c","text":"mens"}],"correctOptionId":"b","explanationVi":"man → men (bất quy tắc)."}'::jsonb),
 ('a1-u06-l2-p4','a1-u06-l2','error_correction',4,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"I have two book.","acceptedAnswers":["I have two books.","I have two books"],"explanationVi":"two + books (số nhiều)."}'::jsonb),
 ('a1-u06-l2-q1','a1-u06-l2','grammar_fill_blank',5,'quiz','easy',true,'{"question":"Số nhiều của \"pen\":","acceptedAnswers":["pens"],"explanationVi":"pen → pens."}'::jsonb),
 ('a1-u06-l2-q2','a1-u06-l2','multiple_choice',6,'quiz','medium',true,'{"question":"Số nhiều của \"child\":","options":[{"id":"a","text":"childs"},{"id":"b","text":"children"},{"id":"c","text":"childes"}],"correctOptionId":"b","explanationVi":"child → children."}'::jsonb),
 ('a1-u06-l2-q3','a1-u06-l2','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Số nhiều của \"watch\":","acceptedAnswers":["watches"],"explanationVi":"watch → watches (thêm -es)."}'::jsonb),
 ('a1-u06-l2-q4','a1-u06-l2','multiple_choice',8,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"three boxes"},{"id":"b","text":"three box"},{"id":"c","text":"three boxs"}],"correctOptionId":"a","explanationVi":"box → boxes."}'::jsonb),
 ('a1-u06-l2-q5','a1-u06-l2','multiple_choice',9,'quiz','hard',true,'{"question":"\"Tôi có ba quyển sách\" dịch ĐÚNG là:","options":[{"id":"a","text":"I have three books."},{"id":"b","text":"I have three book."},{"id":"c","text":"I have three boxs."}],"correctOptionId":"a","explanationVi":"three + books (số nhiều)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u06-l3','A1','reading','a1-u06','normal',3,'Colours & objects','Màu sắc & đồ vật',8,15,70,'{}'::jsonb,
  '{"warmup":"Cái bút của bạn màu gì?",
    "objectives":["Gọi tên màu sắc","Mô tả đồ vật + màu (a red book)"],
    "grammarHtml":"Tính từ chỉ màu đứng TRƯỚC danh từ: a red book, a blue pen. Hỏi màu: What colour is it? – It''s red.",
    "vocabBlock":[
      {"word":"red","ipa":"/red/","meaningVi":"màu đỏ","example":"a red apple"},
      {"word":"blue","ipa":"/bluː/","meaningVi":"màu xanh dương","example":"a blue pen"},
      {"word":"green","ipa":"/ɡriːn/","meaningVi":"màu xanh lá","example":"a green book"},
      {"word":"yellow","ipa":"/ˈjeləʊ/","meaningVi":"màu vàng","example":"a yellow bag"},
      {"word":"black","ipa":"/blæk/","meaningVi":"màu đen","example":"a black chair"}],
    "examples":[
      {"en":"This is a red book.","vi":"Đây là quyển sách màu đỏ."},
      {"en":"What colour is it? – It''s blue.","vi":"Nó màu gì? – Màu xanh dương."}],
    "commonMistakes":["❌ \"a book red\" → ✅ \"a red book\" (màu đứng trước danh từ)"],
    "tips":["Màu sắc là tính từ → đứng trước danh từ."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u06-l3-p1','a1-u06-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối màu với nghĩa:","pairs":[{"left":"red","right":"đỏ"},{"left":"blue","right":"xanh dương"},{"left":"green","right":"xanh lá"},{"left":"yellow","right":"vàng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u06-l3-p2','a1-u06-l3','multiple_choice',2,'practice','easy',false,'{"question":"\"black\" nghĩa là màu:","options":[{"id":"a","text":"đen"},{"id":"b","text":"trắng"},{"id":"c","text":"đỏ"}],"correctOptionId":"a","explanationVi":"black = đen."}'::jsonb),
 ('a1-u06-l3-p3','a1-u06-l3','error_correction',3,'practice','hard',false,'{"question":"Sửa thứ tự: ","sourceText":"a book red","acceptedAnswers":["a red book"],"explanationVi":"Màu đứng trước danh từ: a red book."}'::jsonb),
 ('a1-u06-l3-q1','a1-u06-l3','multiple_choice',4,'quiz','easy',true,'{"question":"\"red\" là màu gì?","options":[{"id":"a","text":"đỏ"},{"id":"b","text":"xanh"},{"id":"c","text":"vàng"}],"correctOptionId":"a","explanationVi":"red = đỏ."}'::jsonb),
 ('a1-u06-l3-q2','a1-u06-l3','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn cụm ĐÚNG:","options":[{"id":"a","text":"a blue pen"},{"id":"b","text":"a pen blue"},{"id":"c","text":"blue a pen"}],"correctOptionId":"a","explanationVi":"a + màu + danh từ."}'::jsonb),
 ('a1-u06-l3-q3','a1-u06-l3','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối màu:","pairs":[{"left":"green","right":"xanh lá"},{"left":"black","right":"đen"},{"left":"yellow","right":"vàng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u06-l3-q4','a1-u06-l3','grammar_fill_blank',7,'quiz','medium',true,'{"question":"What ___ is it? – It''s red. (hỏi màu)","acceptedAnswers":["colour","color"],"explanationVi":"What colour is it?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u06-l4','A1','reading','a1-u06','normal',4,'A, an, the','Mạo từ a / an / the',9,15,70,'{}'::jsonb,
  '{"warmup":"\"a book\" và \"the book\" — khác nhau thế nào?",
    "objectives":["Dùng a/an khi nhắc lần đầu","Dùng the khi đã biết/đã nhắc"],
    "grammarHtml":"a/an: nhắc tới lần đầu, vật chung chung (a book, an apple). the: vật đã biết / đã nhắc / duy nhất (the book = quyển sách đó). a + phụ âm, an + nguyên âm.",
    "vocabBlock":[],
    "examples":[
      {"en":"I have a book. The book is red.","vi":"Tôi có một quyển sách. Quyển sách đó màu đỏ."},
      {"en":"She is an engineer.","vi":"Cô ấy là một kỹ sư."}],
    "commonMistakes":["❌ \"a apple\" → ✅ \"an apple\"","❌ \"the a book\" → ✅ \"a book\" hoặc \"the book\""],
    "tips":["Lần đầu dùng a/an, nhắc lại dùng the."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u06-l4-p1','a1-u06-l4','multiple_choice',1,'practice','easy',false,'{"question":"___ apple (a/an)","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"the"}],"correctOptionId":"b","explanationVi":"an apple (nguyên âm)."}'::jsonb),
 ('a1-u06-l4-p2','a1-u06-l4','multiple_choice',2,'practice','medium',false,'{"question":"\"I have a cat. ___ cat is black.\" (a/the)","options":[{"id":"a","text":"A"},{"id":"b","text":"The"},{"id":"c","text":"An"}],"correctOptionId":"b","explanationVi":"Nhắc lại → The cat."}'::jsonb),
 ('a1-u06-l4-p3','a1-u06-l4','grammar_fill_blank',3,'practice','medium',false,'{"question":"___ book (điền a — phụ âm)","acceptedAnswers":["a"],"explanationVi":"a book (phụ âm)."}'::jsonb),
 ('a1-u06-l4-q1','a1-u06-l4','multiple_choice',4,'quiz','easy',true,'{"question":"\"___ egg\" (a/an)","options":[{"id":"a","text":"a"},{"id":"b","text":"an"},{"id":"c","text":"the"}],"correctOptionId":"b","explanationVi":"an egg (nguyên âm)."}'::jsonb),
 ('a1-u06-l4-q2','a1-u06-l4','multiple_choice',5,'quiz','medium',true,'{"question":"Khi nhắc tới vật ĐÃ BIẾT, dùng:","options":[{"id":"a","text":"the"},{"id":"b","text":"a"},{"id":"c","text":"an"}],"correctOptionId":"a","explanationVi":"the = đã biết/đã nhắc."}'::jsonb),
 ('a1-u06-l4-q3','a1-u06-l4','grammar_fill_blank',6,'quiz','medium',true,'{"question":"She is ___ engineer. (a/an)","acceptedAnswers":["an"],"explanationVi":"an engineer (nguyên âm)."}'::jsonb),
 ('a1-u06-l4-q4','a1-u06-l4','multiple_choice',7,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I have a book. The book is new."},{"id":"b","text":"I have the book. A book is new."},{"id":"c","text":"I have an book."}],"correctOptionId":"a","explanationVi":"Lần đầu a, nhắc lại the."}'::jsonb);

-- ── UNIT 6 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u06-l5','A1','reading','a1-u06','unit_review',5,'Unit 6 Review','Ôn tập Unit 6: this/that, số nhiều, màu, mạo từ',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 6: this/that/these/those, số nhiều, màu sắc, a/an/the.",
    "objectives":["Tổng hợp can-do Unit 6","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u06-l5-q1','a1-u06-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"this\" dùng cho:","options":[{"id":"a","text":"vật gần, số ít"},{"id":"b","text":"vật xa, số nhiều"},{"id":"c","text":"vật xa, số ít"}],"correctOptionId":"a","explanationVi":"this = gần, số ít."}'::jsonb),
 ('a1-u06-l5-q2','a1-u06-l5','multiple_choice',2,'quiz','medium',true,'{"question":"\"___ are pens.\" (xa, số nhiều)","options":[{"id":"a","text":"Those"},{"id":"b","text":"This"},{"id":"c","text":"That"}],"correctOptionId":"a","explanationVi":"those = xa, số nhiều."}'::jsonb),
 ('a1-u06-l5-q3','a1-u06-l5','grammar_fill_blank',3,'quiz','easy',true,'{"question":"Số nhiều của \"book\":","acceptedAnswers":["books"],"explanationVi":"book → books."}'::jsonb),
 ('a1-u06-l5-q4','a1-u06-l5','multiple_choice',4,'quiz','medium',true,'{"question":"Số nhiều của \"box\":","options":[{"id":"a","text":"boxes"},{"id":"b","text":"boxs"},{"id":"c","text":"box"}],"correctOptionId":"a","explanationVi":"box → boxes."}'::jsonb),
 ('a1-u06-l5-q5','a1-u06-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Số nhiều của \"child\":","options":[{"id":"a","text":"children"},{"id":"b","text":"childs"},{"id":"c","text":"childes"}],"correctOptionId":"a","explanationVi":"child → children."}'::jsonb),
 ('a1-u06-l5-q6','a1-u06-l5','vocabulary_match',6,'quiz','easy',true,'{"question":"Nối màu:","pairs":[{"left":"red","right":"đỏ"},{"left":"blue","right":"xanh dương"},{"left":"black","right":"đen"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u06-l5-q7','a1-u06-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Chọn cụm ĐÚNG:","options":[{"id":"a","text":"a red book"},{"id":"b","text":"a book red"},{"id":"c","text":"red a book"}],"correctOptionId":"a","explanationVi":"a + màu + danh từ."}'::jsonb),
 ('a1-u06-l5-q8','a1-u06-l5','multiple_choice',8,'quiz','medium',true,'{"question":"\"___ apple\" (a/an)","options":[{"id":"a","text":"an"},{"id":"b","text":"a"},{"id":"c","text":"the"}],"correctOptionId":"a","explanationVi":"an apple."}'::jsonb),
 ('a1-u06-l5-q9','a1-u06-l5','multiple_choice',9,'quiz','hard',true,'{"question":"Vật đã nhắc tới rồi → dùng:","options":[{"id":"a","text":"the"},{"id":"b","text":"a"},{"id":"c","text":"an"}],"correctOptionId":"a","explanationVi":"the = đã biết."}'::jsonb),
 ('a1-u06-l5-q10','a1-u06-l5','multiple_choice',10,'quiz','hard',true,'{"question":"\"Đây là những cây bút\" dịch ĐÚNG là:","options":[{"id":"a","text":"These are pens."},{"id":"b","text":"This are pens."},{"id":"c","text":"These is pens."}],"correctOptionId":"a","explanationVi":"These are + danh từ số nhiều."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 7 — What Can You Do? / Bạn có thể làm gì?                             ║
-- ║ Can-do: nói khả năng (can/can't) · hỏi-đáp khả năng · sở thích · mệnh lệnh ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u07-l1','A1','reading','a1-u07','normal',1,'Can for ability','Diễn đạt khả năng với can',8,15,70,'{}'::jsonb,
  '{"warmup":"Bạn có thể làm gì giỏi?",
    "objectives":["Dùng can/can''t để nói khả năng"],
    "grammarHtml":"S + can + V(nguyên thể): I can swim. Phủ định: can''t (cannot): I can''t cook. KHÔNG có to sau can.",
    "vocabBlock":[
      {"word":"swim","ipa":"/swɪm/","meaningVi":"bơi","example":"I can swim."},
      {"word":"sing","ipa":"/sɪŋ/","meaningVi":"hát","example":"She can sing."},
      {"word":"cook","ipa":"/kʊk/","meaningVi":"nấu ăn","example":"He can cook."},
      {"word":"dance","ipa":"/dɑːns/","meaningVi":"nhảy/múa","example":"They can dance."}],
    "examples":[
      {"en":"I can swim but I can''t cook.","vi":"Tôi biết bơi nhưng không biết nấu ăn."},
      {"en":"She can sing very well.","vi":"Cô ấy hát rất hay."}],
    "commonMistakes":["❌ \"I can to swim\" → ✅ \"I can swim\" (không có to)"],
    "tips":["Sau can luôn là động từ nguyên thể, không có to."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u07-l1-p1','a1-u07-l1','multiple_choice',1,'practice','easy',false,'{"question":"I ___ swim. (có thể)","options":[{"id":"a","text":"can"},{"id":"b","text":"am"},{"id":"c","text":"do"}],"correctOptionId":"a","explanationVi":"can + V."}'::jsonb),
 ('a1-u07-l1-p2','a1-u07-l1','vocabulary_match',2,'practice','easy',false,'{"question":"Nối động từ:","pairs":[{"left":"swim","right":"bơi"},{"left":"sing","right":"hát"},{"left":"cook","right":"nấu ăn"},{"left":"dance","right":"nhảy"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l1-p3','a1-u07-l1','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"I can to swim.","acceptedAnswers":["I can swim.","I can swim"],"explanationVi":"Bỏ to sau can."}'::jsonb),
 ('a1-u07-l1-p4','a1-u07-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Phủ định: \"He ___ cook.\" (không thể, viết tắt)","acceptedAnswers":["can''t","cannot","cant"],"explanationVi":"can''t = cannot."}'::jsonb),
 ('a1-u07-l1-q1','a1-u07-l1','multiple_choice',5,'quiz','easy',true,'{"question":"Sau \"can\" là gì?","options":[{"id":"a","text":"động từ nguyên thể"},{"id":"b","text":"to + động từ"},{"id":"c","text":"động từ thêm s"}],"correctOptionId":"a","explanationVi":"can + V(nguyên thể)."}'::jsonb),
 ('a1-u07-l1-q2','a1-u07-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"She ___ sing very well. (có thể)","acceptedAnswers":["can"],"explanationVi":"can + V."}'::jsonb),
 ('a1-u07-l1-q3','a1-u07-l1','multiple_choice',7,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I can swim."},{"id":"b","text":"I can to swim."},{"id":"c","text":"I can swims."}],"correctOptionId":"a","explanationVi":"can + nguyên thể."}'::jsonb),
 ('a1-u07-l1-q4','a1-u07-l1','multiple_choice',8,'quiz','hard',true,'{"question":"\"Tôi biết nấu ăn\" dịch ĐÚNG là:","options":[{"id":"a","text":"I can cook."},{"id":"b","text":"I can to cook."},{"id":"c","text":"I can cooks."}],"correctOptionId":"a","explanationVi":"can + V nguyên thể."}'::jsonb),
 ('a1-u07-l1-q5','a1-u07-l1','multiple_choice',9,'quiz','medium',true,'{"question":"\"can''t\" là viết tắt của:","options":[{"id":"a","text":"cannot"},{"id":"b","text":"can to"},{"id":"c","text":"can not be"}],"correctOptionId":"a","explanationVi":"can''t = cannot."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u07-l2','A1','speaking','a1-u07','normal',2,'Can questions & answers','Hỏi-đáp về khả năng',8,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao hỏi ai đó có biết bơi không?",
    "objectives":["Đặt câu hỏi với can","Trả lời ngắn Yes, I can / No, I can''t"],
    "grammarHtml":"Can + S + V? → Yes, S can. / No, S can''t. VD: Can you cook? – Yes, I can. KHÔNG dùng do trong câu hỏi can.",
    "vocabBlock":[],
    "examples":[
      {"en":"Can you sing? – No, I can''t.","vi":"Bạn biết hát không? – Không."},
      {"en":"Can he swim? – Yes, he can.","vi":"Anh ấy biết bơi không? – Có."}],
    "commonMistakes":["❌ \"Do you can swim?\" → ✅ \"Can you swim?\""],
    "tips":["Câu hỏi can: đảo can lên đầu, không dùng do."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u07-l2-p1','a1-u07-l2','multiple_choice',1,'practice','easy',false,'{"question":"Câu hỏi ĐÚNG:","options":[{"id":"a","text":"Can you swim?"},{"id":"b","text":"Do you can swim?"},{"id":"c","text":"You can swim?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 ('a1-u07-l2-p2','a1-u07-l2','sentence_ordering',2,'practice','medium',false,'{"question":"Sắp xếp câu hỏi:","tokens":["you","Can","sing"],"correctOrder":[1,0,2],"explanationVi":"Can you sing?"}'::jsonb),
 ('a1-u07-l2-p3','a1-u07-l2','multiple_choice',3,'practice','medium',false,'{"question":"Trả lời \"Can you cook?\" (không):","options":[{"id":"a","text":"No, I can''t."},{"id":"b","text":"No, I don''t."},{"id":"c","text":"No, I am not."}],"correctOptionId":"a","explanationVi":"Trả lời can: No, I can''t."}'::jsonb),
 ('a1-u07-l2-p4','a1-u07-l2','error_correction',4,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"Do you can swim?","acceptedAnswers":["Can you swim?","Can you swim"],"explanationVi":"Câu hỏi can không dùng do."}'::jsonb),
 ('a1-u07-l2-q1','a1-u07-l2','multiple_choice',5,'quiz','easy',true,'{"question":"Chọn câu hỏi khả năng ĐÚNG:","options":[{"id":"a","text":"Can she dance?"},{"id":"b","text":"Does she can dance?"},{"id":"c","text":"She can dance?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 ('a1-u07-l2-q2','a1-u07-l2','multiple_choice',6,'quiz','medium',true,'{"question":"Trả lời ngắn cho \"Can you sing?\" (có):","options":[{"id":"a","text":"Yes, I can."},{"id":"b","text":"Yes, I do."},{"id":"c","text":"Yes, I am."}],"correctOptionId":"a","explanationVi":"Yes, I can."}'::jsonb),
 ('a1-u07-l2-q3','a1-u07-l2','sentence_ordering',7,'quiz','medium',true,'{"question":"Sắp xếp câu hỏi:","tokens":["cook","Can","he"],"correctOrder":[1,2,0],"explanationVi":"Can he cook?"}'::jsonb),
 ('a1-u07-l2-q4','a1-u07-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"\"___ you swim?\" (câu hỏi khả năng)","acceptedAnswers":["Can","can"],"explanationVi":"Can you swim?"}'::jsonb),
 ('a1-u07-l2-q5','a1-u07-l2','multiple_choice',9,'quiz','hard',true,'{"question":"Câu trả lời phủ định ĐÚNG:","options":[{"id":"a","text":"No, he can''t."},{"id":"b","text":"No, he doesn''t can."},{"id":"c","text":"No, he not can."}],"correctOptionId":"a","explanationVi":"No, he can''t."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u07-l3','A1','reading','a1-u07','normal',3,'Hobbies & free time','Sở thích & thời gian rảnh',8,15,70,'{}'::jsonb,
  '{"warmup":"Lúc rảnh bạn thích làm gì?",
    "objectives":["Gọi tên các sở thích phổ biến","Nói về sở thích với like + V-ing"],
    "grammarHtml":"Nói sở thích: I like + V-ing (I like reading) hoặc I like + N (I like music). Cụm: play football, listen to music, read books, watch TV.",
    "vocabBlock":[
      {"word":"play football","ipa":"/pleɪ ˈfʊtbɔːl/","meaningVi":"chơi bóng đá","example":"I play football on Sunday."},
      {"word":"listen to music","ipa":"/ˈlɪsn tə ˈmjuːzɪk/","meaningVi":"nghe nhạc","example":"She listens to music."},
      {"word":"read books","ipa":"/riːd bʊks/","meaningVi":"đọc sách","example":"I like reading books."},
      {"word":"watch TV","ipa":"/wɒtʃ ˌtiːˈviː/","meaningVi":"xem TV","example":"We watch TV at night."}],
    "examples":[
      {"en":"I like playing football.","vi":"Tôi thích chơi bóng đá."},
      {"en":"She likes listening to music.","vi":"Cô ấy thích nghe nhạc."}],
    "commonMistakes":["❌ \"I like play\" → ✅ \"I like playing\" (like + V-ing)"],
    "tips":["like + V-ing để nói sở thích chung."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u07-l3-p1','a1-u07-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối sở thích với nghĩa:","pairs":[{"left":"play football","right":"chơi bóng đá"},{"left":"listen to music","right":"nghe nhạc"},{"left":"read books","right":"đọc sách"},{"left":"watch TV","right":"xem TV"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l3-p2','a1-u07-l3','multiple_choice',2,'practice','medium',false,'{"question":"\"I like ___ football.\" (thích chơi)","options":[{"id":"a","text":"playing"},{"id":"b","text":"play"},{"id":"c","text":"plays"}],"correctOptionId":"a","explanationVi":"like + V-ing."}'::jsonb),
 ('a1-u07-l3-p3','a1-u07-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"I like ___ music. (listen → V-ing)","acceptedAnswers":["listening to","listening"],"explanationVi":"like listening to music."}'::jsonb),
 ('a1-u07-l3-q1','a1-u07-l3','multiple_choice',4,'quiz','easy',true,'{"question":"\"read books\" nghĩa là:","options":[{"id":"a","text":"đọc sách"},{"id":"b","text":"xem TV"},{"id":"c","text":"nghe nhạc"}],"correctOptionId":"a","explanationVi":"read books = đọc sách."}'::jsonb),
 ('a1-u07-l3-q2','a1-u07-l3','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"I like playing football."},{"id":"b","text":"I like play football."},{"id":"c","text":"I like plays football."}],"correctOptionId":"a","explanationVi":"like + V-ing."}'::jsonb),
 ('a1-u07-l3-q3','a1-u07-l3','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối sở thích:","pairs":[{"left":"watch TV","right":"xem TV"},{"left":"play football","right":"chơi bóng đá"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l3-q4','a1-u07-l3','multiple_choice',7,'quiz','hard',true,'{"question":"\"Tôi thích nghe nhạc\" dịch ĐÚNG là:","options":[{"id":"a","text":"I like listening to music."},{"id":"b","text":"I like listen to music."},{"id":"c","text":"I like to listening music."}],"correctOptionId":"a","explanationVi":"like + V-ing (listening to music)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u07-l4','A1','reading','a1-u07','normal',4,'Imperatives','Câu mệnh lệnh',9,15,70,'{}'::jsonb,
  '{"warmup":"Giáo viên nói \"Open the book!\" — đó là câu gì?",
    "objectives":["Hiểu & dùng câu mệnh lệnh","Mệnh lệnh phủ định Don''t..."],
    "grammarHtml":"Câu mệnh lệnh dùng động từ nguyên thể đứng đầu (không chủ ngữ): Open the book! Sit down! Phủ định: Don''t + V: Don''t run!",
    "vocabBlock":[
      {"word":"open","ipa":"/ˈəʊpən/","meaningVi":"mở","example":"Open the door."},
      {"word":"close","ipa":"/kləʊz/","meaningVi":"đóng","example":"Close the book."},
      {"word":"sit down","ipa":"/sɪt daʊn/","meaningVi":"ngồi xuống","example":"Sit down, please."},
      {"word":"stand up","ipa":"/stænd ʌp/","meaningVi":"đứng lên","example":"Stand up, please."}],
    "examples":[
      {"en":"Open your books, please.","vi":"Hãy mở sách ra."},
      {"en":"Don''t run in the classroom.","vi":"Đừng chạy trong lớp."}],
    "commonMistakes":["❌ \"You open the book\" (mệnh lệnh không cần chủ ngữ) → ✅ \"Open the book\""],
    "tips":["Mệnh lệnh: động từ nguyên thể đứng đầu; thêm please cho lịch sự."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u07-l4-p1','a1-u07-l4','vocabulary_match',1,'practice','easy',false,'{"question":"Nối mệnh lệnh với nghĩa:","pairs":[{"left":"open","right":"mở"},{"left":"close","right":"đóng"},{"left":"sit down","right":"ngồi xuống"},{"left":"stand up","right":"đứng lên"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l4-p2','a1-u07-l4','multiple_choice',2,'practice','medium',false,'{"question":"\"___ the door, please.\" (mở)","options":[{"id":"a","text":"Open"},{"id":"b","text":"You open"},{"id":"c","text":"Opening"}],"correctOptionId":"a","explanationVi":"Mệnh lệnh: Open + tân ngữ."}'::jsonb),
 ('a1-u07-l4-p3','a1-u07-l4','grammar_fill_blank',3,'practice','medium',false,'{"question":"Phủ định: \"___ run!\" (Đừng chạy)","acceptedAnswers":["Don''t","Do not","Dont"],"explanationVi":"Don''t + V."}'::jsonb),
 ('a1-u07-l4-q1','a1-u07-l4','multiple_choice',4,'quiz','easy',true,'{"question":"Câu mệnh lệnh ĐÚNG:","options":[{"id":"a","text":"Sit down, please."},{"id":"b","text":"You sit down please."},{"id":"c","text":"Sitting down."}],"correctOptionId":"a","explanationVi":"Mệnh lệnh: động từ đứng đầu."}'::jsonb),
 ('a1-u07-l4-q2','a1-u07-l4','sentence_ordering',5,'quiz','medium',true,'{"question":"Sắp xếp mệnh lệnh:","tokens":["the","Open","book"],"correctOrder":[1,0,2],"explanationVi":"Open the book."}'::jsonb),
 ('a1-u07-l4-q3','a1-u07-l4','multiple_choice',6,'quiz','medium',true,'{"question":"Mệnh lệnh phủ định ĐÚNG:","options":[{"id":"a","text":"Don''t run!"},{"id":"b","text":"No run!"},{"id":"c","text":"Not run!"}],"correctOptionId":"a","explanationVi":"Don''t + V."}'::jsonb),
 ('a1-u07-l4-q4','a1-u07-l4','grammar_fill_blank',7,'quiz','hard',true,'{"question":"\"___ up, please.\" (đứng lên)","acceptedAnswers":["Stand"],"explanationVi":"Stand up, please."}'::jsonb);

-- ── UNIT 7 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u07-l5','A1','reading','a1-u07','unit_review',5,'Unit 7 Review','Ôn tập Unit 7: can, hỏi-đáp, sở thích, mệnh lệnh',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 7: can/can''t, câu hỏi can, sở thích, câu mệnh lệnh.",
    "objectives":["Tổng hợp can-do Unit 7","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u07-l5-q1','a1-u07-l5','multiple_choice',1,'quiz','easy',true,'{"question":"I ___ swim. (có thể)","options":[{"id":"a","text":"can"},{"id":"b","text":"am"},{"id":"c","text":"do"}],"correctOptionId":"a","explanationVi":"can + V."}'::jsonb),
 ('a1-u07-l5-q2','a1-u07-l5','multiple_choice',2,'quiz','easy',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I can swim."},{"id":"b","text":"I can to swim."},{"id":"c","text":"I can swims."}],"correctOptionId":"a","explanationVi":"can + nguyên thể."}'::jsonb),
 ('a1-u07-l5-q3','a1-u07-l5','multiple_choice',3,'quiz','medium',true,'{"question":"Câu hỏi khả năng ĐÚNG:","options":[{"id":"a","text":"Can you sing?"},{"id":"b","text":"Do you can sing?"},{"id":"c","text":"You can sing?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 ('a1-u07-l5-q4','a1-u07-l5','multiple_choice',4,'quiz','medium',true,'{"question":"Trả lời \"Can you cook?\" (không):","options":[{"id":"a","text":"No, I can''t."},{"id":"b","text":"No, I don''t."},{"id":"c","text":"No, I am not."}],"correctOptionId":"a","explanationVi":"No, I can''t."}'::jsonb),
 ('a1-u07-l5-q5','a1-u07-l5','vocabulary_match',5,'quiz','easy',true,'{"question":"Nối sở thích:","pairs":[{"left":"play football","right":"chơi bóng đá"},{"left":"read books","right":"đọc sách"},{"left":"watch TV","right":"xem TV"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l5-q6','a1-u07-l5','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"I like playing football."},{"id":"b","text":"I like play football."},{"id":"c","text":"I like to playing football."}],"correctOptionId":"a","explanationVi":"like + V-ing."}'::jsonb),
 ('a1-u07-l5-q7','a1-u07-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Câu mệnh lệnh ĐÚNG:","options":[{"id":"a","text":"Open the book."},{"id":"b","text":"You open the book."},{"id":"c","text":"Opening the book."}],"correctOptionId":"a","explanationVi":"Mệnh lệnh: động từ đứng đầu."}'::jsonb),
 ('a1-u07-l5-q8','a1-u07-l5','multiple_choice',8,'quiz','medium',true,'{"question":"Mệnh lệnh phủ định:","options":[{"id":"a","text":"Don''t run!"},{"id":"b","text":"No run!"},{"id":"c","text":"Not run!"}],"correctOptionId":"a","explanationVi":"Don''t + V."}'::jsonb),
 ('a1-u07-l5-q9','a1-u07-l5','grammar_fill_blank',9,'quiz','hard',true,'{"question":"She ___ sing well. (có thể)","acceptedAnswers":["can"],"explanationVi":"can + V."}'::jsonb),
 ('a1-u07-l5-q10','a1-u07-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp câu hỏi:","tokens":["you","Can","cook"],"correctOrder":[1,0,2],"explanationVi":"Can you cook?"}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 8 — Places & Directions / Nơi chốn & chỉ đường                        ║
-- ║ Can-do: gọi tên địa điểm · giới từ nơi chốn · hỏi-đáp đường đi             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u08-l1','A1','reading','a1-u08','normal',1,'Places in town','Địa điểm trong thị trấn',8,15,70,'{}'::jsonb,
  '{"warmup":"Gần nhà bạn có những nơi nào?",
    "objectives":["Gọi tên địa điểm phổ biến","Dùng There is + địa điểm"],
    "grammarHtml":"There is + danh từ số ít: There is a school. go home (không to). go to + nơi: go to school.",
    "vocabBlock":[
      {"word":"school","ipa":"/skuːl/","meaningVi":"trường học","example":"I go to school."},
      {"word":"hospital","ipa":"/ˈhɒspɪtl/","meaningVi":"bệnh viện","example":"The hospital is big."},
      {"word":"market","ipa":"/ˈmɑːkɪt/","meaningVi":"chợ","example":"My mother goes to the market."},
      {"word":"park","ipa":"/pɑːk/","meaningVi":"công viên","example":"We play in the park."},
      {"word":"bank","ipa":"/bæŋk/","meaningVi":"ngân hàng","example":"The bank is near here."}],
    "examples":[
      {"en":"There is a school near my house.","vi":"Có một trường học gần nhà tôi."},
      {"en":"The park is next to the school.","vi":"Công viên ở cạnh trường học."}],
    "commonMistakes":["❌ \"go to home\" → ✅ \"go home\" (home không cần to)"],
    "tips":["There is + danh từ số ít để nói có cái gì đó."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u08-l1-p1','a1-u08-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối địa điểm:","pairs":[{"left":"school","right":"trường học"},{"left":"hospital","right":"bệnh viện"},{"left":"market","right":"chợ"},{"left":"park","right":"công viên"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l1-p2','a1-u08-l1','multiple_choice',2,'practice','easy',false,'{"question":"Nơi để khám bệnh là:","options":[{"id":"a","text":"hospital"},{"id":"b","text":"park"},{"id":"c","text":"market"}],"correctOptionId":"a","explanationVi":"hospital = bệnh viện."}'::jsonb),
 ('a1-u08-l1-p3','a1-u08-l1','grammar_fill_blank',3,'practice','medium',false,'{"question":"There ___ a school near my house. (to be số ít)","acceptedAnswers":["is"],"explanationVi":"There is + danh từ số ít."}'::jsonb),
 ('a1-u08-l1-p4','a1-u08-l1','error_correction',4,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"I go to home.","acceptedAnswers":["I go home.","I go home"],"explanationVi":"go home (không có to)."}'::jsonb),
 ('a1-u08-l1-q1','a1-u08-l1','multiple_choice',5,'quiz','easy',true,'{"question":"\"market\" nghĩa là gì?","options":[{"id":"a","text":"chợ"},{"id":"b","text":"công viên"},{"id":"c","text":"trường"}],"correctOptionId":"a","explanationVi":"market = chợ."}'::jsonb),
 ('a1-u08-l1-q2','a1-u08-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"There ___ a park near here. (to be)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u08-l1-q3','a1-u08-l1','multiple_choice',7,'quiz','medium',true,'{"question":"Nơi để gửi tiền:","options":[{"id":"a","text":"bank"},{"id":"b","text":"market"},{"id":"c","text":"park"}],"correctOptionId":"a","explanationVi":"bank = ngân hàng."}'::jsonb),
 ('a1-u08-l1-q4','a1-u08-l1','multiple_choice',8,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I go home."},{"id":"b","text":"I go to home."},{"id":"c","text":"I go at home."}],"correctOptionId":"a","explanationVi":"go home."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u08-l2','A1','reading','a1-u08','normal',2,'Prepositions of place','Giới từ nơi chốn (in/on/under/next to)',8,15,70,'{}'::jsonb,
  '{"warmup":"Cái bút ở đâu? Trên bàn hay dưới bàn?",
    "objectives":["Dùng in/on/under/next to để nói vị trí"],
    "grammarHtml":"in (trong) · on (trên bề mặt) · under (dưới) · next to (cạnh) · behind (sau) · in front of (trước). VD: The book is on the table.",
    "vocabBlock":[
      {"word":"in","ipa":"/ɪn/","meaningVi":"trong","example":"The pen is in the box."},
      {"word":"on","ipa":"/ɒn/","meaningVi":"trên","example":"The book is on the table."},
      {"word":"under","ipa":"/ˈʌndər/","meaningVi":"dưới","example":"The cat is under the chair."},
      {"word":"next to","ipa":"/nekst tu/","meaningVi":"cạnh","example":"The bank is next to the park."}],
    "examples":[
      {"en":"The cat is under the chair.","vi":"Con mèo ở dưới ghế."},
      {"en":"The bag is on the table.","vi":"Cái túi ở trên bàn."}],
    "commonMistakes":["❌ \"in the table\" (khi ý là trên) → ✅ \"on the table\""],
    "tips":["on = trên bề mặt; in = bên trong."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u08-l2-p1','a1-u08-l2','multiple_choice',1,'practice','easy',false,'{"question":"The book is ___ the table. (trên)","options":[{"id":"a","text":"on"},{"id":"b","text":"in"},{"id":"c","text":"under"}],"correctOptionId":"a","explanationVi":"on = trên bề mặt."}'::jsonb),
 ('a1-u08-l2-p2','a1-u08-l2','multiple_choice',2,'practice','medium',false,'{"question":"The cat is ___ the chair. (dưới)","options":[{"id":"a","text":"on"},{"id":"b","text":"under"},{"id":"c","text":"next to"}],"correctOptionId":"b","explanationVi":"under = dưới."}'::jsonb),
 ('a1-u08-l2-p3','a1-u08-l2','vocabulary_match',3,'practice','medium',false,'{"question":"Nối giới từ với nghĩa:","pairs":[{"left":"in","right":"trong"},{"left":"on","right":"trên"},{"left":"under","right":"dưới"},{"left":"next to","right":"cạnh"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l2-p4','a1-u08-l2','grammar_fill_blank',4,'practice','hard',false,'{"question":"The pen is ___ the box. (bên trong)","acceptedAnswers":["in"],"explanationVi":"in = bên trong."}'::jsonb),
 ('a1-u08-l2-q1','a1-u08-l2','multiple_choice',5,'quiz','easy',true,'{"question":"\"on\" nghĩa là gì?","options":[{"id":"a","text":"trên (bề mặt)"},{"id":"b","text":"dưới"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"on = trên bề mặt."}'::jsonb),
 ('a1-u08-l2-q2','a1-u08-l2','multiple_choice',6,'quiz','medium',true,'{"question":"The ball is ___ the box. (bên trong)","options":[{"id":"a","text":"in"},{"id":"b","text":"on"},{"id":"c","text":"under"}],"correctOptionId":"a","explanationVi":"in = trong."}'::jsonb),
 ('a1-u08-l2-q3','a1-u08-l2','grammar_fill_blank',7,'quiz','medium',true,'{"question":"The lamp is ___ the table. (trên)","acceptedAnswers":["on"],"explanationVi":"on = trên."}'::jsonb),
 ('a1-u08-l2-q4','a1-u08-l2','multiple_choice',8,'quiz','hard',true,'{"question":"\"next to\" nghĩa là gì?","options":[{"id":"a","text":"cạnh"},{"id":"b","text":"dưới"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"next to = bên cạnh."}'::jsonb),
 ('a1-u08-l2-q5','a1-u08-l2','multiple_choice',9,'quiz','hard',true,'{"question":"Sách nằm TRÊN bàn — câu nào ĐÚNG?","options":[{"id":"a","text":"The book is on the table."},{"id":"b","text":"The book is in the table."},{"id":"c","text":"The book is under the table."}],"correctOptionId":"a","explanationVi":"Trên bề mặt → on."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u08-l3','A1','reading','a1-u08','normal',3,'Asking directions','Hỏi đường (Turn left/right)',9,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao hỏi đường đến bưu điện?",
    "objectives":["Hỏi đường: Where is...?","Chỉ đường: Turn left/right, Go straight"],
    "grammarHtml":"Hỏi: Where is the + nơi? / Excuse me, how do I get to...? Chỉ đường (mệnh lệnh): Turn left. Turn right. Go straight. It''s on your left.",
    "vocabBlock":[
      {"word":"turn left","ipa":"/tɜːn left/","meaningVi":"rẽ trái","example":"Turn left at the bank."},
      {"word":"turn right","ipa":"/tɜːn raɪt/","meaningVi":"rẽ phải","example":"Turn right here."},
      {"word":"go straight","ipa":"/ɡəʊ streɪt/","meaningVi":"đi thẳng","example":"Go straight ahead."}],
    "examples":[
      {"en":"Where is the post office? – Go straight and turn left.","vi":"Bưu điện ở đâu? – Đi thẳng rồi rẽ trái."},
      {"en":"Turn right at the school.","vi":"Rẽ phải ở chỗ trường học."}],
    "commonMistakes":["❌ \"Turn to left\" → ✅ \"Turn left\""],
    "tips":["Chỉ đường dùng câu mệnh lệnh: Turn / Go."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u08-l3-p1','a1-u08-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối chỉ dẫn với nghĩa:","pairs":[{"left":"turn left","right":"rẽ trái"},{"left":"turn right","right":"rẽ phải"},{"left":"go straight","right":"đi thẳng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l3-p2','a1-u08-l3','multiple_choice',2,'practice','medium',false,'{"question":"\"Rẽ trái\" =","options":[{"id":"a","text":"Turn left"},{"id":"b","text":"Turn right"},{"id":"c","text":"Go straight"}],"correctOptionId":"a","explanationVi":"turn left = rẽ trái."}'::jsonb),
 ('a1-u08-l3-p3','a1-u08-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"___ is the bank? (hỏi nơi chốn)","acceptedAnswers":["Where"],"explanationVi":"Where is the bank?"}'::jsonb),
 ('a1-u08-l3-q1','a1-u08-l3','multiple_choice',4,'quiz','easy',true,'{"question":"\"go straight\" nghĩa là:","options":[{"id":"a","text":"đi thẳng"},{"id":"b","text":"rẽ trái"},{"id":"c","text":"rẽ phải"}],"correctOptionId":"a","explanationVi":"go straight = đi thẳng."}'::jsonb),
 ('a1-u08-l3-q2','a1-u08-l3','sentence_ordering',5,'quiz','medium',true,'{"question":"Sắp xếp chỉ dẫn:","tokens":["left","Turn","the bank","at"],"correctOrder":[1,0,3,2],"explanationVi":"Turn left at the bank."}'::jsonb),
 ('a1-u08-l3-q3','a1-u08-l3','multiple_choice',6,'quiz','medium',true,'{"question":"Hỏi đường ĐÚNG:","options":[{"id":"a","text":"Where is the school?"},{"id":"b","text":"Where the school is?"},{"id":"c","text":"Where school?"}],"correctOptionId":"a","explanationVi":"Where is the + nơi?"}'::jsonb),
 ('a1-u08-l3-q4','a1-u08-l3','multiple_choice',7,'quiz','hard',true,'{"question":"\"Rẽ phải ở đây\" dịch ĐÚNG là:","options":[{"id":"a","text":"Turn right here."},{"id":"b","text":"Turn to right here."},{"id":"c","text":"Right turn here."}],"correctOptionId":"a","explanationVi":"Turn right (không có to)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u08-l4','A1','reading','a1-u08','normal',4,'My neighbourhood','Đọc về khu phố',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn dưới về khu phố của Tom rồi trả lời.",
    "objectives":["Đọc hiểu đoạn mô tả nơi chốn (There is/are + giới từ)"],
    "grammarHtml":"Đoạn dùng There is/are + giới từ nơi chốn (next to, near, in front of) để mô tả khu phố.",
    "vocabBlock":[
      {"word":"near","ipa":"/nɪər/","meaningVi":"gần","example":"The shop is near my house."},
      {"word":"in front of","ipa":"/ɪn frʌnt əv/","meaningVi":"phía trước","example":"There is a tree in front of the house."}],
    "examples":[
      {"en":"There is a park near my house. The school is next to the park. In front of the school there is a shop.","vi":"Có một công viên gần nhà tôi. Trường học ở cạnh công viên. Trước trường có một cửa hàng."}],
    "commonMistakes":["❌ \"There is two shops\" → ✅ \"There are two shops\""],
    "tips":["Đọc kỹ vị trí: near → next to → in front of."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u08-l4-p1','a1-u08-l4','multiple_choice',1,'practice','easy',false,'{"question":"Đọc: \"There is a park near my house.\" → Gần nhà có gì?","options":[{"id":"a","text":"công viên"},{"id":"b","text":"bệnh viện"},{"id":"c","text":"chợ"}],"correctOptionId":"a","explanationVi":"a park near my house."}'::jsonb),
 ('a1-u08-l4-p2','a1-u08-l4','vocabulary_match',2,'practice','medium',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"near","right":"gần"},{"left":"next to","right":"cạnh"},{"left":"in front of","right":"phía trước"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l4-q1','a1-u08-l4','multiple_choice',3,'quiz','medium',true,'{"question":"Theo đoạn: Trường học ở đâu?","options":[{"id":"a","text":"cạnh công viên"},{"id":"b","text":"trong công viên"},{"id":"c","text":"xa công viên"}],"correctOptionId":"a","explanationVi":"The school is next to the park."}'::jsonb),
 ('a1-u08-l4-q2','a1-u08-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Trước trường học có gì?","options":[{"id":"a","text":"một cửa hàng"},{"id":"b","text":"một bệnh viện"},{"id":"c","text":"một ngân hàng"}],"correctOptionId":"a","explanationVi":"In front of the school there is a shop."}'::jsonb),
 ('a1-u08-l4-q3','a1-u08-l4','grammar_fill_blank',5,'quiz','medium',true,'{"question":"There ___ two shops. (to be, số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u08-l4-q4','a1-u08-l4','multiple_choice',6,'quiz','hard',true,'{"question":"\"in front of\" nghĩa là:","options":[{"id":"a","text":"phía trước"},{"id":"b","text":"phía sau"},{"id":"c","text":"bên cạnh"}],"correctOptionId":"a","explanationVi":"in front of = phía trước."}'::jsonb);

-- ── UNIT 8 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u08-l5','A1','reading','a1-u08','unit_review',5,'Unit 8 Review','Ôn tập Unit 8: địa điểm, giới từ, chỉ đường',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 8: địa điểm, giới từ nơi chốn, hỏi & chỉ đường.",
    "objectives":["Tổng hợp can-do Unit 8","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u08-l5-q1','a1-u08-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"hospital\" nghĩa là:","options":[{"id":"a","text":"bệnh viện"},{"id":"b","text":"chợ"},{"id":"c","text":"công viên"}],"correctOptionId":"a","explanationVi":"hospital = bệnh viện."}'::jsonb),
 ('a1-u08-l5-q2','a1-u08-l5','vocabulary_match',2,'quiz','easy',true,'{"question":"Nối địa điểm:","pairs":[{"left":"market","right":"chợ"},{"left":"park","right":"công viên"},{"left":"bank","right":"ngân hàng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l5-q3','a1-u08-l5','multiple_choice',3,'quiz','easy',true,'{"question":"\"on\" nghĩa là:","options":[{"id":"a","text":"trên (bề mặt)"},{"id":"b","text":"dưới"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"on = trên."}'::jsonb),
 ('a1-u08-l5-q4','a1-u08-l5','multiple_choice',4,'quiz','medium',true,'{"question":"The cat is ___ the chair. (dưới)","options":[{"id":"a","text":"under"},{"id":"b","text":"on"},{"id":"c","text":"in"}],"correctOptionId":"a","explanationVi":"under = dưới."}'::jsonb),
 ('a1-u08-l5-q5','a1-u08-l5','grammar_fill_blank',5,'quiz','medium',true,'{"question":"There ___ a school near here. (to be số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u08-l5-q6','a1-u08-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối chỉ dẫn:","pairs":[{"left":"turn left","right":"rẽ trái"},{"left":"turn right","right":"rẽ phải"},{"left":"go straight","right":"đi thẳng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l5-q7','a1-u08-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Hỏi đường ĐÚNG:","options":[{"id":"a","text":"Where is the bank?"},{"id":"b","text":"Where the bank is?"},{"id":"c","text":"Where bank?"}],"correctOptionId":"a","explanationVi":"Where is the + nơi?"}'::jsonb),
 ('a1-u08-l5-q8','a1-u08-l5','multiple_choice',8,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I go home."},{"id":"b","text":"I go to home."},{"id":"c","text":"I go at home."}],"correctOptionId":"a","explanationVi":"go home (không to)."}'::jsonb),
 ('a1-u08-l5-q9','a1-u08-l5','sentence_ordering',9,'quiz','hard',true,'{"question":"Sắp xếp chỉ dẫn:","tokens":["right","Turn","here"],"correctOrder":[1,0,2],"explanationVi":"Turn right here."}'::jsonb),
 ('a1-u08-l5-q10','a1-u08-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"There ___ two parks. (to be, số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 9 — My Home & Where I Live / Nhà & nơi tôi sống                       ║
-- ║ Can-do: mô tả nơi ở · gọi tên phòng & đồ đạc · nói có gì trong nhà         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u09-l1','A1','reading','a1-u09','normal',1,'Rooms in a house','Các phòng trong nhà',8,15,70,'{}'::jsonb,
  '{"warmup":"Nhà bạn có những phòng nào?",
    "objectives":["Gọi tên các phòng trong nhà"],
    "vocabBlock":[
      {"word":"bedroom","ipa":"/ˈbedruːm/","meaningVi":"phòng ngủ","example":"My bedroom is small."},
      {"word":"kitchen","ipa":"/ˈkɪtʃɪn/","meaningVi":"nhà bếp","example":"Mum is in the kitchen."},
      {"word":"bathroom","ipa":"/ˈbɑːθruːm/","meaningVi":"phòng tắm","example":"The bathroom is upstairs."},
      {"word":"living room","ipa":"/ˈlɪvɪŋ ruːm/","meaningVi":"phòng khách","example":"We watch TV in the living room."}],
    "examples":[
      {"en":"My house has three rooms.","vi":"Nhà tôi có ba phòng."},
      {"en":"The kitchen is next to the living room.","vi":"Nhà bếp ở cạnh phòng khách."}],
    "commonMistakes":["❌ \"sleep room\" → ✅ \"bedroom\""],
    "tips":["bedroom = phòng ngủ; living room = phòng khách."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u09-l1-p1','a1-u09-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối phòng với nghĩa:","pairs":[{"left":"bedroom","right":"phòng ngủ"},{"left":"kitchen","right":"nhà bếp"},{"left":"bathroom","right":"phòng tắm"},{"left":"living room","right":"phòng khách"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l1-p2','a1-u09-l1','multiple_choice',2,'practice','easy',false,'{"question":"Nơi nấu ăn là:","options":[{"id":"a","text":"kitchen"},{"id":"b","text":"bedroom"},{"id":"c","text":"bathroom"}],"correctOptionId":"a","explanationVi":"kitchen = nhà bếp."}'::jsonb),
 ('a1-u09-l1-p3','a1-u09-l1','grammar_fill_blank',3,'practice','medium',false,'{"question":"I sleep in my ___. (phòng ngủ)","acceptedAnswers":["bedroom"],"explanationVi":"bedroom = phòng ngủ."}'::jsonb),
 ('a1-u09-l1-q1','a1-u09-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"kitchen\" nghĩa là:","options":[{"id":"a","text":"nhà bếp"},{"id":"b","text":"phòng ngủ"},{"id":"c","text":"phòng tắm"}],"correctOptionId":"a","explanationVi":"kitchen = nhà bếp."}'::jsonb),
 ('a1-u09-l1-q2','a1-u09-l1','multiple_choice',5,'quiz','medium',true,'{"question":"Xem TV ở phòng nào?","options":[{"id":"a","text":"living room"},{"id":"b","text":"bathroom"},{"id":"c","text":"kitchen"}],"correctOptionId":"a","explanationVi":"living room = phòng khách."}'::jsonb),
 ('a1-u09-l1-q3','a1-u09-l1','grammar_fill_blank',6,'quiz','medium',true,'{"question":"I take a shower in the ___. (phòng tắm)","acceptedAnswers":["bathroom"],"explanationVi":"bathroom = phòng tắm."}'::jsonb),
 ('a1-u09-l1-q4','a1-u09-l1','vocabulary_match',7,'quiz','hard',true,'{"question":"Nối phòng:","pairs":[{"left":"bedroom","right":"phòng ngủ"},{"left":"living room","right":"phòng khách"}],"explanationVi":"Ghép đúng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u09-l2','A1','reading','a1-u09','normal',2,'Furniture & things','Đồ đạc trong nhà',8,15,70,'{}'::jsonb,
  '{"warmup":"Trong phòng ngủ của bạn có những đồ gì?",
    "objectives":["Gọi tên đồ đạc trong nhà"],
    "vocabBlock":[
      {"word":"bed","ipa":"/bed/","meaningVi":"giường","example":"There is a bed in my room."},
      {"word":"table","ipa":"/ˈteɪbl/","meaningVi":"cái bàn","example":"The book is on the table."},
      {"word":"sofa","ipa":"/ˈsəʊfə/","meaningVi":"ghế sofa","example":"The sofa is in the living room."},
      {"word":"fridge","ipa":"/frɪdʒ/","meaningVi":"tủ lạnh","example":"The fridge is in the kitchen."},
      {"word":"TV","ipa":"/ˌtiːˈviː/","meaningVi":"tivi","example":"We have a big TV."}],
    "examples":[
      {"en":"There is a bed and a table in my bedroom.","vi":"Có một cái giường và một cái bàn trong phòng ngủ của tôi."}],
    "commonMistakes":["❌ \"ice box\" → ✅ \"fridge\" (tủ lạnh)"],
    "tips":["fridge để trong kitchen; sofa để trong living room."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u09-l2-p1','a1-u09-l2','vocabulary_match',1,'practice','easy',false,'{"question":"Nối đồ đạc với nghĩa:","pairs":[{"left":"bed","right":"giường"},{"left":"table","right":"cái bàn"},{"left":"sofa","right":"ghế sofa"},{"left":"fridge","right":"tủ lạnh"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l2-p2','a1-u09-l2','multiple_choice',2,'practice','easy',false,'{"question":"Đồ để ngủ là:","options":[{"id":"a","text":"bed"},{"id":"b","text":"table"},{"id":"c","text":"fridge"}],"correctOptionId":"a","explanationVi":"bed = giường."}'::jsonb),
 ('a1-u09-l2-p3','a1-u09-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"The food is in the ___. (tủ lạnh)","acceptedAnswers":["fridge"],"explanationVi":"fridge = tủ lạnh."}'::jsonb),
 ('a1-u09-l2-q1','a1-u09-l2','multiple_choice',4,'quiz','easy',true,'{"question":"\"sofa\" nghĩa là:","options":[{"id":"a","text":"ghế sofa"},{"id":"b","text":"giường"},{"id":"c","text":"bàn"}],"correctOptionId":"a","explanationVi":"sofa = ghế sofa."}'::jsonb),
 ('a1-u09-l2-q2','a1-u09-l2','multiple_choice',5,'quiz','medium',true,'{"question":"Tủ lạnh để ở phòng nào?","options":[{"id":"a","text":"kitchen"},{"id":"b","text":"bedroom"},{"id":"c","text":"bathroom"}],"correctOptionId":"a","explanationVi":"fridge ở kitchen."}'::jsonb),
 ('a1-u09-l2-q3','a1-u09-l2','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối đồ đạc:","pairs":[{"left":"TV","right":"tivi"},{"left":"table","right":"cái bàn"},{"left":"bed","right":"giường"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l2-q4','a1-u09-l2','grammar_fill_blank',7,'quiz','hard',true,'{"question":"I sleep on the ___. (giường)","acceptedAnswers":["bed"],"explanationVi":"bed = giường."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u09-l3','A1','reading','a1-u09','normal',3,'There is / There are','Có gì trong nhà',9,15,70,'{}'::jsonb,
  '{"warmup":"\"Có một cái giường\" và \"có hai cái ghế\" — nói thế nào?",
    "objectives":["Dùng There is + số ít / There are + số nhiều","Phủ định There isn''t / There aren''t"],
    "grammarHtml":"There is + danh từ số ít (There is a bed). There are + danh từ số nhiều (There are two chairs). Phủ định: There isn''t / There aren''t. Câu hỏi: Is there...? Are there...?",
    "vocabBlock":[],
    "examples":[
      {"en":"There is a sofa in the living room.","vi":"Có một ghế sofa trong phòng khách."},
      {"en":"There are two beds in the bedroom.","vi":"Có hai cái giường trong phòng ngủ."}],
    "commonMistakes":["❌ \"There is two chairs\" → ✅ \"There are two chairs\""],
    "tips":["is + số ít, are + số nhiều."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u09-l3-p1','a1-u09-l3','multiple_choice',1,'practice','easy',false,'{"question":"There ___ a bed. (số ít)","options":[{"id":"a","text":"is"},{"id":"b","text":"are"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u09-l3-p2','a1-u09-l3','multiple_choice',2,'practice','medium',false,'{"question":"There ___ two chairs. (số nhiều)","options":[{"id":"a","text":"is"},{"id":"b","text":"are"},{"id":"c","text":"be"}],"correctOptionId":"b","explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l3-p3','a1-u09-l3','error_correction',3,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"There is two tables.","acceptedAnswers":["There are two tables.","There are two tables"],"explanationVi":"số nhiều → There are."}'::jsonb),
 ('a1-u09-l3-q1','a1-u09-l3','grammar_fill_blank',4,'quiz','easy',true,'{"question":"There ___ a sofa in the room. (số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u09-l3-q2','a1-u09-l3','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"There are three beds."},{"id":"b","text":"There is three beds."},{"id":"c","text":"There be three beds."}],"correctOptionId":"a","explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l3-q3','a1-u09-l3','grammar_fill_blank',6,'quiz','medium',true,'{"question":"There ___ four chairs. (số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l3-q4','a1-u09-l3','multiple_choice',7,'quiz','hard',true,'{"question":"Phủ định ĐÚNG (không có giường):","options":[{"id":"a","text":"There isn''t a bed."},{"id":"b","text":"There aren''t a bed."},{"id":"c","text":"There not a bed."}],"correctOptionId":"a","explanationVi":"số ít → There isn''t."}'::jsonb),
 ('a1-u09-l3-q5','a1-u09-l3','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["a","There","sofa","is"],"correctOrder":[1,3,0,2],"explanationVi":"There is a sofa."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u09-l4','A1','reading','a1-u09','normal',4,'Where I live','Đọc về nơi tôi sống',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn dưới về nhà của Mai rồi trả lời.",
    "objectives":["Đọc hiểu đoạn mô tả nhà (rooms + furniture + there is/are)"],
    "grammarHtml":"Đoạn dùng There is/are + đồ đạc + giới từ để mô tả ngôi nhà.",
    "vocabBlock":[
      {"word":"small","ipa":"/smɔːl/","meaningVi":"nhỏ","example":"My house is small."},
      {"word":"big","ipa":"/bɪɡ/","meaningVi":"to/lớn","example":"The kitchen is big."}],
    "examples":[
      {"en":"I live in a small house. There are three rooms. In the living room there is a sofa and a TV. My bedroom is next to the kitchen.","vi":"Tôi sống trong một ngôi nhà nhỏ. Có ba phòng. Trong phòng khách có một ghế sofa và một cái tivi. Phòng ngủ của tôi ở cạnh nhà bếp."}],
    "commonMistakes":["❌ \"There is three rooms\" → ✅ \"There are three rooms\""],
    "tips":["Đọc kỹ số lượng phòng và vị trí đồ đạc."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u09-l4-p1','a1-u09-l4','multiple_choice',1,'practice','easy',false,'{"question":"Đọc: \"I live in a small house.\" → Ngôi nhà thế nào?","options":[{"id":"a","text":"nhỏ"},{"id":"b","text":"to"},{"id":"c","text":"cũ"}],"correctOptionId":"a","explanationVi":"a small house = nhà nhỏ."}'::jsonb),
 ('a1-u09-l4-p2','a1-u09-l4','vocabulary_match',2,'practice','medium',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"small","right":"nhỏ"},{"left":"big","right":"to"},{"left":"sofa","right":"ghế sofa"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l4-q1','a1-u09-l4','multiple_choice',3,'quiz','medium',true,'{"question":"Theo đoạn: Nhà có mấy phòng?","options":[{"id":"a","text":"ba"},{"id":"b","text":"hai"},{"id":"c","text":"bốn"}],"correctOptionId":"a","explanationVi":"There are three rooms."}'::jsonb),
 ('a1-u09-l4-q2','a1-u09-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Trong phòng khách có gì?","options":[{"id":"a","text":"sofa và TV"},{"id":"b","text":"giường và bàn"},{"id":"c","text":"tủ lạnh"}],"correctOptionId":"a","explanationVi":"there is a sofa and a TV."}'::jsonb),
 ('a1-u09-l4-q3','a1-u09-l4','multiple_choice',5,'quiz','medium',true,'{"question":"Phòng ngủ ở đâu?","options":[{"id":"a","text":"cạnh nhà bếp"},{"id":"b","text":"cạnh phòng tắm"},{"id":"c","text":"trên gác"}],"correctOptionId":"a","explanationVi":"My bedroom is next to the kitchen."}'::jsonb),
 ('a1-u09-l4-q4','a1-u09-l4','grammar_fill_blank',6,'quiz','hard',true,'{"question":"There ___ three rooms. (to be, số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb);

-- ── UNIT 9 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u09-l5','A1','reading','a1-u09','unit_review',5,'Unit 9 Review','Ôn tập Unit 9: phòng, đồ đạc, there is/are',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 9: phòng trong nhà, đồ đạc, there is/are.",
    "objectives":["Tổng hợp can-do Unit 9","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u09-l5-q1','a1-u09-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"bedroom\" nghĩa là:","options":[{"id":"a","text":"phòng ngủ"},{"id":"b","text":"nhà bếp"},{"id":"c","text":"phòng tắm"}],"correctOptionId":"a","explanationVi":"bedroom = phòng ngủ."}'::jsonb),
 ('a1-u09-l5-q2','a1-u09-l5','vocabulary_match',2,'quiz','easy',true,'{"question":"Nối phòng:","pairs":[{"left":"kitchen","right":"nhà bếp"},{"left":"bathroom","right":"phòng tắm"},{"left":"living room","right":"phòng khách"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l5-q3','a1-u09-l5','multiple_choice',3,'quiz','easy',true,'{"question":"\"fridge\" nghĩa là:","options":[{"id":"a","text":"tủ lạnh"},{"id":"b","text":"giường"},{"id":"c","text":"bàn"}],"correctOptionId":"a","explanationVi":"fridge = tủ lạnh."}'::jsonb),
 ('a1-u09-l5-q4','a1-u09-l5','vocabulary_match',4,'quiz','medium',true,'{"question":"Nối đồ đạc:","pairs":[{"left":"bed","right":"giường"},{"left":"sofa","right":"ghế sofa"},{"left":"TV","right":"tivi"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l5-q5','a1-u09-l5','grammar_fill_blank',5,'quiz','medium',true,'{"question":"There ___ a bed. (số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u09-l5-q6','a1-u09-l5','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"There are two chairs."},{"id":"b","text":"There is two chairs."},{"id":"c","text":"There be two chairs."}],"correctOptionId":"a","explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l5-q7','a1-u09-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"There ___ four rooms. (số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l5-q8','a1-u09-l5','multiple_choice',8,'quiz','hard',true,'{"question":"Phủ định ĐÚNG (không có sofa):","options":[{"id":"a","text":"There isn''t a sofa."},{"id":"b","text":"There aren''t a sofa."},{"id":"c","text":"There no sofa."}],"correctOptionId":"a","explanationVi":"số ít → There isn''t."}'::jsonb),
 ('a1-u09-l5-q9','a1-u09-l5','multiple_choice',9,'quiz','medium',true,'{"question":"Nấu ăn ở phòng nào?","options":[{"id":"a","text":"kitchen"},{"id":"b","text":"bedroom"},{"id":"c","text":"living room"}],"correctOptionId":"a","explanationVi":"kitchen = nhà bếp."}'::jsonb),
 ('a1-u09-l5-q10','a1-u09-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["are","There","beds","two"],"correctOrder":[1,0,3,2],"explanationVi":"There are two beds."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNIT 10 — Weather, Clothes & Going Out / Thời tiết, quần áo & ra ngoài     ║
-- ║ Can-do: tả thời tiết · gọi tên quần áo & hỏi màu/cỡ/giá · kế hoạch (be going to)║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u10-l1','A1','reading','a1-u10','normal',1,'The weather','Thời tiết (It''s + adj, very + adj)',8,15,70,'{}'::jsonb,
  '{"warmup":"Hôm nay thời tiết thế nào?",
    "objectives":["Tả thời tiết với It''s + tính từ","Dùng very + adj để nhấn mạnh"],
    "grammarHtml":"Tả thời tiết: It''s + tính từ. VD: It''s hot. It''s rainy. Nhấn mạnh: very + adj: It''s very cold. Hỏi: What''s the weather like?",
    "vocabBlock":[
      {"word":"hot","ipa":"/hɒt/","meaningVi":"nóng","example":"It''s hot today."},
      {"word":"cold","ipa":"/kəʊld/","meaningVi":"lạnh","example":"It''s very cold."},
      {"word":"sunny","ipa":"/ˈsʌni/","meaningVi":"nắng","example":"It''s sunny."},
      {"word":"rainy","ipa":"/ˈreɪni/","meaningVi":"mưa","example":"It''s rainy today."}],
    "examples":[
      {"en":"It''s hot and sunny today.","vi":"Hôm nay trời nóng và nắng."},
      {"en":"It''s very cold in winter.","vi":"Mùa đông trời rất lạnh."}],
    "commonMistakes":["❌ \"Today hot\" → ✅ \"It''s hot today\""],
    "tips":["Tả thời tiết luôn bắt đầu bằng It''s."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u10-l1-p1','a1-u10-l1','vocabulary_match',1,'practice','easy',false,'{"question":"Nối thời tiết với nghĩa:","pairs":[{"left":"hot","right":"nóng"},{"left":"cold","right":"lạnh"},{"left":"sunny","right":"nắng"},{"left":"rainy","right":"mưa"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l1-p2','a1-u10-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"___ hot today. (Trời nóng — điền It''s)","acceptedAnswers":["It''s","Its","It is"],"explanationVi":"It''s hot today."}'::jsonb),
 ('a1-u10-l1-p3','a1-u10-l1','multiple_choice',3,'practice','medium',false,'{"question":"Nhấn mạnh \"rất lạnh\":","options":[{"id":"a","text":"It''s very cold."},{"id":"b","text":"It''s cold very."},{"id":"c","text":"Very it''s cold."}],"correctOptionId":"a","explanationVi":"very + adj."}'::jsonb),
 ('a1-u10-l1-q1','a1-u10-l1','multiple_choice',4,'quiz','easy',true,'{"question":"\"rainy\" nghĩa là:","options":[{"id":"a","text":"mưa"},{"id":"b","text":"nắng"},{"id":"c","text":"nóng"}],"correctOptionId":"a","explanationVi":"rainy = mưa."}'::jsonb),
 ('a1-u10-l1-q2','a1-u10-l1','grammar_fill_blank',5,'quiz','medium',true,'{"question":"___ sunny today. (điền It''s)","acceptedAnswers":["It''s","Its","It is"],"explanationVi":"It''s sunny today."}'::jsonb),
 ('a1-u10-l1-q3','a1-u10-l1','multiple_choice',6,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"It''s very hot."},{"id":"b","text":"It''s hot very."},{"id":"c","text":"It very hot."}],"correctOptionId":"a","explanationVi":"very + adj."}'::jsonb),
 ('a1-u10-l1-q4','a1-u10-l1','vocabulary_match',7,'quiz','hard',true,'{"question":"Nối thời tiết:","pairs":[{"left":"hot","right":"nóng"},{"left":"cold","right":"lạnh"}],"explanationVi":"Ghép đúng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u10-l2','A1','reading','a1-u10','normal',2,'Clothes & colours','Quần áo & màu sắc',8,15,70,'{}'::jsonb,
  '{"warmup":"Hôm nay bạn mặc gì?",
    "objectives":["Gọi tên quần áo","Hỏi màu/cỡ: What colour/size?"],
    "grammarHtml":"Quần áo + màu: a red shirt. Hỏi: What colour is it? / What size? VD: I wear a blue shirt.",
    "vocabBlock":[
      {"word":"shirt","ipa":"/ʃɜːt/","meaningVi":"áo sơ mi","example":"a white shirt"},
      {"word":"dress","ipa":"/dres/","meaningVi":"váy/đầm","example":"a red dress"},
      {"word":"shoes","ipa":"/ʃuːz/","meaningVi":"giày","example":"black shoes"},
      {"word":"hat","ipa":"/hæt/","meaningVi":"mũ","example":"a yellow hat"}],
    "examples":[
      {"en":"I wear a blue shirt and black shoes.","vi":"Tôi mặc áo sơ mi xanh và giày đen."},
      {"en":"What colour is your dress?","vi":"Váy của bạn màu gì?"}],
    "commonMistakes":["❌ \"a shoes\" → ✅ \"shoes\" (giày luôn số nhiều)"],
    "tips":["shoes luôn ở dạng số nhiều."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u10-l2-p1','a1-u10-l2','vocabulary_match',1,'practice','easy',false,'{"question":"Nối quần áo với nghĩa:","pairs":[{"left":"shirt","right":"áo sơ mi"},{"left":"dress","right":"váy"},{"left":"shoes","right":"giày"},{"left":"hat","right":"mũ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l2-p2','a1-u10-l2','multiple_choice',2,'practice','easy',false,'{"question":"Đồ đội trên đầu là:","options":[{"id":"a","text":"hat"},{"id":"b","text":"shoes"},{"id":"c","text":"shirt"}],"correctOptionId":"a","explanationVi":"hat = mũ."}'::jsonb),
 ('a1-u10-l2-p3','a1-u10-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"What ___ is your shirt? – It''s blue. (hỏi màu)","acceptedAnswers":["colour","color"],"explanationVi":"What colour is...?"}'::jsonb),
 ('a1-u10-l2-q1','a1-u10-l2','multiple_choice',4,'quiz','easy',true,'{"question":"\"shoes\" nghĩa là:","options":[{"id":"a","text":"giày"},{"id":"b","text":"mũ"},{"id":"c","text":"váy"}],"correctOptionId":"a","explanationVi":"shoes = giày."}'::jsonb),
 ('a1-u10-l2-q2','a1-u10-l2','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn cụm ĐÚNG:","options":[{"id":"a","text":"a red dress"},{"id":"b","text":"a dress red"},{"id":"c","text":"red a dress"}],"correctOptionId":"a","explanationVi":"a + màu + danh từ."}'::jsonb),
 ('a1-u10-l2-q3','a1-u10-l2','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối quần áo:","pairs":[{"left":"shirt","right":"áo sơ mi"},{"left":"hat","right":"mũ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l2-q4','a1-u10-l2','grammar_fill_blank',7,'quiz','hard',true,'{"question":"What ___ is it? – It''s red. (hỏi màu)","acceptedAnswers":["colour","color"],"explanationVi":"What colour is it?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u10-l3','A1','reading','a1-u10','normal',3,'Shopping & prices','Mua sắm & giá cả',9,15,70,'{}'::jsonb,
  '{"warmup":"Vào cửa hàng quần áo, bạn hỏi giá thế nào?",
    "objectives":["Hỏi giá: How much is it?","Mua đồ: I''d like..."],
    "grammarHtml":"Hỏi giá số ít: How much is it? Số nhiều: How much are they? Trả lời: It''s/They''re + giá. Mua: I''d like + đồ.",
    "vocabBlock":[
      {"word":"buy","ipa":"/baɪ/","meaningVi":"mua","example":"I want to buy a hat."},
      {"word":"price","ipa":"/praɪs/","meaningVi":"giá","example":"What''s the price?"},
      {"word":"expensive","ipa":"/ɪkˈspensɪv/","meaningVi":"đắt","example":"It''s expensive."},
      {"word":"cheap","ipa":"/tʃiːp/","meaningVi":"rẻ","example":"This shirt is cheap."}],
    "examples":[
      {"en":"How much is this shirt? – It''s ten dollars.","vi":"Áo này bao nhiêu? – Mười đô la."},
      {"en":"I''d like this hat, please.","vi":"Cho tôi cái mũ này."}],
    "commonMistakes":["❌ \"How much this shirt?\" → ✅ \"How much is this shirt?\""],
    "tips":["is + số ít, are + số nhiều khi hỏi giá."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u10-l3-p1','a1-u10-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"buy","right":"mua"},{"left":"price","right":"giá"},{"left":"expensive","right":"đắt"},{"left":"cheap","right":"rẻ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l3-p2','a1-u10-l3','multiple_choice',2,'practice','medium',false,'{"question":"Hỏi giá (số ít):","options":[{"id":"a","text":"How much is it?"},{"id":"b","text":"How much it is?"},{"id":"c","text":"How is it much?"}],"correctOptionId":"a","explanationVi":"How much is it?"}'::jsonb),
 ('a1-u10-l3-p3','a1-u10-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"It''s ten ___. (đơn vị tiền)","acceptedAnswers":["dollars","dollar"],"explanationVi":"It''s ten dollars."}'::jsonb),
 ('a1-u10-l3-q1','a1-u10-l3','multiple_choice',4,'quiz','easy',true,'{"question":"\"cheap\" nghĩa là:","options":[{"id":"a","text":"rẻ"},{"id":"b","text":"đắt"},{"id":"c","text":"to"}],"correctOptionId":"a","explanationVi":"cheap = rẻ."}'::jsonb),
 ('a1-u10-l3-q2','a1-u10-l3','multiple_choice',5,'quiz','medium',true,'{"question":"Câu hỏi giá ĐÚNG:","options":[{"id":"a","text":"How much is this shirt?"},{"id":"b","text":"How much this shirt?"},{"id":"c","text":"How much shirt is?"}],"correctOptionId":"a","explanationVi":"How much is + N?"}'::jsonb),
 ('a1-u10-l3-q3','a1-u10-l3','sentence_ordering',6,'quiz','hard',true,'{"question":"Sắp xếp câu hỏi giá:","tokens":["is","How","it","much"],"correctOrder":[1,3,0,2],"explanationVi":"How much is it?"}'::jsonb),
 ('a1-u10-l3-q4','a1-u10-l3','multiple_choice',7,'quiz','medium',true,'{"question":"\"expensive\" nghĩa là:","options":[{"id":"a","text":"đắt"},{"id":"b","text":"rẻ"},{"id":"c","text":"nhỏ"}],"correctOptionId":"a","explanationVi":"expensive = đắt."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u10-l4','A1','listening','a1-u10','normal',4,'Be going to','Kế hoạch tương lai (be going to)',10,15,70,'{}'::jsonb,
  '{"warmup":"Cuối tuần này bạn định làm gì?",
    "objectives":["Dùng be going to + V để nói kế hoạch","Nghe & chọn kế hoạch/thời tiết"],
    "grammarHtml":"S + am/is/are + going to + V (kế hoạch/dự định): I am going to study. It''s going to rain (dự đoán).",
    "vocabBlock":[
      {"word":"going to","ipa":"/ˈɡəʊɪŋ tu/","meaningVi":"sẽ/định","example":"I am going to swim."},
      {"word":"tomorrow","ipa":"/təˈmɒrəʊ/","meaningVi":"ngày mai","example":"I am going to study tomorrow."}],
    "examples":[
      {"en":"I am going to visit my grandmother.","vi":"Tôi sẽ đi thăm bà."},
      {"en":"It''s going to rain.","vi":"Trời sắp mưa."}],
    "commonMistakes":["❌ \"I going to study\" → ✅ \"I am going to study\" (cần to be)"],
    "tips":["Luôn có am/is/are trước going to."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u10-l4-p1','a1-u10-l4','multiple_choice',1,'practice','easy',false,'{"question":"I ___ going to study. (to be)","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"I am going to."}'::jsonb),
 ('a1-u10-l4-p2','a1-u10-l4','grammar_fill_blank',2,'practice','medium',false,'{"question":"She is going to ___ tomorrow. (study)","acceptedAnswers":["study"],"explanationVi":"going to + V nguyên thể."}'::jsonb),
 ('a1-u10-l4-p3','a1-u10-l4','listening_choice',3,'practice','medium',false,'{"question":"Nghe và chọn kế hoạch đúng:","audioText":"I am going to play football.","options":[{"id":"a","text":"chơi bóng đá"},{"id":"b","text":"đọc sách"},{"id":"c","text":"nấu ăn"}],"correctOptionId":"a","explanationVi":"going to play football = sẽ chơi bóng đá."}'::jsonb),
 ('a1-u10-l4-q1','a1-u10-l4','multiple_choice',4,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I am going to swim."},{"id":"b","text":"I going to swim."},{"id":"c","text":"I am go to swim."}],"correctOptionId":"a","explanationVi":"to be + going to + V."}'::jsonb),
 ('a1-u10-l4-q2','a1-u10-l4','grammar_fill_blank',5,'quiz','medium',true,'{"question":"They ___ going to travel. (to be)","acceptedAnswers":["are"],"explanationVi":"They are going to."}'::jsonb),
 ('a1-u10-l4-q3','a1-u10-l4','listening_choice',6,'quiz','hard',true,'{"question":"Nghe và chọn thời tiết:","audioText":"It is going to rain.","options":[{"id":"a","text":"sắp mưa"},{"id":"b","text":"trời nắng"},{"id":"c","text":"trời lạnh"}],"correctOptionId":"a","explanationVi":"going to rain = sắp mưa."}'::jsonb),
 ('a1-u10-l4-q4','a1-u10-l4','multiple_choice',7,'quiz','hard',true,'{"question":"\"Tôi sẽ học bài ngày mai\" dịch ĐÚNG là:","options":[{"id":"a","text":"I am going to study tomorrow."},{"id":"b","text":"I going to study tomorrow."},{"id":"c","text":"I am go to study tomorrow."}],"correctOptionId":"a","explanationVi":"to be + going to + V."}'::jsonb);

-- ── UNIT 10 REVIEW (lesson 5) ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-u10-l5','A1','listening','a1-u10','unit_review',5,'Unit 10 Review','Ôn tập Unit 10: thời tiết, quần áo, mua sắm, kế hoạch',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 10: thời tiết, quần áo & màu, mua sắm, be going to.",
    "objectives":["Tổng hợp can-do Unit 10","Đạt ≥ 75% để hoàn thành Unit cuối A1"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để hoàn thành Unit 10. Hoàn thành ≥ 8/10 Unit để mở Checkpoint A1!"]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-u10-l5-q1','a1-u10-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"hot\" nghĩa là:","options":[{"id":"a","text":"nóng"},{"id":"b","text":"lạnh"},{"id":"c","text":"mưa"}],"correctOptionId":"a","explanationVi":"hot = nóng."}'::jsonb),
 ('a1-u10-l5-q2','a1-u10-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"___ sunny today. (điền It''s)","acceptedAnswers":["It''s","Its","It is"],"explanationVi":"It''s sunny today."}'::jsonb),
 ('a1-u10-l5-q3','a1-u10-l5','vocabulary_match',3,'quiz','easy',true,'{"question":"Nối quần áo:","pairs":[{"left":"shirt","right":"áo sơ mi"},{"left":"shoes","right":"giày"},{"left":"hat","right":"mũ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l5-q4','a1-u10-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"What ___ is it? – It''s blue. (hỏi màu)","acceptedAnswers":["colour","color"],"explanationVi":"What colour is it?"}'::jsonb),
 ('a1-u10-l5-q5','a1-u10-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Câu hỏi giá ĐÚNG:","options":[{"id":"a","text":"How much is it?"},{"id":"b","text":"How much it is?"},{"id":"c","text":"How is much it?"}],"correctOptionId":"a","explanationVi":"How much is it?"}'::jsonb),
 ('a1-u10-l5-q6','a1-u10-l5','multiple_choice',6,'quiz','medium',true,'{"question":"\"cheap\" nghĩa là:","options":[{"id":"a","text":"rẻ"},{"id":"b","text":"đắt"},{"id":"c","text":"to"}],"correctOptionId":"a","explanationVi":"cheap = rẻ."}'::jsonb),
 ('a1-u10-l5-q7','a1-u10-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Câu kế hoạch ĐÚNG:","options":[{"id":"a","text":"I am going to study."},{"id":"b","text":"I going to study."},{"id":"c","text":"I am go to study."}],"correctOptionId":"a","explanationVi":"to be + going to + V."}'::jsonb),
 ('a1-u10-l5-q8','a1-u10-l5','grammar_fill_blank',8,'quiz','medium',true,'{"question":"They ___ going to travel. (to be)","acceptedAnswers":["are"],"explanationVi":"They are going to."}'::jsonb),
 ('a1-u10-l5-q9','a1-u10-l5','listening_choice',9,'quiz','hard',true,'{"question":"Nghe và chọn kế hoạch:","audioText":"I am going to visit my grandmother.","options":[{"id":"a","text":"thăm bà"},{"id":"b","text":"đi học"},{"id":"c","text":"mua sắm"}],"correctOptionId":"a","explanationVi":"going to visit my grandmother = sẽ thăm bà."}'::jsonb),
 ('a1-u10-l5-q10','a1-u10-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["going","I''m","swim","to"],"correctOrder":[1,0,3,2],"explanationVi":"I''m going to swim."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 2 — Gắn Unit Review làm review_lesson_id cho từng Unit                ║
-- ║ (recompute coi unit completed khi PASS hết lesson; review_lesson_id để FE  ║
-- ║  / logic nhận diện lesson nào là bài ôn cuối Unit)                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = 'a1-u01-l5' WHERE id = 'a1-u01';
UPDATE learning_units SET review_lesson_id = 'a1-u02-l5' WHERE id = 'a1-u02';
UPDATE learning_units SET review_lesson_id = 'a1-u03-l5' WHERE id = 'a1-u03';
UPDATE learning_units SET review_lesson_id = 'a1-u04-l5' WHERE id = 'a1-u04';
UPDATE learning_units SET review_lesson_id = 'a1-u05-l5' WHERE id = 'a1-u05';
UPDATE learning_units SET review_lesson_id = 'a1-u06-l5' WHERE id = 'a1-u06';
UPDATE learning_units SET review_lesson_id = 'a1-u07-l5' WHERE id = 'a1-u07';
UPDATE learning_units SET review_lesson_id = 'a1-u08-l5' WHERE id = 'a1-u08';
UPDATE learning_units SET review_lesson_id = 'a1-u09-l5' WHERE id = 'a1-u09';
UPDATE learning_units SET review_lesson_id = 'a1-u10-l5' WHERE id = 'a1-u10';

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 3 — LÀM DÀY 40 lesson nội dung → mỗi lesson 6 practice + 6 quiz       ║
-- ║ (chuẩn Busuu/Babbel ~12 câu/lesson). display_order bắt đầu từ 20 (cao hơn  ║
-- ║  mọi display_order hiện có ≤9) để không đụng UNIQUE(lesson_id,display_order)║
-- ║  Unit Review (l5) giữ nguyên 10 quiz, KHÔNG thêm.                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── UNIT 1 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u01-l1 (need +3 prac, +1 quiz)
 ('a1-u01-l1-p4','a1-u01-l1','multiple_choice',20,'practice','easy',false,'{"question":"Gặp ai buổi tối, bạn nói:","options":[{"id":"a","text":"Good evening"},{"id":"b","text":"Good morning"},{"id":"c","text":"Goodbye"}],"correctOptionId":"a","explanationVi":"Good evening = chào buổi tối."}'::jsonb),
 ('a1-u01-l1-p5','a1-u01-l1','vocabulary_match',21,'practice','medium',false,'{"question":"Nối lời chào/tạm biệt:","pairs":[{"left":"Hi","right":"Chào (thân mật)"},{"left":"See you","right":"Hẹn gặp lại"},{"left":"Goodbye","right":"Tạm biệt"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u01-l1-p6','a1-u01-l1','grammar_fill_blank',22,'practice','medium',false,'{"question":"Tạm biệt: \"___, see you tomorrow.\"","acceptedAnswers":["Goodbye","Bye"],"explanationVi":"Goodbye = tạm biệt."}'::jsonb),
 ('a1-u01-l1-q6','a1-u01-l1','multiple_choice',23,'quiz','medium',true,'{"question":"Lời chào buổi tối:","options":[{"id":"a","text":"Good evening"},{"id":"b","text":"Good morning"},{"id":"c","text":"Good afternoon"}],"correctOptionId":"a","explanationVi":"Good evening = chào buổi tối."}'::jsonb),
 -- u01-l2 (need +2 prac, +1 quiz)
 ('a1-u01-l2-p5','a1-u01-l2','multiple_choice',20,'practice','easy',false,'{"question":"Đại từ cho \"a book\" (đồ vật):","options":[{"id":"a","text":"it"},{"id":"b","text":"he"},{"id":"c","text":"she"}],"correctOptionId":"a","explanationVi":"Đồ vật → it."}'::jsonb),
 ('a1-u01-l2-p6','a1-u01-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"Nam and I → ___ are friends. (đại từ)","acceptedAnswers":["We","we"],"explanationVi":"Nam and I = We."}'::jsonb),
 ('a1-u01-l2-q6','a1-u01-l2','multiple_choice',22,'quiz','medium',true,'{"question":"Đại từ cho \"Mai and Lan\":","options":[{"id":"a","text":"they"},{"id":"b","text":"we"},{"id":"c","text":"she"}],"correctOptionId":"a","explanationVi":"hai người khác → they."}'::jsonb),
 -- u01-l3 (need +3 prac, +1 quiz)
 ('a1-u01-l3-p4','a1-u01-l3','multiple_choice',20,'practice','easy',false,'{"question":"We ___ students.","options":[{"id":"a","text":"are"},{"id":"b","text":"is"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"We + are."}'::jsonb),
 ('a1-u01-l3-p5','a1-u01-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"It ___ a dog.\" (to be)","acceptedAnswers":["is"],"explanationVi":"It + is."}'::jsonb),
 ('a1-u01-l3-p6','a1-u01-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối chủ ngữ với to be:","pairs":[{"left":"I","right":"am"},{"left":"She","right":"is"},{"left":"They","right":"are"}],"explanationVi":"I-am, She-is, They-are."}'::jsonb),
 ('a1-u01-l3-q6','a1-u01-l3','grammar_fill_blank',23,'quiz','hard',true,'{"question":"\"My friends ___ kind.\" (to be)","acceptedAnswers":["are"],"explanationVi":"số nhiều → are."}'::jsonb),
 -- u01-l4 (need +3 prac, +1 quiz)
 ('a1-u01-l4-p4','a1-u01-l4','multiple_choice',20,'practice','easy',false,'{"question":"Giới thiệu nhóm: \"___ are my friends.\"","options":[{"id":"a","text":"These"},{"id":"b","text":"This"},{"id":"c","text":"That"}],"correctOptionId":"a","explanationVi":"số nhiều → These."}'::jsonb),
 ('a1-u01-l4-p5','a1-u01-l4','vocabulary_match',21,'practice','medium',false,'{"question":"Nối từ:","pairs":[{"left":"student","right":"sinh viên"},{"left":"from","right":"đến từ"},{"left":"name","right":"tên"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u01-l4-p6','a1-u01-l4','grammar_fill_blank',22,'practice','medium',false,'{"question":"\"___ is my friend, Nam.\" (giới thiệu 1 người)","acceptedAnswers":["This"],"explanationVi":"This is..."}'::jsonb),
 ('a1-u01-l4-q6','a1-u01-l4','multiple_choice',23,'quiz','medium',true,'{"question":"\"Where are you from?\" hỏi điều gì?","options":[{"id":"a","text":"quê quán"},{"id":"b","text":"tên"},{"id":"c","text":"tuổi"}],"correctOptionId":"a","explanationVi":"Where from = hỏi quê quán."}'::jsonb);

-- ── UNIT 2 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u02-l1 (+3 prac, +1 quiz)
 ('a1-u02-l1-p4','a1-u02-l1','multiple_choice',20,'practice','easy',false,'{"question":"Chị/em gái là:","options":[{"id":"a","text":"sister"},{"id":"b","text":"brother"},{"id":"c","text":"mother"}],"correctOptionId":"a","explanationVi":"sister = chị/em gái."}'::jsonb),
 ('a1-u02-l1-p5','a1-u02-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"My ___ and mother are teachers. (bố)","acceptedAnswers":["father"],"explanationVi":"father = bố."}'::jsonb),
 ('a1-u02-l1-p6','a1-u02-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"parents","right":"bố mẹ"},{"left":"brother","right":"anh/em trai"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l1-q6','a1-u02-l1','multiple_choice',23,'quiz','hard',true,'{"question":"\"father\" và \"mother\" gọi chung:","options":[{"id":"a","text":"parents"},{"id":"b","text":"sisters"},{"id":"c","text":"children"}],"correctOptionId":"a","explanationVi":"parents = bố mẹ."}'::jsonb),
 -- u02-l2 (+3 prac, +1 quiz)
 ('a1-u02-l2-p4','a1-u02-l2','multiple_choice',20,'practice','easy',false,'{"question":"\"___ name is Nam.\" (của tôi)","options":[{"id":"a","text":"My"},{"id":"b","text":"Me"},{"id":"c","text":"I"}],"correctOptionId":"a","explanationVi":"My name = tên của tôi."}'::jsonb),
 ('a1-u02-l2-p5','a1-u02-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"They love ___ school. (của họ)","acceptedAnswers":["their"],"explanationVi":"their = của họ."}'::jsonb),
 ('a1-u02-l2-p6','a1-u02-l2','vocabulary_match',22,'practice','medium',false,'{"question":"Nối sở hữu:","pairs":[{"left":"his","right":"của anh ấy"},{"left":"her","right":"của cô ấy"},{"left":"our","right":"của chúng tôi"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l2-q6','a1-u02-l2','multiple_choice',23,'quiz','hard',true,'{"question":"\"It is the dog. ___ name is Rex.\" (của nó)","options":[{"id":"a","text":"Its"},{"id":"b","text":"It''s"},{"id":"c","text":"His"}],"correctOptionId":"a","explanationVi":"Its = của nó (không có dấu '')."}'::jsonb),
 -- u02-l3 (+3 prac, +1 quiz)
 ('a1-u02-l3-p4','a1-u02-l3','multiple_choice',20,'practice','easy',false,'{"question":"\"thấp\" là:","options":[{"id":"a","text":"short"},{"id":"b","text":"tall"},{"id":"c","text":"young"}],"correctOptionId":"a","explanationVi":"short = thấp."}'::jsonb),
 ('a1-u02-l3-p5','a1-u02-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"My grandfather is ___. (già)","acceptedAnswers":["old"],"explanationVi":"old = già."}'::jsonb),
 ('a1-u02-l3-p6','a1-u02-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối tính từ:","pairs":[{"left":"tall","right":"cao"},{"left":"young","right":"trẻ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l3-q6','a1-u02-l3','multiple_choice',23,'quiz','hard',true,'{"question":"Câu ĐÚNG (số nhiều):","options":[{"id":"a","text":"They are tall."},{"id":"b","text":"They is tall."},{"id":"c","text":"They are a tall."}],"correctOptionId":"a","explanationVi":"They are + adj."}'::jsonb),
 -- u02-l4 (+3 prac, +1 quiz)
 ('a1-u02-l4-p4','a1-u02-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"túi của Lan\" =","options":[{"id":"a","text":"Lan''s bag"},{"id":"b","text":"Lan bag"},{"id":"c","text":"bag Lan"}],"correctOptionId":"a","explanationVi":"Lan''s bag."}'::jsonb),
 ('a1-u02-l4-p5','a1-u02-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"Mẹ của Tom\": Tom___ mother. (thêm ''s)","acceptedAnswers":["''s","s"],"explanationVi":"Tom''s mother."}'::jsonb),
 ('a1-u02-l4-p6','a1-u02-l4','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"Nam''s book","right":"sách của Nam"},{"left":"my book","right":"sách của tôi"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u02-l4-q6','a1-u02-l4','multiple_choice',24,'quiz','hard',true,'{"question":"''s dùng để:","options":[{"id":"a","text":"chỉ sở hữu"},{"id":"b","text":"chỉ số nhiều"},{"id":"c","text":"chỉ quá khứ"}],"correctOptionId":"a","explanationVi":"''s = sở hữu."}'::jsonb);

-- ── UNIT 3 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u03-l1 (+3 prac, +1 quiz)
 ('a1-u03-l1-p3b','a1-u03-l1','multiple_choice',20,'practice','easy',false,'{"question":"Buổi sáng đầu tiên làm gì?","options":[{"id":"a","text":"wake up"},{"id":"b","text":"go to bed"},{"id":"c","text":"have dinner"}],"correctOptionId":"a","explanationVi":"wake up = thức dậy."}'::jsonb),
 ('a1-u03-l1-p4','a1-u03-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"I ___ to school at 7. (đi)","acceptedAnswers":["go"],"explanationVi":"go to school = đi học."}'::jsonb),
 ('a1-u03-l1-p5','a1-u03-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"eat breakfast","right":"ăn sáng"},{"left":"go to school","right":"đi học"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l1-q5','a1-u03-l1','multiple_choice',23,'quiz','hard',true,'{"question":"Hành động buổi tối trước khi ngủ:","options":[{"id":"a","text":"go to bed"},{"id":"b","text":"wake up"},{"id":"c","text":"eat breakfast"}],"correctOptionId":"a","explanationVi":"go to bed = đi ngủ."}'::jsonb),
 ('a1-u03-l1-q6','a1-u03-l1','vocabulary_match',24,'quiz','hard',true,'{"question":"Nối hành động hằng ngày:","pairs":[{"left":"wake up","right":"thức dậy"},{"left":"go to school","right":"đi học"},{"left":"go to bed","right":"đi ngủ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 -- u03-l2 (+3 prac, +1 quiz)
 ('a1-u03-l2-p4','a1-u03-l2','multiple_choice',20,'practice','easy',false,'{"question":"She ___ to school. (đi)","options":[{"id":"a","text":"goes"},{"id":"b","text":"go"},{"id":"c","text":"going"}],"correctOptionId":"a","explanationVi":"She + goes."}'::jsonb),
 ('a1-u03-l2-p5','a1-u03-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"They ___ football. (chơi — không thêm s)","acceptedAnswers":["play"],"explanationVi":"They + play."}'::jsonb),
 ('a1-u03-l2-p6','a1-u03-l2','multiple_choice',22,'practice','hard',false,'{"question":"Câu hỏi ĐÚNG:","options":[{"id":"a","text":"Do you like tea?"},{"id":"b","text":"Does you like tea?"},{"id":"c","text":"You do like tea?"}],"correctOptionId":"a","explanationVi":"Do + you + V?"}'::jsonb),
 ('a1-u03-l2-q6','a1-u03-l2','grammar_fill_blank',23,'quiz','hard',true,'{"question":"\"___ she like coffee?\" (Do/Does)","acceptedAnswers":["Does"],"explanationVi":"ngôi 3 số ít → Does."}'::jsonb),
 -- u03-l3 (+3 prac, +1 quiz)
 ('a1-u03-l3-p4','a1-u03-l3','multiple_choice',20,'practice','easy',false,'{"question":"I have lunch ___ 12. (giới từ giờ)","options":[{"id":"a","text":"at"},{"id":"b","text":"in"},{"id":"c","text":"on"}],"correctOptionId":"a","explanationVi":"at + giờ."}'::jsonb),
 ('a1-u03-l3-p5','a1-u03-l3','vocabulary_match',21,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"have lunch","right":"ăn trưa"},{"left":"go home","right":"về nhà"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l3-p6','a1-u03-l3','grammar_fill_blank',22,'practice','medium',false,'{"question":"I go home ___ 5 o''clock. (giới từ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-u03-l3-q6','a1-u03-l3','sentence_ordering',23,'quiz','hard',true,'{"question":"Sắp xếp câu:","tokens":["lunch","I","at","have","twelve"],"correctOrder":[1,3,0,2,4],"explanationVi":"I have lunch at twelve."}'::jsonb),
 -- u03-l4 (+4 prac, +2 quiz)
 ('a1-u03-l4-p3','a1-u03-l4','grammar_fill_blank',20,'practice','easy',false,'{"question":"\"She ___ up at six.\" (get, ngôi 3 số ít)","acceptedAnswers":["gets"],"explanationVi":"She + gets up."}'::jsonb),
 ('a1-u03-l4-p4','a1-u03-l4','multiple_choice',21,'practice','medium',false,'{"question":"\"every day\" nghĩa là:","options":[{"id":"a","text":"mỗi ngày"},{"id":"b","text":"hôm qua"},{"id":"c","text":"ngày mai"}],"correctOptionId":"a","explanationVi":"every day = mỗi ngày."}'::jsonb),
 ('a1-u03-l4-p5','a1-u03-l4','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"get up","right":"thức dậy"},{"left":"breakfast","right":"bữa sáng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u03-l4-p6','a1-u03-l4','sentence_ordering',23,'practice','hard',false,'{"question":"Sắp xếp câu:","tokens":["at","She","up","gets","six"],"correctOrder":[1,3,2,0,4],"explanationVi":"She gets up at six."}'::jsonb),
 ('a1-u03-l4-q5','a1-u03-l4','multiple_choice',24,'quiz','medium',true,'{"question":"Lan dậy lúc mấy giờ (đoạn: gets up at six)?","options":[{"id":"a","text":"6 giờ"},{"id":"b","text":"7 giờ"},{"id":"c","text":"5 giờ"}],"correctOptionId":"a","explanationVi":"gets up at six = 6 giờ."}'::jsonb),
 ('a1-u03-l4-q6','a1-u03-l4','grammar_fill_blank',25,'quiz','hard',true,'{"question":"\"He ___ breakfast at seven.\" (have → ngôi 3 số ít)","acceptedAnswers":["has"],"explanationVi":"He + has breakfast."}'::jsonb);

-- ── UNIT 4 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u04-l1 (+3 prac, +2 quiz)
 ('a1-u04-l1-p4','a1-u04-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"fish\" nghĩa là:","options":[{"id":"a","text":"cá"},{"id":"b","text":"cơm"},{"id":"c","text":"sữa"}],"correctOptionId":"a","explanationVi":"fish = cá."}'::jsonb),
 ('a1-u04-l1-p5','a1-u04-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"I drink ___ for breakfast. (sữa)","acceptedAnswers":["milk"],"explanationVi":"milk = sữa."}'::jsonb),
 ('a1-u04-l1-p6','a1-u04-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"bread","right":"bánh mì"},{"left":"apple","right":"táo"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u04-l1-q5','a1-u04-l1','multiple_choice',23,'quiz','medium',true,'{"question":"\"milk\" nghĩa là:","options":[{"id":"a","text":"sữa"},{"id":"b","text":"nước"},{"id":"c","text":"cơm"}],"correctOptionId":"a","explanationVi":"milk = sữa."}'::jsonb),
 ('a1-u04-l1-q6','a1-u04-l1','grammar_fill_blank',24,'quiz','hard',true,'{"question":"I eat ___ for breakfast. (bánh mì)","acceptedAnswers":["bread"],"explanationVi":"bread = bánh mì."}'::jsonb),
 -- u04-l2 (+3 prac, +1 quiz)
 ('a1-u04-l2-p4','a1-u04-l2','multiple_choice',20,'practice','easy',false,'{"question":"I ___ rice. (thích)","options":[{"id":"a","text":"like"},{"id":"b","text":"likes"},{"id":"c","text":"liking"}],"correctOptionId":"a","explanationVi":"I + like."}'::jsonb),
 ('a1-u04-l2-p5','a1-u04-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"He ___ coffee. (không thích — doesn''t like)","acceptedAnswers":["doesn''t like","does not like","doesnt like"],"explanationVi":"He doesn''t like."}'::jsonb),
 ('a1-u04-l2-p6','a1-u04-l2','multiple_choice',22,'practice','hard',false,'{"question":"Câu ĐÚNG (ngôi 3 số ít):","options":[{"id":"a","text":"She likes tea."},{"id":"b","text":"She like tea."},{"id":"c","text":"She liking tea."}],"correctOptionId":"a","explanationVi":"She + likes."}'::jsonb),
 ('a1-u04-l2-q6','a1-u04-l2','grammar_fill_blank',23,'quiz','hard',true,'{"question":"\"___ you like fish?\" (Do/Does)","acceptedAnswers":["Do"],"explanationVi":"Do you like...?"}'::jsonb),
 -- u04-l3 (+3 prac, +1 quiz)
 ('a1-u04-l3-p4','a1-u04-l3','multiple_choice',20,'practice','easy',false,'{"question":"___ orange (a/an)","options":[{"id":"a","text":"an"},{"id":"b","text":"a"},{"id":"c","text":"some"}],"correctOptionId":"a","explanationVi":"orange bắt đầu nguyên âm → an."}'::jsonb),
 ('a1-u04-l3-p5','a1-u04-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"I want ___ milk. (không đếm được)","acceptedAnswers":["some"],"explanationVi":"some milk."}'::jsonb),
 ('a1-u04-l3-p6','a1-u04-l3','multiple_choice',22,'practice','hard',false,'{"question":"Câu ĐÚNG:","options":[{"id":"a","text":"I have an egg."},{"id":"b","text":"I have a egg."},{"id":"c","text":"I have some egg."}],"correctOptionId":"a","explanationVi":"an egg (nguyên âm)."}'::jsonb),
 ('a1-u04-l3-q6','a1-u04-l3','grammar_fill_blank',23,'quiz','hard',true,'{"question":"She wants ___ water. (không đếm được)","acceptedAnswers":["some"],"explanationVi":"some water."}'::jsonb),
 -- u04-l4 (+3 prac, +1 quiz)
 ('a1-u04-l4-p4','a1-u04-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"coffee\" nghĩa là:","options":[{"id":"a","text":"cà phê"},{"id":"b","text":"trà"},{"id":"c","text":"nước"}],"correctOptionId":"a","explanationVi":"coffee = cà phê."}'::jsonb),
 ('a1-u04-l4-p5','a1-u04-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"___ much is it?\" (hỏi giá)","acceptedAnswers":["How"],"explanationVi":"How much is it?"}'::jsonb),
 ('a1-u04-l4-p6','a1-u04-l4','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"I''d like","right":"tôi muốn"},{"left":"How much","right":"bao nhiêu tiền"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u04-l4-q6','a1-u04-l4','sentence_ordering',23,'quiz','hard',true,'{"question":"Sắp xếp câu gọi món:","tokens":["a","I''d","tea","like"],"correctOrder":[1,3,0,2],"explanationVi":"I''d like a tea."}'::jsonb);

-- ── UNIT 5 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u05-l1 (+3 prac, +2 quiz)
 ('a1-u05-l1-p4','a1-u05-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"five\" là số mấy?","options":[{"id":"a","text":"5"},{"id":"b","text":"4"},{"id":"c","text":"15"}],"correctOptionId":"a","explanationVi":"five = 5."}'::jsonb),
 ('a1-u05-l1-p5','a1-u05-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"Số 20 viết chữ là ___.","acceptedAnswers":["twenty"],"explanationVi":"20 = twenty."}'::jsonb),
 ('a1-u05-l1-p6','a1-u05-l1','multiple_choice',22,'practice','hard',false,'{"question":"\"40\" viết là:","options":[{"id":"a","text":"forty"},{"id":"b","text":"fourteen"},{"id":"c","text":"four"}],"correctOptionId":"a","explanationVi":"40 = forty."}'::jsonb),
 ('a1-u05-l1-q5','a1-u05-l1','multiple_choice',23,'quiz','medium',true,'{"question":"\"twenty\" là số mấy?","options":[{"id":"a","text":"20"},{"id":"b","text":"12"},{"id":"c","text":"2"}],"correctOptionId":"a","explanationVi":"twenty = 20."}'::jsonb),
 ('a1-u05-l1-q6','a1-u05-l1','grammar_fill_blank',24,'quiz','hard',true,'{"question":"Số 100 viết chữ là ___.","acceptedAnswers":["hundred","one hundred","a hundred"],"explanationVi":"100 = (one) hundred."}'::jsonb),
 -- u05-l2 (+3 prac, +2 quiz)
 ('a1-u05-l2-p4','a1-u05-l2','multiple_choice',20,'practice','easy',false,'{"question":"Hỏi giờ:","options":[{"id":"a","text":"What time is it?"},{"id":"b","text":"What time it is?"},{"id":"c","text":"How time is it?"}],"correctOptionId":"a","explanationVi":"What time is it?"}'::jsonb),
 ('a1-u05-l2-p5','a1-u05-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"It''s seven ___.\" (giờ chẵn)","acceptedAnswers":["o''clock","oclock"],"explanationVi":"seven o''clock."}'::jsonb),
 ('a1-u05-l2-p6','a1-u05-l2','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"o''clock","right":"giờ chẵn"},{"left":"half past","right":"giờ rưỡi"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u05-l2-q5','a1-u05-l2','multiple_choice',23,'quiz','medium',true,'{"question":"\"It''s half past eight\" =","options":[{"id":"a","text":"8:30"},{"id":"b","text":"8:00"},{"id":"c","text":"7:30"}],"correctOptionId":"a","explanationVi":"half past eight = 8 giờ 30."}'::jsonb),
 ('a1-u05-l2-q6','a1-u05-l2','grammar_fill_blank',24,'quiz','hard',true,'{"question":"\"What ___ is it?\" (hỏi giờ)","acceptedAnswers":["time"],"explanationVi":"What time is it?"}'::jsonb),
 -- u05-l3 (+3 prac, +2 quiz)
 ('a1-u05-l3-p4','a1-u05-l3','multiple_choice',20,'practice','easy',false,'{"question":"Hỏi số lượng (đếm được):","options":[{"id":"a","text":"How many"},{"id":"b","text":"How much"},{"id":"c","text":"How old"}],"correctOptionId":"a","explanationVi":"How many + đếm được."}'::jsonb),
 ('a1-u05-l3-p5','a1-u05-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"How many ___ are there? (book → số nhiều)","acceptedAnswers":["books"],"explanationVi":"How many books."}'::jsonb),
 ('a1-u05-l3-p6','a1-u05-l3','multiple_choice',22,'practice','hard',false,'{"question":"Câu ĐÚNG:","options":[{"id":"a","text":"How many pens are there?"},{"id":"b","text":"How many pen are there?"},{"id":"c","text":"How much pens are there?"}],"correctOptionId":"a","explanationVi":"How many + số nhiều."}'::jsonb),
 ('a1-u05-l3-q5','a1-u05-l3','multiple_choice',23,'quiz','medium',true,'{"question":"\"How many\" đi với:","options":[{"id":"a","text":"danh từ đếm được số nhiều"},{"id":"b","text":"danh từ không đếm được"},{"id":"c","text":"động từ"}],"correctOptionId":"a","explanationVi":"How many + đếm được số nhiều."}'::jsonb),
 ('a1-u05-l3-q6','a1-u05-l3','grammar_fill_blank',24,'quiz','hard',true,'{"question":"How many ___ are there? (table → số nhiều)","acceptedAnswers":["tables"],"explanationVi":"How many tables."}'::jsonb),
 -- u05-l4 (+3 prac, +2 quiz)
 ('a1-u05-l4-p4','a1-u05-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"Monday\" là thứ mấy?","options":[{"id":"a","text":"thứ Hai"},{"id":"b","text":"thứ Ba"},{"id":"c","text":"Chủ nhật"}],"correctOptionId":"a","explanationVi":"Monday = thứ Hai."}'::jsonb),
 ('a1-u05-l4-p5','a1-u05-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"I rest ___ Sunday. (giới từ)","acceptedAnswers":["on"],"explanationVi":"on Sunday."}'::jsonb),
 ('a1-u05-l4-p6','a1-u05-l4','listening_choice',22,'practice','medium',false,'{"question":"Nghe và chọn số:","audioText":"sixty","options":[{"id":"a","text":"60"},{"id":"b","text":"16"},{"id":"c","text":"6"}],"correctOptionId":"a","explanationVi":"sixty = 60."}'::jsonb),
 ('a1-u05-l4-q5','a1-u05-l4','multiple_choice',23,'quiz','medium',true,'{"question":"\"Sunday\" là:","options":[{"id":"a","text":"Chủ nhật"},{"id":"b","text":"thứ Bảy"},{"id":"c","text":"thứ Hai"}],"correctOptionId":"a","explanationVi":"Sunday = Chủ nhật."}'::jsonb),
 ('a1-u05-l4-q6','a1-u05-l4','listening_choice',24,'quiz','hard',true,'{"question":"Nghe và chọn giờ:","audioText":"It is half past nine.","options":[{"id":"a","text":"9:30"},{"id":"b","text":"9:00"},{"id":"c","text":"8:30"}],"correctOptionId":"a","explanationVi":"half past nine = 9:30."}'::jsonb);

-- ── UNIT 6 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u06-l1 (+3 prac, +1 quiz)
 ('a1-u06-l1-p4','a1-u06-l1','multiple_choice',20,'practice','easy',false,'{"question":"Vật GẦN, số nhiều: \"___ are books.\"","options":[{"id":"a","text":"These"},{"id":"b","text":"This"},{"id":"c","text":"That"}],"correctOptionId":"a","explanationVi":"these = gần, số nhiều."}'::jsonb),
 ('a1-u06-l1-p5','a1-u06-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"___ is a pen.\" (xa, số ít)","acceptedAnswers":["That","that"],"explanationVi":"that = xa, số ít."}'::jsonb),
 ('a1-u06-l1-p6','a1-u06-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"this","right":"gần-ít"},{"left":"these","right":"gần-nhiều"},{"left":"that","right":"xa-ít"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u06-l1-q6','a1-u06-l1','multiple_choice',23,'quiz','hard',true,'{"question":"Câu ĐÚNG:","options":[{"id":"a","text":"These are pens."},{"id":"b","text":"This are pens."},{"id":"c","text":"These is pens."}],"correctOptionId":"a","explanationVi":"These are + số nhiều."}'::jsonb),
 -- u06-l2 (+2 prac, +1 quiz)
 ('a1-u06-l2-p5','a1-u06-l2','grammar_fill_blank',20,'practice','easy',false,'{"question":"Số nhiều của \"chair\":","acceptedAnswers":["chairs"],"explanationVi":"chair → chairs."}'::jsonb),
 ('a1-u06-l2-p6','a1-u06-l2','multiple_choice',21,'practice','medium',false,'{"question":"Số nhiều của \"woman\":","options":[{"id":"a","text":"women"},{"id":"b","text":"womans"},{"id":"c","text":"womens"}],"correctOptionId":"a","explanationVi":"woman → women."}'::jsonb),
 ('a1-u06-l2-q6','a1-u06-l2','grammar_fill_blank',22,'quiz','hard',true,'{"question":"Số nhiều của \"box\":","acceptedAnswers":["boxes"],"explanationVi":"box → boxes."}'::jsonb),
 -- u06-l3 (+3 prac, +2 quiz)
 ('a1-u06-l3-p4','a1-u06-l3','multiple_choice',20,'practice','easy',false,'{"question":"\"yellow\" là màu:","options":[{"id":"a","text":"vàng"},{"id":"b","text":"đỏ"},{"id":"c","text":"xanh"}],"correctOptionId":"a","explanationVi":"yellow = vàng."}'::jsonb),
 ('a1-u06-l3-p5','a1-u06-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"a ___ apple (màu đỏ)","acceptedAnswers":["red"],"explanationVi":"a red apple."}'::jsonb),
 ('a1-u06-l3-p6','a1-u06-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối màu:","pairs":[{"left":"red","right":"đỏ"},{"left":"green","right":"xanh lá"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u06-l3-q5','a1-u06-l3','multiple_choice',23,'quiz','medium',true,'{"question":"\"blue\" là màu:","options":[{"id":"a","text":"xanh dương"},{"id":"b","text":"đen"},{"id":"c","text":"vàng"}],"correctOptionId":"a","explanationVi":"blue = xanh dương."}'::jsonb),
 ('a1-u06-l3-q6','a1-u06-l3','multiple_choice',24,'quiz','hard',true,'{"question":"Cụm ĐÚNG:","options":[{"id":"a","text":"a green book"},{"id":"b","text":"a book green"},{"id":"c","text":"green a book"}],"correctOptionId":"a","explanationVi":"a + màu + danh từ."}'::jsonb),
 -- u06-l4 (+3 prac, +2 quiz)
 ('a1-u06-l4-p4','a1-u06-l4','multiple_choice',20,'practice','easy',false,'{"question":"___ hour (a/an)","options":[{"id":"a","text":"an"},{"id":"b","text":"a"},{"id":"c","text":"the"}],"correctOptionId":"a","explanationVi":"hour đọc âm nguyên âm → an hour."}'::jsonb),
 ('a1-u06-l4-p5','a1-u06-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"I have a cat. ___ cat is white. (a/the)","acceptedAnswers":["The","the"],"explanationVi":"nhắc lại → The cat."}'::jsonb),
 ('a1-u06-l4-p6','a1-u06-l4','multiple_choice',22,'practice','hard',false,'{"question":"Câu ĐÚNG:","options":[{"id":"a","text":"She is an engineer."},{"id":"b","text":"She is a engineer."},{"id":"c","text":"She is engineer."}],"correctOptionId":"a","explanationVi":"an engineer (nguyên âm)."}'::jsonb),
 ('a1-u06-l4-q5','a1-u06-l4','grammar_fill_blank',23,'quiz','medium',true,'{"question":"___ apple (a/an)","acceptedAnswers":["an"],"explanationVi":"an apple."}'::jsonb),
 ('a1-u06-l4-q6','a1-u06-l4','multiple_choice',24,'quiz','hard',true,'{"question":"Lần ĐẦU nhắc tới vật, dùng:","options":[{"id":"a","text":"a/an"},{"id":"b","text":"the"},{"id":"c","text":"không cần mạo từ"}],"correctOptionId":"a","explanationVi":"Lần đầu → a/an."}'::jsonb);

-- ── UNIT 7 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u07-l1 (+2 prac, +1 quiz)
 ('a1-u07-l1-p5','a1-u07-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"dance\" nghĩa là:","options":[{"id":"a","text":"nhảy/múa"},{"id":"b","text":"hát"},{"id":"c","text":"bơi"}],"correctOptionId":"a","explanationVi":"dance = nhảy."}'::jsonb),
 ('a1-u07-l1-p6','a1-u07-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"She ___ swim. (có thể)","acceptedAnswers":["can"],"explanationVi":"can + V."}'::jsonb),
 ('a1-u07-l1-q6','a1-u07-l1','multiple_choice',22,'quiz','hard',true,'{"question":"Phủ định ĐÚNG:","options":[{"id":"a","text":"I can''t cook."},{"id":"b","text":"I don''t can cook."},{"id":"c","text":"I not can cook."}],"correctOptionId":"a","explanationVi":"can''t = cannot."}'::jsonb),
 -- u07-l2 (+2 prac, +1 quiz)
 ('a1-u07-l2-p5','a1-u07-l2','multiple_choice',20,'practice','easy',false,'{"question":"Trả lời \"Can you sing?\" (có):","options":[{"id":"a","text":"Yes, I can."},{"id":"b","text":"Yes, I do."},{"id":"c","text":"Yes, I am."}],"correctOptionId":"a","explanationVi":"Yes, I can."}'::jsonb),
 ('a1-u07-l2-p6','a1-u07-l2','sentence_ordering',21,'practice','medium',false,'{"question":"Sắp xếp câu hỏi:","tokens":["she","Can","dance"],"correctOrder":[1,0,2],"explanationVi":"Can she dance?"}'::jsonb),
 ('a1-u07-l2-q6','a1-u07-l2','multiple_choice',22,'quiz','hard',true,'{"question":"Câu hỏi khả năng ĐÚNG:","options":[{"id":"a","text":"Can they swim?"},{"id":"b","text":"Do they can swim?"},{"id":"c","text":"They can swim?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 -- u07-l3 (+3 prac, +2 quiz)
 ('a1-u07-l3-p4','a1-u07-l3','multiple_choice',20,'practice','easy',false,'{"question":"\"watch TV\" nghĩa là:","options":[{"id":"a","text":"xem TV"},{"id":"b","text":"đọc sách"},{"id":"c","text":"chơi bóng"}],"correctOptionId":"a","explanationVi":"watch TV = xem TV."}'::jsonb),
 ('a1-u07-l3-p5','a1-u07-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"I like ___ books. (read → V-ing)","acceptedAnswers":["reading"],"explanationVi":"like reading books."}'::jsonb),
 ('a1-u07-l3-p6','a1-u07-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"listen to music","right":"nghe nhạc"},{"left":"read books","right":"đọc sách"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u07-l3-q5','a1-u07-l3','multiple_choice',23,'quiz','medium',true,'{"question":"\"play football\" nghĩa là:","options":[{"id":"a","text":"chơi bóng đá"},{"id":"b","text":"xem TV"},{"id":"c","text":"nghe nhạc"}],"correctOptionId":"a","explanationVi":"play football = chơi bóng đá."}'::jsonb),
 ('a1-u07-l3-q6','a1-u07-l3','multiple_choice',24,'quiz','hard',true,'{"question":"Câu ĐÚNG:","options":[{"id":"a","text":"She likes listening to music."},{"id":"b","text":"She like listening to music."},{"id":"c","text":"She likes listen to music."}],"correctOptionId":"a","explanationVi":"She likes + V-ing."}'::jsonb),
 -- u07-l4 (+3 prac, +2 quiz)
 ('a1-u07-l4-p4','a1-u07-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"đứng lên\" =","options":[{"id":"a","text":"Stand up"},{"id":"b","text":"Sit down"},{"id":"c","text":"Open"}],"correctOptionId":"a","explanationVi":"stand up = đứng lên."}'::jsonb),
 ('a1-u07-l4-p5','a1-u07-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"\"___ the door.\" (Đóng)","acceptedAnswers":["Close"],"explanationVi":"Close the door."}'::jsonb),
 ('a1-u07-l4-p6','a1-u07-l4','sentence_ordering',22,'practice','hard',false,'{"question":"Sắp xếp mệnh lệnh:","tokens":["down","Sit","please"],"correctOrder":[1,0,2],"explanationVi":"Sit down, please."}'::jsonb),
 ('a1-u07-l4-q5','a1-u07-l4','multiple_choice',23,'quiz','medium',true,'{"question":"\"open\" nghĩa là:","options":[{"id":"a","text":"mở"},{"id":"b","text":"đóng"},{"id":"c","text":"ngồi"}],"correctOptionId":"a","explanationVi":"open = mở."}'::jsonb),
 ('a1-u07-l4-q6','a1-u07-l4','multiple_choice',24,'quiz','hard',true,'{"question":"Mệnh lệnh phủ định ĐÚNG:","options":[{"id":"a","text":"Don''t run!"},{"id":"b","text":"No run!"},{"id":"c","text":"Not run!"}],"correctOptionId":"a","explanationVi":"Don''t + V."}'::jsonb);

-- ── UNIT 8 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u08-l1 (+2 prac, +2 quiz)
 ('a1-u08-l1-p5','a1-u08-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"park\" nghĩa là:","options":[{"id":"a","text":"công viên"},{"id":"b","text":"chợ"},{"id":"c","text":"bệnh viện"}],"correctOptionId":"a","explanationVi":"park = công viên."}'::jsonb),
 ('a1-u08-l1-p6','a1-u08-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"There ___ a market here. (to be số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u08-l1-q5','a1-u08-l1','multiple_choice',22,'quiz','medium',true,'{"question":"\"school\" nghĩa là:","options":[{"id":"a","text":"trường học"},{"id":"b","text":"chợ"},{"id":"c","text":"công viên"}],"correctOptionId":"a","explanationVi":"school = trường học."}'::jsonb),
 ('a1-u08-l1-q6','a1-u08-l1','vocabulary_match',23,'quiz','hard',true,'{"question":"Nối địa điểm:","pairs":[{"left":"hospital","right":"bệnh viện"},{"left":"bank","right":"ngân hàng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 -- u08-l2 (+2 prac, +1 quiz)
 ('a1-u08-l2-p5','a1-u08-l2','multiple_choice',20,'practice','easy',false,'{"question":"\"under\" nghĩa là:","options":[{"id":"a","text":"dưới"},{"id":"b","text":"trên"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"under = dưới."}'::jsonb),
 ('a1-u08-l2-p6','a1-u08-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"The cat is ___ the chair. (cạnh)","acceptedAnswers":["next to"],"explanationVi":"next to = cạnh."}'::jsonb),
 ('a1-u08-l2-q6','a1-u08-l2','multiple_choice',22,'quiz','hard',true,'{"question":"Bút BÊN TRONG hộp — câu ĐÚNG:","options":[{"id":"a","text":"The pen is in the box."},{"id":"b","text":"The pen is on the box."},{"id":"c","text":"The pen is under the box."}],"correctOptionId":"a","explanationVi":"in = bên trong."}'::jsonb),
 -- u08-l3 (+3 prac, +2 quiz)
 ('a1-u08-l3-p4','a1-u08-l3','multiple_choice',20,'practice','easy',false,'{"question":"\"rẽ phải\" =","options":[{"id":"a","text":"turn right"},{"id":"b","text":"turn left"},{"id":"c","text":"go straight"}],"correctOptionId":"a","explanationVi":"turn right = rẽ phải."}'::jsonb),
 ('a1-u08-l3-p5','a1-u08-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"___ is the post office? (hỏi nơi)","acceptedAnswers":["Where"],"explanationVi":"Where is...?"}'::jsonb),
 ('a1-u08-l3-p6','a1-u08-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"turn left","right":"rẽ trái"},{"left":"go straight","right":"đi thẳng"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l3-q5','a1-u08-l3','multiple_choice',23,'quiz','medium',true,'{"question":"\"turn left\" nghĩa là:","options":[{"id":"a","text":"rẽ trái"},{"id":"b","text":"rẽ phải"},{"id":"c","text":"đi thẳng"}],"correctOptionId":"a","explanationVi":"turn left = rẽ trái."}'::jsonb),
 ('a1-u08-l3-q6','a1-u08-l3','sentence_ordering',24,'quiz','hard',true,'{"question":"Sắp xếp chỉ dẫn:","tokens":["straight","Go","ahead"],"correctOrder":[1,0,2],"explanationVi":"Go straight ahead."}'::jsonb),
 -- u08-l4 (+4 prac, +2 quiz)
 ('a1-u08-l4-p3','a1-u08-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"near\" nghĩa là:","options":[{"id":"a","text":"gần"},{"id":"b","text":"xa"},{"id":"c","text":"trên"}],"correctOptionId":"a","explanationVi":"near = gần."}'::jsonb),
 ('a1-u08-l4-p4','a1-u08-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"There ___ two shops. (to be số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u08-l4-p5','a1-u08-l4','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"near","right":"gần"},{"left":"in front of","right":"phía trước"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u08-l4-p6','a1-u08-l4','multiple_choice',23,'practice','hard',false,'{"question":"\"next to\" nghĩa là:","options":[{"id":"a","text":"cạnh"},{"id":"b","text":"trước"},{"id":"c","text":"sau"}],"correctOptionId":"a","explanationVi":"next to = cạnh."}'::jsonb),
 ('a1-u08-l4-q5','a1-u08-l4','multiple_choice',24,'quiz','medium',true,'{"question":"\"in front of\" nghĩa là:","options":[{"id":"a","text":"phía trước"},{"id":"b","text":"phía sau"},{"id":"c","text":"bên cạnh"}],"correctOptionId":"a","explanationVi":"in front of = phía trước."}'::jsonb),
 ('a1-u08-l4-q6','a1-u08-l4','grammar_fill_blank',25,'quiz','hard',true,'{"question":"There ___ a park near my house. (to be số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb);

-- ── UNIT 9 ───────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u09-l1 (+3 prac, +2 quiz)
 ('a1-u09-l1-p4','a1-u09-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"bathroom\" nghĩa là:","options":[{"id":"a","text":"phòng tắm"},{"id":"b","text":"nhà bếp"},{"id":"c","text":"phòng ngủ"}],"correctOptionId":"a","explanationVi":"bathroom = phòng tắm."}'::jsonb),
 ('a1-u09-l1-p5','a1-u09-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"We watch TV in the ___. (phòng khách)","acceptedAnswers":["living room"],"explanationVi":"living room = phòng khách."}'::jsonb),
 ('a1-u09-l1-p6','a1-u09-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối phòng:","pairs":[{"left":"kitchen","right":"nhà bếp"},{"left":"bedroom","right":"phòng ngủ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l1-q5','a1-u09-l1','multiple_choice',23,'quiz','medium',true,'{"question":"Ngủ ở phòng nào?","options":[{"id":"a","text":"bedroom"},{"id":"b","text":"kitchen"},{"id":"c","text":"bathroom"}],"correctOptionId":"a","explanationVi":"bedroom = phòng ngủ."}'::jsonb),
 ('a1-u09-l1-q6','a1-u09-l1','grammar_fill_blank',24,'quiz','hard',true,'{"question":"I cook in the ___. (nhà bếp)","acceptedAnswers":["kitchen"],"explanationVi":"kitchen = nhà bếp."}'::jsonb),
 -- u09-l2 (+3 prac, +2 quiz)
 ('a1-u09-l2-p4','a1-u09-l2','multiple_choice',20,'practice','easy',false,'{"question":"\"table\" nghĩa là:","options":[{"id":"a","text":"cái bàn"},{"id":"b","text":"giường"},{"id":"c","text":"ghế sofa"}],"correctOptionId":"a","explanationVi":"table = cái bàn."}'::jsonb),
 ('a1-u09-l2-p5','a1-u09-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"The food is in the ___. (tủ lạnh)","acceptedAnswers":["fridge"],"explanationVi":"fridge = tủ lạnh."}'::jsonb),
 ('a1-u09-l2-p6','a1-u09-l2','vocabulary_match',22,'practice','medium',false,'{"question":"Nối đồ đạc:","pairs":[{"left":"sofa","right":"ghế sofa"},{"left":"bed","right":"giường"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l2-q5','a1-u09-l2','multiple_choice',23,'quiz','medium',true,'{"question":"\"TV\" để xem ở:","options":[{"id":"a","text":"living room"},{"id":"b","text":"bathroom"},{"id":"c","text":"kitchen"}],"correctOptionId":"a","explanationVi":"TV thường ở living room."}'::jsonb),
 ('a1-u09-l2-q6','a1-u09-l2','vocabulary_match',24,'quiz','hard',true,'{"question":"Nối đồ đạc:","pairs":[{"left":"fridge","right":"tủ lạnh"},{"left":"table","right":"cái bàn"}],"explanationVi":"Ghép đúng."}'::jsonb),
 -- u09-l3 (+3 prac, +1 quiz)
 ('a1-u09-l3-p4','a1-u09-l3','multiple_choice',20,'practice','easy',false,'{"question":"There ___ a bed. (số ít)","options":[{"id":"a","text":"is"},{"id":"b","text":"are"},{"id":"c","text":"be"}],"correctOptionId":"a","explanationVi":"There is + số ít."}'::jsonb),
 ('a1-u09-l3-p5','a1-u09-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"There ___ two sofas. (số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l3-p6','a1-u09-l3','multiple_choice',22,'practice','hard',false,'{"question":"Phủ định (không có ghế):","options":[{"id":"a","text":"There isn''t a chair."},{"id":"b","text":"There aren''t a chair."},{"id":"c","text":"There no chair."}],"correctOptionId":"a","explanationVi":"số ít → There isn''t."}'::jsonb),
 ('a1-u09-l3-q6','a1-u09-l3','grammar_fill_blank',23,'quiz','hard',true,'{"question":"There ___ five chairs. (số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 -- u09-l4 (+4 prac, +2 quiz)
 ('a1-u09-l4-p3','a1-u09-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"small\" nghĩa là:","options":[{"id":"a","text":"nhỏ"},{"id":"b","text":"to"},{"id":"c","text":"cũ"}],"correctOptionId":"a","explanationVi":"small = nhỏ."}'::jsonb),
 ('a1-u09-l4-p4','a1-u09-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"There ___ three rooms. (số nhiều)","acceptedAnswers":["are"],"explanationVi":"There are + số nhiều."}'::jsonb),
 ('a1-u09-l4-p5','a1-u09-l4','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"big","right":"to"},{"left":"small","right":"nhỏ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u09-l4-p6','a1-u09-l4','multiple_choice',23,'practice','hard',false,'{"question":"\"living room\" là:","options":[{"id":"a","text":"phòng khách"},{"id":"b","text":"nhà bếp"},{"id":"c","text":"phòng ngủ"}],"correctOptionId":"a","explanationVi":"living room = phòng khách."}'::jsonb),
 ('a1-u09-l4-q5','a1-u09-l4','multiple_choice',24,'quiz','medium',true,'{"question":"\"big\" nghĩa là:","options":[{"id":"a","text":"to"},{"id":"b","text":"nhỏ"},{"id":"c","text":"cũ"}],"correctOptionId":"a","explanationVi":"big = to."}'::jsonb),
 ('a1-u09-l4-q6','a1-u09-l4','grammar_fill_blank',25,'quiz','hard',true,'{"question":"There ___ a sofa in the living room. (số ít)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb);

-- ── UNIT 10 ──────────────────────────────────────────────────────────────────
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 -- u10-l1 (+3 prac, +2 quiz)
 ('a1-u10-l1-p4','a1-u10-l1','multiple_choice',20,'practice','easy',false,'{"question":"\"cold\" nghĩa là:","options":[{"id":"a","text":"lạnh"},{"id":"b","text":"nóng"},{"id":"c","text":"nắng"}],"correctOptionId":"a","explanationVi":"cold = lạnh."}'::jsonb),
 ('a1-u10-l1-p5','a1-u10-l1','grammar_fill_blank',21,'practice','medium',false,'{"question":"___ rainy today. (điền It''s)","acceptedAnswers":["It''s","Its","It is"],"explanationVi":"It''s rainy."}'::jsonb),
 ('a1-u10-l1-p6','a1-u10-l1','vocabulary_match',22,'practice','medium',false,'{"question":"Nối thời tiết:","pairs":[{"left":"sunny","right":"nắng"},{"left":"rainy","right":"mưa"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l1-q5','a1-u10-l1','multiple_choice',23,'quiz','medium',true,'{"question":"\"sunny\" nghĩa là:","options":[{"id":"a","text":"nắng"},{"id":"b","text":"mưa"},{"id":"c","text":"lạnh"}],"correctOptionId":"a","explanationVi":"sunny = nắng."}'::jsonb),
 ('a1-u10-l1-q6','a1-u10-l1','grammar_fill_blank',24,'quiz','hard',true,'{"question":"\"It''s ___ cold today.\" (rất)","acceptedAnswers":["very"],"explanationVi":"very + adj."}'::jsonb),
 -- u10-l2 (+3 prac, +2 quiz)
 ('a1-u10-l2-p4','a1-u10-l2','multiple_choice',20,'practice','easy',false,'{"question":"\"dress\" nghĩa là:","options":[{"id":"a","text":"váy/đầm"},{"id":"b","text":"giày"},{"id":"c","text":"mũ"}],"correctOptionId":"a","explanationVi":"dress = váy."}'::jsonb),
 ('a1-u10-l2-p5','a1-u10-l2','grammar_fill_blank',21,'practice','medium',false,'{"question":"I wear a blue ___. (áo sơ mi)","acceptedAnswers":["shirt"],"explanationVi":"shirt = áo sơ mi."}'::jsonb),
 ('a1-u10-l2-p6','a1-u10-l2','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"shoes","right":"giày"},{"left":"dress","right":"váy"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l2-q5','a1-u10-l2','multiple_choice',23,'quiz','medium',true,'{"question":"\"hat\" nghĩa là:","options":[{"id":"a","text":"mũ"},{"id":"b","text":"giày"},{"id":"c","text":"váy"}],"correctOptionId":"a","explanationVi":"hat = mũ."}'::jsonb),
 ('a1-u10-l2-q6','a1-u10-l2','multiple_choice',24,'quiz','hard',true,'{"question":"Cụm ĐÚNG:","options":[{"id":"a","text":"a blue shirt"},{"id":"b","text":"a shirt blue"},{"id":"c","text":"blue a shirt"}],"correctOptionId":"a","explanationVi":"a + màu + danh từ."}'::jsonb),
 -- u10-l3 (+3 prac, +2 quiz)
 ('a1-u10-l3-p4','a1-u10-l3','multiple_choice',20,'practice','easy',false,'{"question":"\"buy\" nghĩa là:","options":[{"id":"a","text":"mua"},{"id":"b","text":"bán"},{"id":"c","text":"giá"}],"correctOptionId":"a","explanationVi":"buy = mua."}'::jsonb),
 ('a1-u10-l3-p5','a1-u10-l3','grammar_fill_blank',21,'practice','medium',false,'{"question":"How much ___ it? (to be)","acceptedAnswers":["is"],"explanationVi":"How much is it?"}'::jsonb),
 ('a1-u10-l3-p6','a1-u10-l3','vocabulary_match',22,'practice','medium',false,'{"question":"Nối:","pairs":[{"left":"expensive","right":"đắt"},{"left":"cheap","right":"rẻ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-u10-l3-q5','a1-u10-l3','multiple_choice',23,'quiz','medium',true,'{"question":"\"price\" nghĩa là:","options":[{"id":"a","text":"giá"},{"id":"b","text":"mua"},{"id":"c","text":"rẻ"}],"correctOptionId":"a","explanationVi":"price = giá."}'::jsonb),
 ('a1-u10-l3-q6','a1-u10-l3','grammar_fill_blank',24,'quiz','hard',true,'{"question":"\"It''s ten ___.\" (đơn vị tiền)","acceptedAnswers":["dollars","dollar"],"explanationVi":"ten dollars."}'::jsonb),
 -- u10-l4 (+3 prac, +2 quiz)
 ('a1-u10-l4-p4','a1-u10-l4','multiple_choice',20,'practice','easy',false,'{"question":"\"tomorrow\" nghĩa là:","options":[{"id":"a","text":"ngày mai"},{"id":"b","text":"hôm qua"},{"id":"c","text":"hôm nay"}],"correctOptionId":"a","explanationVi":"tomorrow = ngày mai."}'::jsonb),
 ('a1-u10-l4-p5','a1-u10-l4','grammar_fill_blank',21,'practice','medium',false,'{"question":"She ___ going to study. (to be)","acceptedAnswers":["is"],"explanationVi":"She is going to."}'::jsonb),
 ('a1-u10-l4-p6','a1-u10-l4','listening_choice',22,'practice','hard',false,'{"question":"Nghe và chọn kế hoạch:","audioText":"I am going to read a book.","options":[{"id":"a","text":"đọc sách"},{"id":"b","text":"chơi bóng"},{"id":"c","text":"nấu ăn"}],"correctOptionId":"a","explanationVi":"going to read a book = sẽ đọc sách."}'::jsonb),
 ('a1-u10-l4-q5','a1-u10-l4','multiple_choice',23,'quiz','medium',true,'{"question":"Câu kế hoạch ĐÚNG:","options":[{"id":"a","text":"We are going to travel."},{"id":"b","text":"We going to travel."},{"id":"c","text":"We are go to travel."}],"correctOptionId":"a","explanationVi":"to be + going to + V."}'::jsonb),
 ('a1-u10-l4-q6','a1-u10-l4','listening_choice',24,'quiz','hard',true,'{"question":"Nghe và chọn thời tiết:","audioText":"It is going to be sunny.","options":[{"id":"a","text":"sắp nắng"},{"id":"b","text":"sắp mưa"},{"id":"c","text":"sắp lạnh"}],"correctOptionId":"a","explanationVi":"going to be sunny = sắp nắng."}'::jsonb);
