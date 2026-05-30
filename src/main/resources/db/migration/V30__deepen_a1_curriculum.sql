-- =============================================================================
-- V30 — LÀM SÂU & CHUẨN HOÁ CẤP A1 (theo khung CEFR A1)
-- =============================================================================
-- Mục tiêu: nội dung A1 đủ sâu để người học THỰC SỰ đạt năng lực A1 → đủ điều kiện
-- lên A2 (không phải câu hỏi cho có). Bám khung CEFR A1 core:
--   chào hỏi · đại từ · to be · this/that · số nhiều · sở hữu · gia đình ·
--   hiện tại đơn · can (khả năng) · giới từ chỉ nơi chốn · số đếm/giờ · đồ ăn.
--
-- Quy tắc an toàn (Flyway không cho sửa V27/V29 đã chạy → CHỈ THÊM ở V30):
--   * Thêm lesson MỚI vào unit cũ với lesson_order nối tiếp (greetings từ 5; các unit 2-lesson từ 3).
--   * Thêm câu hỏi MỚI vào lesson cũ với display_order nối tiếp (không đụng id cũ).
--   * Thêm 3 unit A1 mới (display_order 6,7,8).
-- Mỗi lesson sau khi làm sâu: >= 4 practice + >= 6 quiz (đủ chắc kiến thức).
-- skill_code chỉ dùng: listening|speaking|reading|writing (FK skills).
-- =============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ PHẦN 1 — THÊM CÂU HỎI vào các lesson A1 hiện có (làm dày quiz/practice)     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── Greetings L1 (Hello & Goodbye): đã có p1-p3, q1-q3 → thêm p4-p5, q4-q6 ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l1-p4','a1-unit-greetings-l1','multiple_choice',7,'practice','medium',false,
  '{"question":"Gặp ai đó buổi tối bạn nói gì?","options":[{"id":"a","text":"Good evening"},{"id":"b","text":"Good morning"},{"id":"c","text":"Goodbye"}],"correctOptionId":"a","explanationVi":"Good evening = chào buổi tối."}'::jsonb),
 ('a1-greet-l1-p5','a1-unit-greetings-l1','vocabulary_match',8,'practice','medium',false,
  '{"question":"Nối lời chào với thời điểm:","pairs":[{"left":"Good morning","right":"buổi sáng"},{"left":"Good afternoon","right":"buổi chiều"},{"left":"Good evening","right":"buổi tối"}],"explanationVi":"Mỗi lời chào theo thời điểm trong ngày."}'::jsonb),
 ('a1-greet-l1-q4','a1-unit-greetings-l1','multiple_choice',9,'quiz','easy',true,
  '{"question":"\"Hi\" là cách chào thế nào?","options":[{"id":"a","text":"Thân mật"},{"id":"b","text":"Trang trọng"},{"id":"c","text":"Lời tạm biệt"}],"correctOptionId":"a","explanationVi":"Hi thân mật, dùng với bạn bè."}'::jsonb),
 ('a1-greet-l1-q5','a1-unit-greetings-l1','vocabulary_match',10,'quiz','medium',true,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"Hello","right":"Xin chào"},{"left":"Goodbye","right":"Tạm biệt"},{"left":"See you","right":"Hẹn gặp lại"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a1-greet-l1-q6','a1-unit-greetings-l1','multiple_choice',11,'quiz','hard',true,
  '{"question":"Khi nào KHÔNG dùng \"Good night\"?","options":[{"id":"a","text":"Khi đi ngủ"},{"id":"b","text":"Khi tạm biệt buổi tối"},{"id":"c","text":"Khi gặp nhau buổi sáng"}],"correctOptionId":"c","explanationVi":"Good night không dùng để chào gặp mặt."}'::jsonb);

-- ── Greetings L3 (Verb to be): thêm câu phủ định/nghi vấn ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-greet-l3-p4','a1-unit-greetings-l3','grammar_fill_blank',7,'practice','medium',false,
  '{"question":"Phủ định: \"I ___ not a teacher.\"","acceptedAnswers":["am"],"explanationVi":"I am not."}'::jsonb),
 ('a1-greet-l3-q4','a1-unit-greetings-l3','multiple_choice',8,'quiz','medium',true,
  '{"question":"Chọn câu hỏi ĐÚNG với to be:","options":[{"id":"a","text":"Are you a student?"},{"id":"b","text":"You are student?"},{"id":"c","text":"You student are?"}],"correctOptionId":"a","explanationVi":"Câu hỏi to be: đảo to be lên đầu."}'::jsonb),
 ('a1-greet-l3-q5','a1-unit-greetings-l3','grammar_fill_blank',9,'quiz','medium',true,
  '{"question":"\"We ___ friends.\" (to be)","acceptedAnswers":["are"],"explanationVi":"We đi với are."}'::jsonb);

