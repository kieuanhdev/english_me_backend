-- =============================================================================
-- V29 — Pha 5: Seed thêm Unit A1 (đủ độ phủ ≥80% mở checkpoint) + 1 Unit A2
-- =============================================================================
-- Mục tiêu: demo lên cấp A1→A2 end-to-end.
--   * Thêm 4 Unit A1 (display_order 2..5) → tổng 5 Unit A1 (gồm Greetings của V27).
--     Hoàn thành 4/5 = 80% ⇒ mở Level Checkpoint A1.
--   * Thêm 1 Unit A2 (display_order 1) để sau khi lên cấp có nội dung học ngay.
-- Mỗi lesson: 2 câu practice (không tính điểm) + 3 câu quiz (tính điểm) — đủ BẤT BIẾN §H.
-- Định dạng khớp V27 / FE curriculum_models.dart.
-- =============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ UNITS                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
    ('a1-unit-family',   'A1', 'Family & People',   'Gia đình và miêu tả người',        'people',   '["vocabulary","grammar"]'::jsonb, 2),
    ('a1-unit-daily',    'A1', 'Daily Routine',     'Thói quen hằng ngày, thì hiện tại', 'routine',  '["vocabulary","grammar"]'::jsonb, 3),
    ('a1-unit-food',     'A1', 'Food & Drink',      'Đồ ăn thức uống',                   'food',     '["vocabulary","reading"]'::jsonb, 4),
    ('a1-unit-numbers',  'A1', 'Numbers & Time',    'Số đếm và giờ giấc',                'time',     '["vocabulary","grammar"]'::jsonb, 5),
    ('a2-unit-activities','A2', 'Daily Activities', 'Hoạt động thường ngày (A2)',        'routine',  '["vocabulary","grammar","reading"]'::jsonb, 1);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A1 — UNIT 2: Family & People                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-family-l1','A1','reading','a1-unit-family','normal',1,'Family members','Thành viên gia đình',7,15,70,'{}'::jsonb,
  '{"warmup":"Gia đình bạn có những ai?","objectives":["Gọi tên các thành viên gia đình"],
    "vocabBlock":[
      {"word":"father","ipa":"/ˈfɑːðər/","meaningVi":"bố","example":"My father is a doctor."},
      {"word":"mother","ipa":"/ˈmʌðər/","meaningVi":"mẹ","example":"My mother is a teacher."},
      {"word":"sister","ipa":"/ˈsɪstər/","meaningVi":"chị/em gái","example":"I have one sister."},
      {"word":"brother","ipa":"/ˈbrʌðər/","meaningVi":"anh/em trai","example":"He is my brother."}],
    "examples":[{"en":"This is my family.","vi":"Đây là gia đình tôi."}],
    "commonMistakes":["❌ \"my father he is\" → ✅ \"my father is\""],"tips":["family là danh từ số ít."]}'::jsonb),
 ('a1-family-l2','A1','grammar','a1-unit-family','normal',2,'Possessive: my/your/his/her','Sở hữu cách',8,15,70,'{}'::jsonb,
  '{"warmup":"\"My\" và \"your\" khác nhau thế nào?","objectives":["Dùng my/your/his/her"],
    "grammarHtml":"my (của tôi), your (của bạn), his (của anh ấy), her (của cô ấy).",
    "vocabBlock":[],"examples":[{"en":"This is her mother.","vi":"Đây là mẹ của cô ấy."}],
    "commonMistakes":["❌ \"she book\" → ✅ \"her book\""],"tips":["his đi với nam, her đi với nữ."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-family-l1-p1','a1-family-l1','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"father","right":"bố"},{"left":"mother","right":"mẹ"},{"left":"sister","right":"chị/em gái"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-family-l1-p2','a1-family-l1','grammar_fill_blank',2,'practice','easy',false,
  '{"question":"My ___ is a doctor. (bố)","acceptedAnswers":["father"],"explanationVi":"father = bố."}'::jsonb),
 ('a1-family-l1-q1','a1-family-l1','multiple_choice',3,'quiz','easy',true,
  '{"question":"\"mother\" nghĩa là gì?","options":[{"id":"a","text":"bố"},{"id":"b","text":"mẹ"},{"id":"c","text":"chị"}],"correctOptionId":"b","explanationVi":"mother = mẹ."}'::jsonb),
 ('a1-family-l1-q2','a1-family-l1','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn từ chỉ anh/em trai:","options":[{"id":"a","text":"sister"},{"id":"b","text":"brother"},{"id":"c","text":"father"}],"correctOptionId":"b","explanationVi":"brother = anh/em trai."}'::jsonb),
 ('a1-family-l1-q3','a1-family-l1','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"My ___ is a teacher. (mẹ)","acceptedAnswers":["mother"],"explanationVi":"mother = mẹ."}'::jsonb),
 ('a1-family-l2-p1','a1-family-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"This is ___ book. (của tôi)","options":[{"id":"a","text":"my"},{"id":"b","text":"your"},{"id":"c","text":"her"}],"correctOptionId":"a","explanationVi":"my = của tôi."}'::jsonb),
 ('a1-family-l2-p2','a1-family-l2','grammar_fill_blank',2,'practice','medium',false,
  '{"question":"She loves ___ mother. (của cô ấy)","acceptedAnswers":["her"],"explanationVi":"her = của cô ấy."}'::jsonb),
 ('a1-family-l2-q1','a1-family-l2','multiple_choice',3,'quiz','medium',true,
  '{"question":"He loves ___ father. (của anh ấy)","options":[{"id":"a","text":"her"},{"id":"b","text":"his"},{"id":"c","text":"my"}],"correctOptionId":"b","explanationVi":"his = của anh ấy."}'::jsonb),
 ('a1-family-l2-q2','a1-family-l2','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"This is ___ name? (của bạn)","acceptedAnswers":["your"],"explanationVi":"your = của bạn."}'::jsonb),
 ('a1-family-l2-q3','a1-family-l2','multiple_choice',5,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"This is she book."},{"id":"b","text":"This is her book."},{"id":"c","text":"This is hers book."}],"correctOptionId":"b","explanationVi":"her + danh từ."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A1 — UNIT 3: Daily Routine                                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-daily-l1','A1','reading','a1-unit-daily','normal',1,'Daily actions','Hành động hằng ngày',7,15,70,'{}'::jsonb,
  '{"warmup":"Mỗi sáng bạn làm gì đầu tiên?","objectives":["Động từ chỉ hoạt động hằng ngày"],
    "vocabBlock":[
      {"word":"wake up","ipa":"/weɪk ʌp/","meaningVi":"thức dậy","example":"I wake up at 6."},
      {"word":"eat breakfast","ipa":"/iːt ˈbrekfəst/","meaningVi":"ăn sáng","example":"I eat breakfast at 7."},
      {"word":"go to school","ipa":"/ɡəʊ tə skuːl/","meaningVi":"đi học","example":"I go to school at 8."}],
    "examples":[{"en":"I wake up early.","vi":"Tôi thức dậy sớm."}],
    "commonMistakes":["❌ \"I wakes up\" → ✅ \"I wake up\""],"tips":["Chủ ngữ I đi với động từ nguyên thể."]}'::jsonb),
 ('a1-daily-l2','A1','grammar','a1-unit-daily','normal',2,'Present simple','Thì hiện tại đơn',9,15,70,'{}'::jsonb,
  '{"warmup":"Vì sao \"He plays\" có thêm s?","objectives":["Chia động từ thì hiện tại đơn"],
    "grammarHtml":"I/you/we/they + V. He/she/it + V-s. VD: I play / He plays.",
    "vocabBlock":[],"examples":[{"en":"She goes to school.","vi":"Cô ấy đi học."}],
    "commonMistakes":["❌ \"He go\" → ✅ \"He goes\""],"tips":["Ngôi thứ 3 số ít thêm -s/-es."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-daily-l1-p1','a1-daily-l1','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"wake up","right":"thức dậy"},{"left":"eat breakfast","right":"ăn sáng"},{"left":"go to school","right":"đi học"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-daily-l1-p2','a1-daily-l1','sentence_ordering',2,'practice','medium',false,
  '{"question":"Sắp xếp câu:","tokens":["up","I","wake","early"],"correctOrder":[1,2,0,3],"explanationVi":"I wake up early."}'::jsonb),
 ('a1-daily-l1-q1','a1-daily-l1','multiple_choice',3,'quiz','easy',true,
  '{"question":"\"wake up\" nghĩa là gì?","options":[{"id":"a","text":"đi ngủ"},{"id":"b","text":"thức dậy"},{"id":"c","text":"ăn sáng"}],"correctOptionId":"b","explanationVi":"wake up = thức dậy."}'::jsonb),
 ('a1-daily-l1-q2','a1-daily-l1','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"I ___ breakfast at 7. (ăn)","acceptedAnswers":["eat"],"explanationVi":"eat breakfast = ăn sáng."}'::jsonb),
 ('a1-daily-l1-q3','a1-daily-l1','multiple_choice',5,'quiz','medium',true,
  '{"question":"Chọn cụm \"đi học\":","options":[{"id":"a","text":"go to school"},{"id":"b","text":"go to bed"},{"id":"c","text":"wake up"}],"correctOptionId":"a","explanationVi":"go to school = đi học."}'::jsonb),
 ('a1-daily-l2-p1','a1-daily-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"He ___ football. (chơi)","options":[{"id":"a","text":"play"},{"id":"b","text":"plays"},{"id":"c","text":"playing"}],"correctOptionId":"b","explanationVi":"He + plays (thêm s)."}'::jsonb),
 ('a1-daily-l2-p2','a1-daily-l2','error_correction',2,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"She go to school.","acceptedAnswers":["She goes to school.","She goes to school"],"explanationVi":"She + goes."}'::jsonb),
 ('a1-daily-l2-q1','a1-daily-l2','multiple_choice',3,'quiz','medium',true,
  '{"question":"She ___ to school. (đi)","options":[{"id":"a","text":"go"},{"id":"b","text":"goes"},{"id":"c","text":"going"}],"correctOptionId":"b","explanationVi":"She + goes."}'::jsonb),
 ('a1-daily-l2-q2','a1-daily-l2','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"They ___ football every day. (chơi)","acceptedAnswers":["play"],"explanationVi":"They + play (không thêm s)."}'::jsonb),
 ('a1-daily-l2-q3','a1-daily-l2','multiple_choice',5,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"He go home."},{"id":"b","text":"He goes home."},{"id":"c","text":"He going home."}],"correctOptionId":"b","explanationVi":"He + goes."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A1 — UNIT 4: Food & Drink                                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-food-l1','A1','reading','a1-unit-food','normal',1,'Food vocabulary','Từ vựng đồ ăn',7,15,70,'{}'::jsonb,
  '{"warmup":"Món bạn thích nhất là gì?","objectives":["Gọi tên đồ ăn thức uống cơ bản"],
    "vocabBlock":[
      {"word":"rice","ipa":"/raɪs/","meaningVi":"cơm","example":"I eat rice every day."},
      {"word":"water","ipa":"/ˈwɔːtər/","meaningVi":"nước","example":"I drink water."},
      {"word":"apple","ipa":"/ˈæpl/","meaningVi":"táo","example":"An apple a day."}],
    "examples":[{"en":"I like rice and fish.","vi":"Tôi thích cơm và cá."}],
    "commonMistakes":["❌ \"a water\" → ✅ \"some water\" (không đếm được)"],"tips":["water là danh từ không đếm được."]}'::jsonb),
 ('a1-food-l2','A1','reading','a1-unit-food','normal',2,'I like / I don''t like','Diễn đạt sở thích',8,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao nói bạn không thích món gì?","objectives":["Dùng I like / I don''t like"],
    "grammarHtml":"I like + N. I don''t like + N. VD: I like tea. I don''t like coffee.",
    "vocabBlock":[],"examples":[{"en":"I don''t like coffee.","vi":"Tôi không thích cà phê."}],
    "commonMistakes":["❌ \"I no like\" → ✅ \"I don''t like\""],"tips":["don''t = do not."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-food-l1-p1','a1-food-l1','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"rice","right":"cơm"},{"left":"water","right":"nước"},{"left":"apple","right":"táo"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-food-l1-p2','a1-food-l1','grammar_fill_blank',2,'practice','easy',false,
  '{"question":"I drink ___ every day. (nước)","acceptedAnswers":["water"],"explanationVi":"water = nước."}'::jsonb),
 ('a1-food-l1-q1','a1-food-l1','multiple_choice',3,'quiz','easy',true,
  '{"question":"\"rice\" nghĩa là gì?","options":[{"id":"a","text":"cơm"},{"id":"b","text":"nước"},{"id":"c","text":"táo"}],"correctOptionId":"a","explanationVi":"rice = cơm."}'::jsonb),
 ('a1-food-l1-q2','a1-food-l1','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn từ chỉ trái táo:","options":[{"id":"a","text":"water"},{"id":"b","text":"apple"},{"id":"c","text":"rice"}],"correctOptionId":"b","explanationVi":"apple = táo."}'::jsonb),
 ('a1-food-l1-q3','a1-food-l1','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"I eat ___ every day. (cơm)","acceptedAnswers":["rice"],"explanationVi":"rice = cơm."}'::jsonb),
 ('a1-food-l2-p1','a1-food-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"I ___ tea. (thích)","options":[{"id":"a","text":"like"},{"id":"b","text":"likes"},{"id":"c","text":"liking"}],"correctOptionId":"a","explanationVi":"I + like."}'::jsonb),
 ('a1-food-l2-p2','a1-food-l2','error_correction',2,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"I no like coffee.","acceptedAnswers":["I don''t like coffee.","I do not like coffee.","I dont like coffee"],"explanationVi":"I don''t like + N."}'::jsonb),
 ('a1-food-l2-q1','a1-food-l2','multiple_choice',3,'quiz','medium',true,
  '{"question":"Chọn câu phủ định ĐÚNG:","options":[{"id":"a","text":"I no like fish."},{"id":"b","text":"I don''t like fish."},{"id":"c","text":"I not like fish."}],"correctOptionId":"b","explanationVi":"I don''t like + N."}'::jsonb),
 ('a1-food-l2-q2','a1-food-l2','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"I ___ rice. (thích)","acceptedAnswers":["like"],"explanationVi":"I + like."}'::jsonb),
 ('a1-food-l2-q3','a1-food-l2','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"I don''t like\" nghĩa là gì?","options":[{"id":"a","text":"Tôi thích"},{"id":"b","text":"Tôi không thích"},{"id":"c","text":"Tôi rất thích"}],"correctOptionId":"b","explanationVi":"don''t like = không thích."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A1 — UNIT 5: Numbers & Time                                                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-numbers-l1','A1','reading','a1-unit-numbers','normal',1,'Numbers 1-10','Số đếm 1-10',6,15,70,'{}'::jsonb,
  '{"warmup":"Đếm từ 1 đến 5 bằng tiếng Anh?","objectives":["Đếm số 1-10"],
    "vocabBlock":[
      {"word":"one","ipa":"/wʌn/","meaningVi":"một","example":"I have one book."},
      {"word":"two","ipa":"/tuː/","meaningVi":"hai","example":"Two apples."},
      {"word":"three","ipa":"/θriː/","meaningVi":"ba","example":"Three cats."}],
    "examples":[{"en":"I have two sisters.","vi":"Tôi có hai chị em gái."}],
    "commonMistakes":["❌ \"to\" và \"two\" khác nghĩa."],"tips":["three bắt đầu bằng âm /θ/."]}'::jsonb),
 ('a1-numbers-l2','A1','grammar','a1-unit-numbers','normal',2,'What time is it?','Hỏi giờ',8,15,70,'{}'::jsonb,
  '{"warmup":"Bây giờ là mấy giờ?","objectives":["Hỏi và trả lời giờ"],
    "grammarHtml":"What time is it? – It''s + giờ. VD: It''s seven o''clock.",
    "vocabBlock":[],"examples":[{"en":"What time is it? It''s nine.","vi":"Mấy giờ rồi? 9 giờ."}],
    "commonMistakes":["❌ \"What time is?\" → ✅ \"What time is it?\""],"tips":["o''clock dùng cho giờ chẵn."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-numbers-l1-p1','a1-numbers-l1','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối số với chữ:","pairs":[{"left":"one","right":"một"},{"left":"two","right":"hai"},{"left":"three","right":"ba"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-numbers-l1-p2','a1-numbers-l1','grammar_fill_blank',2,'practice','easy',false,
  '{"question":"I have ___ book. (một)","acceptedAnswers":["one"],"explanationVi":"one = một."}'::jsonb),
 ('a1-numbers-l1-q1','a1-numbers-l1','multiple_choice',3,'quiz','easy',true,
  '{"question":"\"three\" là số mấy?","options":[{"id":"a","text":"2"},{"id":"b","text":"3"},{"id":"c","text":"4"}],"correctOptionId":"b","explanationVi":"three = ba = 3."}'::jsonb),
 ('a1-numbers-l1-q2','a1-numbers-l1','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"I have ___ apples. (hai)","acceptedAnswers":["two"],"explanationVi":"two = hai."}'::jsonb),
 ('a1-numbers-l1-q3','a1-numbers-l1','multiple_choice',5,'quiz','medium',true,
  '{"question":"Chọn từ chỉ số 1:","options":[{"id":"a","text":"one"},{"id":"b","text":"two"},{"id":"c","text":"three"}],"correctOptionId":"a","explanationVi":"one = 1."}'::jsonb),
 ('a1-numbers-l2-p1','a1-numbers-l2','sentence_ordering',1,'practice','medium',false,
  '{"question":"Sắp xếp câu hỏi giờ:","tokens":["time","What","it","is"],"correctOrder":[1,0,3,2],"explanationVi":"What time is it?"}'::jsonb),
 ('a1-numbers-l2-p2','a1-numbers-l2','multiple_choice',2,'practice','easy',false,
  '{"question":"\"It''s seven ___.\"","options":[{"id":"a","text":"o''clock"},{"id":"b","text":"hour"},{"id":"c","text":"time"}],"correctOptionId":"a","explanationVi":"seven o''clock = 7 giờ."}'::jsonb),
 ('a1-numbers-l2-q1','a1-numbers-l2','grammar_fill_blank',3,'quiz','medium',true,
  '{"question":"What ___ is it? (giờ)","acceptedAnswers":["time"],"explanationVi":"What time is it?"}'::jsonb),
 ('a1-numbers-l2-q2','a1-numbers-l2','multiple_choice',4,'quiz','medium',true,
  '{"question":"Chọn câu hỏi giờ ĐÚNG:","options":[{"id":"a","text":"What time is?"},{"id":"b","text":"What time is it?"},{"id":"c","text":"What is time?"}],"correctOptionId":"b","explanationVi":"What time is it?"}'::jsonb),
 ('a1-numbers-l2-q3','a1-numbers-l2','sentence_ordering',5,'quiz','hard',true,
  '{"question":"Sắp xếp câu trả lời:","tokens":["nine","It''s","o''clock"],"correctOrder":[1,0,2],"explanationVi":"It''s nine o''clock."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A2 — UNIT 1: Daily Activities (demo nội dung sau khi lên cấp)              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-activities-l1','A2','reading','a2-unit-activities','normal',1,'Present continuous','Thì hiện tại tiếp diễn',9,18,70,'{}'::jsonb,
  '{"warmup":"Ngay bây giờ bạn đang làm gì?","objectives":["Dùng thì hiện tại tiếp diễn"],
    "grammarHtml":"am/is/are + V-ing. VD: I am reading. She is cooking.",
    "vocabBlock":[
      {"word":"cooking","ipa":"/ˈkʊkɪŋ/","meaningVi":"đang nấu ăn","example":"She is cooking."},
      {"word":"reading","ipa":"/ˈriːdɪŋ/","meaningVi":"đang đọc","example":"I am reading a book."}],
    "examples":[{"en":"They are playing football.","vi":"Họ đang chơi bóng đá."}],
    "commonMistakes":["❌ \"I reading\" → ✅ \"I am reading\""],"tips":["Luôn có to be trước V-ing."]}'::jsonb),
 ('a2-activities-l2','A2','reading','a2-unit-activities','normal',2,'Adverbs of frequency','Trạng từ tần suất',9,18,70,'{}'::jsonb,
  '{"warmup":"Bạn thường xuyên làm gì?","objectives":["Dùng always/usually/sometimes/never"],
    "grammarHtml":"always (luôn) > usually (thường) > sometimes (thỉnh thoảng) > never (không bao giờ). Đứng trước động từ thường.",
    "vocabBlock":[],"examples":[{"en":"I usually wake up at 6.","vi":"Tôi thường dậy lúc 6 giờ."}],
    "commonMistakes":["❌ \"I go always\" → ✅ \"I always go\""],"tips":["Trạng từ tần suất đứng trước động từ chính."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-act-l1-p1','a2-activities-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"She ___ cooking now.","options":[{"id":"a","text":"is"},{"id":"b","text":"are"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"She + is + V-ing."}'::jsonb),
 ('a2-act-l1-p2','a2-activities-l1','grammar_fill_blank',2,'practice','medium',false,
  '{"question":"I am read___ a book. (đang đọc)","acceptedAnswers":["reading","ing"],"explanationVi":"reading = đang đọc."}'::jsonb),
 ('a2-act-l1-q1','a2-activities-l1','multiple_choice',3,'quiz','medium',true,
  '{"question":"They ___ playing football.","options":[{"id":"a","text":"is"},{"id":"b","text":"are"},{"id":"c","text":"am"}],"correctOptionId":"b","explanationVi":"They + are + V-ing."}'::jsonb),
 ('a2-act-l1-q2','a2-activities-l1','grammar_fill_blank',4,'quiz','medium',true,
  '{"question":"I ___ reading now. (to be)","acceptedAnswers":["am"],"explanationVi":"I + am + V-ing."}'::jsonb),
 ('a2-act-l1-q3','a2-activities-l1','error_correction',5,'quiz','hard',true,
  '{"question":"Sửa câu sai:","sourceText":"He reading a book.","acceptedAnswers":["He is reading a book.","He is reading a book"],"explanationVi":"Thiếu to be: He is reading."}'::jsonb),
 ('a2-act-l2-p1','a2-activities-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"\"always\" nghĩa là gì?","options":[{"id":"a","text":"luôn luôn"},{"id":"b","text":"không bao giờ"},{"id":"c","text":"thỉnh thoảng"}],"correctOptionId":"a","explanationVi":"always = luôn luôn."}'::jsonb),
 ('a2-act-l2-p2','a2-activities-l2','sentence_ordering',2,'practice','hard',false,
  '{"question":"Sắp xếp câu:","tokens":["always","I","early","wake up"],"correctOrder":[1,0,3,2],"explanationVi":"I always wake up early."}'::jsonb),
 ('a2-act-l2-q1','a2-activities-l2','multiple_choice',3,'quiz','medium',true,
  '{"question":"\"never\" nghĩa là gì?","options":[{"id":"a","text":"luôn luôn"},{"id":"b","text":"không bao giờ"},{"id":"c","text":"thường"}],"correctOptionId":"b","explanationVi":"never = không bao giờ."}'::jsonb),
 ('a2-act-l2-q2','a2-activities-l2','multiple_choice',4,'quiz','hard',true,
  '{"question":"Vị trí ĐÚNG của trạng từ:","options":[{"id":"a","text":"I go always to school."},{"id":"b","text":"I always go to school."},{"id":"c","text":"Always I go to school."}],"correctOptionId":"b","explanationVi":"Trạng từ tần suất đứng trước động từ chính."}'::jsonb),
 ('a2-act-l2-q3','a2-activities-l2','grammar_fill_blank',5,'quiz','medium',true,
  '{"question":"I ___ wake up at 6. (thường - usually)","acceptedAnswers":["usually"],"explanationVi":"usually = thường."}'::jsonb);