-- ── Family L1 & L2: thêm câu cho đủ >=6 quiz ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-family-l1-p3','a1-family-l1','multiple_choice',6,'practice','medium',false,
  '{"question":"Bố và mẹ gọi chung là gì?","options":[{"id":"a","text":"parents"},{"id":"b","text":"children"},{"id":"c","text":"friends"}],"correctOptionId":"a","explanationVi":"parents = bố mẹ."}'::jsonb),
 ('a1-family-l1-q4','a1-family-l1','vocabulary_match',7,'quiz','medium',true,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"brother","right":"anh/em trai"},{"left":"parents","right":"bố mẹ"},{"left":"sister","right":"chị/em gái"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-family-l2-q4','a1-family-l2','multiple_choice',6,'quiz','hard',true,
  '{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"Their house is big."},{"id":"b","text":"They house is big."},{"id":"c","text":"Them house is big."}],"correctOptionId":"a","explanationVi":"their = của họ."}'::jsonb);

-- ── Daily L1 & L2: thêm câu ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-daily-l1-q4','a1-daily-l1','vocabulary_match',6,'quiz','medium',true,
  '{"question":"Nối hành động với nghĩa:","pairs":[{"left":"wake up","right":"thức dậy"},{"left":"go to bed","right":"đi ngủ"},{"left":"have lunch","right":"ăn trưa"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-daily-l2-q4','a1-daily-l2','grammar_fill_blank',6,'quiz','hard',true,
  '{"question":"Phủ định: \"She ___ not like coffee.\" (does/do)","acceptedAnswers":["does"],"explanationVi":"Ngôi 3 số ít: does not."}'::jsonb),
 ('a1-daily-l2-q5','a1-daily-l2','multiple_choice',7,'quiz','medium',true,
  '{"question":"Câu hỏi ĐÚNG ở hiện tại đơn:","options":[{"id":"a","text":"Does she go to school?"},{"id":"b","text":"Do she goes to school?"},{"id":"c","text":"She does go school?"}],"correctOptionId":"a","explanationVi":"Does + S + V(nguyên thể)?"}'::jsonb);

-- ── Food & Numbers: thêm câu cho đủ độ sâu ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-food-l1-q4','a1-food-l1','vocabulary_match',6,'quiz','medium',true,
  '{"question":"Nối đồ ăn với nghĩa:","pairs":[{"left":"bread","right":"bánh mì"},{"left":"milk","right":"sữa"},{"left":"fish","right":"cá"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-food-l2-q4','a1-food-l2','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"\"___ you like tea?\" (Do/Does)","acceptedAnswers":["Do"],"explanationVi":"Do you like...?"}'::jsonb),
 ('a1-numbers-l1-q4','a1-numbers-l1','multiple_choice',6,'quiz','medium',true,
  '{"question":"\"five\" là số mấy?","options":[{"id":"a","text":"4"},{"id":"b","text":"5"},{"id":"c","text":"6"}],"correctOptionId":"b","explanationVi":"five = 5."}'::jsonb),
 ('a1-numbers-l2-q4','a1-numbers-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"\"It''s half past six\" nghĩa là mấy giờ?","options":[{"id":"a","text":"6 giờ rưỡi"},{"id":"b","text":"6 giờ"},{"id":"c","text":"5 giờ rưỡi"}],"correctOptionId":"a","explanationVi":"half past six = 6 giờ 30."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ PHẦN 2 — THÊM LESSON MỚI vào unit hiện có (làm sâu)                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- ── Family — Lesson 3: Describing people (tính từ miêu tả) ──
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-family-l3','A1','reading','a1-unit-family','normal',3,'Describing people','Miêu tả người (tall/short/young)',8,15,70,'{}'::jsonb,
  '{"warmup":"Bạn miêu tả người thân của mình thế nào?","objectives":["Dùng tính từ miêu tả ngoại hình","Cấu trúc He/She is + adj"],
    "grammarHtml":"He/She is + tính từ. VD: She is tall. He is young. Tính từ KHÔNG đổi theo số nhiều: They are tall.",
    "vocabBlock":[
      {"word":"tall","ipa":"/tɔːl/","meaningVi":"cao","example":"My father is tall."},
      {"word":"short","ipa":"/ʃɔːt/","meaningVi":"thấp/ngắn","example":"She is short."},
      {"word":"young","ipa":"/jʌŋ/","meaningVi":"trẻ","example":"My sister is young."},
      {"word":"old","ipa":"/əʊld/","meaningVi":"già/cũ","example":"My grandfather is old."}],
    "examples":[{"en":"My mother is tall and young.","vi":"Mẹ tôi cao và trẻ."}],
    "commonMistakes":["❌ \"She is a tall\" → ✅ \"She is tall\" (không có a trước tính từ)"],
    "tips":["Tính từ đứng sau to be, không cần mạo từ a/an."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-family-l3-p1','a1-family-l3','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối tính từ với nghĩa:","pairs":[{"left":"tall","right":"cao"},{"left":"short","right":"thấp"},{"left":"young","right":"trẻ"},{"left":"old","right":"già"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-family-l3-p2','a1-family-l3','multiple_choice',2,'practice','easy',false,
  '{"question":"My father is ___. (cao)","options":[{"id":"a","text":"tall"},{"id":"b","text":"short"},{"id":"c","text":"old"}],"correctOptionId":"a","explanationVi":"tall = cao."}'::jsonb),
 ('a1-family-l3-p3','a1-family-l3','grammar_fill_blank',3,'practice','medium',false,
  '{"question":"She ___ young. (to be)","acceptedAnswers":["is"],"explanationVi":"She + is + adj."}'::jsonb),
 ('a1-family-l3-p4','a1-family-l3','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"He is a tall.","acceptedAnswers":["He is tall.","He is tall"],"explanationVi":"Bỏ a trước tính từ."}'::jsonb),
 ('a1-family-l3-q1','a1-family-l3','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"young\" nghĩa là gì?","options":[{"id":"a","text":"già"},{"id":"b","text":"trẻ"},{"id":"c","text":"cao"}],"correctOptionId":"b","explanationVi":"young = trẻ."}'::jsonb),
 ('a1-family-l3-q2','a1-family-l3','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"They ___ tall. (to be, số nhiều)","acceptedAnswers":["are"],"explanationVi":"They + are."}'::jsonb),
 ('a1-family-l3-q3','a1-family-l3','multiple_choice',7,'quiz','medium',true,
  '{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She is tall."},{"id":"b","text":"She is a tall."},{"id":"c","text":"She tall is."}],"correctOptionId":"a","explanationVi":"He/She is + adj (không có a)."}'::jsonb),
 ('a1-family-l3-q4','a1-family-l3','vocabulary_match',8,'quiz','hard',true,
  '{"question":"Nối từ trái nghĩa:","pairs":[{"left":"tall","right":"short"},{"left":"young","right":"old"}],"explanationVi":"tall↔short, young↔old."}'::jsonb),
 ('a1-family-l3-q5','a1-family-l3','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Cô ấy cao.\"","sourceText":"Cô ấy cao.","acceptedAnswers":["She is tall.","She is tall","She''s tall."],"explanationVi":"She is tall."}'::jsonb),
 ('a1-family-l3-q6','a1-family-l3','multiple_choice',10,'quiz','medium',true,
  '{"question":"\"old\" có thể nghĩa là gì?","options":[{"id":"a","text":"già hoặc cũ"},{"id":"b","text":"chỉ trẻ"},{"id":"c","text":"chỉ cao"}],"correctOptionId":"a","explanationVi":"old = già (người) / cũ (vật)."}'::jsonb);

-- ── Daily — Lesson 3: Telling routine with time (kết hợp giờ + thói quen) ──
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-daily-l3','A1','reading','a1-unit-daily','normal',3,'My daily routine','Kể thói quen kèm giờ',9,15,70,'{}'::jsonb,
  '{"warmup":"Một ngày của bạn diễn ra thế nào?","objectives":["Kể chuỗi thói quen kèm giờ","Dùng at + giờ"],
    "grammarHtml":"Dùng \"at + giờ\" để chỉ thời điểm. VD: I wake up at 6. I go to school at 7.",
    "vocabBlock":[
      {"word":"have breakfast","ipa":"/hæv ˈbrekfəst/","meaningVi":"ăn sáng","example":"I have breakfast at 7."},
      {"word":"go home","ipa":"/ɡəʊ həʊm/","meaningVi":"về nhà","example":"I go home at 5."},
      {"word":"go to bed","ipa":"/ɡəʊ tə bed/","meaningVi":"đi ngủ","example":"I go to bed at 10."}],
    "examples":[{"en":"I have lunch at twelve.","vi":"Tôi ăn trưa lúc 12 giờ."}],
    "commonMistakes":["❌ \"in 6 o''clock\" → ✅ \"at 6 o''clock\""],
    "tips":["Dùng at với giờ cụ thể."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-daily-l3-p1','a1-daily-l3','grammar_fill_blank',1,'practice','easy',false,
  '{"question":"I wake up ___ 6. (giới từ chỉ giờ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-daily-l3-p2','a1-daily-l3','vocabulary_match',2,'practice','medium',false,
  '{"question":"Nối hành động:","pairs":[{"left":"have breakfast","right":"ăn sáng"},{"left":"go home","right":"về nhà"},{"left":"go to bed","right":"đi ngủ"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-daily-l3-p3','a1-daily-l3','sentence_ordering',3,'practice','medium',false,
  '{"question":"Sắp xếp câu:","tokens":["at","I","breakfast","seven","have"],"correctOrder":[1,4,2,0,3],"explanationVi":"I have breakfast at seven."}'::jsonb),
 ('a1-daily-l3-p4','a1-daily-l3','multiple_choice',4,'practice','easy',false,
  '{"question":"I go ___ at 10 p.m.","options":[{"id":"a","text":"to bed"},{"id":"b","text":"to school"},{"id":"c","text":"breakfast"}],"correctOptionId":"a","explanationVi":"go to bed = đi ngủ."}'::jsonb),
 ('a1-daily-l3-q1','a1-daily-l3','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"I go to school ___ 7. (giới từ)","acceptedAnswers":["at"],"explanationVi":"at + giờ."}'::jsonb),
 ('a1-daily-l3-q2','a1-daily-l3','multiple_choice',6,'quiz','medium',true,
  '{"question":"\"have lunch\" nghĩa là gì?","options":[{"id":"a","text":"ăn trưa"},{"id":"b","text":"ăn sáng"},{"id":"c","text":"ăn tối"}],"correctOptionId":"a","explanationVi":"have lunch = ăn trưa."}'::jsonb),
 ('a1-daily-l3-q3','a1-daily-l3','sentence_ordering',7,'quiz','hard',true,
  '{"question":"Sắp xếp câu:","tokens":["home","go","at","I","five"],"correctOrder":[3,1,0,2,4],"explanationVi":"I go home at five."}'::jsonb),
 ('a1-daily-l3-q4','a1-daily-l3','multiple_choice',8,'quiz','medium',true,
  '{"question":"Giới từ ĐÚNG: \"I get up ___ 6 o''clock.\"","options":[{"id":"a","text":"at"},{"id":"b","text":"in"},{"id":"c","text":"on"}],"correctOptionId":"a","explanationVi":"at + giờ cụ thể."}'::jsonb),
 ('a1-daily-l3-q5','a1-daily-l3','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Tôi đi ngủ lúc 10 giờ.\"","sourceText":"Tôi đi ngủ lúc 10 giờ.","acceptedAnswers":["I go to bed at ten.","I go to bed at 10.","I go to bed at ten"],"explanationVi":"I go to bed at ten."}'::jsonb),
 ('a1-daily-l3-q6','a1-daily-l3','vocabulary_match',10,'quiz','medium',true,
  '{"question":"Nối:","pairs":[{"left":"have breakfast","right":"ăn sáng"},{"left":"go home","right":"về nhà"}],"explanationVi":"Ghép đúng."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ PHẦN 3 — 3 UNIT A1 MỚI (bổ sung chủ đề CEFR A1 còn thiếu)                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
    ('a1-unit-things',  'A1', 'This & That, Plurals', 'Đồ vật, this/that, số nhiều', 'objects', '["vocabulary","grammar"]'::jsonb, 6),
    ('a1-unit-can',     'A1', 'Can - Ability',        'Diễn đạt khả năng với can',    'ability', '["grammar","speaking"]'::jsonb, 7),
    ('a1-unit-places',  'A1', 'Places & Prepositions','Nơi chốn và giới từ',          'places',  '["vocabulary","reading"]'::jsonb, 8);

-- ── UNIT 6: This/That & Plurals ──
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-things-l1','A1','reading','a1-unit-things','normal',1,'This & That','this/that/these/those',8,15,70,'{}'::jsonb,
  '{"warmup":"Chỉ vào vật gần và vật xa — bạn nói gì?","objectives":["Phân biệt this/that/these/those"],
    "grammarHtml":"this (này - gần, số ít) · that (kia - xa, số ít) · these (những...này) · those (những...kia).",
    "vocabBlock":[
      {"word":"book","ipa":"/bʊk/","meaningVi":"quyển sách","example":"This is a book."},
      {"word":"pen","ipa":"/pen/","meaningVi":"cây bút","example":"That is a pen."},
      {"word":"chair","ipa":"/tʃeər/","meaningVi":"cái ghế","example":"These are chairs."}],
    "examples":[{"en":"This is my book. That is your pen.","vi":"Đây là sách của tôi. Kia là bút của bạn."}],
    "commonMistakes":["❌ \"this are books\" → ✅ \"these are books\""],
    "tips":["this/that số ít; these/those số nhiều."]}'::jsonb),
 ('a1-things-l2','A1','reading','a1-unit-things','normal',2,'Plural nouns','Danh từ số nhiều (-s/-es)',8,15,70,'{}'::jsonb,
  '{"warmup":"Một cuốn sách là book, hai cuốn là gì?","objectives":["Tạo danh từ số nhiều"],
    "grammarHtml":"Thêm -s: book→books. Thêm -es sau s/x/ch/sh: box→boxes. Bất quy tắc: man→men, child→children.",
    "vocabBlock":[],"examples":[{"en":"I have two books.","vi":"Tôi có hai cuốn sách."}],
    "commonMistakes":["❌ \"two book\" → ✅ \"two books\""],
    "tips":["Số nhiều thường thêm -s."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-things-l1-p1','a1-things-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"Vật ở GẦN, số ít: \"___ is a book.\"","options":[{"id":"a","text":"This"},{"id":"b","text":"These"},{"id":"c","text":"Those"}],"correctOptionId":"a","explanationVi":"this = này (gần, số ít)."}'::jsonb),
 ('a1-things-l1-p2','a1-things-l1','multiple_choice',2,'practice','medium',false,
  '{"question":"Vật ở XA, số nhiều: \"___ are pens.\"","options":[{"id":"a","text":"This"},{"id":"b","text":"That"},{"id":"c","text":"Those"}],"correctOptionId":"c","explanationVi":"those = những...kia."}'::jsonb),
 ('a1-things-l1-p3','a1-things-l1','vocabulary_match',3,'practice','easy',false,
  '{"question":"Nối từ với nghĩa:","pairs":[{"left":"book","right":"sách"},{"left":"pen","right":"bút"},{"left":"chair","right":"ghế"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-things-l1-p4','a1-things-l1','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"This are books.","acceptedAnswers":["These are books.","These are books"],"explanationVi":"Số nhiều dùng these."}'::jsonb),
 ('a1-things-l1-q1','a1-things-l1','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"this\" dùng cho:","options":[{"id":"a","text":"vật gần, số ít"},{"id":"b","text":"vật xa, số nhiều"},{"id":"c","text":"vật xa, số ít"}],"correctOptionId":"a","explanationVi":"this = gần, số ít."}'::jsonb),
 ('a1-things-l1-q2','a1-things-l1','multiple_choice',6,'quiz','medium',true,
  '{"question":"\"___ is a pen.\" (xa, số ít)","options":[{"id":"a","text":"That"},{"id":"b","text":"These"},{"id":"c","text":"Those"}],"correctOptionId":"a","explanationVi":"that = kia (xa, số ít)."}'::jsonb),
 ('a1-things-l1-q3','a1-things-l1','grammar_fill_blank',7,'quiz','medium',true,
  '{"question":"___ are my books. (gần, số nhiều)","acceptedAnswers":["These","these"],"explanationVi":"these = những...này."}'::jsonb),
 ('a1-things-l1-q4','a1-things-l1','multiple_choice',8,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"Those is books."},{"id":"b","text":"Those are books."},{"id":"c","text":"That are books."}],"correctOptionId":"b","explanationVi":"those + are + danh từ số nhiều."}'::jsonb),
 ('a1-things-l1-q5','a1-things-l1','vocabulary_match',9,'quiz','medium',true,
  '{"question":"Nối từ chỉ định với loại:","pairs":[{"left":"this","right":"gần - ít"},{"left":"those","right":"xa - nhiều"}],"explanationVi":"this gần-ít, those xa-nhiều."}'::jsonb),
 ('a1-things-l1-q6','a1-things-l1','translation',10,'quiz','hard',true,
  '{"question":"Dịch: \"Đây là cây bút.\"","sourceText":"Đây là cây bút.","acceptedAnswers":["This is a pen.","This is a pen"],"explanationVi":"This is a pen."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-things-l2-p1','a1-things-l2','grammar_fill_blank',1,'practice','easy',false,
  '{"question":"Số nhiều của \"book\":","acceptedAnswers":["books"],"explanationVi":"book → books."}'::jsonb),
 ('a1-things-l2-p2','a1-things-l2','grammar_fill_blank',2,'practice','medium',false,
  '{"question":"Số nhiều của \"box\":","acceptedAnswers":["boxes"],"explanationVi":"box → boxes (thêm -es)."}'::jsonb),
 ('a1-things-l2-p3','a1-things-l2','multiple_choice',3,'practice','medium',false,
  '{"question":"Số nhiều của \"man\":","options":[{"id":"a","text":"mans"},{"id":"b","text":"men"},{"id":"c","text":"mens"}],"correctOptionId":"b","explanationVi":"man → men (bất quy tắc)."}'::jsonb),
 ('a1-things-l2-p4','a1-things-l2','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"I have two book.","acceptedAnswers":["I have two books.","I have two books"],"explanationVi":"two + books (số nhiều)."}'::jsonb),
 ('a1-things-l2-q1','a1-things-l2','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"Số nhiều của \"pen\":","acceptedAnswers":["pens"],"explanationVi":"pen → pens."}'::jsonb),
 ('a1-things-l2-q2','a1-things-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"Số nhiều của \"child\":","options":[{"id":"a","text":"childs"},{"id":"b","text":"children"},{"id":"c","text":"childes"}],"correctOptionId":"b","explanationVi":"child → children."}'::jsonb),
 ('a1-things-l2-q3','a1-things-l2','grammar_fill_blank',7,'quiz','medium',true,
  '{"question":"Số nhiều của \"watch\":","acceptedAnswers":["watches"],"explanationVi":"watch → watches (thêm -es)."}'::jsonb),
 ('a1-things-l2-q4','a1-things-l2','multiple_choice',8,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"three boxes"},{"id":"b","text":"three box"},{"id":"c","text":"three boxs"}],"correctOptionId":"a","explanationVi":"box → boxes."}'::jsonb),
 ('a1-things-l2-q5','a1-things-l2','multiple_choice',9,'quiz','medium',true,
  '{"question":"Khi nào thêm -es?","options":[{"id":"a","text":"sau s/x/ch/sh"},{"id":"b","text":"sau mọi danh từ"},{"id":"c","text":"không bao giờ"}],"correctOptionId":"a","explanationVi":"Thêm -es sau s/x/ch/sh."}'::jsonb),
 ('a1-things-l2-q6','a1-things-l2','translation',10,'quiz','hard',true,
  '{"question":"Dịch: \"Tôi có ba quyển sách.\"","sourceText":"Tôi có ba quyển sách.","acceptedAnswers":["I have three books.","I have three books"],"explanationVi":"I have three books."}'::jsonb);

-- ── UNIT 7: Can - Ability ──
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-can-l1','A1','reading','a1-unit-can','normal',1,'Can for ability','Diễn đạt khả năng',8,15,70,'{}'::jsonb,
  '{"warmup":"Bạn có thể làm gì giỏi?","objectives":["Dùng can/can''t để nói khả năng"],
    "grammarHtml":"S + can + V(nguyên thể): I can swim. Phủ định: can''t (cannot). Câu hỏi: Can you swim?",
    "vocabBlock":[
      {"word":"swim","ipa":"/swɪm/","meaningVi":"bơi","example":"I can swim."},
      {"word":"sing","ipa":"/sɪŋ/","meaningVi":"hát","example":"She can sing."},
      {"word":"cook","ipa":"/kʊk/","meaningVi":"nấu ăn","example":"He can cook."}],
    "examples":[{"en":"I can swim but I can''t cook.","vi":"Tôi biết bơi nhưng không biết nấu ăn."}],
    "commonMistakes":["❌ \"I can to swim\" → ✅ \"I can swim\" (không có to)"],
    "tips":["Sau can luôn là động từ nguyên thể, không có to."]}'::jsonb),
 ('a1-can-l2','A1','speaking','a1-unit-can','normal',2,'Can questions & answers','Hỏi đáp về khả năng',8,15,70,'{}'::jsonb,
  '{"warmup":"Làm sao hỏi ai đó có biết bơi không?","objectives":["Đặt câu hỏi và trả lời với can"],
    "grammarHtml":"Can + S + V? → Yes, S can. / No, S can''t. VD: Can you cook? – Yes, I can.",
    "vocabBlock":[],"examples":[{"en":"Can you sing? – No, I can''t.","vi":"Bạn biết hát không? – Không."}],
    "commonMistakes":["❌ \"Do you can swim?\" → ✅ \"Can you swim?\""],
    "tips":["Câu hỏi can: đảo can lên đầu, không dùng do."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-can-l1-p1','a1-can-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"I ___ swim. (có thể)","options":[{"id":"a","text":"can"},{"id":"b","text":"am"},{"id":"c","text":"do"}],"correctOptionId":"a","explanationVi":"can + V."}'::jsonb),
 ('a1-can-l1-p2','a1-can-l1','vocabulary_match',2,'practice','easy',false,
  '{"question":"Nối động từ:","pairs":[{"left":"swim","right":"bơi"},{"left":"sing","right":"hát"},{"left":"cook","right":"nấu ăn"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-can-l1-p3','a1-can-l1','error_correction',3,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"I can to swim.","acceptedAnswers":["I can swim.","I can swim"],"explanationVi":"Bỏ to sau can."}'::jsonb),
 ('a1-can-l1-p4','a1-can-l1','grammar_fill_blank',4,'practice','medium',false,
  '{"question":"Phủ định: \"He ___ cook.\" (không thể, viết tắt)","acceptedAnswers":["can''t","cannot","cant"],"explanationVi":"can''t = cannot."}'::jsonb),
 ('a1-can-l1-q1','a1-can-l1','multiple_choice',5,'quiz','easy',true,
  '{"question":"Sau \"can\" là gì?","options":[{"id":"a","text":"động từ nguyên thể"},{"id":"b","text":"to + động từ"},{"id":"c","text":"động từ thêm s"}],"correctOptionId":"a","explanationVi":"can + V(nguyên thể)."}'::jsonb),
 ('a1-can-l1-q2','a1-can-l1','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"She ___ sing very well. (có thể)","acceptedAnswers":["can"],"explanationVi":"can + V."}'::jsonb),
 ('a1-can-l1-q3','a1-can-l1','multiple_choice',7,'quiz','medium',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I can swim."},{"id":"b","text":"I can to swim."},{"id":"c","text":"I can swims."}],"correctOptionId":"a","explanationVi":"can + nguyên thể."}'::jsonb),
 ('a1-can-l1-q4','a1-can-l1','translation',8,'quiz','hard',true,
  '{"question":"Dịch: \"Tôi biết nấu ăn.\"","sourceText":"Tôi biết nấu ăn.","acceptedAnswers":["I can cook.","I can cook"],"explanationVi":"I can cook."}'::jsonb),
 ('a1-can-l1-q5','a1-can-l1','sentence_ordering',9,'quiz','hard',true,
  '{"question":"Sắp xếp câu:","tokens":["can''t","I","cook"],"correctOrder":[1,0,2],"explanationVi":"I can''t cook."}'::jsonb),
 ('a1-can-l1-q6','a1-can-l1','multiple_choice',10,'quiz','medium',true,
  '{"question":"\"can''t\" là viết tắt của:","options":[{"id":"a","text":"cannot"},{"id":"b","text":"can to"},{"id":"c","text":"can not be"}],"correctOptionId":"a","explanationVi":"can''t = cannot."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-can-l2-p1','a1-can-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"Câu hỏi ĐÚNG:","options":[{"id":"a","text":"Can you swim?"},{"id":"b","text":"Do you can swim?"},{"id":"c","text":"You can swim?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 ('a1-can-l2-p2','a1-can-l2','sentence_ordering',2,'practice','medium',false,
  '{"question":"Sắp xếp câu hỏi:","tokens":["you","Can","sing"],"correctOrder":[1,0,2],"explanationVi":"Can you sing?"}'::jsonb),
 ('a1-can-l2-p3','a1-can-l2','multiple_choice',3,'practice','medium',false,
  '{"question":"Trả lời \"Can you cook?\" (không):","options":[{"id":"a","text":"No, I can''t."},{"id":"b","text":"No, I don''t."},{"id":"c","text":"No, I am not."}],"correctOptionId":"a","explanationVi":"Trả lời can: No, I can''t."}'::jsonb),
 ('a1-can-l2-p4','a1-can-l2','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"Do you can swim?","acceptedAnswers":["Can you swim?","Can you swim"],"explanationVi":"Câu hỏi can không dùng do."}'::jsonb),
 ('a1-can-l2-q1','a1-can-l2','multiple_choice',5,'quiz','easy',true,
  '{"question":"Chọn câu hỏi khả năng ĐÚNG:","options":[{"id":"a","text":"Can she dance?"},{"id":"b","text":"Does she can dance?"},{"id":"c","text":"She can dance?"}],"correctOptionId":"a","explanationVi":"Can + S + V?"}'::jsonb),
 ('a1-can-l2-q2','a1-can-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"Trả lời ngắn cho \"Can you sing?\" (có):","options":[{"id":"a","text":"Yes, I can."},{"id":"b","text":"Yes, I do."},{"id":"c","text":"Yes, I am."}],"correctOptionId":"a","explanationVi":"Yes, I can."}'::jsonb),
 ('a1-can-l2-q3','a1-can-l2','sentence_ordering',7,'quiz','medium',true,
  '{"question":"Sắp xếp câu hỏi:","tokens":["cook","Can","he"],"correctOrder":[1,2,0],"explanationVi":"Can he cook?"}'::jsonb),
 ('a1-can-l2-q4','a1-can-l2','grammar_fill_blank',8,'quiz','medium',true,
  '{"question":"\"___ you swim?\" (câu hỏi khả năng)","acceptedAnswers":["Can","can"],"explanationVi":"Can you swim?"}'::jsonb),
 ('a1-can-l2-q5','a1-can-l2','multiple_choice',9,'quiz','hard',true,
  '{"question":"Câu trả lời phủ định ĐÚNG:","options":[{"id":"a","text":"No, he can''t."},{"id":"b","text":"No, he doesn''t can."},{"id":"c","text":"No, he not can."}],"correctOptionId":"a","explanationVi":"No, he can''t."}'::jsonb),
 ('a1-can-l2-q6','a1-can-l2','translation',10,'quiz','hard',true,
  '{"question":"Dịch: \"Bạn biết hát không?\"","sourceText":"Bạn biết hát không?","acceptedAnswers":["Can you sing?","Can you sing"],"explanationVi":"Can you sing?"}'::jsonb);

-- ── UNIT 8: Places & Prepositions ──
INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a1-places-l1','A1','reading','a1-unit-places','normal',1,'Places in town','Địa điểm trong thị trấn',8,15,70,'{}'::jsonb,
  '{"warmup":"Gần nhà bạn có những nơi nào?","objectives":["Gọi tên địa điểm phổ biến"],
    "vocabBlock":[
      {"word":"school","ipa":"/skuːl/","meaningVi":"trường học","example":"I go to school."},
      {"word":"hospital","ipa":"/ˈhɒspɪtl/","meaningVi":"bệnh viện","example":"The hospital is big."},
      {"word":"market","ipa":"/ˈmɑːkɪt/","meaningVi":"chợ","example":"My mother goes to the market."},
      {"word":"park","ipa":"/pɑːk/","meaningVi":"công viên","example":"We play in the park."}],
    "examples":[{"en":"There is a school near my house.","vi":"Có một trường học gần nhà tôi."}],
    "commonMistakes":["❌ \"go to home\" → ✅ \"go home\" (home không cần to)"],
    "tips":["There is + danh từ số ít để nói có cái gì đó."]}'::jsonb),
 ('a1-places-l2','A1','reading','a1-unit-places','normal',2,'Prepositions of place','Giới từ chỉ nơi chốn (in/on/under/next to)',8,15,70,'{}'::jsonb,
  '{"warmup":"Cái bút ở đâu? Trên bàn hay dưới bàn?","objectives":["Dùng in/on/under/next to"],
    "grammarHtml":"in (trong) · on (trên bề mặt) · under (dưới) · next to (cạnh). VD: The book is on the table.",
    "vocabBlock":[],"examples":[{"en":"The cat is under the chair.","vi":"Con mèo ở dưới ghế."}],
    "commonMistakes":["❌ \"in the table\" (khi ý là trên) → ✅ \"on the table\""],
    "tips":["on = trên bề mặt; in = bên trong."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-places-l1-p1','a1-places-l1','vocabulary_match',1,'practice','easy',false,
  '{"question":"Nối địa điểm:","pairs":[{"left":"school","right":"trường học"},{"left":"hospital","right":"bệnh viện"},{"left":"market","right":"chợ"},{"left":"park","right":"công viên"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-places-l1-p2','a1-places-l1','multiple_choice',2,'practice','easy',false,
  '{"question":"Nơi để khám bệnh là:","options":[{"id":"a","text":"hospital"},{"id":"b","text":"park"},{"id":"c","text":"market"}],"correctOptionId":"a","explanationVi":"hospital = bệnh viện."}'::jsonb),
 ('a1-places-l1-p3','a1-places-l1','grammar_fill_blank',3,'practice','medium',false,
  '{"question":"There ___ a school near my house. (to be số ít)","acceptedAnswers":["is"],"explanationVi":"There is + danh từ số ít."}'::jsonb),
 ('a1-places-l1-p4','a1-places-l1','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"I go to home.","acceptedAnswers":["I go home.","I go home"],"explanationVi":"go home (không có to)."}'::jsonb),
 ('a1-places-l1-q1','a1-places-l1','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"market\" nghĩa là gì?","options":[{"id":"a","text":"chợ"},{"id":"b","text":"công viên"},{"id":"c","text":"trường"}],"correctOptionId":"a","explanationVi":"market = chợ."}'::jsonb),
 ('a1-places-l1-q2','a1-places-l1','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"There ___ a park near here. (to be)","acceptedAnswers":["is"],"explanationVi":"There is + số ít."}'::jsonb),
 ('a1-places-l1-q3','a1-places-l1','vocabulary_match',7,'quiz','medium',true,
  '{"question":"Nối:","pairs":[{"left":"park","right":"công viên"},{"left":"school","right":"trường học"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-places-l1-q4','a1-places-l1','multiple_choice',8,'quiz','hard',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I go home."},{"id":"b","text":"I go to home."},{"id":"c","text":"I go at home."}],"correctOptionId":"a","explanationVi":"go home."}'::jsonb),
 ('a1-places-l1-q5','a1-places-l1','multiple_choice',9,'quiz','medium',true,
  '{"question":"Nơi để mua đồ ăn:","options":[{"id":"a","text":"market"},{"id":"b","text":"hospital"},{"id":"c","text":"school"}],"correctOptionId":"a","explanationVi":"market = chợ."}'::jsonb),
 ('a1-places-l1-q6','a1-places-l1','translation',10,'quiz','hard',true,
  '{"question":"Dịch: \"Có một công viên gần đây.\"","sourceText":"Có một công viên gần đây.","acceptedAnswers":["There is a park near here.","There is a park near here"],"explanationVi":"There is a park near here."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a1-places-l2-p1','a1-places-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"The book is ___ the table. (trên)","options":[{"id":"a","text":"on"},{"id":"b","text":"in"},{"id":"c","text":"under"}],"correctOptionId":"a","explanationVi":"on = trên bề mặt."}'::jsonb),
 ('a1-places-l2-p2','a1-places-l2','multiple_choice',2,'practice','medium',false,
  '{"question":"The cat is ___ the chair. (dưới)","options":[{"id":"a","text":"on"},{"id":"b","text":"under"},{"id":"c","text":"next to"}],"correctOptionId":"b","explanationVi":"under = dưới."}'::jsonb),
 ('a1-places-l2-p3','a1-places-l2','vocabulary_match',3,'practice','medium',false,
  '{"question":"Nối giới từ với nghĩa:","pairs":[{"left":"in","right":"trong"},{"left":"on","right":"trên"},{"left":"under","right":"dưới"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a1-places-l2-p4','a1-places-l2','grammar_fill_blank',4,'practice','hard',false,
  '{"question":"The pen is ___ the box. (bên trong)","acceptedAnswers":["in"],"explanationVi":"in = bên trong."}'::jsonb),
 ('a1-places-l2-q1','a1-places-l2','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"on\" nghĩa là gì?","options":[{"id":"a","text":"trên (bề mặt)"},{"id":"b","text":"dưới"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"on = trên bề mặt."}'::jsonb),
 ('a1-places-l2-q2','a1-places-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"The ball is ___ the box. (bên trong)","options":[{"id":"a","text":"in"},{"id":"b","text":"on"},{"id":"c","text":"under"}],"correctOptionId":"a","explanationVi":"in = trong."}'::jsonb),
 ('a1-places-l2-q3','a1-places-l2','grammar_fill_blank',7,'quiz','medium',true,
  '{"question":"The lamp is ___ the table. (trên)","acceptedAnswers":["on"],"explanationVi":"on = trên."}'::jsonb),
 ('a1-places-l2-q4','a1-places-l2','multiple_choice',8,'quiz','hard',true,
  '{"question":"\"next to\" nghĩa là gì?","options":[{"id":"a","text":"cạnh"},{"id":"b","text":"dưới"},{"id":"c","text":"trong"}],"correctOptionId":"a","explanationVi":"next to = bên cạnh."}'::jsonb),
 ('a1-places-l2-q5','a1-places-l2','error_correction',9,'quiz','hard',true,
  '{"question":"Sửa câu sai (sách nằm trên bàn):","sourceText":"The book is in the table.","acceptedAnswers":["The book is on the table.","The book is on the table"],"explanationVi":"Trên bề mặt → on."}'::jsonb),
 ('a1-places-l2-q6','a1-places-l2','translation',10,'quiz','medium',true,
  '{"question":"Dịch: \"Con mèo ở dưới ghế.\"","sourceText":"Con mèo ở dưới ghế.","acceptedAnswers":["The cat is under the chair.","The cat is under the chair"],"explanationVi":"The cat is under the chair."}'::jsonb);
