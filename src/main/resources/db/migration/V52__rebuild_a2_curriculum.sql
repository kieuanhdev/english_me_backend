-- =============================================================================
-- V52 — TÁI THIẾT TOÀN BỘ CẤP A2 theo KHUNG_GIAO_TRINH_CEFR.md §4 (cấp A2)
-- =============================================================================
-- Mục tiêu: thay nội dung A2 cũ (V29 a2-unit-activities + V31 past/future/compare —
-- vài unit rời, id scheme cũ) bằng bộ A2 hoàn chỉnh: 10 Unit × 5 Lesson = 50 lesson.
-- Mỗi lesson chạy 3 bước Lý thuyết → Luyện tập → Mini-quiz (PPP vi mô), giống V46 (A1).
--
-- Quyết định đã chốt: TẠO LẠI A2 TỪ ĐẦU (drop seed A2 cũ rồi seed sạch).
-- id mới có hệ thống: a2-u{NN} / a2-u{NN}-l{N} / a2-u{NN}-l{N}-{p|q}{k}.
--
-- Bám JSON contract FE curriculum_models.dart + chấm server CurriculumGradingService:
--   theory_content: { warmup, objectives[], grammarHtml?, vocabBlock[], examples[], commonMistakes[], tips[] }
--   quiz CHỈ dùng 5 dạng chấm tự động (multiple_choice/grammar_fill_blank/vocabulary_match/
--     sentence_ordering/listening_choice). translation + error_correction CHỈ ở phase=practice.
--   listening_choice cần audioText (FE TTS đọc, không cần file audio).
-- Unit Review: lesson_type='unit_review', 10 câu quiz, required_score_to_pass=75.
-- 10 điểm ngữ pháp A2 xoắn ốc: hiện tại (U1) → so sánh (U2) → quá khứ đơn (U3) →
--   quá khứ tiếp diễn/used to (U4) → tương lai (U5) → định lượng (U6) → modals (U7) →
--   điều kiện (U8) → present perfect & gerund/infinitive (U9) → trạng từ & nối câu (U10).
-- =============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 0 — DỌN SẠCH A2 CŨ (V29 + V31; đúng thứ tự FK; idempotent)            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = NULL WHERE level_code = 'A2';

DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'A2');

DELETE FROM learning_lessons WHERE level_code = 'A2';

DELETE FROM learning_units WHERE level_code = 'A2';

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 1 — 10 UNIT A2 (display_order 1..10, mở khoá tuần tự)                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order, required_review_score) VALUES
 ('a2-u01','A2','My Daily Life','Cuộc sống thường ngày','routine', '["grammar","vocabulary","reading"]'::jsonb, 1, 75),
 ('a2-u02','A2','People & Personalities','Con người & Tính cách','people', '["grammar","vocabulary","reading"]'::jsonb, 2, 75),
 ('a2-u03','A2','My Past','Chuyện ngày xưa','past', '["grammar","vocabulary","reading"]'::jsonb, 3, 75),
 ('a2-u04','A2','Telling Stories','Kể chuyện','story', '["grammar","vocabulary","listening"]'::jsonb, 4, 75),
 ('a2-u05','A2','Plans & Predictions','Kế hoạch & Dự đoán','future', '["grammar","vocabulary","reading"]'::jsonb, 5, 75),
 ('a2-u06','A2','Food & Eating Out','Ẩm thực & Ăn ngoài','food', '["grammar","vocabulary","listening"]'::jsonb, 6, 75),
 ('a2-u07','A2','Rules & Advice','Quy tắc & Lời khuyên','advice', '["grammar","vocabulary","reading"]'::jsonb, 7, 75),
 ('a2-u08','A2','If & When','Nếu & Khi','condition', '["grammar","vocabulary","listening"]'::jsonb, 8, 75),
 ('a2-u09','A2','Life Experiences','Trải nghiệm cuộc sống','experience', '["grammar","vocabulary","reading"]'::jsonb, 9, 75),
 ('a2-u10','A2','Out & About','Ra ngoài & Khám phá','everyday', '["grammar","vocabulary","listening"]'::jsonb, 10, 75);

-- ── UNIT 01 — My Daily Life / Cuộc sống thường ngày ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u01-l1','A2','reading','a2-u01','normal',1,'Present simple revisited','Thì hiện tại đơn: thói quen & sự thật',9,15,70,'{}'::jsonb,
  '{"warmup":"Bạn làm gì mỗi sáng? Hãy nghĩ về những việc lặp lại hằng ngày.",
    "objectives":["Dùng hiện tại đơn cho thói quen và sự thật chung","Chia động từ thêm -s/-es ở ngôi thứ ba số ít","Tạo câu phủ định/nghi vấn với do/does","Nhận biết stative verbs (like/want/know) không dùng tiếp diễn"],
    "grammarHtml":"Khẳng định: S + V(s/es). Phủ định: S + do/does + not + V. Nghi vấn: Do/Does + S + V? Ngôi he/she/it thêm -s; động từ tận cùng -s/-sh/-ch/-x/-o thêm -es (goes, watches); phụ âm + y → -ies (study → studies). Stative verbs (like, want, know, need, understand) KHÔNG chia tiếp diễn.",
    "vocabBlock":[
      {"word":"work","ipa":"/wɜːk/","meaningVi":"làm việc","example":"I work in an office."},
      {"word":"study","ipa":"/ˈstʌdi/","meaningVi":"học","example":"She studies English every day."},
      {"word":"watch","ipa":"/wɒtʃ/","meaningVi":"xem","example":"He watches TV at night."},
      {"word":"go","ipa":"/ɡəʊ/","meaningVi":"đi","example":"She goes to school by bus."},
      {"word":"like","ipa":"/laɪk/","meaningVi":"thích","example":"I like coffee."}],
    "examples":[
      {"en":"She works in a hospital.","vi":"Cô ấy làm việc ở bệnh viện."},
      {"en":"He doesn''t drink coffee.","vi":"Anh ấy không uống cà phê."},
      {"en":"Do you live in Hanoi?","vi":"Bạn có sống ở Hà Nội không?"}],
    "commonMistakes":["❌ \"She work here.\" → ✅ \"She works here.\" (ngôi thứ ba thêm -s)","❌ \"He doesn''t works.\" → ✅ \"He doesn''t work.\" (sau does not dùng V nguyên thể)"],
    "tips":["Stative verbs (like, want, know) chỉ trạng thái, không dùng V-ing.","Sau do/does, động từ luôn ở dạng nguyên thể."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u01-l1-p1','a2-u01-l1','grammar_fill_blank',1,'practice','easy',false,'{"question":"Chia động từ: \"She ___ (work) in a bank.\"","acceptedAnswers":["works"],"explanationVi":"Ngôi thứ ba số ít thêm -s: works."}'::jsonb),
 ('a2-u01-l1-p2','a2-u01-l1','multiple_choice',2,'practice','easy',false,'{"question":"Chọn dạng đúng: \"He ___ TV every night.\"","options":[{"id":"a","text":"watch"},{"id":"b","text":"watchs"},{"id":"c","text":"watches"}],"correctOptionId":"c","explanationVi":"Động từ tận cùng -ch thêm -es: watches."}'::jsonb),
 ('a2-u01-l1-p3','a2-u01-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối động từ với nghĩa tiếng Việt:","pairs":[{"left":"work","right":"làm việc"},{"left":"study","right":"học"},{"left":"go","right":"đi"},{"left":"like","right":"thích"}],"explanationVi":"Ghép đúng từng cặp động từ."}'::jsonb),
 ('a2-u01-l1-p4','a2-u01-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Phủ định: \"He ___ (not drink) coffee.\"","acceptedAnswers":["doesn''t drink","does not drink"],"explanationVi":"Ngôi thứ ba phủ định: doesn''t + V nguyên thể."}'::jsonb),
 ('a2-u01-l1-p5','a2-u01-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi học tiếng Anh mỗi ngày.","acceptedAnswers":["I study English every day.","I study English everyday.","I study English every day"],"explanationVi":"I study English every day."}'::jsonb),
 ('a2-u01-l1-p6','a2-u01-l1','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi trong câu:","sourceText":"She go to work by bus.","acceptedAnswers":["She goes to work by bus.","She goes to work by bus"],"explanationVi":"Ngôi thứ ba: go → goes."}'::jsonb),
 ('a2-u01-l1-p7','a2-u01-l1','grammar_fill_blank',7,'practice','medium',false,'{"question":"Chia động từ: \"My sister ___ (study) at university.\"","acceptedAnswers":["studies"],"explanationVi":"Phụ âm + y → -ies: studies."}'::jsonb),
 ('a2-u01-l1-q1','a2-u01-l1','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She work in a school."},{"id":"b","text":"She works in a school."},{"id":"c","text":"She working in a school."}],"correctOptionId":"b","explanationVi":"Ngôi thứ ba số ít thêm -s: works."}'::jsonb),
 ('a2-u01-l1-q2','a2-u01-l1','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Chia động từ: \"He ___ (go) to the gym on Sundays.\"","acceptedAnswers":["goes"],"explanationVi":"Động từ tận cùng -o thêm -es: goes."}'::jsonb),
 ('a2-u01-l1-q3','a2-u01-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu phủ định ĐÚNG:","options":[{"id":"a","text":"He don''t like tea."},{"id":"b","text":"He doesn''t likes tea."},{"id":"c","text":"He doesn''t like tea."}],"correctOptionId":"c","explanationVi":"Ngôi thứ ba: doesn''t + V nguyên thể."}'::jsonb),
 ('a2-u01-l1-q4','a2-u01-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền do/does: \"___ your brother play football?\"","acceptedAnswers":["Does"],"explanationVi":"Chủ ngữ ngôi thứ ba số ít dùng Does."}'::jsonb),
 ('a2-u01-l1-q5','a2-u01-l1','multiple_choice',12,'quiz','medium',true,'{"question":"Stative verb nào KHÔNG dùng ở thì tiếp diễn?","options":[{"id":"a","text":"run"},{"id":"b","text":"know"},{"id":"c","text":"eat"}],"correctOptionId":"b","explanationVi":"know là stative verb, không dùng V-ing."}'::jsonb),
 ('a2-u01-l1-q6','a2-u01-l1','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["Does","work","she","here"],"correctOrder":[0,2,1,3],"explanationVi":"Câu đúng: Does she work here?"}'::jsonb),
 ('a2-u01-l1-q7','a2-u01-l1','vocabulary_match',14,'quiz','easy',true,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"watch","right":"xem"},{"left":"study","right":"học"},{"left":"work","right":"làm việc"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u01-l2','A2','reading','a2-u01','normal',2,'Present continuous','Thì hiện tại tiếp diễn: am/is/are + V-ing',9,15,70,'{}'::jsonb,
  '{"warmup":"Ngay lúc này bạn đang làm gì? Bạn đang đọc câu này!",
    "objectives":["Dùng am/is/are + V-ing cho hành động đang diễn ra","Dùng dấu hiệu now / at the moment","Phân biệt hiện tại tiếp diễn với hiện tại đơn"],
    "grammarHtml":"Cấu trúc: S + am/is/are + V-ing. I am; he/she/it is; you/we/they are. Quy tắc thêm -ing: bỏ -e (make → making), gấp đôi phụ âm cuối nếu CVC nhấn cuối (run → running). Dấu hiệu: now, at the moment, right now, Look!, Listen!. So sánh: hiện tại đơn = thói quen; hiện tại tiếp diễn = đang xảy ra lúc nói.",
    "vocabBlock":[
      {"word":"now","ipa":"/naʊ/","meaningVi":"bây giờ","example":"I am studying now."},
      {"word":"at the moment","ipa":"/ət ðə ˈməʊmənt/","meaningVi":"lúc này","example":"She is cooking at the moment."},
      {"word":"cook","ipa":"/kʊk/","meaningVi":"nấu ăn","example":"Mum is cooking dinner."},
      {"word":"read","ipa":"/riːd/","meaningVi":"đọc","example":"He is reading a book."},
      {"word":"sleep","ipa":"/sliːp/","meaningVi":"ngủ","example":"The baby is sleeping."}],
    "examples":[
      {"en":"I am working now.","vi":"Tôi đang làm việc bây giờ."},
      {"en":"They are playing football at the moment.","vi":"Họ đang chơi bóng đá lúc này."},
      {"en":"Look! It is raining.","vi":"Nhìn kìa! Trời đang mưa."}],
    "commonMistakes":["❌ \"I working now.\" → ✅ \"I am working now.\" (thiếu trợ động từ be)","❌ \"She is study.\" → ✅ \"She is studying.\" (thiếu -ing)"],
    "tips":["now / at the moment báo hiệu hiện tại tiếp diễn.","every day / usually báo hiệu hiện tại đơn."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u01-l2-p1','a2-u01-l2','grammar_fill_blank',1,'practice','easy',false,'{"question":"Điền be: \"I ___ working now.\"","acceptedAnswers":["am","''m"],"explanationVi":"I + am: I am working now."}'::jsonb),
 ('a2-u01-l2-p2','a2-u01-l2','multiple_choice',2,'practice','easy',false,'{"question":"Chọn dạng đúng: \"She is ___ a book.\"","options":[{"id":"a","text":"read"},{"id":"b","text":"reads"},{"id":"c","text":"reading"}],"correctOptionId":"c","explanationVi":"be + V-ing: is reading."}'::jsonb),
 ('a2-u01-l2-p3','a2-u01-l2','grammar_fill_blank',3,'practice','easy',false,'{"question":"Thêm -ing: \"They are ___ (play) football.\"","acceptedAnswers":["playing"],"explanationVi":"play → playing."}'::jsonb),
 ('a2-u01-l2-p4','a2-u01-l2','vocabulary_match',4,'practice','easy',false,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"cook","right":"nấu ăn"},{"left":"sleep","right":"ngủ"},{"left":"read","right":"đọc"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u01-l2-p5','a2-u01-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Trời đang mưa.","acceptedAnswers":["It is raining.","It''s raining.","It is raining","It''s raining"],"explanationVi":"It is raining."}'::jsonb),
 ('a2-u01-l2-p6','a2-u01-l2','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi trong câu:","sourceText":"I working at the moment.","acceptedAnswers":["I am working at the moment.","I''m working at the moment.","I am working at the moment","I''m working at the moment"],"explanationVi":"Thiếu trợ động từ be: I am working."}'::jsonb),
 ('a2-u01-l2-p7','a2-u01-l2','grammar_fill_blank',7,'practice','medium',false,'{"question":"Thêm -ing: \"He is ___ (run) in the park.\"","acceptedAnswers":["running"],"explanationVi":"CVC nhấn cuối gấp đôi phụ âm: running."}'::jsonb),
 ('a2-u01-l2-q1','a2-u01-l2','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"They are play football."},{"id":"b","text":"They are playing football."},{"id":"c","text":"They playing football."}],"correctOptionId":"b","explanationVi":"be + V-ing: are playing."}'::jsonb),
 ('a2-u01-l2-q2','a2-u01-l2','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Điền be: \"She ___ cooking dinner now.\"","acceptedAnswers":["is","''s"],"explanationVi":"she + is: She is cooking."}'::jsonb),
 ('a2-u01-l2-q3','a2-u01-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Dấu hiệu nào báo thì hiện tại tiếp diễn?","options":[{"id":"a","text":"every day"},{"id":"b","text":"at the moment"},{"id":"c","text":"usually"}],"correctOptionId":"b","explanationVi":"at the moment = lúc này → tiếp diễn."}'::jsonb),
 ('a2-u01-l2-q4','a2-u01-l2','multiple_choice',11,'quiz','medium',true,'{"question":"Chọn câu dùng thì ĐÚNG cho thói quen hằng ngày:","options":[{"id":"a","text":"I am going to school every day."},{"id":"b","text":"I go to school every day."},{"id":"c","text":"I going to school every day."}],"correctOptionId":"b","explanationVi":"every day = thói quen → hiện tại đơn: I go."}'::jsonb),
 ('a2-u01-l2-q5','a2-u01-l2','grammar_fill_blank',12,'quiz','medium',true,'{"question":"Thêm -ing: \"Look! The baby is ___ (sleep).\"","acceptedAnswers":["sleeping"],"explanationVi":"sleep → sleeping."}'::jsonb),
 ('a2-u01-l2-q6','a2-u01-l2','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["is","She","now","studying"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: She is studying now."}'::jsonb),
 ('a2-u01-l2-q7','a2-u01-l2','vocabulary_match',14,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"now","right":"bây giờ"},{"left":"cook","right":"nấu ăn"},{"left":"sleep","right":"ngủ"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u01-l3','A2','reading','a2-u01','normal',3,'Daily routine words','Từ vựng sinh hoạt & trạng từ tần suất',8,15,70,'{}'::jsonb,
  '{"warmup":"Một ngày của bạn bắt đầu thế nào? get up, have breakfast, go to work...",
    "objectives":["Học cụm từ chỉ hoạt động hằng ngày","Dùng trạng từ tần suất always/usually/often/sometimes/never","Đặt trạng từ tần suất đúng vị trí trong câu"],
    "grammarHtml":"Trạng từ tần suất theo mức độ: always (100%) > usually > often > sometimes > never (0%). Vị trí: TRƯỚC động từ thường (I always get up early), SAU động từ to be (She is never late).",
    "vocabBlock":[
      {"word":"get up","ipa":"/ɡet ʌp/","meaningVi":"thức dậy","example":"I get up at six."},
      {"word":"have breakfast","ipa":"/hæv ˈbrekfəst/","meaningVi":"ăn sáng","example":"I have breakfast at seven."},
      {"word":"go to work","ipa":"/ɡəʊ tə wɜːk/","meaningVi":"đi làm","example":"He goes to work by bus."},
      {"word":"come home","ipa":"/kʌm həʊm/","meaningVi":"về nhà","example":"She comes home at five."},
      {"word":"always","ipa":"/ˈɔːlweɪz/","meaningVi":"luôn luôn","example":"I always brush my teeth."},
      {"word":"sometimes","ipa":"/ˈsʌmtaɪmz/","meaningVi":"thỉnh thoảng","example":"We sometimes eat out."}],
    "examples":[
      {"en":"I usually get up at six.","vi":"Tôi thường thức dậy lúc sáu giờ."},
      {"en":"She never drinks coffee.","vi":"Cô ấy không bao giờ uống cà phê."},
      {"en":"They often go to work by bus.","vi":"Họ thường đi làm bằng xe buýt."}],
    "commonMistakes":["❌ \"I get up always early.\" → ✅ \"I always get up early.\" (tần suất đứng trước động từ thường)"],
    "tips":["always/usually/often/sometimes/never đứng TRƯỚC động từ thường, SAU động từ to be."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u01-l3-p1','a2-u01-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối cụm từ sinh hoạt với nghĩa:","pairs":[{"left":"get up","right":"thức dậy"},{"left":"have breakfast","right":"ăn sáng"},{"left":"go to work","right":"đi làm"},{"left":"come home","right":"về nhà"}],"explanationVi":"Ghép đúng từng cụm sinh hoạt."}'::jsonb),
 ('a2-u01-l3-p2','a2-u01-l3','vocabulary_match',2,'practice','easy',false,'{"question":"Nối trạng từ tần suất với nghĩa:","pairs":[{"left":"always","right":"luôn luôn"},{"left":"usually","right":"thường xuyên"},{"left":"sometimes","right":"thỉnh thoảng"},{"left":"never","right":"không bao giờ"}],"explanationVi":"Ghép đúng từng trạng từ tần suất."}'::jsonb),
 ('a2-u01-l3-p3','a2-u01-l3','multiple_choice',3,'practice','easy',false,'{"question":"Cụm từ nào nghĩa là \"thức dậy\"?","options":[{"id":"a","text":"come home"},{"id":"b","text":"get up"},{"id":"c","text":"go to work"}],"correctOptionId":"b","explanationVi":"get up = thức dậy."}'::jsonb),
 ('a2-u01-l3-p4','a2-u01-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền trạng từ (100%): \"I ___ brush my teeth in the morning.\"","acceptedAnswers":["always"],"explanationVi":"always = luôn luôn (100%)."}'::jsonb),
 ('a2-u01-l3-p5','a2-u01-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi thường thức dậy lúc sáu giờ.","acceptedAnswers":["I usually get up at six.","I usually get up at six o''clock.","I usually get up at 6.","I usually get up at six"],"explanationVi":"I usually get up at six."}'::jsonb),
 ('a2-u01-l3-p6','a2-u01-l3','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi vị trí trạng từ:","sourceText":"She drinks never coffee.","acceptedAnswers":["She never drinks coffee.","She never drinks coffee"],"explanationVi":"Trạng từ tần suất đứng trước động từ thường: never drinks."}'::jsonb),
 ('a2-u01-l3-p7','a2-u01-l3','vocabulary_match',7,'practice','easy',false,'{"question":"Nối cụm từ với nghĩa:","pairs":[{"left":"have lunch","right":"ăn trưa"},{"left":"go to bed","right":"đi ngủ"},{"left":"take a shower","right":"tắm"}],"explanationVi":"Ghép đúng từng cụm sinh hoạt."}'::jsonb),
 ('a2-u01-l3-q1','a2-u01-l3','vocabulary_match',8,'quiz','easy',true,'{"question":"Nối cụm từ sinh hoạt với nghĩa:","pairs":[{"left":"get up","right":"thức dậy"},{"left":"go to work","right":"đi làm"},{"left":"come home","right":"về nhà"}],"explanationVi":"Ghép đúng từng cụm."}'::jsonb),
 ('a2-u01-l3-q2','a2-u01-l3','multiple_choice',9,'quiz','easy',true,'{"question":"Trạng từ nào chỉ tần suất CAO NHẤT (100%)?","options":[{"id":"a","text":"sometimes"},{"id":"b","text":"always"},{"id":"c","text":"never"}],"correctOptionId":"b","explanationVi":"always = 100%."}'::jsonb),
 ('a2-u01-l3-q3','a2-u01-l3','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu đúng vị trí trạng từ:","options":[{"id":"a","text":"I always get up early."},{"id":"b","text":"I get up always early."},{"id":"c","text":"Always I get up early."}],"correctOptionId":"a","explanationVi":"Tần suất đứng trước động từ thường: always get up."}'::jsonb),
 ('a2-u01-l3-q4','a2-u01-l3','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền trạng từ (0%): \"He ___ eats fast food.\"","acceptedAnswers":["never"],"explanationVi":"never = không bao giờ (0%)."}'::jsonb),
 ('a2-u01-l3-q5','a2-u01-l3','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối trạng từ tần suất với mức độ:","pairs":[{"left":"always","right":"luôn luôn"},{"left":"often","right":"thường"},{"left":"sometimes","right":"thỉnh thoảng"}],"explanationVi":"Ghép đúng mức tần suất."}'::jsonb),
 ('a2-u01-l3-q6','a2-u01-l3','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["usually","I","breakfast","have","at seven"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: I usually have breakfast at seven."}'::jsonb),
 ('a2-u01-l3-q7','a2-u01-l3','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Đặt trạng từ đúng vị trí với to be: \"She is ___ late.\" (không bao giờ)","acceptedAnswers":["never"],"explanationVi":"Sau động từ to be: She is never late."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u01-l4','A2','reading','a2-u01','normal',4,'A day in my life','Đọc hiểu: lịch sinh hoạt một ngày',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn văn ngắn về một ngày của Linh, rồi trả lời câu hỏi đọc hiểu.",
    "objectives":["Đọc hiểu đoạn văn kể về lịch sinh hoạt","Tìm thông tin chi tiết trong bài đọc","Ôn lại từ vựng routine và trạng từ tần suất qua ngữ cảnh"],
    "vocabBlock":[
      {"word":"breakfast","ipa":"/ˈbrekfəst/","meaningVi":"bữa sáng","example":"I have breakfast at seven."},
      {"word":"office","ipa":"/ˈɒfɪs/","meaningVi":"văn phòng","example":"She works in an office."},
      {"word":"dinner","ipa":"/ˈdɪnə/","meaningVi":"bữa tối","example":"We have dinner at eight."},
      {"word":"weekend","ipa":"/ˌwiːkˈend/","meaningVi":"cuối tuần","example":"I relax at the weekend."}],
    "examples":[
      {"en":"My name is Linh. I am a teacher. On weekdays I get up at six o''clock. I have breakfast with my family at half past six. Then I go to work by motorbike. I usually start work at half past seven and teach English until four in the afternoon. After work I sometimes go to the gym, but I never stay there for long. I come home at about six, cook dinner, and watch TV with my parents. At the weekend I do not work. I relax, read books, and meet my friends.","vi":"Tên tôi là Linh. Tôi là giáo viên. Vào ngày thường tôi thức dậy lúc sáu giờ. Tôi ăn sáng cùng gia đình lúc sáu giờ rưỡi. Sau đó tôi đi làm bằng xe máy. Tôi thường bắt đầu làm việc lúc bảy giờ rưỡi và dạy tiếng Anh đến bốn giờ chiều. Sau giờ làm tôi thỉnh thoảng đi tập gym, nhưng không bao giờ ở đó lâu. Tôi về nhà khoảng sáu giờ, nấu bữa tối và xem TV với bố mẹ. Cuối tuần tôi không làm việc. Tôi thư giãn, đọc sách và gặp bạn bè."}],
    "commonMistakes":["Đọc kỹ dấu hiệu thời gian (at six, at the weekend) để trả lời chính xác."],
    "tips":["Gạch chân các mốc thời gian và động từ trong bài để trả lời câu hỏi nhanh hơn."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u01-l4-p1','a2-u01-l4','multiple_choice',1,'practice','easy',false,'{"question":"Theo bài đọc, Linh làm nghề gì?","options":[{"id":"a","text":"Bác sĩ"},{"id":"b","text":"Giáo viên"},{"id":"c","text":"Kỹ sư"}],"correctOptionId":"b","explanationVi":"\"I am a teacher.\" → Linh là giáo viên."}'::jsonb),
 ('a2-u01-l4-p2','a2-u01-l4','multiple_choice',2,'practice','easy',false,'{"question":"Linh thức dậy lúc mấy giờ vào ngày thường?","options":[{"id":"a","text":"6 giờ"},{"id":"b","text":"7 giờ"},{"id":"c","text":"6 giờ rưỡi"}],"correctOptionId":"a","explanationVi":"\"I get up at six o''clock.\" → 6 giờ."}'::jsonb),
 ('a2-u01-l4-p3','a2-u01-l4','multiple_choice',3,'practice','medium',false,'{"question":"Linh đi làm bằng phương tiện gì?","options":[{"id":"a","text":"Xe buýt"},{"id":"b","text":"Xe máy"},{"id":"c","text":"Đi bộ"}],"correctOptionId":"b","explanationVi":"\"I go to work by motorbike.\" → xe máy."}'::jsonb),
 ('a2-u01-l4-p4','a2-u01-l4','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ trong bài với nghĩa:","pairs":[{"left":"breakfast","right":"bữa sáng"},{"left":"office","right":"văn phòng"},{"left":"weekend","right":"cuối tuần"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('a2-u01-l4-p5','a2-u01-l4','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cuối tuần tôi không làm việc.","acceptedAnswers":["At the weekend I do not work.","At the weekend I don''t work.","I do not work at the weekend.","I don''t work at the weekend."],"explanationVi":"At the weekend I do not work."}'::jsonb),
 ('a2-u01-l4-p6','a2-u01-l4','multiple_choice',6,'practice','medium',false,'{"question":"Sau giờ làm, Linh thỉnh thoảng làm gì?","options":[{"id":"a","text":"Đi tập gym"},{"id":"b","text":"Đi mua sắm"},{"id":"c","text":"Đi ngủ sớm"}],"correctOptionId":"a","explanationVi":"\"I sometimes go to the gym.\" → đi tập gym."}'::jsonb),
 ('a2-u01-l4-q1','a2-u01-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Linh ăn sáng cùng ai?","options":[{"id":"a","text":"Bạn bè"},{"id":"b","text":"Gia đình"},{"id":"c","text":"Một mình"}],"correctOptionId":"b","explanationVi":"\"I have breakfast with my family.\""}'::jsonb),
 ('a2-u01-l4-q2','a2-u01-l4','multiple_choice',8,'quiz','easy',true,'{"question":"Linh dạy tiếng Anh đến mấy giờ chiều?","options":[{"id":"a","text":"3 giờ"},{"id":"b","text":"4 giờ"},{"id":"c","text":"5 giờ"}],"correctOptionId":"b","explanationVi":"\"...until four in the afternoon.\" → 4 giờ."}'::jsonb),
 ('a2-u01-l4-q3','a2-u01-l4','multiple_choice',9,'quiz','medium',true,'{"question":"Linh về nhà khoảng mấy giờ?","options":[{"id":"a","text":"5 giờ"},{"id":"b","text":"6 giờ"},{"id":"c","text":"7 giờ"}],"correctOptionId":"b","explanationVi":"\"I come home at about six.\" → khoảng 6 giờ."}'::jsonb),
 ('a2-u01-l4-q4','a2-u01-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Vào cuối tuần Linh KHÔNG làm việc gì sau đây?","options":[{"id":"a","text":"Đọc sách"},{"id":"b","text":"Gặp bạn bè"},{"id":"c","text":"Đi làm"}],"correctOptionId":"c","explanationVi":"\"At the weekend I do not work.\" → cuối tuần không đi làm."}'::jsonb),
 ('a2-u01-l4-q5','a2-u01-l4','multiple_choice',11,'quiz','medium',true,'{"question":"Linh ở phòng gym bao lâu?","options":[{"id":"a","text":"Rất lâu"},{"id":"b","text":"Không bao giờ lâu"},{"id":"c","text":"Cả buổi tối"}],"correctOptionId":"b","explanationVi":"\"I never stay there for long.\" → không bao giờ ở lâu."}'::jsonb),
 ('a2-u01-l4-q6','a2-u01-l4','grammar_fill_blank',12,'quiz','medium',true,'{"question":"Hoàn thành theo bài: \"Linh ___ (cook) dinner after coming home.\"","acceptedAnswers":["cooks"],"explanationVi":"Ngôi thứ ba số ít: cooks."}'::jsonb),
 ('a2-u01-l4-q7','a2-u01-l4','vocabulary_match',13,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"dinner","right":"bữa tối"},{"left":"office","right":"văn phòng"},{"left":"weekend","right":"cuối tuần"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u01-l5','A2','reading','a2-u01','unit_review',5,'Unit 1 Review','Ôn tập Unit 1: hai thì, tần suất, từ routine',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 1: hiện tại đơn, hiện tại tiếp diễn, trạng từ tần suất, từ vựng sinh hoạt.",
    "objectives":["Tổng hợp can-do Unit 1","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u01-l5-q1','a2-u01-l5','grammar_fill_blank',1,'quiz','easy',true,'{"question":"Chia động từ: \"She ___ (work) in a bank.\"","acceptedAnswers":["works"],"explanationVi":"Ngôi thứ ba thêm -s: works."}'::jsonb),
 ('a2-u01-l5-q2','a2-u01-l5','multiple_choice',2,'quiz','easy',true,'{"question":"Chọn câu hiện tại tiếp diễn ĐÚNG:","options":[{"id":"a","text":"He is read a book."},{"id":"b","text":"He is reading a book."},{"id":"c","text":"He reading a book."}],"correctOptionId":"b","explanationVi":"be + V-ing: is reading."}'::jsonb),
 ('a2-u01-l5-q3','a2-u01-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Trạng từ nào nghĩa là \"không bao giờ\"?","options":[{"id":"a","text":"always"},{"id":"b","text":"never"},{"id":"c","text":"often"}],"correctOptionId":"b","explanationVi":"never = không bao giờ."}'::jsonb),
 ('a2-u01-l5-q4','a2-u01-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền do/does: \"___ he like coffee?\"","acceptedAnswers":["Does"],"explanationVi":"Ngôi thứ ba số ít: Does."}'::jsonb),
 ('a2-u01-l5-q5','a2-u01-l5','vocabulary_match',5,'quiz','medium',true,'{"question":"Nối cụm từ sinh hoạt với nghĩa:","pairs":[{"left":"get up","right":"thức dậy"},{"left":"have breakfast","right":"ăn sáng"},{"left":"go to work","right":"đi làm"}],"explanationVi":"Ghép đúng từng cụm."}'::jsonb),
 ('a2-u01-l5-q6','a2-u01-l5','multiple_choice',6,'quiz','medium',true,'{"question":"Chọn câu dùng thì ĐÚNG: \"Look! It ___ now.\"","options":[{"id":"a","text":"rains"},{"id":"b","text":"is raining"},{"id":"c","text":"rain"}],"correctOptionId":"b","explanationVi":"Look! + now → tiếp diễn: is raining."}'::jsonb),
 ('a2-u01-l5-q7','a2-u01-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Thêm -ing: \"They are ___ (play) football now.\"","acceptedAnswers":["playing"],"explanationVi":"play → playing."}'::jsonb),
 ('a2-u01-l5-q8','a2-u01-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["always","I","early","up","get"],"correctOrder":[1,0,4,3,2],"explanationVi":"Câu đúng: I always get up early."}'::jsonb),
 ('a2-u01-l5-q9','a2-u01-l5','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn câu phủ định ĐÚNG ở hiện tại đơn:","options":[{"id":"a","text":"He doesn''t likes tea."},{"id":"b","text":"He don''t like tea."},{"id":"c","text":"He doesn''t like tea."}],"correctOptionId":"c","explanationVi":"doesn''t + V nguyên thể: doesn''t like."}'::jsonb),
 ('a2-u01-l5-q10','a2-u01-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["is","She","now","cooking"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: She is cooking now."}'::jsonb);

-- ── UNIT 02 — People & Personalities / Con người & Tính cách ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u02-l1','A2','reading','a2-u02','normal',1,'Adjective Order','Trật tự tính từ trước danh từ',9,15,70,'{}'::jsonb,
  '{"warmup":"Vì sao ta nói \"a nice big old brown bag\" mà không phải \"a brown old big nice bag\"?",
    "objectives":["Nắm thứ tự tính từ: opinion-size-age-colour + noun","Sắp xếp nhiều tính từ trước một danh từ"],
    "grammarHtml":"Khi có nhiều tính từ trước danh từ, thứ tự thường là: <b>Opinion → Size → Age → Colour</b> + noun. Ví dụ: a <i>nice</i> (opinion) <i>big</i> (size) <i>old</i> (age) <i>brown</i> (colour) bag.",
    "vocabBlock":[
      {"word":"nice","ipa":"/naɪs/","meaningVi":"đẹp, dễ chịu (opinion)","example":"It is a nice idea."},
      {"word":"big","ipa":"/bɪɡ/","meaningVi":"to, lớn (size)","example":"a big house"},
      {"word":"old","ipa":"/əʊld/","meaningVi":"cũ, già (age)","example":"an old car"},
      {"word":"brown","ipa":"/braʊn/","meaningVi":"màu nâu (colour)","example":"a brown bag"},
      {"word":"small","ipa":"/smɔːl/","meaningVi":"nhỏ (size)","example":"a small dog"}],
    "examples":[
      {"en":"a nice big old brown bag","vi":"một cái túi đẹp, to, cũ, màu nâu"},
      {"en":"a beautiful little white cat","vi":"một con mèo trắng nhỏ xinh đẹp"},
      {"en":"an expensive new black phone","vi":"một chiếc điện thoại đen mới đắt tiền"}],
    "commonMistakes":["Đặt sai thứ tự: ❌ \"a brown big bag\" → ✅ \"a big brown bag\" (size trước colour)."],
    "tips":["Ghi nhớ trật tự O-S-A-C: Opinion → Size → Age → Colour."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u02-l1-p1','a2-u02-l1','multiple_choice',1,'practice','easy',false,'{"question":"Thứ tự tính từ thường gặp là gì?","options":[{"id":"a","text":"Colour - Age - Size - Opinion"},{"id":"b","text":"Opinion - Size - Age - Colour"},{"id":"c","text":"Size - Opinion - Colour - Age"}],"correctOptionId":"b","explanationVi":"Trật tự chuẩn: Opinion - Size - Age - Colour."}'::jsonb),
 ('a2-u02-l1-p2','a2-u02-l1','sentence_ordering',2,'practice','medium',false,'{"question":"Sắp xếp các tính từ đúng trật tự trước \"car\":","tokens":["old","a","red","big"],"correctOrder":[1,3,0,2],"explanationVi":"a big (size) old (age) red (colour) car."}'::jsonb),
 ('a2-u02-l1-p3','a2-u02-l1','multiple_choice',3,'practice','easy',false,'{"question":"Chọn cụm đúng trật tự:","options":[{"id":"a","text":"a small old white dog"},{"id":"b","text":"a white small old dog"},{"id":"c","text":"an old white small dog"}],"correctOptionId":"a","explanationVi":"Size (small) - Age (old) - Colour (white)."}'::jsonb),
 ('a2-u02-l1-p4','a2-u02-l1','vocabulary_match',4,'practice','easy',false,'{"question":"Nối tính từ với loại của nó:","pairs":[{"left":"nice","right":"opinion (ý kiến)"},{"left":"big","right":"size (kích cỡ)"},{"left":"old","right":"age (tuổi)"},{"left":"brown","right":"colour (màu)"}],"explanationVi":"Phân loại theo O-S-A-C."}'::jsonb),
 ('a2-u02-l1-p5','a2-u02-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"một con mèo đen nhỏ","acceptedAnswers":["a small black cat","small black cat"],"explanationVi":"Size (small) trước Colour (black): a small black cat."}'::jsonb),
 ('a2-u02-l1-p6','a2-u02-l1','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trật tự tính từ:","sourceText":"a brown big old bag","acceptedAnswers":["a big old brown bag"],"explanationVi":"Size - Age - Colour: a big old brown bag."}'::jsonb),
 ('a2-u02-l1-q1','a2-u02-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Cụm nào đúng trật tự?","options":[{"id":"a","text":"a big old brown bag"},{"id":"b","text":"a brown old big bag"},{"id":"c","text":"an old brown big bag"}],"correctOptionId":"a","explanationVi":"Size - Age - Colour."}'::jsonb),
 ('a2-u02-l1-q2','a2-u02-l1','sentence_ordering',8,'quiz','medium',true,'{"question":"Sắp xếp đúng trật tự trước \"bag\":","tokens":["brown","big","a","old"],"correctOrder":[2,1,3,0],"explanationVi":"a big old brown bag."}'::jsonb),
 ('a2-u02-l1-q3','a2-u02-l1','grammar_fill_blank',9,'quiz','medium',true,'{"question":"Sắp đúng trật tự: a ___ ___ cat (small / white)","acceptedAnswers":["small white","small, white"],"explanationVi":"Size (small) trước Colour (white)."}'::jsonb),
 ('a2-u02-l1-q4','a2-u02-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn cụm đúng:","options":[{"id":"a","text":"a beautiful little white cat"},{"id":"b","text":"a white little beautiful cat"},{"id":"c","text":"a little beautiful white cat"}],"correctOptionId":"a","explanationVi":"Opinion - Size - Colour: beautiful little white."}'::jsonb),
 ('a2-u02-l1-q5','a2-u02-l1','vocabulary_match',11,'quiz','easy',true,'{"question":"Nối tính từ với loại:","pairs":[{"left":"expensive","right":"opinion"},{"left":"small","right":"size"},{"left":"new","right":"age"},{"left":"black","right":"colour"}],"explanationVi":"Phân loại O-S-A-C."}'::jsonb),
 ('a2-u02-l1-q6','a2-u02-l1','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp đúng trật tự:","tokens":["new","a","black","expensive","phone"],"correctOrder":[1,3,0,2,4],"explanationVi":"an expensive (opinion) new (age) black (colour) phone."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u02-l2','A2','reading','a2-u02','normal',2,'Comparatives & (not) as...as','So sánh hơn và (không) bằng',9,15,70,'{}'::jsonb,
  '{"warmup":"Bạn cao hơn hay thấp hơn người bên cạnh? Làm sao nói điều đó bằng tiếng Anh?",
    "objectives":["Tạo so sánh hơn: adj-er / more... than","Dùng as...as (bằng) và not as...as (không bằng)"],
    "grammarHtml":"Tính từ ngắn: thêm <b>-er</b> + than (taller than). Tính từ dài: <b>more</b> + adj + than (more beautiful than). Bằng nhau: <b>as + adj + as</b>. Không bằng: <b>not as + adj + as</b>.",
    "vocabBlock":[
      {"word":"taller","ipa":"/ˈtɔːlə/","meaningVi":"cao hơn","example":"Tom is taller than me."},
      {"word":"bigger","ipa":"/ˈbɪɡə/","meaningVi":"to hơn","example":"My house is bigger than yours."},
      {"word":"more friendly","ipa":"/mɔː ˈfrendli/","meaningVi":"thân thiện hơn","example":"She is more friendly than him."},
      {"word":"as tall as","ipa":"/əz tɔːl əz/","meaningVi":"cao bằng","example":"He is as tall as his father."},
      {"word":"than","ipa":"/ðæn/","meaningVi":"hơn (so sánh)","example":"older than me"}],
    "examples":[
      {"en":"Tom is taller than Nam.","vi":"Tom cao hơn Nam."},
      {"en":"This book is more interesting than that one.","vi":"Cuốn sách này thú vị hơn cuốn kia."},
      {"en":"Mai is as clever as her sister.","vi":"Mai thông minh bằng chị gái cô ấy."},
      {"en":"I am not as tall as you.","vi":"Tôi không cao bằng bạn."}],
    "commonMistakes":["❌ \"more taller\" → ✅ \"taller\" (không dùng more với tính từ đã có -er).","❌ \"taller as me\" → ✅ \"taller than me\"."],
    "tips":["Tính từ 1 âm tiết tận cùng phụ âm + nguyên âm + phụ âm: gấp đôi phụ âm (big → bigger)."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u02-l2-p1','a2-u02-l2','grammar_fill_blank',1,'practice','easy',false,'{"question":"\"Tom is ___ (tall) than Nam.\"","acceptedAnswers":["taller"],"explanationVi":"Tính từ ngắn + -er: taller."}'::jsonb),
 ('a2-u02-l2-p2','a2-u02-l2','multiple_choice',2,'practice','easy',false,'{"question":"Chọn dạng so sánh đúng của \"beautiful\":","options":[{"id":"a","text":"beautifuler"},{"id":"b","text":"more beautiful"},{"id":"c","text":"beautifuller"}],"correctOptionId":"b","explanationVi":"Tính từ dài dùng more + adj."}'::jsonb),
 ('a2-u02-l2-p3','a2-u02-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"\"My bag is ___ (big) than yours.\"","acceptedAnswers":["bigger"],"explanationVi":"big → bigger (gấp đôi g)."}'::jsonb),
 ('a2-u02-l2-p4','a2-u02-l2','multiple_choice',4,'practice','medium',false,'{"question":"\"He is ___ tall ___ his brother.\" (cao bằng)","options":[{"id":"a","text":"as ... as"},{"id":"b","text":"more ... than"},{"id":"c","text":"as ... than"}],"correctOptionId":"a","explanationVi":"Bằng nhau dùng as...as."}'::jsonb),
 ('a2-u02-l2-p5','a2-u02-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi không cao bằng bạn.","acceptedAnswers":["I am not as tall as you.","I''m not as tall as you.","I am not as tall as you","I''m not as tall as you"],"explanationVi":"not as + adj + as: I am not as tall as you."}'::jsonb),
 ('a2-u02-l2-p6','a2-u02-l2','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi:","sourceText":"She is more taller than me.","acceptedAnswers":["She is taller than me.","She is taller than me"],"explanationVi":"Không dùng more với taller; bỏ more."}'::jsonb),
 ('a2-u02-l2-q1','a2-u02-l2','grammar_fill_blank',7,'quiz','easy',true,'{"question":"\"This box is ___ (heavy) than that one.\"","acceptedAnswers":["heavier"],"explanationVi":"heavy → heavier (y → ier)."}'::jsonb),
 ('a2-u02-l2-q2','a2-u02-l2','multiple_choice',8,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She is more clever than him."},{"id":"b","text":"She is cleverer than him."},{"id":"c","text":"She is clevererer than him."}],"correctOptionId":"b","explanationVi":"clever → cleverer (tính từ ngắn)."}'::jsonb),
 ('a2-u02-l2-q3','a2-u02-l2','grammar_fill_blank',9,'quiz','medium',true,'{"question":"\"Mai is as ___ (clever) as her sister.\"","acceptedAnswers":["clever"],"explanationVi":"as + adj nguyên gốc + as."}'::jsonb),
 ('a2-u02-l2-q4','a2-u02-l2','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu so sánh:","tokens":["than","taller","Tom","is","Nam"],"correctOrder":[2,3,1,0,4],"explanationVi":"Tom is taller than Nam."}'::jsonb),
 ('a2-u02-l2-q5','a2-u02-l2','multiple_choice',11,'quiz','medium',true,'{"question":"\"I am not ___ strong ___ you.\" (không khỏe bằng)","options":[{"id":"a","text":"as ... as"},{"id":"b","text":"more ... than"},{"id":"c","text":"so ... than"}],"correctOptionId":"a","explanationVi":"not as + adj + as."}'::jsonb),
 ('a2-u02-l2-q6','a2-u02-l2','grammar_fill_blank',12,'quiz','hard',true,'{"question":"\"This film is ___ ___ (interesting) than that one.\"","acceptedAnswers":["more interesting"],"explanationVi":"Tính từ dài: more interesting than."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u02-l3','A2','reading','a2-u02','normal',3,'Superlatives','So sánh nhất',9,15,70,'{}'::jsonb,
  '{"warmup":"Ai cao nhất trong lớp bạn? Đó là so sánh nhất!",
    "objectives":["Tạo so sánh nhất: the -est / the most","Nhớ dạng bất quy tắc: good → best, bad → worst"],
    "grammarHtml":"Tính từ ngắn: <b>the + adj-est</b> (the tallest). Tính từ dài: <b>the most + adj</b> (the most beautiful). Bất quy tắc: good → <b>the best</b>, bad → <b>the worst</b>.",
    "vocabBlock":[
      {"word":"the tallest","ipa":"/ðə ˈtɔːlɪst/","meaningVi":"cao nhất","example":"He is the tallest in the class."},
      {"word":"the best","ipa":"/ðə best/","meaningVi":"tốt nhất","example":"She is the best student."},
      {"word":"the worst","ipa":"/ðə wɜːst/","meaningVi":"tệ nhất","example":"It was the worst day."},
      {"word":"the most popular","ipa":"/ðə məʊst ˈpɒpjələ/","meaningVi":"nổi tiếng nhất","example":"the most popular singer"},
      {"word":"the biggest","ipa":"/ðə ˈbɪɡɪst/","meaningVi":"to nhất","example":"the biggest city"}],
    "examples":[
      {"en":"Tom is the tallest boy in the class.","vi":"Tom là cậu bé cao nhất lớp."},
      {"en":"This is the most interesting book.","vi":"Đây là cuốn sách thú vị nhất."},
      {"en":"She is the best singer.","vi":"Cô ấy là ca sĩ hay nhất."},
      {"en":"That was the worst film.","vi":"Đó là bộ phim tệ nhất."}],
    "commonMistakes":["❌ \"the most tallest\" → ✅ \"the tallest\".","❌ \"the goodest\" → ✅ \"the best\" (bất quy tắc)."],
    "tips":["So sánh nhất luôn đi với the. good → best, bad → worst phải học thuộc."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u02-l3-p1','a2-u02-l3','grammar_fill_blank',1,'practice','easy',false,'{"question":"\"He is the ___ (tall) in the class.\"","acceptedAnswers":["tallest"],"explanationVi":"Tính từ ngắn: the + adj-est."}'::jsonb),
 ('a2-u02-l3-p2','a2-u02-l3','multiple_choice',2,'practice','easy',false,'{"question":"So sánh nhất của \"good\" là gì?","options":[{"id":"a","text":"the goodest"},{"id":"b","text":"the best"},{"id":"c","text":"the most good"}],"correctOptionId":"b","explanationVi":"good → the best (bất quy tắc)."}'::jsonb),
 ('a2-u02-l3-p3','a2-u02-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"\"It was the ___ (bad) day of my life.\"","acceptedAnswers":["worst"],"explanationVi":"bad → the worst."}'::jsonb),
 ('a2-u02-l3-p4','a2-u02-l3','multiple_choice',4,'practice','medium',false,'{"question":"Chọn dạng đúng của \"popular\":","options":[{"id":"a","text":"the popularest"},{"id":"b","text":"the most popular"},{"id":"c","text":"most popular"}],"correctOptionId":"b","explanationVi":"Tính từ dài: the most + adj."}'::jsonb),
 ('a2-u02-l3-p5','a2-u02-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cô ấy là học sinh giỏi nhất.","acceptedAnswers":["She is the best student.","She is the best student"],"explanationVi":"good → the best: She is the best student."}'::jsonb),
 ('a2-u02-l3-p6','a2-u02-l3','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi:","sourceText":"He is the most tallest boy.","acceptedAnswers":["He is the tallest boy.","He is the tallest boy"],"explanationVi":"Bỏ most: the tallest boy."}'::jsonb),
 ('a2-u02-l3-q1','a2-u02-l3','grammar_fill_blank',7,'quiz','easy',true,'{"question":"\"This is the ___ (big) city in my country.\"","acceptedAnswers":["biggest"],"explanationVi":"big → the biggest."}'::jsonb),
 ('a2-u02-l3-q2','a2-u02-l3','multiple_choice',8,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She is the most clever girl."},{"id":"b","text":"She is the cleverest girl."},{"id":"c","text":"She is the cleverestest girl."}],"correctOptionId":"b","explanationVi":"clever → the cleverest."}'::jsonb),
 ('a2-u02-l3-q3','a2-u02-l3','grammar_fill_blank',9,'quiz','medium',true,'{"question":"\"It was the ___ (good) film of the year.\"","acceptedAnswers":["best"],"explanationVi":"good → the best."}'::jsonb),
 ('a2-u02-l3-q4','a2-u02-l3','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu so sánh nhất:","tokens":["the","Tom","tallest","is"],"correctOrder":[1,3,0,2],"explanationVi":"Tom is the tallest."}'::jsonb),
 ('a2-u02-l3-q5','a2-u02-l3','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối tính từ với dạng so sánh nhất:","pairs":[{"left":"good","right":"the best"},{"left":"bad","right":"the worst"},{"left":"big","right":"the biggest"},{"left":"happy","right":"the happiest"}],"explanationVi":"Nhớ dạng bất quy tắc và quy tắc."}'::jsonb),
 ('a2-u02-l3-q6','a2-u02-l3','multiple_choice',12,'quiz','hard',true,'{"question":"\"Mount Everest is the ___ mountain in the world.\"","options":[{"id":"a","text":"highest"},{"id":"b","text":"higher"},{"id":"c","text":"most high"}],"correctOptionId":"a","explanationVi":"high → the highest."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u02-l4','A2','reading','a2-u02','normal',4,'Appearance & Personality','Từ vựng tả ngoại hình & tính cách',9,15,70,'{}'::jsonb,
  '{"warmup":"Hãy nghĩ về một người bạn — họ trông thế nào và tính cách ra sao?",
    "objectives":["Học 15+ tính từ tả ngoại hình & tính cách","Phân biệt từ tả ngoại hình và từ tả tính cách"],
    "vocabBlock":[
      {"word":"tall","ipa":"/tɔːl/","meaningVi":"cao","example":"He is very tall."},
      {"word":"short","ipa":"/ʃɔːt/","meaningVi":"thấp","example":"She is short."},
      {"word":"kind","ipa":"/kaɪnd/","meaningVi":"tốt bụng","example":"My teacher is very kind."},
      {"word":"friendly","ipa":"/ˈfrendli/","meaningVi":"thân thiện","example":"The people here are friendly."},
      {"word":"shy","ipa":"/ʃaɪ/","meaningVi":"nhút nhát","example":"He is too shy to speak."},
      {"word":"clever","ipa":"/ˈklevə/","meaningVi":"thông minh","example":"She is a clever student."},
      {"word":"lazy","ipa":"/ˈleɪzi/","meaningVi":"lười biếng","example":"My brother is lazy."},
      {"word":"hard-working","ipa":"/ˌhɑːdˈwɜːkɪŋ/","meaningVi":"chăm chỉ","example":"She is hard-working."},
      {"word":"young","ipa":"/jʌŋ/","meaningVi":"trẻ","example":"He looks young."},
      {"word":"old","ipa":"/əʊld/","meaningVi":"già","example":"My grandfather is old."},
      {"word":"slim","ipa":"/slɪm/","meaningVi":"mảnh mai","example":"She is slim."},
      {"word":"funny","ipa":"/ˈfʌni/","meaningVi":"vui tính","example":"My friend is funny."},
      {"word":"polite","ipa":"/pəˈlaɪt/","meaningVi":"lịch sự","example":"He is always polite."},
      {"word":"quiet","ipa":"/ˈkwaɪət/","meaningVi":"trầm tính, ít nói","example":"She is a quiet girl."},
      {"word":"honest","ipa":"/ˈɒnɪst/","meaningVi":"trung thực","example":"He is an honest man."}],
    "examples":[
      {"en":"My sister is tall and friendly.","vi":"Chị tôi cao và thân thiện."},
      {"en":"He is clever but a bit lazy.","vi":"Cậu ấy thông minh nhưng hơi lười."},
      {"en":"She is shy and quiet.","vi":"Cô ấy nhút nhát và ít nói."}],
    "commonMistakes":["Đừng nhầm \"sympathetic\" (thông cảm) với \"nice/friendly\" (tốt/thân thiện)."],
    "tips":["Ngoại hình: tall, short, slim, young, old. Tính cách: kind, friendly, shy, clever, lazy, hard-working."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u02-l4-p1','a2-u02-l4','vocabulary_match',1,'practice','easy',false,'{"question":"Nối tính từ ngoại hình với nghĩa:","pairs":[{"left":"tall","right":"cao"},{"left":"short","right":"thấp"},{"left":"slim","right":"mảnh mai"},{"left":"young","right":"trẻ"}],"explanationVi":"Từ tả ngoại hình."}'::jsonb),
 ('a2-u02-l4-p2','a2-u02-l4','vocabulary_match',2,'practice','easy',false,'{"question":"Nối tính từ tính cách với nghĩa:","pairs":[{"left":"kind","right":"tốt bụng"},{"left":"friendly","right":"thân thiện"},{"left":"shy","right":"nhút nhát"},{"left":"clever","right":"thông minh"}],"explanationVi":"Từ tả tính cách."}'::jsonb),
 ('a2-u02-l4-p3','a2-u02-l4','vocabulary_match',3,'practice','medium',false,'{"question":"Nối từ trái nghĩa:","pairs":[{"left":"tall","right":"short"},{"left":"lazy","right":"hard-working"},{"left":"young","right":"old"},{"left":"shy","right":"friendly"}],"explanationVi":"Cặp trái nghĩa."}'::jsonb),
 ('a2-u02-l4-p4','a2-u02-l4','multiple_choice',4,'practice','easy',false,'{"question":"\"hard-working\" nghĩa là gì?","options":[{"id":"a","text":"lười biếng"},{"id":"b","text":"chăm chỉ"},{"id":"c","text":"trầm tính"}],"correctOptionId":"b","explanationVi":"hard-working = chăm chỉ."}'::jsonb),
 ('a2-u02-l4-p5','a2-u02-l4','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Chị tôi cao và thân thiện.","acceptedAnswers":["My sister is tall and friendly.","My sister is tall and friendly"],"explanationVi":"tall (ngoại hình) and friendly (tính cách)."}'::jsonb),
 ('a2-u02-l4-p6','a2-u02-l4','vocabulary_match',6,'practice','medium',false,'{"question":"Nối tính từ với nghĩa:","pairs":[{"left":"funny","right":"vui tính"},{"left":"polite","right":"lịch sự"},{"left":"quiet","right":"ít nói"},{"left":"honest","right":"trung thực"}],"explanationVi":"Thêm từ tả tính cách."}'::jsonb),
 ('a2-u02-l4-q1','a2-u02-l4','vocabulary_match',7,'quiz','easy',true,'{"question":"Nối tính từ với nghĩa:","pairs":[{"left":"tall","right":"cao"},{"left":"kind","right":"tốt bụng"},{"left":"lazy","right":"lười biếng"},{"left":"clever","right":"thông minh"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u02-l4-q2','a2-u02-l4','multiple_choice',8,'quiz','easy',true,'{"question":"Từ nào tả TÍNH CÁCH (không phải ngoại hình)?","options":[{"id":"a","text":"tall"},{"id":"b","text":"slim"},{"id":"c","text":"friendly"}],"correctOptionId":"c","explanationVi":"friendly = thân thiện (tính cách)."}'::jsonb),
 ('a2-u02-l4-q3','a2-u02-l4','grammar_fill_blank',9,'quiz','medium',true,'{"question":"Điền tính từ trái nghĩa: \"He is not lazy, he is very ___.\"","acceptedAnswers":["hard-working","hardworking"],"explanationVi":"Trái nghĩa của lazy là hard-working."}'::jsonb),
 ('a2-u02-l4-q4','a2-u02-l4','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"shy","right":"nhút nhát"},{"left":"funny","right":"vui tính"},{"left":"polite","right":"lịch sự"},{"left":"honest","right":"trung thực"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a2-u02-l4-q5','a2-u02-l4','multiple_choice',11,'quiz','medium',true,'{"question":"\"quiet\" nghĩa là gì?","options":[{"id":"a","text":"trầm tính, ít nói"},{"id":"b","text":"vui tính"},{"id":"c","text":"cao"}],"correctOptionId":"a","explanationVi":"quiet = ít nói, trầm tính."}'::jsonb),
 ('a2-u02-l4-q6','a2-u02-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu mô tả người:","tokens":["clever","is","and","She","kind"],"correctOrder":[3,1,0,2,4],"explanationVi":"She is clever and kind."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u02-l5','A2','reading','a2-u02','unit_review',5,'Unit 2 Review','Ôn tập Unit 2: so sánh, trật tự tính từ, tả người',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 2: trật tự tính từ, so sánh hơn/bằng/nhất, từ tả ngoại hình & tính cách.",
    "objectives":["Tổng hợp can-do Unit 2","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u02-l5-q1','a2-u02-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Cụm nào đúng trật tự tính từ?","options":[{"id":"a","text":"a big old brown bag"},{"id":"b","text":"a brown big old bag"},{"id":"c","text":"an old brown big bag"}],"correctOptionId":"a","explanationVi":"Size - Age - Colour."}'::jsonb),
 ('a2-u02-l5-q2','a2-u02-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"\"Tom is ___ (tall) than Nam.\"","acceptedAnswers":["taller"],"explanationVi":"Tính từ ngắn + -er."}'::jsonb),
 ('a2-u02-l5-q3','a2-u02-l5','multiple_choice',3,'quiz','easy',true,'{"question":"So sánh nhất của \"good\":","options":[{"id":"a","text":"the goodest"},{"id":"b","text":"the best"},{"id":"c","text":"the most good"}],"correctOptionId":"b","explanationVi":"good → the best."}'::jsonb),
 ('a2-u02-l5-q4','a2-u02-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"\"This box is ___ (heavy) than that one.\"","acceptedAnswers":["heavier"],"explanationVi":"heavy → heavier."}'::jsonb),
 ('a2-u02-l5-q5','a2-u02-l5','vocabulary_match',5,'quiz','medium',true,'{"question":"Nối tính từ với nghĩa:","pairs":[{"left":"kind","right":"tốt bụng"},{"left":"shy","right":"nhút nhát"},{"left":"lazy","right":"lười biếng"},{"left":"tall","right":"cao"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('a2-u02-l5-q6','a2-u02-l5','multiple_choice',6,'quiz','medium',true,'{"question":"\"Mai is ___ clever ___ her sister.\" (thông minh bằng)","options":[{"id":"a","text":"as ... as"},{"id":"b","text":"more ... than"},{"id":"c","text":"the ... est"}],"correctOptionId":"a","explanationVi":"Bằng nhau dùng as...as."}'::jsonb),
 ('a2-u02-l5-q7','a2-u02-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"\"It was the ___ (bad) day of my life.\"","acceptedAnswers":["worst"],"explanationVi":"bad → the worst."}'::jsonb),
 ('a2-u02-l5-q8','a2-u02-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp đúng trật tự tính từ:","tokens":["black","a","new","expensive","phone"],"correctOrder":[1,3,2,0,4],"explanationVi":"an expensive new black phone."}'::jsonb),
 ('a2-u02-l5-q9','a2-u02-l5','multiple_choice',9,'quiz','hard',true,'{"question":"Chọn câu so sánh nhất ĐÚNG:","options":[{"id":"a","text":"She is the most beautiful girl."},{"id":"b","text":"She is the beautifulest girl."},{"id":"c","text":"She is the most beautifulest girl."}],"correctOptionId":"a","explanationVi":"Tính từ dài: the most + adj."}'::jsonb),
 ('a2-u02-l5-q10','a2-u02-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu so sánh:","tokens":["than","taller","is","Tom","Nam"],"correctOrder":[3,2,1,0,4],"explanationVi":"Tom is taller than Nam."}'::jsonb);

-- ── UNIT 03 — My Past / Chuyện ngày xưa ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u03-l1','A2','reading','a2-u03','normal',1,'Past simple: was/were','Thì quá khứ đơn của to be',9,15,70,'{}'::jsonb,
  '{"warmup":"Hôm qua bạn ở đâu? Hãy nghĩ cách nói câu đó bằng tiếng Anh.",
    "objectives":["Dùng was với I/he/she/it","Dùng were với you/we/they","Phủ định wasn''t/weren''t và câu hỏi Was/Were...?"],
    "grammarHtml":"<b>was/were</b> là dạng quá khứ của <i>to be</i>. <br>I/he/she/it + <b>was</b>; you/we/they + <b>were</b>. <br>Phủ định: <b>wasn''t</b> (was not), <b>weren''t</b> (were not). <br>Câu hỏi: <b>Was</b> he tired? – <b>Were</b> they at home?",
    "vocabBlock":[
      {"word":"yesterday","ipa":"/ˈjestədeɪ/","meaningVi":"hôm qua","example":"I was at school yesterday."},
      {"word":"last night","ipa":"/lɑːst naɪt/","meaningVi":"tối qua","example":"We were tired last night."},
      {"word":"tired","ipa":"/ˈtaɪəd/","meaningVi":"mệt","example":"She was very tired."},
      {"word":"at home","ipa":"/ət həʊm/","meaningVi":"ở nhà","example":"They were at home."},
      {"word":"ago","ipa":"/əˈɡəʊ/","meaningVi":"cách đây (trước)","example":"Two days ago I was sick."}],
    "examples":[
      {"en":"I was at home last night.","vi":"Tối qua tôi ở nhà."},
      {"en":"They were happy yesterday.","vi":"Hôm qua họ vui."},
      {"en":"She wasn''t at work.","vi":"Cô ấy đã không đi làm."},
      {"en":"Were you tired?","vi":"Bạn có mệt không?"}],
    "commonMistakes":["❌ \"They was happy.\" → ✅ \"They were happy.\" (you/we/they dùng were).","❌ \"I were late.\" → ✅ \"I was late.\""],
    "tips":["Mẹo: I/he/she/it đi với WAS; you/we/they đi với WERE."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u03-l1-p1','a2-u03-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn từ đúng: \"I ___ at home yesterday.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"is"}],"correctOptionId":"a","explanationVi":"I + was."}'::jsonb),
 ('a2-u03-l1-p2','a2-u03-l1','multiple_choice',2,'practice','easy',false,'{"question":"Chọn từ đúng: \"They ___ happy.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"is"}],"correctOptionId":"b","explanationVi":"They + were."}'::jsonb),
 ('a2-u03-l1-p3','a2-u03-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"yesterday","right":"hôm qua"},{"left":"last night","right":"tối qua"},{"left":"tired","right":"mệt"},{"left":"ago","right":"cách đây"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u03-l1-p4','a2-u03-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền was/were: \"She ___ at school.\"","acceptedAnswers":["was"],"explanationVi":"She + was."}'::jsonb),
 ('a2-u03-l1-p5','a2-u03-l1','grammar_fill_blank',5,'practice','medium',false,'{"question":"Điền dạng phủ định rút gọn: \"We ___ at home.\" (were not)","acceptedAnswers":["weren''t","were not"],"explanationVi":"were not = weren''t."}'::jsonb),
 ('a2-u03-l1-p6','a2-u03-l1','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Hôm qua tôi mệt.","acceptedAnswers":["I was tired yesterday.","Yesterday I was tired.","I was tired yesterday","Yesterday I was tired"],"explanationVi":"I was tired yesterday."}'::jsonb),
 ('a2-u03-l1-p7','a2-u03-l1','error_correction',7,'practice','hard',false,'{"question":"Sửa lỗi was/were trong câu sau:","sourceText":"They was at the park.","acceptedAnswers":["They were at the park.","They were at the park"],"explanationVi":"They đi với were, không phải was."}'::jsonb),
 ('a2-u03-l1-q1','a2-u03-l1','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn từ đúng: \"He ___ tired last night.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"He + was."}'::jsonb),
 ('a2-u03-l1-q2','a2-u03-l1','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Điền was/were: \"You ___ late.\"","acceptedAnswers":["were"],"explanationVi":"You + were."}'::jsonb),
 ('a2-u03-l1-q3','a2-u03-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu phủ định ĐÚNG:","options":[{"id":"a","text":"She wasn''t at work."},{"id":"b","text":"She weren''t at work."},{"id":"c","text":"She not was at work."}],"correctOptionId":"a","explanationVi":"She + wasn''t (was not)."}'::jsonb),
 ('a2-u03-l1-q4','a2-u03-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền was/were vào câu hỏi: \"___ they at home?\"","acceptedAnswers":["Were"],"explanationVi":"Were they...? (they + were)."}'::jsonb),
 ('a2-u03-l1-q5','a2-u03-l1','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["you","Were","tired","?"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: Were you tired?"}'::jsonb),
 ('a2-u03-l1-q6','a2-u03-l1','vocabulary_match',13,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"at home","right":"ở nhà"},{"left":"yesterday","right":"hôm qua"},{"left":"tired","right":"mệt"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u03-l1-q7','a2-u03-l1','multiple_choice',14,'quiz','hard',true,'{"question":"Câu nào dùng SAI was/were?","options":[{"id":"a","text":"We were at the park."},{"id":"b","text":"I were happy."},{"id":"c","text":"It was cold."}],"correctOptionId":"b","explanationVi":"I đi với was → \"I was happy.\""}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u03-l2','A2','reading','a2-u03','normal',2,'Past simple regular -ed','Quá khứ đơn động từ có quy tắc',9,15,70,'{}'::jsonb,
  '{"warmup":"Bạn đã làm gì hôm qua? \"played\", \"watched\", \"studied\" — đó là quá khứ có quy tắc.",
    "objectives":["Thêm -ed để tạo quá khứ động từ có quy tắc","Nắm quy tắc chính tả: stop→stopped, study→studied","Dùng didn''t + V (nguyên thể) và câu hỏi Did...?"],
    "grammarHtml":"Động từ có quy tắc: thêm <b>-ed</b> (play→played, watch→watched). <br>Quy tắc chính tả: kết thúc <i>e</i> → +d (live→lived); phụ âm-nguyên âm-phụ âm → gấp đôi (stop→<b>stopped</b>); phụ âm + y → đổi y thành i (study→<b>studied</b>). <br>Phủ định: <b>didn''t</b> + V nguyên thể (I didn''t play). <br>Câu hỏi: <b>Did</b> you play?",
    "vocabBlock":[
      {"word":"played","ipa":"/pleɪd/","meaningVi":"đã chơi","example":"I played football."},
      {"word":"watched","ipa":"/wɒtʃt/","meaningVi":"đã xem","example":"She watched TV."},
      {"word":"studied","ipa":"/ˈstʌdid/","meaningVi":"đã học","example":"We studied English."},
      {"word":"stopped","ipa":"/stɒpt/","meaningVi":"đã dừng","example":"The bus stopped."},
      {"word":"visited","ipa":"/ˈvɪzɪtɪd/","meaningVi":"đã thăm","example":"They visited Hanoi."}],
    "examples":[
      {"en":"I watched a film last night.","vi":"Tối qua tôi xem một bộ phim."},
      {"en":"She studied for the test.","vi":"Cô ấy đã học để thi."},
      {"en":"We didn''t play football.","vi":"Chúng tôi đã không chơi bóng đá."},
      {"en":"Did you visit your grandma?","vi":"Bạn có thăm bà không?"}],
    "commonMistakes":["❌ \"I didn''t played.\" → ✅ \"I didn''t play.\" (sau didn''t dùng V nguyên thể).","❌ \"studyed\" → ✅ \"studied\" (phụ âm + y → ied)."],
    "tips":["Sau did/didn''t luôn dùng động từ NGUYÊN THỂ, không thêm -ed."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u03-l2-p1','a2-u03-l2','grammar_fill_blank',1,'practice','easy',false,'{"question":"Viết quá khứ của \"play\": I ___ football.","acceptedAnswers":["played"],"explanationVi":"play → played."}'::jsonb),
 ('a2-u03-l2-p2','a2-u03-l2','multiple_choice',2,'practice','easy',false,'{"question":"Quá khứ của \"watch\" là gì?","options":[{"id":"a","text":"watched"},{"id":"b","text":"watchs"},{"id":"c","text":"watcht"}],"correctOptionId":"a","explanationVi":"watch → watched."}'::jsonb),
 ('a2-u03-l2-p3','a2-u03-l2','multiple_choice',3,'practice','medium',false,'{"question":"Quá khứ của \"study\" là gì?","options":[{"id":"a","text":"studyed"},{"id":"b","text":"studied"},{"id":"c","text":"studed"}],"correctOptionId":"b","explanationVi":"study → studied (phụ âm + y → ied)."}'::jsonb),
 ('a2-u03-l2-p4','a2-u03-l2','vocabulary_match',4,'practice','medium',false,'{"question":"Nối động từ quá khứ với nghĩa:","pairs":[{"left":"played","right":"đã chơi"},{"left":"watched","right":"đã xem"},{"left":"studied","right":"đã học"},{"left":"visited","right":"đã thăm"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u03-l2-p5','a2-u03-l2','grammar_fill_blank',5,'practice','medium',false,'{"question":"Điền dạng phủ định: \"We ___ play football.\" (did not)","acceptedAnswers":["didn''t","did not"],"explanationVi":"did not = didn''t, sau đó dùng V nguyên thể."}'::jsonb),
 ('a2-u03-l2-p6','a2-u03-l2','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cô ấy đã xem TV tối qua.","acceptedAnswers":["She watched TV last night.","She watched TV last night"],"explanationVi":"She watched TV last night."}'::jsonb),
 ('a2-u03-l2-p7','a2-u03-l2','error_correction',7,'practice','hard',false,'{"question":"Sửa lỗi trong câu sau:","sourceText":"I didn''t played football.","acceptedAnswers":["I didn''t play football.","I didn''t play football"],"explanationVi":"Sau didn''t dùng V nguyên thể: play."}'::jsonb),
 ('a2-u03-l2-q1','a2-u03-l2','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Viết quá khứ của \"visit\": They ___ Hanoi.","acceptedAnswers":["visited"],"explanationVi":"visit → visited."}'::jsonb),
 ('a2-u03-l2-q2','a2-u03-l2','multiple_choice',9,'quiz','medium',true,'{"question":"Quá khứ của \"stop\" là gì?","options":[{"id":"a","text":"stoped"},{"id":"b","text":"stopped"},{"id":"c","text":"stopt"}],"correctOptionId":"b","explanationVi":"stop → stopped (gấp đôi phụ âm cuối)."}'::jsonb),
 ('a2-u03-l2-q3','a2-u03-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"She didn''t watch TV."},{"id":"b","text":"She didn''t watched TV."},{"id":"c","text":"She not watched TV."}],"correctOptionId":"a","explanationVi":"Sau didn''t dùng V nguyên thể: watch."}'::jsonb),
 ('a2-u03-l2-q4','a2-u03-l2','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền vào câu hỏi: \"___ you study English?\"","acceptedAnswers":["Did"],"explanationVi":"Did you study...? (câu hỏi quá khứ)."}'::jsonb),
 ('a2-u03-l2-q5','a2-u03-l2','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["watched","She","a","film"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: She watched a film."}'::jsonb),
 ('a2-u03-l2-q6','a2-u03-l2','vocabulary_match',13,'quiz','medium',true,'{"question":"Nối động từ quá khứ với nghĩa:","pairs":[{"left":"stopped","right":"đã dừng"},{"left":"visited","right":"đã thăm"},{"left":"played","right":"đã chơi"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u03-l2-q7','a2-u03-l2','multiple_choice',14,'quiz','hard',true,'{"question":"Câu nào dùng SAI quá khứ?","options":[{"id":"a","text":"We studied hard."},{"id":"b","text":"Did you played?"},{"id":"c","text":"They visited me."}],"correctOptionId":"b","explanationVi":"Sau Did dùng V nguyên thể → \"Did you play?\""}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u03-l3','A2','reading','a2-u03','normal',3,'Past simple irregular','Động từ bất quy tắc ở quá khứ',10,15,70,'{}'::jsonb,
  '{"warmup":"Một số động từ không thêm -ed mà đổi hẳn: go→went, eat→ate. Cùng học nhé!",
    "objectives":["Ghi nhớ các động từ bất quy tắc thường gặp","Dùng đúng dạng quá khứ trong câu kể","Phân biệt động từ bất quy tắc với có quy tắc"],
    "grammarHtml":"Động từ bất quy tắc KHÔNG thêm -ed mà đổi dạng riêng: <br>go→<b>went</b>, have→<b>had</b>, see→<b>saw</b>, eat→<b>ate</b>, come→<b>came</b>, take→<b>took</b>, get→<b>got</b>, make→<b>made</b>, do→<b>did</b>, say→<b>said</b>, write→<b>wrote</b>, drink→<b>drank</b>, buy→<b>bought</b>, give→<b>gave</b>. <br>Lưu ý: trong câu hỏi/phủ định với <i>did</i>, vẫn dùng động từ NGUYÊN THỂ (Did you go? – I didn''t go).",
    "vocabBlock":[
      {"word":"went","ipa":"/went/","meaningVi":"đã đi (go)","example":"I went to school."},
      {"word":"had","ipa":"/hæd/","meaningVi":"đã có/đã ăn (have)","example":"We had lunch."},
      {"word":"saw","ipa":"/sɔː/","meaningVi":"đã thấy (see)","example":"She saw a film."},
      {"word":"ate","ipa":"/eɪt/","meaningVi":"đã ăn (eat)","example":"They ate pizza."},
      {"word":"took","ipa":"/tʊk/","meaningVi":"đã lấy/đi (take)","example":"He took a bus."}],
    "examples":[
      {"en":"I went to the beach yesterday.","vi":"Hôm qua tôi đi biển."},
      {"en":"We had a big dinner.","vi":"Chúng tôi đã ăn một bữa tối lớn."},
      {"en":"She saw her friends.","vi":"Cô ấy đã gặp bạn bè."},
      {"en":"Did you eat breakfast?","vi":"Bạn đã ăn sáng chưa?"}],
    "commonMistakes":["❌ \"goed\" → ✅ \"went\" (go là bất quy tắc).","❌ \"Did you went?\" → ✅ \"Did you go?\" (sau did dùng nguyên thể)."],
    "tips":["Động từ bất quy tắc phải HỌC THUỘC theo cặp: go-went, see-saw, eat-ate..."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u03-l3-p1','a2-u03-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối động từ nguyên thể với dạng quá khứ:","pairs":[{"left":"go","right":"went"},{"left":"have","right":"had"},{"left":"see","right":"saw"},{"left":"eat","right":"ate"}],"explanationVi":"go-went, have-had, see-saw, eat-ate."}'::jsonb),
 ('a2-u03-l3-p2','a2-u03-l3','vocabulary_match',2,'practice','medium',false,'{"question":"Nối động từ với dạng quá khứ:","pairs":[{"left":"come","right":"came"},{"left":"take","right":"took"},{"left":"get","right":"got"},{"left":"make","right":"made"}],"explanationVi":"come-came, take-took, get-got, make-made."}'::jsonb),
 ('a2-u03-l3-p3','a2-u03-l3','grammar_fill_blank',3,'practice','easy',false,'{"question":"Viết quá khứ của \"go\": I ___ to school.","acceptedAnswers":["went"],"explanationVi":"go → went."}'::jsonb),
 ('a2-u03-l3-p4','a2-u03-l3','multiple_choice',4,'practice','medium',false,'{"question":"Quá khứ của \"eat\" là gì?","options":[{"id":"a","text":"eated"},{"id":"b","text":"ate"},{"id":"c","text":"eat"}],"correctOptionId":"b","explanationVi":"eat → ate."}'::jsonb),
 ('a2-u03-l3-p5','a2-u03-l3','grammar_fill_blank',5,'practice','medium',false,'{"question":"Viết quá khứ của \"have\": We ___ lunch.","acceptedAnswers":["had"],"explanationVi":"have → had."}'::jsonb),
 ('a2-u03-l3-p6','a2-u03-l3','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Hôm qua tôi đi biển.","acceptedAnswers":["I went to the beach yesterday.","Yesterday I went to the beach.","I went to the beach yesterday","Yesterday I went to the beach"],"explanationVi":"I went to the beach yesterday."}'::jsonb),
 ('a2-u03-l3-p7','a2-u03-l3','error_correction',7,'practice','hard',false,'{"question":"Sửa lỗi động từ bất quy tắc:","sourceText":"She goed to the park.","acceptedAnswers":["She went to the park.","She went to the park"],"explanationVi":"go là bất quy tắc → went, không phải goed."}'::jsonb),
 ('a2-u03-l3-q1','a2-u03-l3','vocabulary_match',8,'quiz','easy',true,'{"question":"Nối động từ với dạng quá khứ:","pairs":[{"left":"go","right":"went"},{"left":"see","right":"saw"},{"left":"eat","right":"ate"}],"explanationVi":"go-went, see-saw, eat-ate."}'::jsonb),
 ('a2-u03-l3-q2','a2-u03-l3','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Viết quá khứ của \"take\": He ___ a bus.","acceptedAnswers":["took"],"explanationVi":"take → took."}'::jsonb),
 ('a2-u03-l3-q3','a2-u03-l3','multiple_choice',10,'quiz','medium',true,'{"question":"Quá khứ của \"have\" là gì?","options":[{"id":"a","text":"haved"},{"id":"b","text":"had"},{"id":"c","text":"has"}],"correctOptionId":"b","explanationVi":"have → had."}'::jsonb),
 ('a2-u03-l3-q4','a2-u03-l3','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối động từ với dạng quá khứ:","pairs":[{"left":"make","right":"made"},{"left":"get","right":"got"},{"left":"come","right":"came"}],"explanationVi":"make-made, get-got, come-came."}'::jsonb),
 ('a2-u03-l3-q5','a2-u03-l3','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["went","I","to","school"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: I went to school."}'::jsonb),
 ('a2-u03-l3-q6','a2-u03-l3','grammar_fill_blank',13,'quiz','medium',true,'{"question":"Viết quá khứ của \"see\": They ___ a film.","acceptedAnswers":["saw"],"explanationVi":"see → saw."}'::jsonb),
 ('a2-u03-l3-q7','a2-u03-l3','multiple_choice',14,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"Did you went home?"},{"id":"b","text":"Did you go home?"},{"id":"c","text":"Did you goes home?"}],"correctOptionId":"b","explanationVi":"Sau Did dùng động từ nguyên thể: go."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u03-l4','A2','reading','a2-u03','normal',4,'My last holiday','Đọc hiểu: kỳ nghỉ vừa rồi',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn văn kể về kỳ nghỉ của Lan và chú ý các từ nối thứ tự: first, then, next, after that.",
    "objectives":["Đọc hiểu đoạn văn kể chuyện quá khứ","Nhận biết từ nối thứ tự: then, next, after that","Trả lời câu hỏi về thông tin trong bài"],
    "grammarHtml":"<b>Đoạn văn:</b> <i>Last summer I went to Da Nang with my family. <b>First</b>, we stayed at a small hotel near the beach. The weather was sunny and warm. <b>Then</b> we swam in the sea and played on the sand. <b>Next</b>, we visited the Marble Mountains and took many photos. <b>After that</b>, we ate fresh seafood at a local restaurant. The food was delicious. In the evening, we walked along the river and watched the Dragon Bridge. We were very happy. It was a wonderful holiday and I want to go back next year.</i>",
    "vocabBlock":[
      {"word":"holiday","ipa":"/ˈhɒlədeɪ/","meaningVi":"kỳ nghỉ","example":"My last holiday was great."},
      {"word":"beach","ipa":"/biːtʃ/","meaningVi":"bãi biển","example":"We stayed near the beach."},
      {"word":"seafood","ipa":"/ˈsiːfuːd/","meaningVi":"hải sản","example":"We ate fresh seafood."},
      {"word":"after that","ipa":"/ˈɑːftə ðæt/","meaningVi":"sau đó","example":"After that, we went home."},
      {"word":"wonderful","ipa":"/ˈwʌndəfʊl/","meaningVi":"tuyệt vời","example":"It was a wonderful trip."}],
    "examples":[
      {"en":"First we stayed at a hotel.","vi":"Đầu tiên chúng tôi ở khách sạn."},
      {"en":"Then we swam in the sea.","vi":"Sau đó chúng tôi bơi ở biển."},
      {"en":"After that, we ate seafood.","vi":"Sau đó nữa, chúng tôi ăn hải sản."}],
    "commonMistakes":["Đừng nhầm \"then\" (sau đó) với \"than\" (hơn — dùng khi so sánh)."],
    "tips":["Từ nối thứ tự first → then → next → after that giúp kể chuyện mạch lạc."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u03-l4-p1','a2-u03-l4','multiple_choice',1,'practice','easy',false,'{"question":"Lan đã đi đâu vào kỳ nghỉ?","options":[{"id":"a","text":"Hà Nội"},{"id":"b","text":"Đà Nẵng"},{"id":"c","text":"Huế"}],"correctOptionId":"b","explanationVi":"\"I went to Da Nang with my family.\""}'::jsonb),
 ('a2-u03-l4-p2','a2-u03-l4','multiple_choice',2,'practice','easy',false,'{"question":"Thời tiết trong bài thế nào?","options":[{"id":"a","text":"Nắng và ấm"},{"id":"b","text":"Mưa và lạnh"},{"id":"c","text":"Có tuyết"}],"correctOptionId":"a","explanationVi":"\"The weather was sunny and warm.\""}'::jsonb),
 ('a2-u03-l4-p3','a2-u03-l4','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"holiday","right":"kỳ nghỉ"},{"left":"beach","right":"bãi biển"},{"left":"seafood","right":"hải sản"},{"left":"wonderful","right":"tuyệt vời"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u03-l4-p4','a2-u03-l4','multiple_choice',4,'practice','medium',false,'{"question":"Họ đã ăn gì ở nhà hàng địa phương?","options":[{"id":"a","text":"Pizza"},{"id":"b","text":"Hải sản tươi"},{"id":"c","text":"Phở"}],"correctOptionId":"b","explanationVi":"\"we ate fresh seafood at a local restaurant.\""}'::jsonb),
 ('a2-u03-l4-p5','a2-u03-l4','grammar_fill_blank',5,'practice','medium',false,'{"question":"Điền từ nối thứ tự: \"___ that, we ate seafood.\" (sau đó nữa)","acceptedAnswers":["After","after"],"explanationVi":"After that = sau đó nữa."}'::jsonb),
 ('a2-u03-l4-p6','a2-u03-l4','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Đó là một kỳ nghỉ tuyệt vời.","acceptedAnswers":["It was a wonderful holiday.","It was a wonderful holiday"],"explanationVi":"It was a wonderful holiday."}'::jsonb),
 ('a2-u03-l4-q1','a2-u03-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Lan đi nghỉ với ai?","options":[{"id":"a","text":"Bạn bè"},{"id":"b","text":"Gia đình"},{"id":"c","text":"Một mình"}],"correctOptionId":"b","explanationVi":"\"I went to Da Nang with my family.\""}'::jsonb),
 ('a2-u03-l4-q2','a2-u03-l4','multiple_choice',8,'quiz','medium',true,'{"question":"Họ KHÔNG làm việc nào sau đây?","options":[{"id":"a","text":"Bơi ở biển"},{"id":"b","text":"Thăm Ngũ Hành Sơn"},{"id":"c","text":"Đi xem phim"}],"correctOptionId":"c","explanationVi":"Bài không nhắc tới việc xem phim."}'::jsonb),
 ('a2-u03-l4-q3','a2-u03-l4','multiple_choice',9,'quiz','medium',true,'{"question":"Buổi tối họ làm gì?","options":[{"id":"a","text":"Đi dạo bên sông và ngắm cầu Rồng"},{"id":"b","text":"Ngủ sớm"},{"id":"c","text":"Mua sắm"}],"correctOptionId":"a","explanationVi":"\"we walked along the river and watched the Dragon Bridge.\""}'::jsonb),
 ('a2-u03-l4-q4','a2-u03-l4','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền từ nối: \"___ we swam in the sea.\" (sau đó)","acceptedAnswers":["Then","then"],"explanationVi":"Then = sau đó."}'::jsonb),
 ('a2-u03-l4-q5','a2-u03-l4','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ nối thứ tự với nghĩa:","pairs":[{"left":"first","right":"đầu tiên"},{"left":"then","right":"sau đó"},{"left":"after that","right":"sau đó nữa"}],"explanationVi":"first → then → after that."}'::jsonb),
 ('a2-u03-l4-q6','a2-u03-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["ate","We","fresh","seafood"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: We ate fresh seafood."}'::jsonb),
 ('a2-u03-l4-q7','a2-u03-l4','multiple_choice',13,'quiz','hard',true,'{"question":"Lan cảm thấy thế nào về kỳ nghỉ?","options":[{"id":"a","text":"Rất vui, muốn quay lại"},{"id":"b","text":"Buồn chán"},{"id":"c","text":"Không thích"}],"correctOptionId":"a","explanationVi":"\"We were very happy... I want to go back next year.\""}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u03-l5','A2','reading','a2-u03','unit_review',5,'Unit 3 Review','Ôn tập Unit 3: was/were, V-ed, bất quy tắc, wh-questions',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại toàn bộ Unit 3: was/were, quá khứ có quy tắc -ed, bất quy tắc và câu hỏi quá khứ.",
    "objectives":["Tổng hợp can-do Unit 3","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u03-l5-q1','a2-u03-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"They ___ at home yesterday.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"is"}],"correctOptionId":"b","explanationVi":"They + were."}'::jsonb),
 ('a2-u03-l5-q2','a2-u03-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Viết quá khứ của \"watch\": She ___ TV.","acceptedAnswers":["watched"],"explanationVi":"watch → watched."}'::jsonb),
 ('a2-u03-l5-q3','a2-u03-l5','vocabulary_match',3,'quiz','easy',true,'{"question":"Nối động từ với dạng quá khứ:","pairs":[{"left":"go","right":"went"},{"left":"eat","right":"ate"},{"left":"have","right":"had"}],"explanationVi":"go-went, eat-ate, have-had."}'::jsonb),
 ('a2-u03-l5-q4','a2-u03-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Viết quá khứ của \"study\": We ___ English.","acceptedAnswers":["studied"],"explanationVi":"study → studied."}'::jsonb),
 ('a2-u03-l5-q5','a2-u03-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu phủ định ĐÚNG:","options":[{"id":"a","text":"I didn''t go."},{"id":"b","text":"I didn''t went."},{"id":"c","text":"I not went."}],"correctOptionId":"a","explanationVi":"Sau didn''t dùng V nguyên thể: go."}'::jsonb),
 ('a2-u03-l5-q6','a2-u03-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền was/were: \"He ___ tired last night.\"","acceptedAnswers":["was"],"explanationVi":"He + was."}'::jsonb),
 ('a2-u03-l5-q7','a2-u03-l5','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["did","Where","you","go","?"],"correctOrder":[1,0,2,3,4],"explanationVi":"Câu đúng: Where did you go?"}'::jsonb),
 ('a2-u03-l5-q8','a2-u03-l5','multiple_choice',8,'quiz','medium',true,'{"question":"\"___ did you do yesterday?\" (hỏi làm gì)","options":[{"id":"a","text":"What"},{"id":"b","text":"Where"},{"id":"c","text":"When"}],"correctOptionId":"a","explanationVi":"What did you do? = Bạn đã làm gì?"}'::jsonb),
 ('a2-u03-l5-q9','a2-u03-l5','vocabulary_match',9,'quiz','medium',true,'{"question":"Nối động từ với dạng quá khứ:","pairs":[{"left":"take","right":"took"},{"left":"see","right":"saw"},{"left":"make","right":"made"}],"explanationVi":"take-took, see-saw, make-made."}'::jsonb),
 ('a2-u03-l5-q10','a2-u03-l5','multiple_choice',10,'quiz','hard',true,'{"question":"Câu nào ĐÚNG hoàn toàn?","options":[{"id":"a","text":"She went to school and ate lunch."},{"id":"b","text":"She goed to school and eated lunch."},{"id":"c","text":"She did went and did ate."}],"correctOptionId":"a","explanationVi":"went, ate là dạng quá khứ bất quy tắc đúng."}'::jsonb);

-- ── UNIT 04 — Telling Stories / Kể chuyện ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u04-l1','A2','reading','a2-u04','normal',1,'Past continuous','was/were + V-ing — mô tả bối cảnh quá khứ',9,15,70,'{}'::jsonb,
  '{"warmup":"Tối qua lúc 8 giờ bạn đang làm gì?",
    "objectives":["Tạo câu với was/were + V-ing","Mô tả hành động đang diễn ra tại một thời điểm trong quá khứ","Đặt câu hỏi và phủ định ở thì quá khứ tiếp diễn"],
    "grammarHtml":"Quá khứ tiếp diễn = was/were + V-ing. Khẳng định: I/he/she/it <b>was</b> working; you/we/they <b>were</b> working. Phủ định: wasn''t / weren''t + V-ing. Nghi vấn: Was/Were + S + V-ing? Dùng để mô tả hành động đang diễn ra tại một thời điểm cụ thể trong quá khứ.",
    "vocabBlock":[
      {"word":"was","ipa":"/wɒz/","meaningVi":"đã (số ít)","example":"He was sleeping at 10 p.m."},
      {"word":"were","ipa":"/wɜː/","meaningVi":"đã (số nhiều/you)","example":"They were playing football."},
      {"word":"while","ipa":"/waɪl/","meaningVi":"trong khi","example":"She was reading while I cooked."},
      {"word":"at that time","ipa":"/æt ðæt taɪm/","meaningVi":"lúc đó","example":"At that time, we were studying."},
      {"word":"all day","ipa":"/ɔːl deɪ/","meaningVi":"cả ngày","example":"It was raining all day."}],
    "examples":[
      {"en":"I was watching TV at 8 o''clock.","vi":"Lúc 8 giờ tôi đang xem TV."},
      {"en":"They were not sleeping.","vi":"Họ đã không ngủ."},
      {"en":"What were you doing yesterday evening?","vi":"Tối qua bạn đang làm gì?"}],
    "commonMistakes":["❌ \"I was play\" → ✅ \"I was playing\" (phải có V-ing).","❌ \"They was working\" → ✅ \"They were working\" (số nhiều dùng were)."],
    "tips":["I/he/she/it → was; you/we/they → were.","Quá khứ tiếp diễn nhấn mạnh hành động ĐANG diễn ra, không phải đã hoàn thành."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u04-l1-p1','a2-u04-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn dạng đúng: \"I ___ watching TV.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"is"}],"correctOptionId":"a","explanationVi":"I đi với was."}'::jsonb),
 ('a2-u04-l1-p2','a2-u04-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền was/were: \"They ___ playing football.\"","acceptedAnswers":["were"],"explanationVi":"They (số nhiều) đi với were."}'::jsonb),
 ('a2-u04-l1-p3','a2-u04-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"was","right":"đã (số ít)"},{"left":"were","right":"đã (số nhiều)"},{"left":"while","right":"trong khi"},{"left":"all day","right":"cả ngày"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u04-l1-p4','a2-u04-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Chia động từ: \"She ___ (cook) at 7 p.m.\"","acceptedAnswers":["was cooking"],"explanationVi":"She + was + cooking."}'::jsonb),
 ('a2-u04-l1-p5','a2-u04-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Lúc 8 giờ tôi đang xem TV.","acceptedAnswers":["I was watching TV at 8 o''clock.","I was watching TV at eight o''clock.","At 8 o''clock I was watching TV."],"explanationVi":"I was watching TV at 8 o''clock."}'::jsonb),
 ('a2-u04-l1-p6','a2-u04-l1','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu:","sourceText":"They was working all day.","acceptedAnswers":["They were working all day.","They were working all day"],"explanationVi":"They (số nhiều) phải dùng were."}'::jsonb),
 ('a2-u04-l1-q1','a2-u04-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn dạng đúng: \"We ___ studying at that time.\"","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"are"}],"correctOptionId":"b","explanationVi":"We đi với were."}'::jsonb),
 ('a2-u04-l1-q2','a2-u04-l1','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Chia động từ: \"He ___ (sleep) at 10 p.m.\"","acceptedAnswers":["was sleeping"],"explanationVi":"He + was + sleeping."}'::jsonb),
 ('a2-u04-l1-q3','a2-u04-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Câu phủ định nào đúng?","options":[{"id":"a","text":"They weren''t sleeping."},{"id":"b","text":"They wasn''t sleeping."},{"id":"c","text":"They not were sleeping."}],"correctOptionId":"a","explanationVi":"They + weren''t + V-ing."}'::jsonb),
 ('a2-u04-l1-q4','a2-u04-l1','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["you","were","doing","What"],"correctOrder":[3,1,0,2],"explanationVi":"Câu đúng: What were you doing?"}'::jsonb),
 ('a2-u04-l1-q5','a2-u04-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền was/were: \"It ___ raining all day.\"","acceptedAnswers":["was"],"explanationVi":"It đi với was."}'::jsonb),
 ('a2-u04-l1-q6','a2-u04-l1','vocabulary_match',12,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"at that time","right":"lúc đó"},{"left":"while","right":"trong khi"},{"left":"was","right":"đã (số ít)"},{"left":"were","right":"đã (số nhiều)"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u04-l2','A2','reading','a2-u04','normal',2,'When & while','Past simple ngắt past continuous',9,15,70,'{}'::jsonb,
  '{"warmup":"Trong khi bạn đang ngủ, điều gì đã xảy ra?",
    "objectives":["Dùng when + quá khứ đơn cho hành động ngắt","Dùng while + quá khứ tiếp diễn cho hành động nền","Nối hai hành động quá khứ đúng cách"],
    "grammarHtml":"Hành động nền (đang diễn ra) = <b>past continuous</b>; hành động ngắt (xảy ra một lần) = <b>past simple</b>. <b>While</b> + past continuous (nền): While I <u>was cooking</u>, the phone rang. <b>When</b> + past simple (ngắt): When the phone rang, I <u>was cooking</u>.",
    "vocabBlock":[
      {"word":"when","ipa":"/wen/","meaningVi":"khi (hành động ngắt)","example":"When he arrived, I was eating."},
      {"word":"while","ipa":"/waɪl/","meaningVi":"trong khi (hành động nền)","example":"While I was eating, he arrived."},
      {"word":"suddenly","ipa":"/ˈsʌdənli/","meaningVi":"đột nhiên","example":"Suddenly, the lights went out."},
      {"word":"ring","ipa":"/rɪŋ/","meaningVi":"reo (chuông)","example":"The phone rang loudly."},
      {"word":"happen","ipa":"/ˈhæpən/","meaningVi":"xảy ra","example":"What happened next?"}],
    "examples":[
      {"en":"While I was cooking, the phone rang.","vi":"Trong khi tôi đang nấu ăn, điện thoại reo."},
      {"en":"When the rain started, we were walking.","vi":"Khi trời bắt đầu mưa, chúng tôi đang đi bộ."},
      {"en":"I was sleeping when he called.","vi":"Tôi đang ngủ khi anh ấy gọi."}],
    "commonMistakes":["❌ \"While the phone rang...\" → ✅ \"When the phone rang...\" (hành động ngắt dùng when + quá khứ đơn).","❌ \"When I was cooking, the phone was ringing\" cho hành động ngắt → dùng quá khứ đơn: rang."],
    "tips":["While → hành động dài/nền (V-ing). When → hành động ngắn/ngắt (V quá khứ đơn).","Có thể đảo vế: đặt mệnh đề when/while ở đầu thì thêm dấu phẩy."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u04-l2-p1','a2-u04-l2','multiple_choice',1,'practice','easy',false,'{"question":"Chọn từ đúng: \"___ I was cooking, the phone rang.\"","options":[{"id":"a","text":"While"},{"id":"b","text":"When"},{"id":"c","text":"And"}],"correctOptionId":"a","explanationVi":"While + hành động nền (đang diễn ra)."}'::jsonb),
 ('a2-u04-l2-p2','a2-u04-l2','multiple_choice',2,'practice','easy',false,'{"question":"Chọn từ đúng: \"___ the phone rang, I was cooking.\"","options":[{"id":"a","text":"While"},{"id":"b","text":"When"},{"id":"c","text":"But"}],"correctOptionId":"b","explanationVi":"When + hành động ngắt (quá khứ đơn)."}'::jsonb),
 ('a2-u04-l2-p3','a2-u04-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"Chia động từ: \"While she ___ (read), the baby cried.\"","acceptedAnswers":["was reading"],"explanationVi":"While + was reading (hành động nền)."}'::jsonb),
 ('a2-u04-l2-p4','a2-u04-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Chia động từ: \"When the rain ___ (start), we were walking.\"","acceptedAnswers":["started"],"explanationVi":"When + quá khứ đơn (hành động ngắt)."}'::jsonb),
 ('a2-u04-l2-p5','a2-u04-l2','vocabulary_match',5,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"when","right":"khi (ngắt)"},{"left":"while","right":"trong khi (nền)"},{"left":"suddenly","right":"đột nhiên"},{"left":"happen","right":"xảy ra"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u04-l2-p6','a2-u04-l2','translation',6,'practice','hard',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi đang ngủ khi anh ấy gọi.","acceptedAnswers":["I was sleeping when he called.","I was sleeping when he called"],"explanationVi":"I was sleeping when he called."}'::jsonb),
 ('a2-u04-l2-q1','a2-u04-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn từ đúng: \"I was reading ___ she came in.\"","options":[{"id":"a","text":"when"},{"id":"b","text":"while"},{"id":"c","text":"so"}],"correctOptionId":"a","explanationVi":"Hành động ngắt (came) dùng when."}'::jsonb),
 ('a2-u04-l2-q2','a2-u04-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Chia động từ: \"While they ___ (play), it started to rain.\"","acceptedAnswers":["were playing"],"explanationVi":"While + were playing (hành động nền)."}'::jsonb),
 ('a2-u04-l2-q3','a2-u04-l2','grammar_fill_blank',9,'quiz','medium',true,'{"question":"Chia động từ: \"When she ___ (call), I was eating.\"","acceptedAnswers":["called"],"explanationVi":"When + quá khứ đơn cho hành động ngắt."}'::jsonb),
 ('a2-u04-l2-q4','a2-u04-l2','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["was","I","cooking","While"],"correctOrder":[3,1,0,2],"explanationVi":"Câu đúng: While I was cooking."}'::jsonb),
 ('a2-u04-l2-q5','a2-u04-l2','multiple_choice',11,'quiz','hard',true,'{"question":"Câu nào đúng?","options":[{"id":"a","text":"When the phone rang, I was sleeping."},{"id":"b","text":"When the phone was ringing, I slept."},{"id":"c","text":"While the phone rang, I sleeping."}],"correctOptionId":"a","explanationVi":"when + quá khứ đơn (rang) + nền was sleeping."}'::jsonb),
 ('a2-u04-l2-q6','a2-u04-l2','vocabulary_match',12,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"ring","right":"reo (chuông)"},{"left":"suddenly","right":"đột nhiên"},{"left":"happen","right":"xảy ra"},{"left":"when","right":"khi (ngắt)"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u04-l3','A2','reading','a2-u04','normal',3,'used to','Thói quen trong quá khứ',9,15,70,'{}'::jsonb,
  '{"warmup":"Hồi nhỏ bạn từng làm gì mà bây giờ không còn làm nữa?",
    "objectives":["Dùng used to + V để nói thói quen/trạng thái trong quá khứ","Tạo phủ định didn''t use to","Phân biệt used to với hiện tại"],
    "grammarHtml":"<b>used to</b> + V nguyên thể: diễn tả thói quen/trạng thái trong quá khứ nay không còn. Khẳng định: I <b>used to</b> play. Phủ định: I <b>didn''t use to</b> play (bỏ -d). Nghi vấn: Did you <b>use to</b> play?",
    "vocabBlock":[
      {"word":"used to","ipa":"/ˈjuːst tə/","meaningVi":"đã từng (thói quen cũ)","example":"I used to live in Hue."},
      {"word":"didn''t use to","ipa":"/ˈdɪdnt juːs tə/","meaningVi":"đã từng không","example":"She didn''t use to like coffee."},
      {"word":"anymore","ipa":"/ˌeniˈmɔː/","meaningVi":"nữa (không còn)","example":"He doesn''t smoke anymore."},
      {"word":"childhood","ipa":"/ˈtʃaɪldhʊd/","meaningVi":"tuổi thơ","example":"In my childhood, I used to swim."},
      {"word":"these days","ipa":"/ðiːz deɪz/","meaningVi":"dạo này","example":"These days I read more."}],
    "examples":[
      {"en":"I used to play football every day.","vi":"Tôi đã từng chơi bóng đá mỗi ngày."},
      {"en":"She didn''t use to like coffee.","vi":"Cô ấy đã từng không thích cà phê."},
      {"en":"Did you use to live here?","vi":"Bạn đã từng sống ở đây phải không?"}],
    "commonMistakes":["❌ \"I used to played\" → ✅ \"I used to play\" (sau used to là V nguyên thể).","❌ \"didn''t used to\" → ✅ \"didn''t use to\" (bỏ -d sau did)."],
    "tips":["used to chỉ dùng cho QUÁ KHỨ; hiện tại dùng usually + hiện tại đơn.","Sau used to / use to luôn là động từ nguyên thể."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u04-l3-p1','a2-u04-l3','multiple_choice',1,'practice','easy',false,'{"question":"Chọn dạng đúng: \"I used to ___ football.\"","options":[{"id":"a","text":"play"},{"id":"b","text":"played"},{"id":"c","text":"playing"}],"correctOptionId":"a","explanationVi":"Sau used to là V nguyên thể."}'::jsonb),
 ('a2-u04-l3-p2','a2-u04-l3','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền: \"She ___ to live in Hue.\" (đã từng)","acceptedAnswers":["used"],"explanationVi":"used to + V = đã từng."}'::jsonb),
 ('a2-u04-l3-p3','a2-u04-l3','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"used to","right":"đã từng"},{"left":"anymore","right":"nữa (không còn)"},{"left":"childhood","right":"tuổi thơ"},{"left":"these days","right":"dạo này"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u04-l3-p4','a2-u04-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Hoàn thành phủ định: \"He didn''t ___ to smoke.\"","acceptedAnswers":["use"],"explanationVi":"didn''t use to (bỏ -d)."}'::jsonb),
 ('a2-u04-l3-p5','a2-u04-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi đã từng sống ở Huế.","acceptedAnswers":["I used to live in Hue.","I used to live in Hue"],"explanationVi":"I used to live in Hue."}'::jsonb),
 ('a2-u04-l3-p6','a2-u04-l3','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu:","sourceText":"I used to played tennis.","acceptedAnswers":["I used to play tennis.","I used to play tennis"],"explanationVi":"Sau used to là V nguyên thể: play."}'::jsonb),
 ('a2-u04-l3-q1','a2-u04-l3','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn dạng đúng: \"They used to ___ in the countryside.\"","options":[{"id":"a","text":"live"},{"id":"b","text":"lived"},{"id":"c","text":"living"}],"correctOptionId":"a","explanationVi":"used to + V nguyên thể."}'::jsonb),
 ('a2-u04-l3-q2','a2-u04-l3','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Hoàn thành: \"She didn''t ___ to like coffee.\"","acceptedAnswers":["use"],"explanationVi":"didn''t use to (bỏ -d)."}'::jsonb),
 ('a2-u04-l3-q3','a2-u04-l3','multiple_choice',9,'quiz','medium',true,'{"question":"Câu hỏi nào đúng?","options":[{"id":"a","text":"Did you use to live here?"},{"id":"b","text":"Did you used to live here?"},{"id":"c","text":"Do you used to live here?"}],"correctOptionId":"a","explanationVi":"Did + S + use to + V (bỏ -d)."}'::jsonb),
 ('a2-u04-l3-q4','a2-u04-l3','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["used","I","swim","to"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: I used to swim."}'::jsonb),
 ('a2-u04-l3-q5','a2-u04-l3','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền: \"In my childhood, I ___ to play outside.\" (đã từng)","acceptedAnswers":["used"],"explanationVi":"used to + V = đã từng."}'::jsonb),
 ('a2-u04-l3-q6','a2-u04-l3','vocabulary_match',12,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"didn''t use to","right":"đã từng không"},{"left":"anymore","right":"nữa (không còn)"},{"left":"these days","right":"dạo này"},{"left":"childhood","right":"tuổi thơ"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u04-l4','A2','listening','a2-u04','normal',4,'A short story','Nghe & nắm cốt truyện',10,15,70,'{}'::jsonb,
  '{"warmup":"Nghe một câu chuyện ngắn và đoán điều gì xảy ra tiếp theo.",
    "objectives":["Nghe và nắm cốt truyện một câu chuyện ngắn","Nghe chi tiết về thời gian, nhân vật, hành động","Nhận biết động từ quá khứ khi nghe"],
    "vocabBlock":[
      {"word":"forest","ipa":"/ˈfɒrɪst/","meaningVi":"khu rừng","example":"They walked into the forest."},
      {"word":"lost","ipa":"/lɒst/","meaningVi":"bị lạc","example":"The boy got lost."},
      {"word":"afraid","ipa":"/əˈfreɪd/","meaningVi":"sợ hãi","example":"She was afraid of the dark."},
      {"word":"found","ipa":"/faʊnd/","meaningVi":"tìm thấy (quá khứ)","example":"He found the way home."},
      {"word":"finally","ipa":"/ˈfaɪnəli/","meaningVi":"cuối cùng","example":"Finally, they were safe."}],
    "examples":[
      {"en":"Last summer, Tom and Mai went camping in the forest.","vi":"Mùa hè trước, Tom và Mai đi cắm trại trong rừng."},
      {"en":"While they were walking, it started to rain.","vi":"Trong khi họ đang đi, trời bắt đầu mưa."},
      {"en":"Finally, they found a small house and were safe.","vi":"Cuối cùng họ tìm thấy một ngôi nhà nhỏ và an toàn."}],
    "commonMistakes":["Nghe nhầm thì: chú ý đuôi -ed và was/were + V-ing để xác định hành động nền hay ngắt."],
    "tips":["Nghe lần đầu để nắm ý chính, lần hai để bắt chi tiết.","Chú ý từ chỉ thời gian: last summer, then, finally."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u04-l4-p1','a2-u04-l4','listening_choice',1,'practice','easy',false,'{"question":"Nghe và chọn nơi câu chuyện diễn ra:","audioText":"Last summer, Tom and Mai went camping in the forest.","options":[{"id":"a","text":"trong rừng"},{"id":"b","text":"ở biển"},{"id":"c","text":"trong thành phố"}],"correctOptionId":"a","explanationVi":"They went camping in the forest = trong rừng."}'::jsonb),
 ('a2-u04-l4-p2','a2-u04-l4','listening_choice',2,'practice','easy',false,'{"question":"Nghe và chọn điều đã xảy ra:","audioText":"While they were walking, it started to rain.","options":[{"id":"a","text":"Trời bắt đầu mưa"},{"id":"b","text":"Trời nắng to"},{"id":"c","text":"Có tuyết rơi"}],"correctOptionId":"a","explanationVi":"It started to rain = trời bắt đầu mưa."}'::jsonb),
 ('a2-u04-l4-p3','a2-u04-l4','listening_choice',3,'practice','medium',false,'{"question":"Nghe và chọn cảm xúc của nhân vật:","audioText":"Mai was afraid because she could not see the path.","options":[{"id":"a","text":"sợ hãi"},{"id":"b","text":"vui vẻ"},{"id":"c","text":"buồn ngủ"}],"correctOptionId":"a","explanationVi":"Mai was afraid = Mai sợ hãi."}'::jsonb),
 ('a2-u04-l4-p4','a2-u04-l4','listening_choice',4,'practice','medium',false,'{"question":"Nghe và chọn hành động của Tom:","audioText":"Tom was looking for the way while Mai was waiting.","options":[{"id":"a","text":"đang tìm đường"},{"id":"b","text":"đang ngủ"},{"id":"c","text":"đang nấu ăn"}],"correctOptionId":"a","explanationVi":"Tom was looking for the way = đang tìm đường."}'::jsonb),
 ('a2-u04-l4-p5','a2-u04-l4','listening_choice',5,'practice','medium',false,'{"question":"Nghe và chọn kết thúc câu chuyện:","audioText":"Finally, they found a small house and were safe.","options":[{"id":"a","text":"Họ tìm thấy ngôi nhà và an toàn"},{"id":"b","text":"Họ vẫn bị lạc"},{"id":"c","text":"Họ về thành phố"}],"correctOptionId":"a","explanationVi":"They found a small house and were safe."}'::jsonb),
 ('a2-u04-l4-p6','a2-u04-l4','vocabulary_match',6,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"forest","right":"khu rừng"},{"left":"lost","right":"bị lạc"},{"left":"afraid","right":"sợ hãi"},{"left":"finally","right":"cuối cùng"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u04-l4-q1','a2-u04-l4','listening_choice',7,'quiz','easy',true,'{"question":"Nghe và chọn thời điểm câu chuyện xảy ra:","audioText":"Last summer, Tom and Mai went camping in the forest.","options":[{"id":"a","text":"Mùa hè năm ngoái"},{"id":"b","text":"Tuần trước"},{"id":"c","text":"Sáng nay"}],"correctOptionId":"a","explanationVi":"Last summer = mùa hè năm ngoái."}'::jsonb),
 ('a2-u04-l4-q2','a2-u04-l4','listening_choice',8,'quiz','medium',true,'{"question":"Nghe và chọn điều đang diễn ra khi trời mưa:","audioText":"While they were walking, it started to rain.","options":[{"id":"a","text":"Họ đang đi bộ"},{"id":"b","text":"Họ đang ngủ"},{"id":"c","text":"Họ đang ăn"}],"correctOptionId":"a","explanationVi":"They were walking = họ đang đi bộ (hành động nền)."}'::jsonb),
 ('a2-u04-l4-q3','a2-u04-l4','listening_choice',9,'quiz','medium',true,'{"question":"Nghe và chọn câu đúng về kết thúc:","audioText":"Finally, they found a small house and were safe.","options":[{"id":"a","text":"Họ tìm thấy ngôi nhà và an toàn"},{"id":"b","text":"Họ không tìm được gì"},{"id":"c","text":"Họ bị thương"}],"correctOptionId":"a","explanationVi":"They found a small house and were safe."}'::jsonb),
 ('a2-u04-l4-q4','a2-u04-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Trong câu \"While they were walking, it started to rain\", hành động nào là hành động nền?","options":[{"id":"a","text":"they were walking"},{"id":"b","text":"it started to rain"},{"id":"c","text":"cả hai"}],"correctOptionId":"a","explanationVi":"were walking (past continuous) là hành động nền."}'::jsonb),
 ('a2-u04-l4-q5','a2-u04-l4','listening_choice',11,'quiz','hard',true,'{"question":"Nghe và chọn nhân vật cảm thấy sợ:","audioText":"Mai was afraid but Tom stayed calm.","options":[{"id":"a","text":"Mai"},{"id":"b","text":"Tom"},{"id":"c","text":"Cả hai"}],"correctOptionId":"a","explanationVi":"Mai was afraid; Tom stayed calm."}'::jsonb),
 ('a2-u04-l4-q6','a2-u04-l4','vocabulary_match',12,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"found","right":"tìm thấy"},{"left":"lost","right":"bị lạc"},{"left":"forest","right":"khu rừng"},{"left":"finally","right":"cuối cùng"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u04-l5','A2','reading','a2-u04','unit_review',5,'Unit 4 Review','Past continuous · when/while · used to',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 4: kể chuyện quá khứ.","objectives":["Tổng hợp can-do Unit 4","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u04-l5-q1','a2-u04-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn dạng đúng: \"They ___ playing at 5 p.m.\"","options":[{"id":"a","text":"were"},{"id":"b","text":"was"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"They đi với were."}'::jsonb),
 ('a2-u04-l5-q2','a2-u04-l5','grammar_fill_blank',2,'quiz','medium',true,'{"question":"Chia động từ: \"While I ___ (cook), the phone rang.\"","acceptedAnswers":["was cooking"],"explanationVi":"While + was cooking (hành động nền)."}'::jsonb),
 ('a2-u04-l5-q3','a2-u04-l5','multiple_choice',3,'quiz','medium',true,'{"question":"Chọn từ đúng: \"___ the rain started, we were walking.\"","options":[{"id":"a","text":"When"},{"id":"b","text":"While"},{"id":"c","text":"And"}],"correctOptionId":"a","explanationVi":"When + quá khứ đơn (hành động ngắt)."}'::jsonb),
 ('a2-u04-l5-q4','a2-u04-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Hoàn thành: \"He didn''t ___ to like tea.\" (used to phủ định)","acceptedAnswers":["use"],"explanationVi":"didn''t use to (bỏ -d)."}'::jsonb),
 ('a2-u04-l5-q5','a2-u04-l5','multiple_choice',5,'quiz','easy',true,'{"question":"Chọn dạng đúng: \"I used to ___ in Hanoi.\"","options":[{"id":"a","text":"live"},{"id":"b","text":"lived"},{"id":"c","text":"living"}],"correctOptionId":"a","explanationVi":"Sau used to là V nguyên thể."}'::jsonb),
 ('a2-u04-l5-q6','a2-u04-l5','vocabulary_match',6,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"while","right":"trong khi"},{"left":"used to","right":"đã từng"},{"left":"suddenly","right":"đột nhiên"},{"left":"finally","right":"cuối cùng"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u04-l5-q7','a2-u04-l5','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["you","were","doing","What"],"correctOrder":[3,1,0,2],"explanationVi":"Câu đúng: What were you doing?"}'::jsonb),
 ('a2-u04-l5-q8','a2-u04-l5','listening_choice',8,'quiz','medium',true,'{"question":"Nghe và chọn điều đang diễn ra:","audioText":"While they were walking, it started to rain.","options":[{"id":"a","text":"Họ đang đi bộ"},{"id":"b","text":"Họ đang ngủ"},{"id":"c","text":"Họ đang chạy"}],"correctOptionId":"a","explanationVi":"They were walking = họ đang đi bộ."}'::jsonb),
 ('a2-u04-l5-q9','a2-u04-l5','listening_choice',9,'quiz','medium',true,'{"question":"Nghe và chọn thời điểm:","audioText":"Last summer, we went camping in the forest.","options":[{"id":"a","text":"Mùa hè năm ngoái"},{"id":"b","text":"Tối nay"},{"id":"c","text":"Mùa đông"}],"correctOptionId":"a","explanationVi":"Last summer = mùa hè năm ngoái."}'::jsonb),
 ('a2-u04-l5-q10','a2-u04-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["used","I","play","to"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: I used to play."}'::jsonb);

-- ── UNIT 05 — Plans & Predictions / Kế hoạch & Dự đoán ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u05-l1','A2','reading','a2-u05','normal',1,'Be going to','Kế hoạch tương lai gần',9,15,70,'{}'::jsonb,
  '{"warmup":"Cuối tuần này bạn định làm gì? Hãy nói bằng tiếng Anh!",
    "objectives":["Dùng be going to để nói kế hoạch đã định","Chia am/is/are đúng theo chủ ngữ","Dùng trạng từ tương lai: tomorrow, next week"],
    "grammarHtml":"Cấu trúc: S + am/is/are + going to + V(nguyên thể). I am going to / He is going to / They are going to. Phủ định: am/is/are + not going to. Trạng từ: tomorrow, tonight, next week, this weekend.",
    "vocabBlock":[
      {"word":"going to","ipa":"/ˈɡəʊɪŋ tuː/","meaningVi":"sẽ (kế hoạch đã định)","example":"I am going to study tonight."},
      {"word":"tomorrow","ipa":"/təˈmɒrəʊ/","meaningVi":"ngày mai","example":"We are going to travel tomorrow."},
      {"word":"next week","ipa":"/nekst wiːk/","meaningVi":"tuần sau","example":"She is going to start a new job next week."},
      {"word":"plan","ipa":"/plæn/","meaningVi":"kế hoạch","example":"What is your plan for the weekend?"},
      {"word":"visit","ipa":"/ˈvɪzɪt/","meaningVi":"thăm","example":"They are going to visit their grandparents."}],
    "examples":[
      {"en":"I am going to watch a film tonight.","vi":"Tối nay tôi sẽ xem một bộ phim."},
      {"en":"She is going to buy a new phone next week.","vi":"Tuần sau cô ấy sẽ mua điện thoại mới."},
      {"en":"They are not going to come to the party.","vi":"Họ sẽ không đến bữa tiệc."}],
    "commonMistakes":["❌ \"I going to study.\" → ✅ \"I am going to study.\" (thiếu am)","❌ \"He is going to studies.\" → ✅ \"He is going to study.\" (sau going to dùng V nguyên thể)"],
    "tips":["be going to dùng cho kế hoạch đã quyết định trước.","Nhớ chia be: I am, he/she/it is, you/we/they are."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u05-l1-p1','a2-u05-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn dạng be đúng: \"I ___ going to travel.\"","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"Với I dùng am."}'::jsonb),
 ('a2-u05-l1-p2','a2-u05-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền be đúng: \"She ___ going to cook dinner.\"","acceptedAnswers":["is"],"explanationVi":"She → is going to."}'::jsonb),
 ('a2-u05-l1-p3','a2-u05-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"tomorrow","right":"ngày mai"},{"left":"next week","right":"tuần sau"},{"left":"plan","right":"kế hoạch"},{"left":"visit","right":"thăm"}],"explanationVi":"Ghép đúng từng cặp từ vựng."}'::jsonb),
 ('a2-u05-l1-p4','a2-u05-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền be đúng: \"They ___ going to play football.\"","acceptedAnswers":["are"],"explanationVi":"They → are going to."}'::jsonb),
 ('a2-u05-l1-p5','a2-u05-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tối nay tôi sẽ học bài.","acceptedAnswers":["I am going to study tonight.","I''m going to study tonight.","I am going to study tonight","I''m going to study tonight"],"explanationVi":"I am going to study tonight."}'::jsonb),
 ('a2-u05-l1-p6','a2-u05-l1','error_correction',6,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"He is going to studies English.","acceptedAnswers":["He is going to study English.","He is going to study English","He''s going to study English.","He''s going to study English"],"explanationVi":"Sau going to dùng V nguyên thể: study."}'::jsonb),
 ('a2-u05-l1-q1','a2-u05-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"She is going to visit her aunt."},{"id":"b","text":"She going to visit her aunt."},{"id":"c","text":"She is going to visits her aunt."}],"correctOptionId":"a","explanationVi":"is going to + V nguyên thể."}'::jsonb),
 ('a2-u05-l1-q2','a2-u05-l1','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền be đúng: \"We ___ going to have a party.\"","acceptedAnswers":["are"],"explanationVi":"We → are going to."}'::jsonb),
 ('a2-u05-l1-q3','a2-u05-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn dạng phủ định đúng: \"I ___ going to come.\"","options":[{"id":"a","text":"am not"},{"id":"b","text":"not"},{"id":"c","text":"do not"}],"correctOptionId":"a","explanationVi":"Phủ định: am not going to."}'::jsonb),
 ('a2-u05-l1-q4','a2-u05-l1','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền: \"He is going to ___ a new car next month.\" (mua)","acceptedAnswers":["buy"],"explanationVi":"Sau going to dùng V nguyên thể: buy."}'::jsonb),
 ('a2-u05-l1-q5','a2-u05-l1','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["going","I","to","am","travel","tomorrow"],"correctOrder":[1,3,0,2,4,5],"explanationVi":"Câu đúng: I am going to travel tomorrow."}'::jsonb),
 ('a2-u05-l1-q6','a2-u05-l1','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"tonight","right":"tối nay"},{"left":"this weekend","right":"cuối tuần này"},{"left":"visit","right":"thăm"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u05-l2','A2','reading','a2-u05','normal',2,'Will for predictions','Dự đoán với will/won''t',9,15,70,'{}'::jsonb,
  '{"warmup":"Bạn nghĩ ngày mai trời sẽ nắng hay mưa? Dự đoán bằng tiếng Anh!",
    "objectives":["Dùng will/won''t + V để dự đoán tương lai","Dùng I think... will để nêu ý kiến","Dùng will cho quyết định tức thì"],
    "grammarHtml":"Cấu trúc: S + will + V(nguyên thể) cho mọi chủ ngữ. Viết tắt: I''ll, he''ll... Phủ định: will not = won''t. Dự đoán: I think it will rain. Quyết định tức thì: \"The phone is ringing.\" — \"I''ll answer it.\"",
    "vocabBlock":[
      {"word":"will","ipa":"/wɪl/","meaningVi":"sẽ (dự đoán)","example":"It will rain tomorrow."},
      {"word":"won''t","ipa":"/wəʊnt/","meaningVi":"sẽ không","example":"She won''t be late."},
      {"word":"think","ipa":"/θɪŋk/","meaningVi":"nghĩ","example":"I think they will win."},
      {"word":"maybe","ipa":"/ˈmeɪbi/","meaningVi":"có lẽ","example":"Maybe it will be sunny."},
      {"word":"future","ipa":"/ˈfjuːtʃə/","meaningVi":"tương lai","example":"In the future, cars will fly."}],
    "examples":[
      {"en":"I think it will rain tomorrow.","vi":"Tôi nghĩ ngày mai trời sẽ mưa."},
      {"en":"They won''t come to the meeting.","vi":"Họ sẽ không đến cuộc họp."},
      {"en":"The phone is ringing. I''ll answer it.","vi":"Điện thoại đang reo. Tôi sẽ nghe máy."}],
    "commonMistakes":["❌ \"She will to go.\" → ✅ \"She will go.\" (không có to sau will)","❌ \"He wills come.\" → ✅ \"He will come.\" (will không chia theo chủ ngữ)"],
    "tips":["will + V nguyên thể cho mọi chủ ngữ.","won''t = will not.","Dùng will cho quyết định ngay lúc nói; be going to cho kế hoạch đã định."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u05-l2-p1','a2-u05-l2','multiple_choice',1,'practice','easy',false,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"It will rain tomorrow."},{"id":"b","text":"It will rains tomorrow."},{"id":"c","text":"It will to rain tomorrow."}],"correctOptionId":"a","explanationVi":"will + V nguyên thể."}'::jsonb),
 ('a2-u05-l2-p2','a2-u05-l2','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền dạng phủ định của will: \"She ___ be late.\"","acceptedAnswers":["won''t","will not"],"explanationVi":"won''t = will not."}'::jsonb),
 ('a2-u05-l2-p3','a2-u05-l2','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"will","right":"sẽ"},{"left":"won''t","right":"sẽ không"},{"left":"maybe","right":"có lẽ"},{"left":"future","right":"tương lai"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u05-l2-p4','a2-u05-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền will + V: \"I think they ___ (win) the match.\"","acceptedAnswers":["will win"],"explanationVi":"will + win (nguyên thể)."}'::jsonb),
 ('a2-u05-l2-p5','a2-u05-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi nghĩ ngày mai trời sẽ nắng.","acceptedAnswers":["I think it will be sunny tomorrow.","I think it will be sunny tomorrow","I think tomorrow will be sunny.","I think tomorrow will be sunny"],"explanationVi":"I think it will be sunny tomorrow."}'::jsonb),
 ('a2-u05-l2-p6','a2-u05-l2','error_correction',6,'practice','hard',false,'{"question":"Sửa câu sai:","sourceText":"She will to go home early.","acceptedAnswers":["She will go home early.","She will go home early","She''ll go home early.","She''ll go home early"],"explanationVi":"Không có to sau will."}'::jsonb),
 ('a2-u05-l2-q1','a2-u05-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Điền từ đúng: \"I think it ___ rain.\"","options":[{"id":"a","text":"will"},{"id":"b","text":"wills"},{"id":"c","text":"will to"}],"correctOptionId":"a","explanationVi":"will + V nguyên thể."}'::jsonb),
 ('a2-u05-l2-q2','a2-u05-l2','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền dạng viết tắt của will not: \"They ___ come.\"","acceptedAnswers":["won''t","will not"],"explanationVi":"won''t = will not."}'::jsonb),
 ('a2-u05-l2-q3','a2-u05-l2','multiple_choice',9,'quiz','medium',true,'{"question":"Tình huống nào dùng will (quyết định tức thì)?","options":[{"id":"a","text":"The phone is ringing. I''ll answer it."},{"id":"b","text":"I am going to study tonight (đã lên kế hoạch)."},{"id":"c","text":"We are going to travel next week (đã định)."}],"correctOptionId":"a","explanationVi":"Quyết định ngay lúc nói dùng will."}'::jsonb),
 ('a2-u05-l2-q4','a2-u05-l2','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền will + V: \"He ___ (be) a doctor.\"","acceptedAnswers":["will be"],"explanationVi":"will + be (nguyên thể)."}'::jsonb),
 ('a2-u05-l2-q5','a2-u05-l2','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["will","I","help","you"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: I will help you."}'::jsonb),
 ('a2-u05-l2-q6','a2-u05-l2','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["won''t","She","be","late"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: She won''t be late."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u05-l3','A2','reading','a2-u05','normal',3,'Will vs going to vs present continuous','Phân biệt các thì tương lai',10,15,70,'{}'::jsonb,
  '{"warmup":"\"Tôi sẽ đi xem phim\" — đó là dự định, dự đoán hay hẹn cố định?",
    "objectives":["Phân biệt will (dự đoán/quyết định tức thì)","Phân biệt be going to (dự định đã định)","Dùng hiện tại tiếp diễn cho hẹn cố định trong tương lai"],
    "grammarHtml":"will: dự đoán hoặc quyết định tức thì — \"I think it will rain.\" / \"I''ll get it.\" be going to: dự định đã quyết định trước — \"I am going to visit Hue.\" Hiện tại tiếp diễn (am/is/are + V-ing): hẹn cố định, đã sắp xếp — \"I am meeting John at 6 tomorrow.\"",
    "vocabBlock":[
      {"word":"decide","ipa":"/dɪˈsaɪd/","meaningVi":"quyết định","example":"I''ll decide later."},
      {"word":"arrange","ipa":"/əˈreɪndʒ/","meaningVi":"sắp xếp, hẹn","example":"We are arranging a meeting."},
      {"word":"appointment","ipa":"/əˈpɔɪntmənt/","meaningVi":"cuộc hẹn","example":"I have an appointment at 3."},
      {"word":"probably","ipa":"/ˈprɒbəbli/","meaningVi":"có lẽ","example":"It will probably be cold."},
      {"word":"definitely","ipa":"/ˈdefɪnətli/","meaningVi":"chắc chắn","example":"I am definitely going to pass."}],
    "examples":[
      {"en":"I am going to visit Hue next summer.","vi":"Mùa hè tới tôi định thăm Huế. (dự định)"},
      {"en":"I think she will pass the exam.","vi":"Tôi nghĩ cô ấy sẽ đỗ kỳ thi. (dự đoán)"},
      {"en":"I am meeting Lan at 6 p.m. tomorrow.","vi":"6 giờ tối mai tôi gặp Lan. (hẹn cố định)"}],
    "commonMistakes":["❌ Dùng will cho hẹn đã sắp xếp: \"I will meet John at 6\" → ✅ dùng hiện tại tiếp diễn \"I am meeting John at 6\".","❌ Dùng going to cho quyết định tức thì → nên dùng will."],
    "tips":["Kế hoạch đã định = going to.","Hẹn cố định có giờ giấc = hiện tại tiếp diễn.","Dự đoán/quyết định ngay = will."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u05-l3-p1','a2-u05-l3','multiple_choice',1,'practice','easy',false,'{"question":"Dự đoán dùng dạng nào?","options":[{"id":"a","text":"will"},{"id":"b","text":"hiện tại tiếp diễn"},{"id":"c","text":"quá khứ đơn"}],"correctOptionId":"a","explanationVi":"Dự đoán thường dùng will."}'::jsonb),
 ('a2-u05-l3-p2','a2-u05-l3','multiple_choice',2,'practice','medium',false,'{"question":"\"I am meeting Lan at 6 tomorrow\" diễn tả điều gì?","options":[{"id":"a","text":"Hẹn cố định đã sắp xếp"},{"id":"b","text":"Dự đoán"},{"id":"c","text":"Quyết định tức thì"}],"correctOptionId":"a","explanationVi":"Hiện tại tiếp diễn cho hẹn cố định."}'::jsonb),
 ('a2-u05-l3-p3','a2-u05-l3','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"decide","right":"quyết định"},{"left":"arrange","right":"sắp xếp"},{"left":"appointment","right":"cuộc hẹn"},{"left":"probably","right":"có lẽ"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u05-l3-p4','a2-u05-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền going to: \"We ___ (visit) Da Nang next month.\" (dự định)","acceptedAnswers":["are going to visit"],"explanationVi":"Dự định đã định → be going to + V."}'::jsonb),
 ('a2-u05-l3-p5','a2-u05-l3','translation',5,'practice','hard',false,'{"question":"Dịch sang tiếng Anh (dự đoán):","sourceText":"Tôi nghĩ họ sẽ thắng.","acceptedAnswers":["I think they will win.","I think they will win","I think they''ll win.","I think they''ll win"],"explanationVi":"Dự đoán dùng will: I think they will win."}'::jsonb),
 ('a2-u05-l3-p6','a2-u05-l3','error_correction',6,'practice','hard',false,'{"question":"Sửa câu (hẹn cố định nên dùng hiện tại tiếp diễn):","sourceText":"I will meet John at 6 tomorrow.","acceptedAnswers":["I am meeting John at 6 tomorrow.","I am meeting John at 6 tomorrow","I''m meeting John at 6 tomorrow.","I''m meeting John at 6 tomorrow"],"explanationVi":"Hẹn cố định có giờ → hiện tại tiếp diễn."}'::jsonb),
 ('a2-u05-l3-q1','a2-u05-l3','multiple_choice',7,'quiz','medium',true,'{"question":"Chọn câu đúng cho dự định đã quyết định:","options":[{"id":"a","text":"I am going to learn French."},{"id":"b","text":"I will learning French."},{"id":"c","text":"I learn French tomorrow."}],"correctOptionId":"a","explanationVi":"Dự định đã định → be going to."}'::jsonb),
 ('a2-u05-l3-q2','a2-u05-l3','multiple_choice',8,'quiz','medium',true,'{"question":"\"Look at those clouds! It ___ rain.\" (dự đoán có bằng chứng)","options":[{"id":"a","text":"is going to"},{"id":"b","text":"meets"},{"id":"c","text":"met"}],"correctOptionId":"a","explanationVi":"Có bằng chứng hiện tại → be going to."}'::jsonb),
 ('a2-u05-l3-q3','a2-u05-l3','grammar_fill_blank',9,'quiz','medium',true,'{"question":"Điền hiện tại tiếp diễn: \"I ___ (see) the doctor at 3 tomorrow.\"","acceptedAnswers":["am seeing","''m seeing"],"explanationVi":"Hẹn cố định → am seeing."}'::jsonb),
 ('a2-u05-l3-q4','a2-u05-l3','multiple_choice',10,'quiz','hard',true,'{"question":"\"The bag is heavy.\" — \"I ___ carry it for you.\" (quyết định tức thì)","options":[{"id":"a","text":"will"},{"id":"b","text":"am going to"},{"id":"c","text":"am carrying"}],"correctOptionId":"a","explanationVi":"Quyết định ngay lúc nói → will."}'::jsonb),
 ('a2-u05-l3-q5','a2-u05-l3','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["going","We","to","are","visit","Hue"],"correctOrder":[1,3,0,2,4,5],"explanationVi":"Câu đúng: We are going to visit Hue."}'::jsonb),
 ('a2-u05-l3-q6','a2-u05-l3','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối dạng tương lai với cách dùng:","pairs":[{"left":"will","right":"dự đoán/quyết định tức thì"},{"left":"be going to","right":"dự định đã định"},{"left":"present continuous","right":"hẹn cố định"}],"explanationVi":"Mỗi dạng có cách dùng riêng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u05-l4','A2','reading','a2-u05','normal',4,'My plans for the weekend','Đọc hiểu: kế hoạch cuối tuần',10,15,70,'{}'::jsonb,
  '{"warmup":"Hãy đọc đoạn văn ngắn về kế hoạch cuối tuần của Linh và trả lời câu hỏi.",
    "objectives":["Đọc hiểu đoạn văn về kế hoạch tương lai","Nhận biết be going to và will trong ngữ cảnh","Trả lời câu hỏi đọc hiểu"],
    "readingPassage":"Hi, I am Linh. This weekend is going to be busy and fun. On Saturday morning, I am going to clean my room and do my homework. In the afternoon, my friend Mai and I are going to go shopping in the city centre. We need new clothes for a party. In the evening, we are going to watch a film at the cinema. I think the film will be great because it is a comedy. On Sunday, my family is going to visit my grandparents in the countryside. We will have lunch together and play games in the garden. I am sure it will be a wonderful weekend. What are you going to do?",
    "vocabBlock":[
      {"word":"busy","ipa":"/ˈbɪzi/","meaningVi":"bận rộn","example":"This weekend is going to be busy."},
      {"word":"shopping","ipa":"/ˈʃɒpɪŋ/","meaningVi":"mua sắm","example":"We are going to go shopping."},
      {"word":"cinema","ipa":"/ˈsɪnəmə/","meaningVi":"rạp chiếu phim","example":"We watch a film at the cinema."},
      {"word":"countryside","ipa":"/ˈkʌntrisaɪd/","meaningVi":"vùng quê","example":"My grandparents live in the countryside."},
      {"word":"wonderful","ipa":"/ˈwʌndəfl/","meaningVi":"tuyệt vời","example":"It will be a wonderful weekend."}],
    "examples":[
      {"en":"This weekend is going to be busy and fun.","vi":"Cuối tuần này sẽ bận rộn và vui."},
      {"en":"I think the film will be great.","vi":"Tôi nghĩ bộ phim sẽ rất hay."}],
    "commonMistakes":["Đọc kỹ trạng từ thời gian (Saturday/Sunday) để trả lời đúng từng hoạt động."],
    "tips":["Tìm từ khóa trong câu hỏi rồi quét lại đoạn văn.","Chú ý ai làm gì, vào ngày nào."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u05-l4-p1','a2-u05-l4','multiple_choice',1,'practice','easy',false,'{"question":"Theo đoạn văn, ai là người kể chuyện?","options":[{"id":"a","text":"Linh"},{"id":"b","text":"Mai"},{"id":"c","text":"Người bà"}],"correctOptionId":"a","explanationVi":"\"Hi, I am Linh.\""}'::jsonb),
 ('a2-u05-l4-p2','a2-u05-l4','multiple_choice',2,'practice','easy',false,'{"question":"Sáng thứ Bảy Linh định làm gì?","options":[{"id":"a","text":"Dọn phòng và làm bài tập"},{"id":"b","text":"Đi mua sắm"},{"id":"c","text":"Thăm ông bà"}],"correctOptionId":"a","explanationVi":"\"On Saturday morning, I am going to clean my room and do my homework.\""}'::jsonb),
 ('a2-u05-l4-p3','a2-u05-l4','multiple_choice',3,'practice','medium',false,'{"question":"Linh và Mai đi mua sắm vì sao?","options":[{"id":"a","text":"Cần quần áo mới cho bữa tiệc"},{"id":"b","text":"Mua đồ ăn"},{"id":"c","text":"Mua sách"}],"correctOptionId":"a","explanationVi":"\"We need new clothes for a party.\""}'::jsonb),
 ('a2-u05-l4-p4','a2-u05-l4','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"busy","right":"bận rộn"},{"left":"cinema","right":"rạp chiếu phim"},{"left":"countryside","right":"vùng quê"},{"left":"wonderful","right":"tuyệt vời"}],"explanationVi":"Từ vựng trong đoạn văn."}'::jsonb),
 ('a2-u05-l4-p5','a2-u05-l4','multiple_choice',5,'practice','medium',false,'{"question":"Chủ nhật gia đình Linh định làm gì?","options":[{"id":"a","text":"Thăm ông bà ở quê"},{"id":"b","text":"Xem phim"},{"id":"c","text":"Đi mua sắm"}],"correctOptionId":"a","explanationVi":"\"On Sunday, my family is going to visit my grandparents in the countryside.\""}'::jsonb),
 ('a2-u05-l4-p6','a2-u05-l4','translation',6,'practice','hard',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cuối tuần này sẽ bận rộn.","acceptedAnswers":["This weekend is going to be busy.","This weekend is going to be busy","This weekend will be busy.","This weekend will be busy"],"explanationVi":"This weekend is going to be busy."}'::jsonb),
 ('a2-u05-l4-q1','a2-u05-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Buổi tối thứ Bảy họ định làm gì?","options":[{"id":"a","text":"Xem phim ở rạp"},{"id":"b","text":"Dọn phòng"},{"id":"c","text":"Ăn trưa với ông bà"}],"correctOptionId":"a","explanationVi":"\"In the evening, we are going to watch a film at the cinema.\""}'::jsonb),
 ('a2-u05-l4-q2','a2-u05-l4','multiple_choice',8,'quiz','medium',true,'{"question":"Vì sao Linh nghĩ bộ phim sẽ hay?","options":[{"id":"a","text":"Vì đó là phim hài"},{"id":"b","text":"Vì phim dài"},{"id":"c","text":"Vì phim mới"}],"correctOptionId":"a","explanationVi":"\"...the film will be great because it is a comedy.\""}'::jsonb),
 ('a2-u05-l4-q3','a2-u05-l4','multiple_choice',9,'quiz','medium',true,'{"question":"Chủ nhật cả nhà sẽ làm gì cùng nhau?","options":[{"id":"a","text":"Ăn trưa và chơi trò chơi trong vườn"},{"id":"b","text":"Đi mua sắm"},{"id":"c","text":"Xem phim"}],"correctOptionId":"a","explanationVi":"\"We will have lunch together and play games in the garden.\""}'::jsonb),
 ('a2-u05-l4-q4','a2-u05-l4','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền từ còn thiếu theo đoạn văn: \"My family is going to ___ my grandparents.\"","acceptedAnswers":["visit"],"explanationVi":"\"...is going to visit my grandparents.\""}'::jsonb),
 ('a2-u05-l4-q5','a2-u05-l4','multiple_choice',11,'quiz','hard',true,'{"question":"Linh cảm thấy thế nào về cuối tuần này?","options":[{"id":"a","text":"Chắc chắn sẽ tuyệt vời"},{"id":"b","text":"Buồn chán"},{"id":"c","text":"Mệt mỏi"}],"correctOptionId":"a","explanationVi":"\"I am sure it will be a wonderful weekend.\""}'::jsonb),
 ('a2-u05-l4-q6','a2-u05-l4','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"shopping","right":"mua sắm"},{"left":"clothes","right":"quần áo"},{"left":"garden","right":"khu vườn"}],"explanationVi":"Từ vựng trong đoạn văn."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u05-l5','A2','reading','a2-u05','unit_review',5,'Unit 5 Review','Ôn tập: going to, will, future forms',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại be going to, will và các dạng tương lai của Unit 5.","objectives":["Tổng hợp can-do Unit 5","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u05-l5-q1','a2-u05-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn dạng be đúng: \"They ___ going to travel.\"","options":[{"id":"a","text":"are"},{"id":"b","text":"is"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"They → are going to."}'::jsonb),
 ('a2-u05-l5-q2','a2-u05-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Điền dạng viết tắt của will not: \"She ___ be late.\"","acceptedAnswers":["won''t","will not"],"explanationVi":"won''t = will not."}'::jsonb),
 ('a2-u05-l5-q3','a2-u05-l5','multiple_choice',3,'quiz','medium',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"He is going to study English."},{"id":"b","text":"He is going to studies English."},{"id":"c","text":"He going to study English."}],"correctOptionId":"a","explanationVi":"is going to + V nguyên thể."}'::jsonb),
 ('a2-u05-l5-q4','a2-u05-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền will + V: \"I think it ___ (rain) tomorrow.\"","acceptedAnswers":["will rain"],"explanationVi":"Dự đoán: will + rain."}'::jsonb),
 ('a2-u05-l5-q5','a2-u05-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Quyết định tức thì dùng dạng nào?","options":[{"id":"a","text":"will"},{"id":"b","text":"be going to"},{"id":"c","text":"hiện tại tiếp diễn"}],"correctOptionId":"a","explanationVi":"Quyết định ngay lúc nói dùng will."}'::jsonb),
 ('a2-u05-l5-q6','a2-u05-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"tomorrow","right":"ngày mai"},{"left":"next week","right":"tuần sau"},{"left":"maybe","right":"có lẽ"},{"left":"future","right":"tương lai"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u05-l5-q7','a2-u05-l5','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["going","I","to","am","visit","Hue"],"correctOrder":[1,3,0,2,4,5],"explanationVi":"Câu đúng: I am going to visit Hue."}'::jsonb),
 ('a2-u05-l5-q8','a2-u05-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["will","It","tomorrow","rain"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: It will rain tomorrow."}'::jsonb),
 ('a2-u05-l5-q9','a2-u05-l5','multiple_choice',9,'quiz','hard',true,'{"question":"Hẹn cố định có giờ giấc dùng dạng nào?","options":[{"id":"a","text":"Hiện tại tiếp diễn"},{"id":"b","text":"will"},{"id":"c","text":"quá khứ đơn"}],"correctOptionId":"a","explanationVi":"Hẹn cố định → hiện tại tiếp diễn (am/is/are + V-ing)."}'::jsonb),
 ('a2-u05-l5-q10','a2-u05-l5','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền be đúng: \"We ___ going to have a party next week.\"","acceptedAnswers":["are"],"explanationVi":"We → are going to."}'::jsonb);

-- ── UNIT 06 — Food & Eating Out / Ẩm thực & Ăn ngoài ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u06-l1','A2','reading','a2-u06','normal',1,'Countable / uncountable','Danh từ đếm được và không đếm được',9,15,70,'{}'::jsonb,
  '{"warmup":"Ta nói \"an apple\" nhưng KHÔNG nói \"a water\" — vì sao?",
    "objectives":["Phân biệt danh từ đếm được và không đếm được","Dùng a/an với danh từ đếm được số ít","Không dùng a/an với danh từ không đếm được"],
    "grammarHtml":"<b>Đếm được</b> (countable): có số ít/số nhiều, dùng a/an: an apple, two eggs. <b>Không đếm được</b> (uncountable): water, rice, money, bread, milk — KHÔNG có số nhiều, KHÔNG dùng a/an. Nói số lượng qua đơn vị: a glass of water, a bowl of rice.",
    "vocabBlock":[
      {"word":"apple","ipa":"/ˈæpl/","meaningVi":"quả táo (đếm được)","example":"I eat an apple every day."},
      {"word":"water","ipa":"/ˈwɔːtər/","meaningVi":"nước (không đếm được)","example":"I drink a lot of water."},
      {"word":"rice","ipa":"/raɪs/","meaningVi":"cơm, gạo (không đếm được)","example":"We eat rice for lunch."},
      {"word":"egg","ipa":"/eɡ/","meaningVi":"quả trứng (đếm được)","example":"I want two eggs."},
      {"word":"money","ipa":"/ˈmʌni/","meaningVi":"tiền (không đếm được)","example":"I have some money."},
      {"word":"bread","ipa":"/bred/","meaningVi":"bánh mì (không đếm được)","example":"I buy some bread."}],
    "examples":[
      {"en":"I want an apple and a banana.","vi":"Tôi muốn một quả táo và một quả chuối."},
      {"en":"There is some water in the glass.","vi":"Có một ít nước trong cốc."},
      {"en":"Can I have a bowl of rice?","vi":"Cho tôi một bát cơm được không?"}],
    "commonMistakes":["❌ \"a water\" / \"a rice\" → ✅ \"some water\" / \"a bowl of rice\" (không đếm được không dùng a/an)","❌ \"two breads\" → ✅ \"two pieces of bread\""],
    "tips":["Nếu danh từ không thêm -s được (water, rice, money) thì là không đếm được → không dùng a/an."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u06-l1-p1','a2-u06-l1','multiple_choice',1,'practice','easy',false,'{"question":"Danh từ nào ĐẾM ĐƯỢC?","options":[{"id":"a","text":"water"},{"id":"b","text":"apple"},{"id":"c","text":"rice"}],"correctOptionId":"b","explanationVi":"apple đếm được (an apple, two apples)."}'::jsonb),
 ('a2-u06-l1-p2','a2-u06-l1','multiple_choice',2,'practice','easy',false,'{"question":"Chọn cách dùng ĐÚNG:","options":[{"id":"a","text":"a water"},{"id":"b","text":"an water"},{"id":"c","text":"some water"}],"correctOptionId":"c","explanationVi":"water không đếm được → dùng some, không dùng a/an."}'::jsonb),
 ('a2-u06-l1-p3','a2-u06-l1','grammar_fill_blank',3,'practice','easy',false,'{"question":"Điền a/an: \"I eat ___ egg for breakfast.\"","acceptedAnswers":["an"],"explanationVi":"egg bắt đầu bằng nguyên âm → an egg."}'::jsonb),
 ('a2-u06-l1-p4','a2-u06-l1','vocabulary_match',4,'practice','medium',false,'{"question":"Nối danh từ với loại của nó:","pairs":[{"left":"apple","right":"đếm được"},{"left":"water","right":"không đếm được"},{"left":"egg","right":"đếm được"},{"left":"rice","right":"không đếm được"}],"explanationVi":"apple/egg đếm được; water/rice không đếm được."}'::jsonb),
 ('a2-u06-l1-p5','a2-u06-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi muốn một quả táo.","acceptedAnswers":["I want an apple.","I want an apple","I would like an apple."],"explanationVi":"I want an apple. (apple đếm được, dùng an)."}'::jsonb),
 ('a2-u06-l1-p6','a2-u06-l1','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"Can I have a rice?","acceptedAnswers":["Can I have some rice?","Can I have a bowl of rice?","Can I have rice?"],"explanationVi":"rice không đếm được → some rice / a bowl of rice."}'::jsonb),
 ('a2-u06-l1-q1','a2-u06-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Danh từ nào KHÔNG đếm được?","options":[{"id":"a","text":"banana"},{"id":"b","text":"money"},{"id":"c","text":"egg"}],"correctOptionId":"b","explanationVi":"money không đếm được (không có \"moneys\")."}'::jsonb),
 ('a2-u06-l1-q2','a2-u06-l1','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền a/an: \"I want ___ apple.\"","acceptedAnswers":["an"],"explanationVi":"apple bắt đầu bằng nguyên âm → an apple."}'::jsonb),
 ('a2-u06-l1-q3','a2-u06-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"I drink a water."},{"id":"b","text":"I drink some water."},{"id":"c","text":"I drink an water."}],"correctOptionId":"b","explanationVi":"water không đếm được → some water."}'::jsonb),
 ('a2-u06-l1-q4','a2-u06-l1','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối danh từ với loại của nó:","pairs":[{"left":"bread","right":"không đếm được"},{"left":"banana","right":"đếm được"},{"left":"milk","right":"không đếm được"}],"explanationVi":"bread/milk không đếm được; banana đếm được."}'::jsonb),
 ('a2-u06-l1-q5','a2-u06-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền a/an hoặc để trống (gõ \"x\" nếu không cần): \"Can I have ___ rice?\" (không đếm được)","acceptedAnswers":["x","some","X"],"explanationVi":"rice không đếm được → không dùng a/an (some rice)."}'::jsonb),
 ('a2-u06-l1-q6','a2-u06-l1','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["want","I","an","egg"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: I want an egg."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u06-l2','A2','reading','a2-u06','normal',2,'some / any','Dùng some và any',9,15,70,'{}'::jsonb,
  '{"warmup":"\"I have some bread\" và \"I don''t have any bread\" — khác nhau ở đâu?",
    "objectives":["Dùng some trong câu khẳng định và lời đề nghị","Dùng any trong câu phủ định và nghi vấn"],
    "grammarHtml":"<b>some</b>: câu khẳng định (I have some apples) và lời mời/đề nghị (Would you like some tea?). <b>any</b>: câu phủ định (I don''t have any money) và câu hỏi (Is there any milk?). Dùng với cả danh từ đếm được số nhiều và không đếm được.",
    "vocabBlock":[
      {"word":"some","ipa":"/sʌm/","meaningVi":"một vài, một ít","example":"I have some friends."},
      {"word":"any","ipa":"/ˈeni/","meaningVi":"nào, một chút (phủ định/nghi vấn)","example":"Is there any sugar?"},
      {"word":"sugar","ipa":"/ˈʃʊɡər/","meaningVi":"đường (không đếm được)","example":"I don''t take any sugar."},
      {"word":"milk","ipa":"/mɪlk/","meaningVi":"sữa","example":"Is there any milk?"},
      {"word":"tea","ipa":"/tiː/","meaningVi":"trà","example":"Would you like some tea?"}],
    "examples":[
      {"en":"There is some milk in the fridge.","vi":"Có một ít sữa trong tủ lạnh."},
      {"en":"I don''t have any money.","vi":"Tôi không có đồng nào."},
      {"en":"Would you like some coffee?","vi":"Bạn có muốn chút cà phê không?"}],
    "commonMistakes":["❌ \"I don''t have some money\" → ✅ \"I don''t have any money\" (phủ định dùng any)","❌ \"Is there some milk?\" (câu hỏi thường) → ✅ \"Is there any milk?\""],
    "tips":["Mời ai đó dùng some dù là câu hỏi: \"Would you like some cake?\""]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u06-l2-p1','a2-u06-l2','multiple_choice',1,'practice','easy',false,'{"question":"\"I have ___ apples.\" (khẳng định)","options":[{"id":"a","text":"some"},{"id":"b","text":"any"},{"id":"c","text":"a"}],"correctOptionId":"a","explanationVi":"Câu khẳng định dùng some."}'::jsonb),
 ('a2-u06-l2-p2','a2-u06-l2','multiple_choice',2,'practice','easy',false,'{"question":"\"I don''t have ___ money.\" (phủ định)","options":[{"id":"a","text":"some"},{"id":"b","text":"any"},{"id":"c","text":"a"}],"correctOptionId":"b","explanationVi":"Câu phủ định dùng any."}'::jsonb),
 ('a2-u06-l2-p3','a2-u06-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"Điền some/any: \"Is there ___ milk in the fridge?\"","acceptedAnswers":["any"],"explanationVi":"Câu hỏi dùng any."}'::jsonb),
 ('a2-u06-l2-p4','a2-u06-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền some/any: \"Would you like ___ tea?\" (lời mời)","acceptedAnswers":["some"],"explanationVi":"Lời mời/đề nghị dùng some."}'::jsonb),
 ('a2-u06-l2-p5','a2-u06-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi không có quả trứng nào.","acceptedAnswers":["I don''t have any eggs.","I do not have any eggs.","I haven''t got any eggs."],"explanationVi":"Phủ định dùng any: I don''t have any eggs."}'::jsonb),
 ('a2-u06-l2-p6','a2-u06-l2','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"There isn''t some sugar.","acceptedAnswers":["There isn''t any sugar.","There is not any sugar."],"explanationVi":"Câu phủ định dùng any, không dùng some."}'::jsonb),
 ('a2-u06-l2-q1','a2-u06-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn từ đúng: \"There is ___ bread on the table.\"","options":[{"id":"a","text":"any"},{"id":"b","text":"some"},{"id":"c","text":"an"}],"correctOptionId":"b","explanationVi":"Câu khẳng định dùng some."}'::jsonb),
 ('a2-u06-l2-q2','a2-u06-l2','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền some/any: \"I don''t want ___ sugar.\"","acceptedAnswers":["any"],"explanationVi":"Phủ định dùng any."}'::jsonb),
 ('a2-u06-l2-q3','a2-u06-l2','multiple_choice',9,'quiz','medium',true,'{"question":"Câu hỏi nào ĐÚNG?","options":[{"id":"a","text":"Do you have any milk?"},{"id":"b","text":"Do you have some milk?"},{"id":"c","text":"Do you have a milk?"}],"correctOptionId":"a","explanationVi":"Câu hỏi (yes/no) dùng any."}'::jsonb),
 ('a2-u06-l2-q4','a2-u06-l2','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền some/any (lời mời): \"Would you like ___ cake?\"","acceptedAnswers":["some"],"explanationVi":"Lời mời dùng some."}'::jsonb),
 ('a2-u06-l2-q5','a2-u06-l2','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"sugar","right":"đường"},{"left":"milk","right":"sữa"},{"left":"tea","right":"trà"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u06-l2-q6','a2-u06-l2','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["any","I","don''t","have","money"],"correctOrder":[1,2,3,0,4],"explanationVi":"Câu đúng: I don''t have any money."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u06-l3','A2','reading','a2-u06','normal',3,'much / many / a lot of','Số lượng nhiều: much, many, a lot of',9,15,70,'{}'::jsonb,
  '{"warmup":"\"How many apples?\" hay \"How much water?\" — chọn từ nào khi nào?",
    "objectives":["Dùng many với danh từ đếm được số nhiều","Dùng much với danh từ không đếm được","Dùng a lot of cho cả hai và đặt câu hỏi How much/How many"],
    "grammarHtml":"<b>many</b> + đếm được số nhiều: many apples, many people. <b>much</b> + không đếm được: much water, much money (thường trong phủ định/nghi vấn). <b>a lot of</b> + cả hai (khẳng định): a lot of friends, a lot of rice. Hỏi: <b>How many</b> + đếm được (How many eggs?), <b>How much</b> + không đếm được (How much money?).",
    "vocabBlock":[
      {"word":"many","ipa":"/ˈmeni/","meaningVi":"nhiều (đếm được)","example":"How many books do you have?"},
      {"word":"much","ipa":"/mʌtʃ/","meaningVi":"nhiều (không đếm được)","example":"How much water do you drink?"},
      {"word":"a lot of","ipa":"/ə lɒt əv/","meaningVi":"nhiều (cả hai loại)","example":"I have a lot of friends."},
      {"word":"people","ipa":"/ˈpiːpl/","meaningVi":"người (số nhiều, đếm được)","example":"There are many people here."},
      {"word":"sugar","ipa":"/ˈʃʊɡər/","meaningVi":"đường","example":"How much sugar do you want?"}],
    "examples":[
      {"en":"How many eggs do you need?","vi":"Bạn cần bao nhiêu quả trứng?"},
      {"en":"How much money do you have?","vi":"Bạn có bao nhiêu tiền?"},
      {"en":"There are a lot of restaurants here.","vi":"Ở đây có nhiều nhà hàng."}],
    "commonMistakes":["❌ \"How much apples?\" → ✅ \"How many apples?\" (apples đếm được)","❌ \"many water\" → ✅ \"much water\" / \"a lot of water\""],
    "tips":["Nhớ: many đi với danh từ có -s; much đi với danh từ không đếm được."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u06-l3-p1','a2-u06-l3','multiple_choice',1,'practice','easy',false,'{"question":"\"How ___ apples do you want?\"","options":[{"id":"a","text":"much"},{"id":"b","text":"many"},{"id":"c","text":"a lot"}],"correctOptionId":"b","explanationVi":"apples đếm được → many."}'::jsonb),
 ('a2-u06-l3-p2','a2-u06-l3','multiple_choice',2,'practice','easy',false,'{"question":"\"How ___ water do you drink?\"","options":[{"id":"a","text":"many"},{"id":"b","text":"much"},{"id":"c","text":"an"}],"correctOptionId":"b","explanationVi":"water không đếm được → much."}'::jsonb),
 ('a2-u06-l3-p3','a2-u06-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"Điền much/many: \"There are ___ people here.\"","acceptedAnswers":["many"],"explanationVi":"people đếm được số nhiều → many."}'::jsonb),
 ('a2-u06-l3-p4','a2-u06-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền much/many: \"I don''t have ___ money.\"","acceptedAnswers":["much"],"explanationVi":"money không đếm được → much."}'::jsonb),
 ('a2-u06-l3-p5','a2-u06-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Bạn cần bao nhiêu quả trứng?","acceptedAnswers":["How many eggs do you need?","How many eggs do you want?"],"explanationVi":"eggs đếm được → How many eggs do you need?"}'::jsonb),
 ('a2-u06-l3-p6','a2-u06-l3','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"How much apples do you want?","acceptedAnswers":["How many apples do you want?"],"explanationVi":"apples đếm được → How many."}'::jsonb),
 ('a2-u06-l3-q1','a2-u06-l3','multiple_choice',7,'quiz','easy',true,'{"question":"\"How ___ money do you have?\"","options":[{"id":"a","text":"many"},{"id":"b","text":"much"},{"id":"c","text":"a"}],"correctOptionId":"b","explanationVi":"money không đếm được → much."}'::jsonb),
 ('a2-u06-l3-q2','a2-u06-l3','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền much/many: \"How ___ books are there?\"","acceptedAnswers":["many"],"explanationVi":"books đếm được → many."}'::jsonb),
 ('a2-u06-l3-q3','a2-u06-l3','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"I have many water."},{"id":"b","text":"I have a lot of water."},{"id":"c","text":"I have many waters."}],"correctOptionId":"b","explanationVi":"water không đếm được → a lot of water."}'::jsonb),
 ('a2-u06-l3-q4','a2-u06-l3','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền much/many: \"There isn''t ___ sugar in my coffee.\"","acceptedAnswers":["much"],"explanationVi":"sugar không đếm được → much."}'::jsonb),
 ('a2-u06-l3-q5','a2-u06-l3','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ với cách dùng đúng:","pairs":[{"left":"many","right":"đếm được số nhiều"},{"left":"much","right":"không đếm được"},{"left":"a lot of","right":"cả hai loại"}],"explanationVi":"many + đếm được, much + không đếm được, a lot of + cả hai."}'::jsonb),
 ('a2-u06-l3-q6','a2-u06-l3','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["many","How","do","eggs","you","need"],"correctOrder":[1,0,3,2,4,5],"explanationVi":"Câu đúng: How many eggs do you need?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u06-l4','A2','listening','a2-u06','normal',4,'Ordering food','Nghe và gọi món ở nhà hàng',10,15,70,'{}'::jsonb,
  '{"warmup":"Bạn vào nhà hàng — người phục vụ nói gì, và bạn gọi món thế nào?",
    "objectives":["Nghe hiểu hội thoại gọi món ở nhà hàng","Dùng mẫu I''d like... / Can I have...?","Nhận biết từ vựng đồ ăn thường gặp"],
    "grammarHtml":"Gọi món lịch sự: <b>I''d like</b> + món (I''d like a pizza). <b>Can I have</b> + món? (Can I have the menu, please?). Người phục vụ: \"Are you ready to order?\", \"What would you like?\", \"Anything to drink?\"",
    "vocabBlock":[
      {"word":"menu","ipa":"/ˈmenjuː/","meaningVi":"thực đơn","example":"Can I have the menu, please?"},
      {"word":"order","ipa":"/ˈɔːdər/","meaningVi":"gọi món, order","example":"Are you ready to order?"},
      {"word":"waiter","ipa":"/ˈweɪtər/","meaningVi":"người phục vụ","example":"The waiter is coming."},
      {"word":"soup","ipa":"/suːp/","meaningVi":"súp","example":"I''d like some soup."},
      {"word":"chicken","ipa":"/ˈtʃɪkɪn/","meaningVi":"thịt gà","example":"I''d like the chicken, please."},
      {"word":"bill","ipa":"/bɪl/","meaningVi":"hóa đơn","example":"Can I have the bill, please?"}],
    "examples":[
      {"en":"Waiter: Are you ready to order? – Me: Yes, I''d like a pizza, please.","vi":"Phục vụ: Bạn gọi món chưa? – Tôi: Vâng, cho tôi một chiếc pizza."},
      {"en":"Can I have a glass of orange juice, please?","vi":"Cho tôi một ly nước cam được không?"},
      {"en":"Can I have the bill, please?","vi":"Cho tôi xin hóa đơn được không?"}],
    "commonMistakes":["❌ \"I want pizza\" (cộc lốc) → ✅ \"I''d like a pizza, please\" (lịch sự hơn)"],
    "tips":["Nghe kỹ từ khóa món ăn và đồ uống trong hội thoại trước khi chọn đáp án."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u06-l4-p1','a2-u06-l4','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ đồ ăn với nghĩa:","pairs":[{"left":"soup","right":"súp"},{"left":"chicken","right":"thịt gà"},{"left":"menu","right":"thực đơn"},{"left":"bill","right":"hóa đơn"}],"explanationVi":"Ghép đúng từng cặp từ vựng nhà hàng."}'::jsonb),
 ('a2-u06-l4-p2','a2-u06-l4','listening_choice',2,'practice','easy',false,'{"question":"Nghe và chọn món người nói gọi:","audioText":"I''d like a pizza, please.","options":[{"id":"a","text":"pizza"},{"id":"b","text":"soup"},{"id":"c","text":"chicken"}],"correctOptionId":"a","explanationVi":"\"I''d like a pizza\" = gọi món pizza."}'::jsonb),
 ('a2-u06-l4-p3','a2-u06-l4','listening_choice',3,'practice','medium',false,'{"question":"Nghe và chọn câu người phục vụ nói:","audioText":"Are you ready to order?","options":[{"id":"a","text":"Bạn đã sẵn sàng gọi món chưa?"},{"id":"b","text":"Bạn muốn uống gì?"},{"id":"c","text":"Hóa đơn của bạn đây."}],"correctOptionId":"a","explanationVi":"\"Are you ready to order?\" = Bạn sẵn sàng gọi món chưa?"}'::jsonb),
 ('a2-u06-l4-p4','a2-u06-l4','listening_choice',4,'practice','medium',false,'{"question":"Nghe và chọn đồ uống được gọi:","audioText":"Can I have a glass of orange juice, please?","options":[{"id":"a","text":"orange juice"},{"id":"b","text":"coffee"},{"id":"c","text":"water"}],"correctOptionId":"a","explanationVi":"orange juice = nước cam."}'::jsonb),
 ('a2-u06-l4-p5','a2-u06-l4','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh (lịch sự):","sourceText":"Cho tôi xin hóa đơn được không?","acceptedAnswers":["Can I have the bill, please?","Can I have the bill please?","Could I have the bill, please?"],"explanationVi":"Can I have the bill, please?"}'::jsonb),
 ('a2-u06-l4-p6','a2-u06-l4','listening_choice',6,'practice','hard',false,'{"question":"Nghe và chọn câu cuối bữa ăn:","audioText":"Can I have the bill, please?","options":[{"id":"a","text":"Xin hóa đơn"},{"id":"b","text":"Cho tôi xem thực đơn"},{"id":"c","text":"Tôi muốn gọi món"}],"correctOptionId":"a","explanationVi":"\"the bill\" = hóa đơn, dùng khi xong bữa."}'::jsonb),
 ('a2-u06-l4-q1','a2-u06-l4','listening_choice',7,'quiz','easy',true,'{"question":"Nghe và chọn món được gọi:","audioText":"I''d like the chicken, please.","options":[{"id":"a","text":"chicken"},{"id":"b","text":"fish"},{"id":"c","text":"soup"}],"correctOptionId":"a","explanationVi":"\"the chicken\" = món thịt gà."}'::jsonb),
 ('a2-u06-l4-q2','a2-u06-l4','listening_choice',8,'quiz','medium',true,'{"question":"Nghe và chọn nghĩa đúng:","audioText":"Can I have the menu, please?","options":[{"id":"a","text":"Cho tôi xem thực đơn"},{"id":"b","text":"Cho tôi hóa đơn"},{"id":"c","text":"Tôi muốn nước"}],"correctOptionId":"a","explanationVi":"menu = thực đơn."}'::jsonb),
 ('a2-u06-l4-q3','a2-u06-l4','listening_choice',9,'quiz','medium',true,'{"question":"Nghe câu hỏi của phục vụ và chọn nghĩa:","audioText":"Anything to drink?","options":[{"id":"a","text":"Bạn muốn uống gì không?"},{"id":"b","text":"Bạn muốn món tráng miệng không?"},{"id":"c","text":"Bạn trả tiền mặt chứ?"}],"correctOptionId":"a","explanationVi":"\"Anything to drink?\" = Bạn muốn uống gì không?"}'::jsonb),
 ('a2-u06-l4-q4','a2-u06-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Cách gọi món LỊCH SỰ nhất:","options":[{"id":"a","text":"Give me pizza."},{"id":"b","text":"I want pizza."},{"id":"c","text":"I''d like a pizza, please."}],"correctOptionId":"c","explanationVi":"I''d like... please là cách gọi món lịch sự."}'::jsonb),
 ('a2-u06-l4-q5','a2-u06-l4','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"waiter","right":"người phục vụ"},{"left":"order","right":"gọi món"},{"left":"bill","right":"hóa đơn"}],"explanationVi":"Ghép đúng từ vựng nhà hàng."}'::jsonb),
 ('a2-u06-l4-q6','a2-u06-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu gọi món đúng:","tokens":["like","I''d","a","pizza"],"correctOrder":[1,0,2,3],"explanationVi":"Câu đúng: I''d like a pizza."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u06-l5','A2','listening','a2-u06','unit_review',5,'Unit 6 Review','Ôn tập Unit 6: đếm được/không đếm được, some/any, much/many, gọi món (có nghe)',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại Unit 6: danh từ đếm được/không đếm được, some/any, much/many/a lot of, gọi món.",
    "objectives":["Tổng hợp can-do Unit 6","Đạt ≥ 75% để hoàn thành Unit"],
    "vocabBlock":[],"examples":[],"commonMistakes":[],
    "tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u06-l5-q1','a2-u06-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Danh từ nào KHÔNG đếm được?","options":[{"id":"a","text":"egg"},{"id":"b","text":"water"},{"id":"c","text":"apple"}],"correctOptionId":"b","explanationVi":"water không đếm được."}'::jsonb),
 ('a2-u06-l5-q2','a2-u06-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Điền a/an: \"I want ___ apple.\"","acceptedAnswers":["an"],"explanationVi":"apple bắt đầu bằng nguyên âm → an."}'::jsonb),
 ('a2-u06-l5-q3','a2-u06-l5','multiple_choice',3,'quiz','easy',true,'{"question":"\"There is ___ milk in the fridge.\" (khẳng định)","options":[{"id":"a","text":"any"},{"id":"b","text":"some"},{"id":"c","text":"a"}],"correctOptionId":"b","explanationVi":"Câu khẳng định dùng some."}'::jsonb),
 ('a2-u06-l5-q4','a2-u06-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền some/any: \"I don''t have ___ money.\"","acceptedAnswers":["any"],"explanationVi":"Câu phủ định dùng any."}'::jsonb),
 ('a2-u06-l5-q5','a2-u06-l5','multiple_choice',5,'quiz','medium',true,'{"question":"\"How ___ eggs do you need?\"","options":[{"id":"a","text":"much"},{"id":"b","text":"many"},{"id":"c","text":"a lot"}],"correctOptionId":"b","explanationVi":"eggs đếm được → many."}'::jsonb),
 ('a2-u06-l5-q6','a2-u06-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền much/many: \"How ___ water do you drink?\"","acceptedAnswers":["much"],"explanationVi":"water không đếm được → much."}'::jsonb),
 ('a2-u06-l5-q7','a2-u06-l5','vocabulary_match',7,'quiz','medium',true,'{"question":"Nối từ đồ ăn với nghĩa:","pairs":[{"left":"soup","right":"súp"},{"left":"chicken","right":"thịt gà"},{"left":"bill","right":"hóa đơn"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u06-l5-q8','a2-u06-l5','listening_choice',8,'quiz','medium',true,'{"question":"Nghe và chọn món được gọi:","audioText":"I''d like a pizza, please.","options":[{"id":"a","text":"pizza"},{"id":"b","text":"soup"},{"id":"c","text":"chicken"}],"correctOptionId":"a","explanationVi":"\"I''d like a pizza\" = gọi pizza."}'::jsonb),
 ('a2-u06-l5-q9','a2-u06-l5','listening_choice',9,'quiz','hard',true,'{"question":"Nghe và chọn nghĩa đúng:","audioText":"Can I have the bill, please?","options":[{"id":"a","text":"Cho tôi xin hóa đơn"},{"id":"b","text":"Cho tôi thực đơn"},{"id":"c","text":"Tôi muốn gọi món"}],"correctOptionId":"a","explanationVi":"the bill = hóa đơn."}'::jsonb),
 ('a2-u06-l5-q10','a2-u06-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["any","I","don''t","have","money"],"correctOrder":[1,2,3,0,4],"explanationVi":"Câu đúng: I don''t have any money."}'::jsonb);

-- ── UNIT 07 — Rules & Advice / Quy tắc & Lời khuyên ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u07-l1','A2','reading','a2-u07','normal',1,'should / shouldn''t','Đưa ra lời khuyên',9,15,70,'{}'::jsonb,
  '{"warmup":"Một người bạn bị đau đầu — bạn khuyên họ làm gì?",
    "objectives":["Dùng should/shouldn''t + V (nguyên thể) để khuyên","Phân biệt nên / không nên","Đặt câu hỏi khuyên với Should I...?"],
    "grammarHtml":"<b>should</b> + V (động từ nguyên thể, không to) = nên. <b>shouldn''t</b> (= should not) = không nên. Dùng cho mọi chủ ngữ (I/you/he/she...): <i>He should rest.</i> Câu hỏi: <i>Should I see a doctor?</i>",
    "vocabBlock":[
      {"word":"should","ipa":"/ʃʊd/","meaningVi":"nên","example":"You should see a doctor."},
      {"word":"shouldn''t","ipa":"/ˈʃʊdnt/","meaningVi":"không nên","example":"You shouldn''t eat too much sugar."},
      {"word":"advice","ipa":"/ədˈvaɪs/","meaningVi":"lời khuyên","example":"Can you give me some advice?"},
      {"word":"rest","ipa":"/rest/","meaningVi":"nghỉ ngơi","example":"You should rest at home."},
      {"word":"healthy","ipa":"/ˈhelθi/","meaningVi":"khỏe mạnh, lành mạnh","example":"Eat healthy food."}],
    "examples":[
      {"en":"You should see a doctor.","vi":"Bạn nên đi khám bác sĩ."},
      {"en":"You shouldn''t drink coffee at night.","vi":"Bạn không nên uống cà phê vào ban đêm."},
      {"en":"Should I take this medicine?","vi":"Tôi có nên uống thuốc này không?"}],
    "commonMistakes":["❌ \"You should to see a doctor.\" → ✅ \"You should see a doctor.\" (không có to sau should).","❌ \"He shoulds rest.\" → ✅ \"He should rest.\" (should không chia theo ngôi)."],
    "tips":["Sau should luôn là động từ nguyên thể, không thêm to, không thêm -s.","shouldn''t = should not."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u07-l1-p1','a2-u07-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn câu khuyên đúng (nên đi khám):","options":[{"id":"a","text":"You should see a doctor."},{"id":"b","text":"You should to see a doctor."},{"id":"c","text":"You shoulds see a doctor."}],"correctOptionId":"a","explanationVi":"should + V nguyên thể, không có to, không thêm -s."}'::jsonb),
 ('a2-u07-l1-p2','a2-u07-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền từ (nên): \"You ___ drink more water.\"","acceptedAnswers":["should"],"explanationVi":"should = nên."}'::jsonb),
 ('a2-u07-l1-p3','a2-u07-l1','grammar_fill_blank',3,'practice','medium',false,'{"question":"Điền từ (không nên): \"You ___ eat too much sugar.\"","acceptedAnswers":["shouldn''t","should not"],"explanationVi":"shouldn''t = should not = không nên."}'::jsonb),
 ('a2-u07-l1-p4','a2-u07-l1','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"should","right":"nên"},{"left":"shouldn''t","right":"không nên"},{"left":"advice","right":"lời khuyên"},{"left":"rest","right":"nghỉ ngơi"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l1-p5','a2-u07-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Bạn nên nghỉ ngơi ở nhà.","acceptedAnswers":["You should rest at home.","You should rest at home"],"explanationVi":"should + V: You should rest at home."}'::jsonb),
 ('a2-u07-l1-p6','a2-u07-l1','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu sau:","sourceText":"He should to rest today.","acceptedAnswers":["He should rest today.","He should rest today"],"explanationVi":"Bỏ to: He should rest today."}'::jsonb),
 ('a2-u07-l1-q1','a2-u07-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Câu nào đưa ra lời khuyên \"không nên\"?","options":[{"id":"a","text":"You should sleep more."},{"id":"b","text":"You shouldn''t smoke."},{"id":"c","text":"You should rest."}],"correctOptionId":"b","explanationVi":"shouldn''t = không nên."}'::jsonb),
 ('a2-u07-l1-q2','a2-u07-l1','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền từ: \"You ___ see a doctor.\" (khuyên nên)","acceptedAnswers":["should"],"explanationVi":"should = nên."}'::jsonb),
 ('a2-u07-l1-q3','a2-u07-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn dạng đúng sau should:","options":[{"id":"a","text":"You should rests."},{"id":"b","text":"You should rest."},{"id":"c","text":"You should resting."}],"correctOptionId":"b","explanationVi":"should + V nguyên thể: rest."}'::jsonb),
 ('a2-u07-l1-q4','a2-u07-l1','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu khuyên đúng:","tokens":["should","You","a","see","doctor"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: You should see a doctor."}'::jsonb),
 ('a2-u07-l1-q5','a2-u07-l1','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"healthy","right":"khỏe mạnh"},{"left":"advice","right":"lời khuyên"},{"left":"should","right":"nên"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l1-q6','a2-u07-l1','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi khuyên:","tokens":["Should","take","I","medicine","this"],"correctOrder":[0,2,1,4,3],"explanationVi":"Câu đúng: Should I take this medicine?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u07-l2','A2','reading','a2-u07','normal',2,'have to / must','Nói quy tắc và nghĩa vụ',9,15,70,'{}'::jsonb,
  '{"warmup":"Ở trường có những quy tắc nào bạn bắt buộc phải làm?",
    "objectives":["Dùng have to / has to nói nghĩa vụ","Dùng must / mustn''t nói quy tắc bắt buộc / cấm","Phân biệt mustn''t (cấm) với don''t have to (không bắt buộc)"],
    "grammarHtml":"<b>have to / has to</b> + V = phải (nghĩa vụ). He/she/it dùng <i>has to</i>. <b>don''t/doesn''t have to</b> = không cần, không bắt buộc. <b>must</b> + V = phải (quy tắc mạnh). <b>mustn''t</b> (= must not) = không được phép (cấm). <br>So sánh: <i>You don''t have to come</i> (không bắt buộc) vs <i>You mustn''t come</i> (cấm).",
    "vocabBlock":[
      {"word":"have to","ipa":"/ˈhæv tu/","meaningVi":"phải, bắt buộc","example":"I have to wear a uniform."},
      {"word":"must","ipa":"/mʌst/","meaningVi":"phải (quy tắc)","example":"You must stop at a red light."},
      {"word":"mustn''t","ipa":"/ˈmʌsnt/","meaningVi":"không được phép","example":"You mustn''t smoke here."},
      {"word":"rule","ipa":"/ruːl/","meaningVi":"quy tắc","example":"Follow the rules."},
      {"word":"uniform","ipa":"/ˈjuːnɪfɔːm/","meaningVi":"đồng phục","example":"Students wear a uniform."}],
    "examples":[
      {"en":"I have to get up early.","vi":"Tôi phải dậy sớm."},
      {"en":"You mustn''t use your phone in class.","vi":"Bạn không được dùng điện thoại trong lớp."},
      {"en":"You don''t have to pay; it''s free.","vi":"Bạn không cần trả tiền; nó miễn phí."}],
    "commonMistakes":["❌ \"He have to go.\" → ✅ \"He has to go.\" (he/she/it dùng has to).","mustn''t (cấm) KHÁC don''t have to (không bắt buộc)."],
    "tips":["mustn''t = cấm; don''t have to = không bắt buộc (được phép không làm).","Sau must / have to luôn là V nguyên thể."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u07-l2-p1','a2-u07-l2','multiple_choice',1,'practice','easy',false,'{"question":"Chọn dạng đúng: \"He ___ wear a uniform.\"","options":[{"id":"a","text":"have to"},{"id":"b","text":"has to"},{"id":"c","text":"to have"}],"correctOptionId":"b","explanationVi":"He/she/it dùng has to."}'::jsonb),
 ('a2-u07-l2-p2','a2-u07-l2','grammar_fill_blank',2,'practice','medium',false,'{"question":"Điền (cấm): \"You ___ smoke here.\"","acceptedAnswers":["mustn''t","must not"],"explanationVi":"mustn''t = không được phép (cấm)."}'::jsonb),
 ('a2-u07-l2-p3','a2-u07-l2','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"must","right":"phải"},{"left":"mustn''t","right":"không được phép"},{"left":"rule","right":"quy tắc"},{"left":"uniform","right":"đồng phục"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l2-p4','a2-u07-l2','multiple_choice',4,'practice','medium',false,'{"question":"\"It''s free. You ___ pay.\" (không bắt buộc trả tiền)","options":[{"id":"a","text":"mustn''t"},{"id":"b","text":"don''t have to"},{"id":"c","text":"have to"}],"correctOptionId":"b","explanationVi":"don''t have to = không bắt buộc."}'::jsonb),
 ('a2-u07-l2-p5','a2-u07-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi phải dậy sớm.","acceptedAnswers":["I have to get up early.","I have to get up early","I must get up early.","I must get up early"],"explanationVi":"I have to get up early. / I must get up early."}'::jsonb),
 ('a2-u07-l2-p6','a2-u07-l2','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu sau:","sourceText":"She have to study tonight.","acceptedAnswers":["She has to study tonight.","She has to study tonight"],"explanationVi":"She → has to: She has to study tonight."}'::jsonb),
 ('a2-u07-l2-q1','a2-u07-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu diễn tả \"cấm\":","options":[{"id":"a","text":"You don''t have to wait."},{"id":"b","text":"You mustn''t park here."},{"id":"c","text":"You have to wait."}],"correctOptionId":"b","explanationVi":"mustn''t = cấm."}'::jsonb),
 ('a2-u07-l2-q2','a2-u07-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền has to / have to: \"My sister ___ work on Saturday.\"","acceptedAnswers":["has to"],"explanationVi":"My sister (she) dùng has to."}'::jsonb),
 ('a2-u07-l2-q3','a2-u07-l2','multiple_choice',9,'quiz','hard',true,'{"question":"\"Tomorrow is a holiday, so you ___ go to school.\" (không bắt buộc)","options":[{"id":"a","text":"mustn''t"},{"id":"b","text":"don''t have to"},{"id":"c","text":"must"}],"correctOptionId":"b","explanationVi":"Không bắt buộc → don''t have to (không phải cấm)."}'::jsonb),
 ('a2-u07-l2-q4','a2-u07-l2','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"have to","right":"phải"},{"left":"don''t have to","right":"không bắt buộc"},{"left":"mustn''t","right":"không được phép"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l2-q5','a2-u07-l2','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["must","You","at","stop","a red light"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: You must stop at a red light."}'::jsonb),
 ('a2-u07-l2-q6','a2-u07-l2','grammar_fill_blank',12,'quiz','medium',true,'{"question":"Điền (cấm dùng điện thoại): \"You ___ use your phone in class.\"","acceptedAnswers":["mustn''t","must not"],"explanationVi":"mustn''t = không được phép."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u07-l3','A2','reading','a2-u07','normal',3,'can / could / be able to','Nói về khả năng',10,15,70,'{}'::jsonb,
  '{"warmup":"Bạn có thể làm gì bây giờ mà hồi nhỏ chưa làm được?",
    "objectives":["Dùng can / can''t nói khả năng ở hiện tại","Dùng could / couldn''t nói khả năng trong quá khứ","Dùng be able to thay cho can/could"],
    "grammarHtml":"<b>can</b> + V = có thể (hiện tại); phủ định <b>can''t</b> (cannot). <b>could</b> + V = có thể (quá khứ); phủ định <b>couldn''t</b>. <b>be able to</b> + V = có khả năng, dùng được mọi thì: <i>am/is/are able to</i> (hiện tại), <i>was/were able to</i> (quá khứ). Sau tất cả là V nguyên thể.",
    "vocabBlock":[
      {"word":"can","ipa":"/kæn/","meaningVi":"có thể","example":"I can swim."},
      {"word":"can''t","ipa":"/kɑːnt/","meaningVi":"không thể","example":"I can''t drive."},
      {"word":"could","ipa":"/kʊd/","meaningVi":"có thể (quá khứ)","example":"I could read at five."},
      {"word":"be able to","ipa":"/bi ˈeɪbl tu/","meaningVi":"có khả năng","example":"She is able to speak French."},
      {"word":"swim","ipa":"/swɪm/","meaningVi":"bơi","example":"Can you swim?"}],
    "examples":[
      {"en":"I can speak English.","vi":"Tôi có thể nói tiếng Anh."},
      {"en":"When I was six, I couldn''t ride a bike.","vi":"Khi tôi sáu tuổi, tôi chưa biết đi xe đạp."},
      {"en":"She is able to swim very well.","vi":"Cô ấy có thể bơi rất giỏi."}],
    "commonMistakes":["❌ \"I can to swim.\" → ✅ \"I can swim.\" (không có to sau can/could).","❌ \"He cans drive.\" → ✅ \"He can drive.\" (can không thêm -s)."],
    "tips":["could là quá khứ của can.","be able to dùng khi cần các thì khác hoặc sau modal khác."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u07-l3-p1','a2-u07-l3','multiple_choice',1,'practice','easy',false,'{"question":"Chọn câu đúng (khả năng hiện tại):","options":[{"id":"a","text":"I can swim."},{"id":"b","text":"I can to swim."},{"id":"c","text":"I cans swim."}],"correctOptionId":"a","explanationVi":"can + V nguyên thể, không có to, không -s."}'::jsonb),
 ('a2-u07-l3-p2','a2-u07-l3','grammar_fill_blank',2,'practice','medium',false,'{"question":"Điền quá khứ của can: \"When I was five, I ___ read.\"","acceptedAnswers":["could"],"explanationVi":"could = quá khứ của can."}'::jsonb),
 ('a2-u07-l3-p3','a2-u07-l3','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"can","right":"có thể"},{"left":"can''t","right":"không thể"},{"left":"could","right":"có thể (quá khứ)"},{"left":"be able to","right":"có khả năng"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l3-p4','a2-u07-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền be able to (hiện tại, she): \"She ___ speak French.\"","acceptedAnswers":["is able to"],"explanationVi":"she → is able to."}'::jsonb),
 ('a2-u07-l3-p5','a2-u07-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi không thể lái xe.","acceptedAnswers":["I can''t drive.","I cannot drive.","I can''t drive","I cannot drive"],"explanationVi":"I can''t drive. = Tôi không thể lái xe."}'::jsonb),
 ('a2-u07-l3-p6','a2-u07-l3','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu sau:","sourceText":"He can to play the guitar.","acceptedAnswers":["He can play the guitar.","He can play the guitar"],"explanationVi":"Bỏ to: He can play the guitar."}'::jsonb),
 ('a2-u07-l3-q1','a2-u07-l3','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu phủ định khả năng hiện tại:","options":[{"id":"a","text":"I couldn''t cook."},{"id":"b","text":"I can''t cook."},{"id":"c","text":"I can cook."}],"correctOptionId":"b","explanationVi":"can''t = không thể (hiện tại)."}'::jsonb),
 ('a2-u07-l3-q2','a2-u07-l3','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền (quá khứ, phủ định): \"I ___ swim when I was four.\"","acceptedAnswers":["couldn''t","could not"],"explanationVi":"couldn''t = quá khứ phủ định của can."}'::jsonb),
 ('a2-u07-l3-q3','a2-u07-l3','multiple_choice',9,'quiz','medium',true,'{"question":"\"Yesterday I ___ finish my homework.\" (đã có thể, quá khứ)","options":[{"id":"a","text":"can"},{"id":"b","text":"was able to"},{"id":"c","text":"am able to"}],"correctOptionId":"b","explanationVi":"Quá khứ → was able to."}'::jsonb),
 ('a2-u07-l3-q4','a2-u07-l3','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"swim","right":"bơi"},{"left":"could","right":"có thể (quá khứ)"},{"left":"can''t","right":"không thể"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l3-q5','a2-u07-l3','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["can","She","French","speak"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: She can speak French."}'::jsonb),
 ('a2-u07-l3-q6','a2-u07-l3','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu quá khứ đúng:","tokens":["couldn''t","I","a bike","ride"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: I couldn''t ride a bike."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u07-l4','A2','reading','a2-u07','normal',4,'At the doctor''s','Đọc hiểu: đi khám bệnh',10,15,70,'{}'::jsonb,
  '{"warmup":"Khi bị ốm và đi khám, bác sĩ thường hỏi bạn điều gì?",
    "objectives":["Đọc hiểu đoạn hội thoại khám bệnh ~110 từ","Học từ vựng cơ thể và sức khỏe (headache, fever, cough...)","Hiểu lời khuyên của bác sĩ với should"],
    "grammarHtml":"<b>Đoạn đọc:</b> <i>Tom doesn''t feel well today. He goes to see the doctor. \"What''s the matter?\" asks the doctor. Tom says, \"I have a bad headache and a high fever. I also have a cough and a sore throat. I feel very tired and I can''t sleep.\" The doctor checks him and says, \"You have a cold. You should stay at home and rest. You should drink a lot of water and take this medicine twice a day. You mustn''t go to work for three days. You shouldn''t eat cold food. If you don''t feel better in a week, you have to come back.\" Tom says, \"Thank you, doctor.\"</i>",
    "vocabBlock":[
      {"word":"headache","ipa":"/ˈhedeɪk/","meaningVi":"đau đầu","example":"I have a headache."},
      {"word":"fever","ipa":"/ˈfiːvə/","meaningVi":"sốt","example":"She has a high fever."},
      {"word":"cough","ipa":"/kɒf/","meaningVi":"ho","example":"He has a bad cough."},
      {"word":"sore throat","ipa":"/sɔː θrəʊt/","meaningVi":"đau họng","example":"I have a sore throat."},
      {"word":"tired","ipa":"/ˈtaɪəd/","meaningVi":"mệt","example":"I feel very tired."},
      {"word":"medicine","ipa":"/ˈmedsn/","meaningVi":"thuốc","example":"Take this medicine twice a day."}],
    "examples":[
      {"en":"What''s the matter?","vi":"Bạn bị làm sao vậy?"},
      {"en":"You have a cold.","vi":"Bạn bị cảm lạnh."},
      {"en":"You should stay at home and rest.","vi":"Bạn nên ở nhà và nghỉ ngơi."}],
    "commonMistakes":["have a headache (có a), KHÔNG nói \"have headache\".","\"What''s the matter?\" = bạn bị sao? — câu hỏi thông dụng khi ai đó ốm."],
    "tips":["Đọc lướt lấy ý chính trước, rồi đọc kỹ tìm chi tiết.","Để ý các lời khuyên dùng should/shouldn''t/mustn''t/have to trong đoạn."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u07-l4-p1','a2-u07-l4','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ sức khỏe với nghĩa tiếng Việt:","pairs":[{"left":"headache","right":"đau đầu"},{"left":"fever","right":"sốt"},{"left":"cough","right":"ho"},{"left":"sore throat","right":"đau họng"}],"explanationVi":"Từ vựng triệu chứng cơ bản."}'::jsonb),
 ('a2-u07-l4-p2','a2-u07-l4','multiple_choice',2,'practice','easy',false,'{"question":"Theo đoạn đọc, Tom đến gặp ai?","options":[{"id":"a","text":"the teacher"},{"id":"b","text":"the doctor"},{"id":"c","text":"his friend"}],"correctOptionId":"b","explanationVi":"He goes to see the doctor."}'::jsonb),
 ('a2-u07-l4-p3','a2-u07-l4','multiple_choice',3,'practice','medium',false,'{"question":"Tom KHÔNG có triệu chứng nào sau đây?","options":[{"id":"a","text":"a headache"},{"id":"b","text":"a fever"},{"id":"c","text":"a stomachache"}],"correctOptionId":"c","explanationVi":"Đoạn văn không nhắc đến đau bụng (stomachache)."}'::jsonb),
 ('a2-u07-l4-p4','a2-u07-l4','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền theo đoạn: \"You should drink a lot of ___.\"","acceptedAnswers":["water"],"explanationVi":"You should drink a lot of water."}'::jsonb),
 ('a2-u07-l4-p5','a2-u07-l4','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi bị đau đầu.","acceptedAnswers":["I have a headache.","I have a headache"],"explanationVi":"have a headache = bị đau đầu."}'::jsonb),
 ('a2-u07-l4-p6','a2-u07-l4','multiple_choice',6,'practice','medium',false,'{"question":"Bác sĩ nói Tom bị bệnh gì?","options":[{"id":"a","text":"a cold"},{"id":"b","text":"the flu"},{"id":"c","text":"a broken leg"}],"correctOptionId":"a","explanationVi":"\"You have a cold.\""}'::jsonb),
 ('a2-u07-l4-q1','a2-u07-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Theo đoạn đọc, Tom cảm thấy thế nào?","options":[{"id":"a","text":"happy and strong"},{"id":"b","text":"very tired"},{"id":"c","text":"hungry"}],"correctOptionId":"b","explanationVi":"\"I feel very tired and I can''t sleep.\""}'::jsonb),
 ('a2-u07-l4-q2','a2-u07-l4','multiple_choice',8,'quiz','medium',true,'{"question":"Bác sĩ khuyên Tom KHÔNG nên làm gì?","options":[{"id":"a","text":"rest at home"},{"id":"b","text":"eat cold food"},{"id":"c","text":"drink water"}],"correctOptionId":"b","explanationVi":"\"You shouldn''t eat cold food.\""}'::jsonb),
 ('a2-u07-l4-q3','a2-u07-l4','multiple_choice',9,'quiz','medium',true,'{"question":"Tom phải uống thuốc bao nhiêu lần một ngày?","options":[{"id":"a","text":"once a day"},{"id":"b","text":"twice a day"},{"id":"c","text":"three times a day"}],"correctOptionId":"b","explanationVi":"\"take this medicine twice a day.\""}'::jsonb),
 ('a2-u07-l4-q4','a2-u07-l4','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"tired","right":"mệt"},{"left":"medicine","right":"thuốc"},{"left":"fever","right":"sốt"},{"left":"cough","right":"ho"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l4-q5','a2-u07-l4','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền theo đoạn (cấm đi làm): \"You ___ go to work for three days.\"","acceptedAnswers":["mustn''t","must not"],"explanationVi":"\"You mustn''t go to work for three days.\""}'::jsonb),
 ('a2-u07-l4-q6','a2-u07-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi của bác sĩ:","tokens":["the","What''s","matter"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: What''s the matter?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u07-l5','A2','reading','a2-u07','unit_review',5,'Unit 7 Review','Ôn tập Quy tắc & Lời khuyên',9,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại should + have to/must + can/could/be able to + từ sức khỏe","objectives":["Tổng hợp can-do Unit 7","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u07-l5-q1','a2-u07-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn câu khuyên đúng:","options":[{"id":"a","text":"You should to rest."},{"id":"b","text":"You should rest."},{"id":"c","text":"You should resting."}],"correctOptionId":"b","explanationVi":"should + V nguyên thể."}'::jsonb),
 ('a2-u07-l5-q2','a2-u07-l5','grammar_fill_blank',2,'quiz','medium',true,'{"question":"Điền has to / have to: \"He ___ wear a uniform.\"","acceptedAnswers":["has to"],"explanationVi":"He dùng has to."}'::jsonb),
 ('a2-u07-l5-q3','a2-u07-l5','multiple_choice',3,'quiz','medium',true,'{"question":"Câu nào diễn tả \"cấm\"?","options":[{"id":"a","text":"You don''t have to smoke."},{"id":"b","text":"You mustn''t smoke."},{"id":"c","text":"You should smoke."}],"correctOptionId":"b","explanationVi":"mustn''t = cấm."}'::jsonb),
 ('a2-u07-l5-q4','a2-u07-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền quá khứ của can: \"When I was six, I ___ swim.\"","acceptedAnswers":["could"],"explanationVi":"could = quá khứ của can."}'::jsonb),
 ('a2-u07-l5-q5','a2-u07-l5','vocabulary_match',5,'quiz','medium',true,'{"question":"Nối từ sức khỏe với nghĩa tiếng Việt:","pairs":[{"left":"headache","right":"đau đầu"},{"left":"fever","right":"sốt"},{"left":"cough","right":"ho"},{"left":"tired","right":"mệt"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u07-l5-q6','a2-u07-l5','multiple_choice',6,'quiz','medium',true,'{"question":"\"It''s free. You ___ pay.\" (không bắt buộc)","options":[{"id":"a","text":"mustn''t"},{"id":"b","text":"don''t have to"},{"id":"c","text":"have to"}],"correctOptionId":"b","explanationVi":"don''t have to = không bắt buộc."}'::jsonb),
 ('a2-u07-l5-q7','a2-u07-l5','sentence_ordering',7,'quiz','hard',true,'{"question":"Sắp xếp thành câu khuyên đúng:","tokens":["should","You","a","see","doctor"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: You should see a doctor."}'::jsonb),
 ('a2-u07-l5-q8','a2-u07-l5','multiple_choice',8,'quiz','medium',true,'{"question":"Chọn dạng đúng: \"She ___ speak French.\" (có khả năng, hiện tại)","options":[{"id":"a","text":"is able to"},{"id":"b","text":"are able to"},{"id":"c","text":"be able to"}],"correctOptionId":"a","explanationVi":"she → is able to."}'::jsonb),
 ('a2-u07-l5-q9','a2-u07-l5','grammar_fill_blank',9,'quiz','medium',true,'{"question":"Điền (không nên): \"You ___ eat too much sugar.\"","acceptedAnswers":["shouldn''t","should not"],"explanationVi":"shouldn''t = không nên."}'::jsonb),
 ('a2-u07-l5-q10','a2-u07-l5','sentence_ordering',10,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["must","You","at","stop","a red light"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: You must stop at a red light."}'::jsonb);

-- ── UNIT 08 — If & When / Nếu & Khi ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
('a2-u08-l1', 'A2', 'reading', 'a2-u08', 'normal', 1, 'Zero conditional', 'If + hiện tại, hiện tại — nói sự thật, quy luật', 9, 15, 70, '{}'::jsonb, '{"warmup":"Bạn đã biết cách nói về sự thật hiển nhiên chưa? Khi đun nóng nước đá, nó tan ra — đó là quy luật. Hôm nay ta học cách diễn đạt điều đó bằng câu điều kiện loại 0.","objectives":["Hiểu cấu trúc If + hiện tại đơn, hiện tại đơn","Dùng câu điều kiện loại 0 để nói sự thật/quy luật khoa học","Phân biệt khi nào dùng if và when với nghĩa tương tự"],"grammarHtml":"<p><b>Câu điều kiện loại 0 (Zero conditional)</b> diễn tả sự thật chung, quy luật tự nhiên — điều luôn đúng.</p><p>Cấu trúc: <b>If + S + V(hiện tại đơn), S + V(hiện tại đơn)</b>.</p><ul><li>If you heat ice, it melts. (Nếu bạn đun nóng đá, nó tan.)</li><li>Plants die if they don''t get water.</li></ul><p>Có thể đảo vế: <i>If</i> đứng đầu thì có dấu phẩy; <i>If</i> đứng giữa thì không cần phẩy.</p><p>Với nghĩa quy luật, có thể thay <b>if</b> bằng <b>when</b>: <i>When you heat ice, it melts.</i></p>","vocabBlock":[{"word":"heat","ipa":"/hiːt/","meaningVi":"đun nóng, làm nóng","example":"If you heat water to 100 degrees, it boils."},{"word":"melt","ipa":"/melt/","meaningVi":"tan chảy","example":"Ice melts when the temperature rises."},{"word":"boil","ipa":"/bɔɪl/","meaningVi":"sôi","example":"Water boils at 100 degrees Celsius."},{"word":"freeze","ipa":"/friːz/","meaningVi":"đóng băng","example":"Water freezes if it gets very cold."},{"word":"mix","ipa":"/mɪks/","meaningVi":"trộn, pha","example":"If you mix blue and yellow, you get green."}],"examples":[{"en":"If you heat ice, it melts.","vi":"Nếu bạn đun nóng đá, nó tan ra."},{"en":"Plants grow well if they get enough sunlight.","vi":"Cây phát triển tốt nếu chúng có đủ ánh nắng."},{"en":"When it rains, the streets get wet.","vi":"Khi trời mưa, đường phố bị ướt."}],"commonMistakes":["Dùng will ở vế chính (sai: If you heat ice, it will melt cho nghĩa quy luật) — loại 0 dùng hiện tại đơn cả hai vế.","Quên dấu phẩy khi If đứng đầu câu."],"tips":["Loại 0 = sự thật luôn đúng; nếu nói về kết quả tương lai cụ thể thì dùng loại 1.","If và when có thể thay nhau khi diễn tả quy luật."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
('a2-u08-l1-p1', 'a2-u08-l1', 'grammar_fill_blank', 1, 'practice', 'easy', false, '{"question":"If you heat ice, it ___ (melt).","acceptedAnswers":["melts"],"explanationVi":"Câu điều kiện loại 0: vế chính dùng hiện tại đơn, chủ ngữ it nên thêm s -> melts."}'::jsonb),
('a2-u08-l1-p2', 'a2-u08-l1', 'grammar_fill_blank', 2, 'practice', 'easy', false, '{"question":"Water ___ (boil) if you heat it to 100 degrees.","acceptedAnswers":["boils"],"explanationVi":"Sự thật khoa học, hiện tại đơn. Water (số ít) -> boils."}'::jsonb),
('a2-u08-l1-p3', 'a2-u08-l1', 'multiple_choice', 3, 'practice', 'medium', false, '{"question":"Chọn câu điều kiện loại 0 đúng (nói quy luật):","options":[{"id":"a","text":"If you mix blue and yellow, you get green."},{"id":"b","text":"If you will mix blue and yellow, you get green."},{"id":"c","text":"If you mixed blue and yellow, you get green."}],"correctOptionId":"a","explanationVi":"Loại 0 dùng hiện tại đơn ở cả hai vế: If + present, present."}'::jsonb),
('a2-u08-l1-p4', 'a2-u08-l1', 'translation', 4, 'practice', 'medium', false, '{"question":"Dịch sang tiếng Anh: Nếu trời mưa, đường phố bị ướt.","sourceText":"Nếu trời mưa, đường phố bị ướt.","acceptedAnswers":["If it rains, the streets get wet.","If it rains the streets get wet","When it rains, the streets get wet."],"explanationVi":"Quy luật chung -> loại 0: If/When + hiện tại, hiện tại."}'::jsonb),
('a2-u08-l1-p5', 'a2-u08-l1', 'vocabulary_match', 5, 'practice', 'easy', false, '{"question":"Nối động từ tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"heat","right":"đun nóng"},{"left":"melt","right":"tan chảy"},{"left":"freeze","right":"đóng băng"},{"left":"boil","right":"sôi"}],"explanationVi":"Các động từ chỉ hiện tượng vật lý thường gặp trong câu điều kiện loại 0."}'::jsonb),
('a2-u08-l1-p6', 'a2-u08-l1', 'error_correction', 6, 'practice', 'hard', false, '{"question":"Sửa lỗi: If you heat ice, it will melt. (nói quy luật chung)","sourceText":"If you heat ice, it will melt.","acceptedAnswers":["If you heat ice, it melts.","If you heat ice it melts"],"explanationVi":"Quy luật chung dùng loại 0, vế chính là hiện tại đơn (melts), không dùng will."}'::jsonb),
('a2-u08-l1-q1', 'a2-u08-l1', 'grammar_fill_blank', 7, 'quiz', 'easy', true, '{"question":"If you mix blue and yellow, you ___ (get) green.","acceptedAnswers":["get"],"explanationVi":"Loại 0, chủ ngữ you -> get (không thêm s)."}'::jsonb),
('a2-u08-l1-q2', 'a2-u08-l1', 'grammar_fill_blank', 8, 'quiz', 'medium', true, '{"question":"Ice ___ (melt) if the temperature rises.","acceptedAnswers":["melts"],"explanationVi":"Vế chính hiện tại đơn, Ice (số ít) -> melts."}'::jsonb),
('a2-u08-l1-q3', 'a2-u08-l1', 'multiple_choice', 9, 'quiz', 'medium', true, '{"question":"Câu nào diễn tả sự thật khoa học đúng nhất?","options":[{"id":"a","text":"Water freezes if it gets very cold."},{"id":"b","text":"Water will freeze if it gets very cold."},{"id":"c","text":"Water froze if it gets very cold."}],"correctOptionId":"a","explanationVi":"Sự thật chung -> loại 0, cả hai vế hiện tại đơn."}'::jsonb),
('a2-u08-l1-q4', 'a2-u08-l1', 'sentence_ordering', 10, 'quiz', 'medium', true, '{"question":"Sắp xếp thành câu điều kiện loại 0 đúng:","tokens":["If","you","heat","water","it","boils"],"correctOrder":[0,1,2,3,4,5],"explanationVi":"If + you heat water, it boils — quy luật, hiện tại đơn cả hai vế."}'::jsonb),
('a2-u08-l1-q5', 'a2-u08-l1', 'multiple_choice', 11, 'quiz', 'easy', true, '{"question":"Chọn từ đúng: Plants die ___ they don''t get water.","options":[{"id":"a","text":"if"},{"id":"b","text":"will"},{"id":"c","text":"to"}],"correctOptionId":"a","explanationVi":"Liên từ điều kiện if (hoặc when) nối hai vế quy luật."}'::jsonb),
('a2-u08-l1-q6', 'a2-u08-l1', 'grammar_fill_blank', 12, 'quiz', 'hard', true, '{"question":"When it ___ (rain), the streets get wet.","acceptedAnswers":["rains"],"explanationVi":"When dùng cho quy luật giống if; it -> rains."}'::jsonb);
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
('a2-u08-l2', 'A2', 'reading', 'a2-u08', 'normal', 2, 'First conditional', 'If + hiện tại, will + V — khả năng tương lai có thật', 9, 15, 70, '{}'::jsonb, '{"warmup":"Nếu trời mưa, mình sẽ ở nhà. Đây là khả năng tương lai có thật — ta dùng câu điều kiện loại 1 để nói về nó.","objectives":["Hiểu cấu trúc If + hiện tại đơn, will + V nguyên thể","Dùng loại 1 để nói khả năng/kết quả tương lai có thật","Phân biệt loại 0 (quy luật) và loại 1 (tương lai cụ thể)"],"grammarHtml":"<p><b>Câu điều kiện loại 1 (First conditional)</b> nói về điều có khả năng xảy ra trong tương lai.</p><p>Cấu trúc: <b>If + S + V(hiện tại đơn), S + will + V(nguyên thể)</b>.</p><ul><li>If it rains, I will stay at home. (Nếu trời mưa, tôi sẽ ở nhà.)</li><li>If you study hard, you will pass the exam.</li></ul><p>Vế <i>if</i> KHÔNG dùng <b>will</b>; chỉ vế chính mới dùng <b>will</b>. Có thể rút gọn: <b>I''ll, you''ll, she''ll...</b></p>","vocabBlock":[{"word":"pass","ipa":"/pɑːs/","meaningVi":"đỗ, vượt qua (kỳ thi)","example":"If you study hard, you will pass."},{"word":"miss","ipa":"/mɪs/","meaningVi":"lỡ, bỏ lỡ","example":"If you don''t hurry, you will miss the bus."},{"word":"hurry","ipa":"/ˈhʌri/","meaningVi":"vội vàng, nhanh lên","example":"Hurry up or we will be late."},{"word":"forget","ipa":"/fəˈɡet/","meaningVi":"quên","example":"If you forget your key, you can call me."},{"word":"win","ipa":"/wɪn/","meaningVi":"thắng, giành","example":"If our team plays well, we will win."}],"examples":[{"en":"If it rains, I will stay at home.","vi":"Nếu trời mưa, tôi sẽ ở nhà."},{"en":"If you don''t hurry, you will miss the bus.","vi":"Nếu bạn không nhanh lên, bạn sẽ lỡ xe buýt."},{"en":"She will be happy if you call her.","vi":"Cô ấy sẽ vui nếu bạn gọi cho cô ấy."}],"commonMistakes":["Dùng will ở vế if (sai: If it will rain, I will stay home). Vế if luôn dùng hiện tại đơn.","Nhầm loại 1 với loại 0: loại 1 nói tương lai cụ thể, có will."],"tips":["Vế if = hiện tại đơn; vế chính = will + V.","Có thể đảo vế: I will stay home if it rains."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
('a2-u08-l2-p1', 'a2-u08-l2', 'grammar_fill_blank', 1, 'practice', 'easy', false, '{"question":"If it rains, I ___ (stay) at home. (dùng will)","acceptedAnswers":["will stay","''ll stay"],"explanationVi":"Loại 1: vế chính dùng will + V nguyên thể -> will stay."}'::jsonb),
('a2-u08-l2-p2', 'a2-u08-l2', 'grammar_fill_blank', 2, 'practice', 'easy', false, '{"question":"If you study hard, you ___ (pass) the exam.","acceptedAnswers":["will pass","''ll pass"],"explanationVi":"Vế chính loại 1 dùng will + pass."}'::jsonb),
('a2-u08-l2-p3', 'a2-u08-l2', 'multiple_choice', 3, 'practice', 'medium', false, '{"question":"Chọn câu điều kiện loại 1 đúng:","options":[{"id":"a","text":"If you don''t hurry, you will miss the bus."},{"id":"b","text":"If you will not hurry, you miss the bus."},{"id":"c","text":"If you don''t hurry, you miss the bus."}],"correctOptionId":"a","explanationVi":"Vế if dùng hiện tại đơn, vế chính dùng will + V."}'::jsonb),
('a2-u08-l2-p4', 'a2-u08-l2', 'translation', 4, 'practice', 'medium', false, '{"question":"Dịch sang tiếng Anh: Nếu bạn gọi cô ấy, cô ấy sẽ vui.","sourceText":"Nếu bạn gọi cô ấy, cô ấy sẽ vui.","acceptedAnswers":["If you call her, she will be happy.","If you call her she''ll be happy","If you call her, she''ll be happy."],"explanationVi":"Loại 1: If + hiện tại đơn (call), vế chính will be happy."}'::jsonb),
('a2-u08-l2-p5', 'a2-u08-l2', 'vocabulary_match', 5, 'practice', 'easy', false, '{"question":"Nối từ tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"pass","right":"đỗ (kỳ thi)"},{"left":"miss","right":"lỡ, bỏ lỡ"},{"left":"hurry","right":"vội vàng"},{"left":"win","right":"thắng"}],"explanationVi":"Từ vựng thường gặp trong câu điều kiện loại 1."}'::jsonb),
('a2-u08-l2-p6', 'a2-u08-l2', 'error_correction', 6, 'practice', 'hard', false, '{"question":"Sửa lỗi: If it will rain, I will stay home.","sourceText":"If it will rain, I will stay home.","acceptedAnswers":["If it rains, I will stay home.","If it rains I will stay home","If it rains, I''ll stay home."],"explanationVi":"Vế if không dùng will; phải là hiện tại đơn: If it rains."}'::jsonb),
('a2-u08-l2-q1', 'a2-u08-l2', 'grammar_fill_blank', 7, 'quiz', 'easy', true, '{"question":"If you don''t hurry, you ___ (miss) the bus.","acceptedAnswers":["will miss","''ll miss"],"explanationVi":"Vế chính loại 1 dùng will + miss."}'::jsonb),
('a2-u08-l2-q2', 'a2-u08-l2', 'grammar_fill_blank', 8, 'quiz', 'medium', true, '{"question":"If our team ___ (play) well, we will win.","acceptedAnswers":["plays"],"explanationVi":"Vế if dùng hiện tại đơn; our team (số ít) -> plays."}'::jsonb),
('a2-u08-l2-q3', 'a2-u08-l2', 'multiple_choice', 9, 'quiz', 'medium', true, '{"question":"Chọn câu loại 1 đúng ngữ pháp:","options":[{"id":"a","text":"If you study hard, you will pass."},{"id":"b","text":"If you will study hard, you pass."},{"id":"c","text":"If you studied hard, you will pass."}],"correctOptionId":"a","explanationVi":"If + hiện tại đơn, vế chính will + V."}'::jsonb),
('a2-u08-l2-q4', 'a2-u08-l2', 'sentence_ordering', 10, 'quiz', 'medium', true, '{"question":"Sắp xếp thành câu điều kiện loại 1 đúng:","tokens":["If","it","rains","I","will","stay","home"],"correctOrder":[0,1,2,3,4,5,6],"explanationVi":"If it rains, I will stay home — vế if hiện tại, vế chính will."}'::jsonb),
('a2-u08-l2-q5', 'a2-u08-l2', 'multiple_choice', 11, 'quiz', 'easy', true, '{"question":"Chọn dạng đúng: If you call her, she ___ happy.","options":[{"id":"a","text":"will be"},{"id":"b","text":"is being"},{"id":"c","text":"be"}],"correctOptionId":"a","explanationVi":"Vế chính loại 1: will + be -> will be."}'::jsonb),
('a2-u08-l2-q6', 'a2-u08-l2', 'grammar_fill_blank', 12, 'quiz', 'hard', true, '{"question":"If you ___ (forget) your key, you can call me.","acceptedAnswers":["forget"],"explanationVi":"Vế if dùng hiện tại đơn; chủ ngữ you -> forget (không thêm s)."}'::jsonb);
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
('a2-u08-l3', 'A2', 'reading', 'a2-u08', 'normal', 3, 'might / may / could', 'Diễn tả khả năng không chắc chắn', 9, 15, 70, '{}'::jsonb, '{"warmup":"Trời có thể mưa chiều nay — nhưng cũng có thể không. Khi không chắc chắn, ta dùng might, may, hoặc could.","objectives":["Hiểu cách dùng might/may/could + V nguyên thể để nói khả năng không chắc","Phân biệt mức độ chắc chắn với will (chắc) và might/may (có thể)","Tạo câu phỏng đoán về thời tiết và sự kiện tương lai"],"grammarHtml":"<p><b>might / may / could</b> + V (nguyên thể) diễn tả <b>khả năng không chắc chắn</b> — có thể xảy ra, nhưng không chắc.</p><ul><li>It might rain this afternoon. (Trời có thể mưa chiều nay.)</li><li>She may be late. (Cô ấy có thể đến muộn.)</li><li>We could go to the beach. (Chúng ta có thể đi biển.)</li></ul><p>Sau might/may/could luôn là <b>động từ nguyên thể không to</b>. Dạng phủ định: <b>might not / may not</b>.</p><p>So sánh: <i>will</i> = chắc chắn; <i>might/may/could</i> = có thể, không chắc.</p>","vocabBlock":[{"word":"might","ipa":"/maɪt/","meaningVi":"có thể (không chắc)","example":"It might rain later."},{"word":"may","ipa":"/meɪ/","meaningVi":"có thể","example":"She may come tonight."},{"word":"could","ipa":"/kʊd/","meaningVi":"có thể, có lẽ","example":"We could visit the museum."},{"word":"probably","ipa":"/ˈprɒbəbli/","meaningVi":"có lẽ, có khả năng","example":"It will probably be sunny."},{"word":"perhaps","ipa":"/pəˈhæps/","meaningVi":"có lẽ","example":"Perhaps they will join us."}],"examples":[{"en":"It might rain this afternoon.","vi":"Trời có thể mưa chiều nay."},{"en":"She may be late for the meeting.","vi":"Cô ấy có thể đến muộn cuộc họp."},{"en":"We could go to the beach if it is sunny.","vi":"Chúng ta có thể đi biển nếu trời nắng."}],"commonMistakes":["Thêm to sau might/may/could (sai: It might to rain). Phải dùng V nguyên thể không to.","Chia động từ sau might/may/could (sai: She may comes). Luôn dùng nguyên thể."],"tips":["might, may, could đều chỉ khả năng — gần như thay nhau được trong văn nói.","Phủ định: might not / may not (không rút gọn mayn''t trong văn viết hiện đại)."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
('a2-u08-l3-p1', 'a2-u08-l3', 'multiple_choice', 1, 'practice', 'easy', false, '{"question":"Chọn câu đúng diễn tả khả năng không chắc:","options":[{"id":"a","text":"It might rain this afternoon."},{"id":"b","text":"It might to rain this afternoon."},{"id":"c","text":"It might rains this afternoon."}],"correctOptionId":"a","explanationVi":"Sau might dùng V nguyên thể không to: might rain."}'::jsonb),
('a2-u08-l3-p2', 'a2-u08-l3', 'grammar_fill_blank', 2, 'practice', 'easy', false, '{"question":"She may ___ (be) late for the meeting.","acceptedAnswers":["be"],"explanationVi":"Sau may dùng động từ nguyên thể không to -> be."}'::jsonb),
('a2-u08-l3-p3', 'a2-u08-l3', 'multiple_choice', 3, 'practice', 'medium', false, '{"question":"Câu nào diễn tả KHÔNG chắc chắn?","options":[{"id":"a","text":"We could go to the beach."},{"id":"b","text":"We will definitely go to the beach."},{"id":"c","text":"We always go to the beach."}],"correctOptionId":"a","explanationVi":"could chỉ khả năng không chắc; will definitely là chắc chắn."}'::jsonb),
('a2-u08-l3-p4', 'a2-u08-l3', 'translation', 4, 'practice', 'medium', false, '{"question":"Dịch sang tiếng Anh: Cô ấy có thể đến tối nay.","sourceText":"Cô ấy có thể đến tối nay.","acceptedAnswers":["She may come tonight.","She might come tonight.","She could come tonight."],"explanationVi":"Khả năng không chắc -> may/might/could + come (nguyên thể)."}'::jsonb),
('a2-u08-l3-p5', 'a2-u08-l3', 'vocabulary_match', 5, 'practice', 'easy', false, '{"question":"Nối từ tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"might","right":"có thể (không chắc)"},{"left":"perhaps","right":"có lẽ"},{"left":"probably","right":"có khả năng"},{"left":"could","right":"có thể, có lẽ"}],"explanationVi":"Các từ diễn tả mức độ chắc chắn khác nhau."}'::jsonb),
('a2-u08-l3-p6', 'a2-u08-l3', 'error_correction', 6, 'practice', 'hard', false, '{"question":"Sửa lỗi: She may comes tonight.","sourceText":"She may comes tonight.","acceptedAnswers":["She may come tonight.","She may come tonight"],"explanationVi":"Sau may dùng động từ nguyên thể không chia -> come, không comes."}'::jsonb),
('a2-u08-l3-q1', 'a2-u08-l3', 'multiple_choice', 7, 'quiz', 'easy', true, '{"question":"Chọn dạng đúng: It ___ rain later, take an umbrella.","options":[{"id":"a","text":"might"},{"id":"b","text":"might to"},{"id":"c","text":"mights"}],"correctOptionId":"a","explanationVi":"might + V nguyên thể không to: might rain."}'::jsonb),
('a2-u08-l3-q2', 'a2-u08-l3', 'grammar_fill_blank', 8, 'quiz', 'medium', true, '{"question":"We could ___ (visit) the museum tomorrow.","acceptedAnswers":["visit"],"explanationVi":"Sau could dùng động từ nguyên thể không to -> visit."}'::jsonb),
('a2-u08-l3-q3', 'a2-u08-l3', 'multiple_choice', 9, 'quiz', 'medium', true, '{"question":"Câu nào dùng might/may/could ĐÚNG?","options":[{"id":"a","text":"They may join us later."},{"id":"b","text":"They may joins us later."},{"id":"c","text":"They may to join us later."}],"correctOptionId":"a","explanationVi":"may + nguyên thể không to, không chia -> may join."}'::jsonb),
('a2-u08-l3-q4', 'a2-u08-l3', 'sentence_ordering', 10, 'quiz', 'medium', true, '{"question":"Sắp xếp thành câu đúng:","tokens":["It","might","rain","this","afternoon"],"correctOrder":[0,1,2,3,4],"explanationVi":"It might rain this afternoon — might + V nguyên thể."}'::jsonb),
('a2-u08-l3-q5', 'a2-u08-l3', 'multiple_choice', 11, 'quiz', 'easy', true, '{"question":"Từ nào KHÔNG diễn tả khả năng không chắc?","options":[{"id":"a","text":"definitely"},{"id":"b","text":"might"},{"id":"c","text":"perhaps"}],"correctOptionId":"a","explanationVi":"definitely = chắc chắn; might và perhaps chỉ khả năng không chắc."}'::jsonb),
('a2-u08-l3-q6', 'a2-u08-l3', 'grammar_fill_blank', 12, 'quiz', 'hard', true, '{"question":"Điền might/may: She ___ not come because she is busy.","acceptedAnswers":["might","may"],"explanationVi":"Phủ định khả năng dùng might not / may not."}'::jsonb);
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
('a2-u08-l4', 'A2', 'listening', 'a2-u08', 'normal', 4, 'Weather forecast', 'Nghe dự báo thời tiết và từ vựng thời tiết', 9, 15, 70, '{}'::jsonb, '{"warmup":"Hãy nghe bản tin dự báo thời tiết: nắng, mưa, nhiều mây, có gió... Bạn cần nhận ra các từ chỉ thời tiết để hiểu dự báo.","objectives":["Nghe và nhận ra từ vựng thời tiết trong dự báo","Hiểu câu dự báo dùng will và might/may","Nối từ thời tiết tiếng Anh với nghĩa tiếng Việt"],"vocabBlock":[{"word":"sunny","ipa":"/ˈsʌni/","meaningVi":"nắng","example":"It will be sunny tomorrow."},{"word":"rainy","ipa":"/ˈreɪni/","meaningVi":"mưa, có mưa","example":"It is rainy in the north."},{"word":"cloudy","ipa":"/ˈklaʊdi/","meaningVi":"nhiều mây","example":"The sky is cloudy today."},{"word":"windy","ipa":"/ˈwɪndi/","meaningVi":"có gió, nhiều gió","example":"It will be windy on the coast."},{"word":"snow","ipa":"/snəʊ/","meaningVi":"tuyết, có tuyết","example":"It might snow in the mountains."},{"word":"forecast","ipa":"/ˈfɔːkɑːst/","meaningVi":"dự báo","example":"Here is the weather forecast for tomorrow."}],"examples":[{"en":"Tomorrow will be sunny in the south.","vi":"Ngày mai trời sẽ nắng ở miền nam."},{"en":"It might snow in the mountains tonight.","vi":"Đêm nay có thể có tuyết trên núi."},{"en":"The weather will be cloudy and windy.","vi":"Thời tiết sẽ nhiều mây và có gió."}],"commonMistakes":["Nhầm sunny (nắng) với rainy (mưa) khi nghe nhanh.","Bỏ qua might/may trong dự báo (chỉ khả năng, không chắc)."],"tips":["Nghe các từ khóa: sunny, rainy, cloudy, windy, snow.","Dự báo thường dùng will (chắc) hoặc might/may (có thể)."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
('a2-u08-l4-p1', 'a2-u08-l4', 'listening_choice', 1, 'practice', 'easy', false, '{"question":"Nghe và chọn thời tiết được nhắc đến:","audioText":"Tomorrow will be sunny in the south.","options":[{"id":"a","text":"nắng"},{"id":"b","text":"mưa"},{"id":"c","text":"có tuyết"}],"correctOptionId":"a","explanationVi":"sunny = nắng."}'::jsonb),
('a2-u08-l4-p2', 'a2-u08-l4', 'listening_choice', 2, 'practice', 'easy', false, '{"question":"Nghe và chọn đáp án đúng:","audioText":"It is rainy in the north today.","options":[{"id":"a","text":"Miền bắc có mưa"},{"id":"b","text":"Miền bắc có nắng"},{"id":"c","text":"Miền bắc có tuyết"}],"correctOptionId":"a","explanationVi":"rainy in the north = miền bắc có mưa."}'::jsonb),
('a2-u08-l4-p3', 'a2-u08-l4', 'listening_choice', 3, 'practice', 'medium', false, '{"question":"Nghe và chọn thời tiết đúng:","audioText":"The weather will be cloudy and windy on the coast.","options":[{"id":"a","text":"nhiều mây và có gió"},{"id":"b","text":"nắng và nóng"},{"id":"c","text":"mưa và lạnh"}],"correctOptionId":"a","explanationVi":"cloudy and windy = nhiều mây và có gió."}'::jsonb),
('a2-u08-l4-p4', 'a2-u08-l4', 'listening_choice', 4, 'practice', 'medium', false, '{"question":"Nghe và chọn đáp án đúng:","audioText":"It might snow in the mountains tonight.","options":[{"id":"a","text":"Đêm nay có thể có tuyết trên núi"},{"id":"b","text":"Đêm nay chắc chắn có tuyết trên núi"},{"id":"c","text":"Đêm nay trời nắng trên núi"}],"correctOptionId":"a","explanationVi":"might snow = có thể có tuyết (không chắc)."}'::jsonb),
('a2-u08-l4-p5', 'a2-u08-l4', 'vocabulary_match', 5, 'practice', 'easy', false, '{"question":"Nối từ thời tiết tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"sunny","right":"nắng"},{"left":"rainy","right":"có mưa"},{"left":"cloudy","right":"nhiều mây"},{"left":"windy","right":"có gió"}],"explanationVi":"Từ vựng thời tiết cơ bản trong dự báo."}'::jsonb),
('a2-u08-l4-p6', 'a2-u08-l4', 'listening_choice', 6, 'practice', 'hard', false, '{"question":"Nghe và chọn đáp án đúng:","audioText":"Here is the weather forecast for tomorrow: it will be windy in the morning and sunny in the afternoon.","options":[{"id":"a","text":"Sáng có gió, chiều nắng"},{"id":"b","text":"Sáng nắng, chiều mưa"},{"id":"c","text":"Cả ngày nhiều mây"}],"correctOptionId":"a","explanationVi":"windy in the morning and sunny in the afternoon = sáng có gió, chiều nắng."}'::jsonb),
('a2-u08-l4-q1', 'a2-u08-l4', 'listening_choice', 7, 'quiz', 'easy', true, '{"question":"Nghe và chọn thời tiết đúng:","audioText":"It will be sunny and warm tomorrow.","options":[{"id":"a","text":"nắng và ấm"},{"id":"b","text":"mưa và lạnh"},{"id":"c","text":"nhiều mây"}],"correctOptionId":"a","explanationVi":"sunny and warm = nắng và ấm."}'::jsonb),
('a2-u08-l4-q2', 'a2-u08-l4', 'listening_choice', 8, 'quiz', 'medium', true, '{"question":"Nghe và chọn đáp án đúng:","audioText":"It might rain in the evening, so take an umbrella.","options":[{"id":"a","text":"Buổi tối có thể mưa"},{"id":"b","text":"Buổi tối chắc chắn nắng"},{"id":"c","text":"Buổi tối có tuyết"}],"correctOptionId":"a","explanationVi":"might rain in the evening = buổi tối có thể mưa."}'::jsonb),
('a2-u08-l4-q3', 'a2-u08-l4', 'listening_choice', 9, 'quiz', 'medium', true, '{"question":"Nghe và chọn thời tiết được nhắc đến:","audioText":"The sky is cloudy and it is very windy today.","options":[{"id":"a","text":"nhiều mây và rất nhiều gió"},{"id":"b","text":"nắng và yên tĩnh"},{"id":"c","text":"có tuyết"}],"correctOptionId":"a","explanationVi":"cloudy and very windy = nhiều mây và rất nhiều gió."}'::jsonb),
('a2-u08-l4-q4', 'a2-u08-l4', 'vocabulary_match', 10, 'quiz', 'medium', true, '{"question":"Nối từ thời tiết tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"snow","right":"tuyết"},{"left":"forecast","right":"dự báo"},{"left":"cloudy","right":"nhiều mây"},{"left":"windy","right":"có gió"}],"explanationVi":"Từ vựng thời tiết và dự báo."}'::jsonb),
('a2-u08-l4-q5', 'a2-u08-l4', 'listening_choice', 11, 'quiz', 'easy', true, '{"question":"Nghe và chọn đáp án đúng:","audioText":"It might snow tonight in the north.","options":[{"id":"a","text":"Đêm nay miền bắc có thể có tuyết"},{"id":"b","text":"Đêm nay miền bắc nắng"},{"id":"c","text":"Đêm nay miền bắc có gió"}],"correctOptionId":"a","explanationVi":"might snow tonight in the north = đêm nay miền bắc có thể có tuyết."}'::jsonb),
('a2-u08-l4-q6', 'a2-u08-l4', 'multiple_choice', 12, 'quiz', 'hard', true, '{"question":"Từ nào KHÔNG phải từ chỉ thời tiết?","options":[{"id":"a","text":"forecast"},{"id":"b","text":"sunny"},{"id":"c","text":"rainy"}],"correctOptionId":"a","explanationVi":"forecast = dự báo (không phải kiểu thời tiết); sunny và rainy là từ chỉ thời tiết."}'::jsonb);
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
('a2-u08-l5', 'A2', 'reading', 'a2-u08', 'unit_review', 5, 'Unit 8 Review', 'Ôn tập: câu điều kiện loại 0, loại 1, might/may/could và từ thời tiết', 10, 25, 75, '{}'::jsonb, '{"warmup":"Ôn lại toàn bộ Unit 8: câu điều kiện loại 0, loại 1, might/may/could và từ vựng thời tiết.","objectives":["Tổng hợp can-do Unit 8","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
('a2-u08-l5-q1', 'a2-u08-l5', 'grammar_fill_blank', 1, 'quiz', 'easy', true, '{"question":"If you heat ice, it ___ (melt).","acceptedAnswers":["melts"],"explanationVi":"Loại 0: vế chính hiện tại đơn, it -> melts."}'::jsonb),
('a2-u08-l5-q2', 'a2-u08-l5', 'grammar_fill_blank', 2, 'quiz', 'medium', true, '{"question":"If it rains, I ___ (stay) at home. (dùng will)","acceptedAnswers":["will stay","''ll stay"],"explanationVi":"Loại 1: vế chính will + V -> will stay."}'::jsonb),
('a2-u08-l5-q3', 'a2-u08-l5', 'multiple_choice', 3, 'quiz', 'medium', true, '{"question":"Chọn câu diễn tả khả năng KHÔNG chắc chắn:","options":[{"id":"a","text":"It might rain this afternoon."},{"id":"b","text":"It will definitely rain this afternoon."},{"id":"c","text":"It rains every afternoon."}],"correctOptionId":"a","explanationVi":"might chỉ khả năng không chắc."}'::jsonb),
('a2-u08-l5-q4', 'a2-u08-l5', 'grammar_fill_blank', 4, 'quiz', 'medium', true, '{"question":"She may ___ (be) late for the meeting.","acceptedAnswers":["be"],"explanationVi":"Sau may dùng V nguyên thể không to -> be."}'::jsonb),
('a2-u08-l5-q5', 'a2-u08-l5', 'vocabulary_match', 5, 'quiz', 'easy', true, '{"question":"Nối từ thời tiết tiếng Anh với nghĩa tiếng Việt:","pairs":[{"left":"sunny","right":"nắng"},{"left":"rainy","right":"có mưa"},{"left":"windy","right":"có gió"},{"left":"snow","right":"tuyết"}],"explanationVi":"Từ vựng thời tiết Unit 8."}'::jsonb),
('a2-u08-l5-q6', 'a2-u08-l5', 'sentence_ordering', 6, 'quiz', 'medium', true, '{"question":"Sắp xếp thành câu điều kiện loại 1 đúng:","tokens":["If","you","study","hard","you","will","pass"],"correctOrder":[0,1,2,3,4,5,6],"explanationVi":"If you study hard, you will pass — loại 1."}'::jsonb),
('a2-u08-l5-q7', 'a2-u08-l5', 'listening_choice', 7, 'quiz', 'medium', true, '{"question":"Nghe và chọn đáp án đúng:","audioText":"Tomorrow will be sunny in the south.","options":[{"id":"a","text":"Ngày mai miền nam nắng"},{"id":"b","text":"Ngày mai miền nam mưa"},{"id":"c","text":"Ngày mai miền nam có tuyết"}],"correctOptionId":"a","explanationVi":"sunny in the south = miền nam nắng."}'::jsonb),
('a2-u08-l5-q8', 'a2-u08-l5', 'listening_choice', 8, 'quiz', 'hard', true, '{"question":"Nghe và chọn đáp án đúng:","audioText":"It might snow in the mountains tonight.","options":[{"id":"a","text":"Đêm nay trên núi có thể có tuyết"},{"id":"b","text":"Đêm nay trên núi chắc chắn nắng"},{"id":"c","text":"Đêm nay trên núi có gió"}],"correctOptionId":"a","explanationVi":"might snow = có thể có tuyết."}'::jsonb),
('a2-u08-l5-q9', 'a2-u08-l5', 'multiple_choice', 9, 'quiz', 'medium', true, '{"question":"Chọn câu điều kiện loại 0 đúng:","options":[{"id":"a","text":"Water boils if you heat it to 100 degrees."},{"id":"b","text":"Water will boil if you will heat it."},{"id":"c","text":"Water boiled if you heat it."}],"correctOptionId":"a","explanationVi":"Loại 0: cả hai vế hiện tại đơn."}'::jsonb),
('a2-u08-l5-q10', 'a2-u08-l5', 'grammar_fill_blank', 10, 'quiz', 'hard', true, '{"question":"If you don''t hurry, you ___ (miss) the bus. (dùng will)","acceptedAnswers":["will miss","''ll miss"],"explanationVi":"Loại 1: vế chính will + V -> will miss."}'::jsonb);

-- ── UNIT 09 — Life Experiences / Trải nghiệm cuộc sống ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u09-l1','A2','reading','a2-u09','normal',1,'Present perfect (introduced)','Giới thiệu thì hiện tại hoàn thành',9,15,70,'{}'::jsonb,
  '{"warmup":"Khi muốn nói \"Tôi đã từng làm điều gì đó\" mà không nói rõ thời gian, ta dùng thì gì?",
    "objectives":["Hiểu cấu trúc have/has + V3 (past participle)","Viết câu khẳng định/phủ định/nghi vấn cơ bản với present perfect","Phân biệt sơ bộ present perfect với past simple"],
    "grammarHtml":"Hiện tại hoàn thành: <b>have/has + V3</b>. I/you/we/they + <b>have</b> + V3; he/she/it + <b>has</b> + V3. Phủ định: have/has + <b>not</b> + V3 (haven''t / hasn''t). Câu hỏi: <b>Have/Has</b> + chủ ngữ + V3? Dùng cho trải nghiệm không nói rõ thời gian (I have visited Hue). Past simple dùng khi có mốc thời gian rõ (I visited Hue last year).",
    "vocabBlock":[
      {"word":"visited","ipa":"/ˈvɪzɪtɪd/","meaningVi":"đã thăm (V3 của visit)","example":"I have visited Da Nang."},
      {"word":"seen","ipa":"/siːn/","meaningVi":"đã thấy (V3 của see)","example":"She has seen that film."},
      {"word":"eaten","ipa":"/ˈiːtn/","meaningVi":"đã ăn (V3 của eat)","example":"We have eaten sushi."},
      {"word":"been","ipa":"/biːn/","meaningVi":"đã ở/đã đến (V3 của be)","example":"He has been to Japan."},
      {"word":"done","ipa":"/dʌn/","meaningVi":"đã làm (V3 của do)","example":"I have done my homework."}],
    "examples":[
      {"en":"I have visited Ha Long Bay.","vi":"Tôi đã từng đến vịnh Hạ Long."},
      {"en":"She has eaten Korean food.","vi":"Cô ấy đã từng ăn món Hàn Quốc."},
      {"en":"They have not seen this movie.","vi":"Họ chưa xem bộ phim này."}],
    "commonMistakes":["❌ \"She have seen\" → ✅ \"She has seen\" (he/she/it dùng has).","❌ \"I have visit\" → ✅ \"I have visited\" (phải dùng V3)."],
    "tips":["Nhớ V3 của động từ bất quy tắc: be-been, see-seen, eat-eaten, do-done, go-gone."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u09-l1-p1','a2-u09-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn dạng đúng: \"I ___ visited Da Nang.\"","options":[{"id":"a","text":"have"},{"id":"b","text":"has"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"I đi với have + V3."}'::jsonb),
 ('a2-u09-l1-p2','a2-u09-l1','multiple_choice',2,'practice','easy',false,'{"question":"\"She ___ seen that film.\"","options":[{"id":"a","text":"have"},{"id":"b","text":"has"},{"id":"c","text":"is"}],"correctOptionId":"b","explanationVi":"She (he/she/it) đi với has."}'::jsonb),
 ('a2-u09-l1-p3','a2-u09-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối động từ với dạng V3 (past participle):","pairs":[{"left":"see","right":"seen"},{"left":"eat","right":"eaten"},{"left":"be","right":"been"},{"left":"do","right":"done"}],"explanationVi":"V3 của các động từ bất quy tắc."}'::jsonb),
 ('a2-u09-l1-p4','a2-u09-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền V3 của \"eat\": \"We have ___ sushi.\"","acceptedAnswers":["eaten"],"explanationVi":"eat → eaten."}'::jsonb),
 ('a2-u09-l1-p5','a2-u09-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi đã từng đến Nhật Bản.","acceptedAnswers":["I have been to Japan.","I have been to Japan","I''ve been to Japan.","I''ve been to Japan"],"explanationVi":"Dùng have been to để nói đã đến nơi nào đó."}'::jsonb),
 ('a2-u09-l1-p6','a2-u09-l1','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"She have seen this movie.","acceptedAnswers":["She has seen this movie.","She has seen this movie"],"explanationVi":"She đi với has, không phải have."}'::jsonb),
 ('a2-u09-l1-q1','a2-u09-l1','multiple_choice',7,'quiz','easy',true,'{"question":"\"He ___ been to Korea.\"","options":[{"id":"a","text":"have"},{"id":"b","text":"has"},{"id":"c","text":"is"}],"correctOptionId":"b","explanationVi":"He đi với has."}'::jsonb),
 ('a2-u09-l1-q2','a2-u09-l1','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền V3 của \"do\": \"I have ___ my homework.\"","acceptedAnswers":["done"],"explanationVi":"do → done."}'::jsonb),
 ('a2-u09-l1-q3','a2-u09-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Câu nào ĐÚNG ngữ pháp hiện tại hoàn thành?","options":[{"id":"a","text":"They have visited Hue."},{"id":"b","text":"They has visit Hue."},{"id":"c","text":"They have visit Hue."}],"correctOptionId":"a","explanationVi":"have + V3 (visited)."}'::jsonb),
 ('a2-u09-l1-q4','a2-u09-l1','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền have/has: \"My friends ___ eaten pho.\"","acceptedAnswers":["have"],"explanationVi":"My friends (số nhiều) đi với have."}'::jsonb),
 ('a2-u09-l1-q5','a2-u09-l1','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["has","She","Japan","visited"],"correctOrder":[1,0,3,2],"explanationVi":"Câu đúng: She has visited Japan."}'::jsonb),
 ('a2-u09-l1-q6','a2-u09-l1','multiple_choice',12,'quiz','hard',true,'{"question":"Câu nào dùng PRESENT PERFECT (không nói rõ thời gian)?","options":[{"id":"a","text":"I visited Hue last year."},{"id":"b","text":"I have visited Hue."},{"id":"c","text":"I visit Hue yesterday."}],"correctOptionId":"b","explanationVi":"Present perfect không nêu mốc thời gian cụ thể."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u09-l2','A2','reading','a2-u09','normal',2,'ever / never / just / already / yet','Trạng từ đi với hiện tại hoàn thành',10,15,70,'{}'::jsonb,
  '{"warmup":"\"Have you ever...?\" — bạn hiểu câu hỏi này hỏi điều gì?",
    "objectives":["Hỏi trải nghiệm với Have you ever...?","Dùng never để nói chưa bao giờ","Dùng just/already trong câu khẳng định và yet trong câu phủ định/nghi vấn"],
    "grammarHtml":"<b>ever</b>: dùng trong câu hỏi trải nghiệm — Have you <b>ever</b> + V3? <b>never</b>: chưa bao giờ (mang nghĩa phủ định, không thêm not) — I have <b>never</b> + V3. <b>just</b>: vừa mới — I have <b>just</b> + V3. <b>already</b>: đã rồi (khẳng định) — She has <b>already</b> + V3. <b>yet</b>: chưa (phủ định) / đã...chưa (nghi vấn), đặt cuối câu — I haven''t + V3 + <b>yet</b>; Have you + V3 + <b>yet</b>?",
    "vocabBlock":[
      {"word":"ever","ipa":"/ˈevə(r)/","meaningVi":"đã từng (trong câu hỏi)","example":"Have you ever been abroad?"},
      {"word":"never","ipa":"/ˈnevə(r)/","meaningVi":"chưa bao giờ","example":"I have never tried surfing."},
      {"word":"just","ipa":"/dʒʌst/","meaningVi":"vừa mới","example":"She has just arrived."},
      {"word":"already","ipa":"/ɔːlˈredi/","meaningVi":"đã rồi","example":"We have already eaten."},
      {"word":"yet","ipa":"/jet/","meaningVi":"chưa / đã...chưa","example":"He hasn''t finished yet."}],
    "examples":[
      {"en":"Have you ever been to London?","vi":"Bạn đã từng đến London chưa?"},
      {"en":"I have never eaten snails.","vi":"Tôi chưa bao giờ ăn ốc sên."},
      {"en":"She has just finished her work.","vi":"Cô ấy vừa mới hoàn thành công việc."},
      {"en":"They haven''t arrived yet.","vi":"Họ vẫn chưa đến."}],
    "commonMistakes":["❌ \"I haven''t never...\" → ✅ \"I have never...\" (never đã mang nghĩa phủ định).","❌ \"Have you yet eaten?\" → ✅ \"Have you eaten yet?\" (yet đặt cuối câu)."],
    "tips":["just/already → câu khẳng định; yet → câu phủ định và nghi vấn; ever → câu hỏi."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u09-l2-p1','a2-u09-l2','multiple_choice',1,'practice','easy',false,'{"question":"\"Have you ___ been to London?\" (hỏi trải nghiệm)","options":[{"id":"a","text":"ever"},{"id":"b","text":"never"},{"id":"c","text":"yet"}],"correctOptionId":"a","explanationVi":"ever dùng trong câu hỏi trải nghiệm."}'::jsonb),
 ('a2-u09-l2-p2','a2-u09-l2','multiple_choice',2,'practice','easy',false,'{"question":"\"I have ___ tried surfing.\" (chưa bao giờ)","options":[{"id":"a","text":"ever"},{"id":"b","text":"never"},{"id":"c","text":"yet"}],"correctOptionId":"b","explanationVi":"never = chưa bao giờ."}'::jsonb),
 ('a2-u09-l2-p3','a2-u09-l2','vocabulary_match',3,'practice','easy',false,'{"question":"Nối trạng từ với nghĩa tiếng Việt:","pairs":[{"left":"ever","right":"đã từng (câu hỏi)"},{"left":"never","right":"chưa bao giờ"},{"left":"just","right":"vừa mới"},{"left":"already","right":"đã rồi"},{"left":"yet","right":"chưa"}],"explanationVi":"Nghĩa từng trạng từ."}'::jsonb),
 ('a2-u09-l2-p4','a2-u09-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền trạng từ \"chưa\" vào cuối câu: \"They haven''t arrived ___.\"","acceptedAnswers":["yet"],"explanationVi":"yet đặt cuối câu phủ định."}'::jsonb),
 ('a2-u09-l2-p5','a2-u09-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cô ấy vừa mới hoàn thành công việc.","acceptedAnswers":["She has just finished her work.","She has just finished her work","She''s just finished her work.","She''s just finished her work"],"explanationVi":"have/has + just + V3 = vừa mới làm gì."}'::jsonb),
 ('a2-u09-l2-p6','a2-u09-l2','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"I haven''t never eaten snails.","acceptedAnswers":["I have never eaten snails.","I have never eaten snails"],"explanationVi":"never đã mang nghĩa phủ định, không dùng với haven''t."}'::jsonb),
 ('a2-u09-l2-q1','a2-u09-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu hỏi trải nghiệm ĐÚNG:","options":[{"id":"a","text":"Have you ever eaten sushi?"},{"id":"b","text":"Have you yet eaten sushi?"},{"id":"c","text":"Do you ever eaten sushi?"}],"correctOptionId":"a","explanationVi":"Have you ever + V3?"}'::jsonb),
 ('a2-u09-l2-q2','a2-u09-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền trạng từ \"đã rồi\" (khẳng định): \"We have ___ eaten.\"","acceptedAnswers":["already"],"explanationVi":"already dùng trong câu khẳng định."}'::jsonb),
 ('a2-u09-l2-q3','a2-u09-l2','multiple_choice',9,'quiz','medium',true,'{"question":"\"He hasn''t finished ___.\"","options":[{"id":"a","text":"already"},{"id":"b","text":"just"},{"id":"c","text":"yet"}],"correctOptionId":"c","explanationVi":"Câu phủ định dùng yet ở cuối câu."}'::jsonb),
 ('a2-u09-l2-q4','a2-u09-l2','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền trạng từ \"vừa mới\": \"The train has ___ arrived.\"","acceptedAnswers":["just"],"explanationVi":"just = vừa mới."}'::jsonb),
 ('a2-u09-l2-q5','a2-u09-l2','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["you","Have","been","ever","abroad"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: Have you ever been abroad?"}'::jsonb),
 ('a2-u09-l2-q6','a2-u09-l2','multiple_choice',12,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I have never been to Paris."},{"id":"b","text":"I haven''t never been to Paris."},{"id":"c","text":"I have not never been to Paris."}],"correctOptionId":"a","explanationVi":"never đã phủ định, dùng have never."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u09-l3','A2','reading','a2-u09','normal',3,'Gerund vs to-infinitive','Danh động từ và động từ nguyên mẫu có to',10,15,70,'{}'::jsonb,
  '{"warmup":"\"I like swimming\" hay \"I like to swim\"? — khi nào dùng V-ing, khi nào dùng to + V?",
    "objectives":["Dùng like/love/hate/enjoy + V-ing","Dùng want/need/decide + to-V","Phân biệt động từ theo sau là gerund hay to-infinitive"],
    "grammarHtml":"Một số động từ theo sau là <b>gerund (V-ing)</b>: like, love, hate, enjoy. VD: I love <b>reading</b>. Một số động từ theo sau là <b>to-infinitive (to + V)</b>: want, need, decide, hope, would like. VD: I want <b>to travel</b>. Lưu ý: like/love/hate có thể đi với V-ing hoặc to-V, nhưng ở A2 ta tập trung dùng V-ing.",
    "vocabBlock":[
      {"word":"enjoy","ipa":"/ɪnˈdʒɔɪ/","meaningVi":"thích thú (+ V-ing)","example":"I enjoy cooking."},
      {"word":"decide","ipa":"/dɪˈsaɪd/","meaningVi":"quyết định (+ to-V)","example":"She decided to leave."},
      {"word":"swimming","ipa":"/ˈswɪmɪŋ/","meaningVi":"bơi lội (V-ing)","example":"I like swimming."},
      {"word":"travel","ipa":"/ˈtrævl/","meaningVi":"du lịch","example":"They want to travel."},
      {"word":"hate","ipa":"/heɪt/","meaningVi":"ghét (+ V-ing)","example":"He hates waiting."}],
    "examples":[
      {"en":"I love swimming in the sea.","vi":"Tôi thích bơi ở biển."},
      {"en":"She wants to learn Japanese.","vi":"Cô ấy muốn học tiếng Nhật."},
      {"en":"They decided to buy a new house.","vi":"Họ quyết định mua nhà mới."}],
    "commonMistakes":["❌ \"I want swimming\" → ✅ \"I want to swim\" (want + to-V).","❌ \"I enjoy to cook\" → ✅ \"I enjoy cooking\" (enjoy + V-ing)."],
    "tips":["Nhóm cảm xúc (like/love/hate/enjoy) → V-ing. Nhóm ý định (want/need/decide/hope) → to-V."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u09-l3-p1','a2-u09-l3','multiple_choice',1,'practice','easy',false,'{"question":"\"I enjoy ___.\"","options":[{"id":"a","text":"cooking"},{"id":"b","text":"to cook"},{"id":"c","text":"cook"}],"correctOptionId":"a","explanationVi":"enjoy + V-ing."}'::jsonb),
 ('a2-u09-l3-p2','a2-u09-l3','multiple_choice',2,'practice','easy',false,'{"question":"\"She wants ___ Japanese.\"","options":[{"id":"a","text":"learning"},{"id":"b","text":"to learn"},{"id":"c","text":"learn"}],"correctOptionId":"b","explanationVi":"want + to-V."}'::jsonb),
 ('a2-u09-l3-p3','a2-u09-l3','vocabulary_match',3,'practice','medium',false,'{"question":"Nối động từ với dạng theo sau nó:","pairs":[{"left":"enjoy","right":"+ V-ing"},{"left":"want","right":"+ to-V"},{"left":"decide","right":"+ to-V"},{"left":"hate","right":"+ V-ing"}],"explanationVi":"enjoy/hate + V-ing; want/decide + to-V."}'::jsonb),
 ('a2-u09-l3-p4','a2-u09-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền dạng đúng của \"swim\": \"I love ___ in the sea.\"","acceptedAnswers":["swimming"],"explanationVi":"love + V-ing → swimming."}'::jsonb),
 ('a2-u09-l3-p5','a2-u09-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Họ quyết định mua một ngôi nhà mới.","acceptedAnswers":["They decided to buy a new house.","They decided to buy a new house","They decide to buy a new house.","They decide to buy a new house"],"explanationVi":"decide + to-V."}'::jsonb),
 ('a2-u09-l3-p6','a2-u09-l3','error_correction',6,'practice','hard',false,'{"question":"Câu sau sai — hãy viết lại cho đúng:","sourceText":"I want swimming this weekend.","acceptedAnswers":["I want to swim this weekend.","I want to swim this weekend"],"explanationVi":"want đi với to-V → want to swim."}'::jsonb),
 ('a2-u09-l3-q1','a2-u09-l3','multiple_choice',7,'quiz','easy',true,'{"question":"\"He hates ___.\"","options":[{"id":"a","text":"waiting"},{"id":"b","text":"to waiting"},{"id":"c","text":"waits"}],"correctOptionId":"a","explanationVi":"hate + V-ing → waiting."}'::jsonb),
 ('a2-u09-l3-q2','a2-u09-l3','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền dạng đúng của \"travel\": \"They want ___ to Japan.\"","acceptedAnswers":["to travel"],"explanationVi":"want + to-V → to travel."}'::jsonb),
 ('a2-u09-l3-q3','a2-u09-l3','multiple_choice',9,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I enjoy reading books."},{"id":"b","text":"I enjoy to read books."},{"id":"c","text":"I enjoy read books."}],"correctOptionId":"a","explanationVi":"enjoy + V-ing."}'::jsonb),
 ('a2-u09-l3-q4','a2-u09-l3','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền dạng đúng của \"cook\": \"She enjoys ___ for her family.\"","acceptedAnswers":["cooking"],"explanationVi":"enjoy + V-ing → cooking."}'::jsonb),
 ('a2-u09-l3-q5','a2-u09-l3','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["to","She","learn","decided","English"],"correctOrder":[1,3,0,2,4],"explanationVi":"Câu đúng: She decided to learn English."}'::jsonb),
 ('a2-u09-l3-q6','a2-u09-l3','multiple_choice',12,'quiz','hard',true,'{"question":"Động từ nào theo sau là to-infinitive?","options":[{"id":"a","text":"want"},{"id":"b","text":"enjoy"},{"id":"c","text":"hate"}],"correctOptionId":"a","explanationVi":"want + to-V; enjoy/hate + V-ing."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u09-l4','A2','reading','a2-u09','normal',4,'Have you ever...?','Đọc hiểu về trải nghiệm & sở thích',10,15,70,'{}'::jsonb,
  '{"warmup":"Đọc đoạn văn về sở thích của Linh và xem cô ấy đã thử những hoạt động nào.",
    "objectives":["Đọc hiểu đoạn văn ~120 từ về trải nghiệm","Nhận biết từ vựng thể thao và sở thích","Trả lời câu hỏi đọc hiểu về present perfect"],
    "grammarHtml":"Đoạn văn dùng present perfect (have/has + V3) để kể trải nghiệm và past simple cho sự việc cụ thể. Chú ý các từ ever/never/already khi đọc.<br/><br/><b>Đọc đoạn sau:</b><br/>\"Hi, I am Linh. I love trying new activities. I have played badminton for five years, and I am quite good at it. Last summer, I tried surfing for the first time in Da Nang. It was difficult, but very exciting! I have also been hiking in Sapa twice. The mountains there are beautiful. However, I have never gone skiing because Vietnam does not have snow. My dream is to visit Japan and learn to ski one day. I also enjoy cycling around my city every weekend with my friends. What about you? Have you ever tried an extreme sport?\"",
    "vocabBlock":[
      {"word":"badminton","ipa":"/ˈbædmɪntən/","meaningVi":"cầu lông","example":"I have played badminton for years."},
      {"word":"surfing","ipa":"/ˈsɜːfɪŋ/","meaningVi":"lướt sóng","example":"She tried surfing last summer."},
      {"word":"hiking","ipa":"/ˈhaɪkɪŋ/","meaningVi":"đi bộ đường dài (leo núi)","example":"We have been hiking in Sapa."},
      {"word":"skiing","ipa":"/ˈskiːɪŋ/","meaningVi":"trượt tuyết","example":"He has never gone skiing."},
      {"word":"cycling","ipa":"/ˈsaɪklɪŋ/","meaningVi":"đạp xe","example":"I enjoy cycling on weekends."}],
    "examples":[
      {"en":"I have played badminton for five years.","vi":"Tôi đã chơi cầu lông được năm năm."},
      {"en":"Have you ever tried an extreme sport?","vi":"Bạn đã từng thử môn thể thao mạo hiểm nào chưa?"}],
    "commonMistakes":["Đọc kỹ từ never/already để hiểu Linh đã/chưa làm gì."],
    "tips":["Gạch chân động từ ở dạng V3 để xác định câu nào là present perfect."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u09-l4-p1','a2-u09-l4','multiple_choice',1,'practice','easy',false,'{"question":"Linh đã chơi môn nào trong năm năm?","options":[{"id":"a","text":"Cầu lông (badminton)"},{"id":"b","text":"Lướt sóng (surfing)"},{"id":"c","text":"Trượt tuyết (skiing)"}],"correctOptionId":"a","explanationVi":"\"I have played badminton for five years.\""}'::jsonb),
 ('a2-u09-l4-p2','a2-u09-l4','multiple_choice',2,'practice','easy',false,'{"question":"Linh đã thử lướt sóng ở đâu?","options":[{"id":"a","text":"Sapa"},{"id":"b","text":"Da Nang"},{"id":"c","text":"Japan"}],"correctOptionId":"b","explanationVi":"\"I tried surfing for the first time in Da Nang.\""}'::jsonb),
 ('a2-u09-l4-p3','a2-u09-l4','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ vựng thể thao với nghĩa tiếng Việt:","pairs":[{"left":"badminton","right":"cầu lông"},{"left":"surfing","right":"lướt sóng"},{"left":"hiking","right":"leo núi"},{"left":"cycling","right":"đạp xe"}],"explanationVi":"Từ vựng thể thao trong đoạn văn."}'::jsonb),
 ('a2-u09-l4-p4','a2-u09-l4','multiple_choice',4,'practice','medium',false,'{"question":"Hoạt động nào Linh CHƯA BAO GIỜ làm?","options":[{"id":"a","text":"Trượt tuyết (skiing)"},{"id":"b","text":"Leo núi (hiking)"},{"id":"c","text":"Đạp xe (cycling)"}],"correctOptionId":"a","explanationVi":"\"I have never gone skiing because Vietnam does not have snow.\""}'::jsonb),
 ('a2-u09-l4-p5','a2-u09-l4','grammar_fill_blank',5,'practice','medium',false,'{"question":"Điền theo đoạn văn: \"I have been hiking in Sapa ___.\" (số lần)","acceptedAnswers":["twice"],"explanationVi":"\"I have also been hiking in Sapa twice.\""}'::jsonb),
 ('a2-u09-l4-p6','a2-u09-l4','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Tôi thích đạp xe vào cuối tuần.","acceptedAnswers":["I enjoy cycling on weekends.","I enjoy cycling on weekends","I like cycling on weekends.","I like cycling at weekends.","I enjoy cycling at weekends"],"explanationVi":"enjoy/like + V-ing (cycling)."}'::jsonb),
 ('a2-u09-l4-q1','a2-u09-l4','multiple_choice',7,'quiz','easy',true,'{"question":"Vì sao Linh chưa bao giờ trượt tuyết?","options":[{"id":"a","text":"Vì Việt Nam không có tuyết"},{"id":"b","text":"Vì cô ấy không thích"},{"id":"c","text":"Vì quá đắt"}],"correctOptionId":"a","explanationVi":"\"...because Vietnam does not have snow.\""}'::jsonb),
 ('a2-u09-l4-q2','a2-u09-l4','multiple_choice',8,'quiz','medium',true,'{"question":"Ước mơ của Linh là gì?","options":[{"id":"a","text":"Thăm Nhật Bản và học trượt tuyết"},{"id":"b","text":"Chơi cầu lông chuyên nghiệp"},{"id":"c","text":"Đi lướt sóng ở Sapa"}],"correctOptionId":"a","explanationVi":"\"My dream is to visit Japan and learn to ski one day.\""}'::jsonb),
 ('a2-u09-l4-q3','a2-u09-l4','vocabulary_match',9,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"skiing","right":"trượt tuyết"},{"left":"exciting","right":"thú vị, hào hứng"},{"left":"mountains","right":"núi"},{"left":"weekend","right":"cuối tuần"}],"explanationVi":"Từ vựng trong đoạn văn."}'::jsonb),
 ('a2-u09-l4-q4','a2-u09-l4','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền V3 theo đoạn: \"I have ___ badminton for five years.\"","acceptedAnswers":["played"],"explanationVi":"play → played (have played)."}'::jsonb),
 ('a2-u09-l4-q5','a2-u09-l4','multiple_choice',11,'quiz','hard',true,'{"question":"Câu hỏi Linh đặt cho người đọc ở cuối đoạn là gì?","options":[{"id":"a","text":"Have you ever tried an extreme sport?"},{"id":"b","text":"Do you like badminton?"},{"id":"c","text":"Where are you from?"}],"correctOptionId":"a","explanationVi":"\"Have you ever tried an extreme sport?\""}'::jsonb),
 ('a2-u09-l4-q6','a2-u09-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["ever","you","Have","surfing","tried"],"correctOrder":[2,1,0,4,3],"explanationVi":"Câu đúng: Have you ever tried surfing?"}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u09-l5','A2','reading','a2-u09','unit_review',5,'Unit 9 Review','Ôn tập Unit 9',9,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại present perfect + ever/never/yet + gerund/infinitive.","objectives":["Tổng hợp can-do Unit 9","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u09-l5-q1','a2-u09-l5','multiple_choice',1,'quiz','easy',true,'{"question":"\"She ___ visited Hue.\"","options":[{"id":"a","text":"have"},{"id":"b","text":"has"},{"id":"c","text":"is"}],"correctOptionId":"b","explanationVi":"She đi với has + V3."}'::jsonb),
 ('a2-u09-l5-q2','a2-u09-l5','grammar_fill_blank',2,'quiz','medium',true,'{"question":"Điền V3 của \"see\": \"I have ___ that film.\"","acceptedAnswers":["seen"],"explanationVi":"see → seen."}'::jsonb),
 ('a2-u09-l5-q3','a2-u09-l5','multiple_choice',3,'quiz','easy',true,'{"question":"\"Have you ___ been to London?\"","options":[{"id":"a","text":"ever"},{"id":"b","text":"never"},{"id":"c","text":"already"}],"correctOptionId":"a","explanationVi":"Câu hỏi trải nghiệm dùng ever."}'::jsonb),
 ('a2-u09-l5-q4','a2-u09-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền trạng từ \"chưa\" vào cuối: \"They haven''t finished ___.\"","acceptedAnswers":["yet"],"explanationVi":"yet đặt cuối câu phủ định."}'::jsonb),
 ('a2-u09-l5-q5','a2-u09-l5','multiple_choice',5,'quiz','medium',true,'{"question":"\"I have ___ tried surfing.\" (chưa bao giờ)","options":[{"id":"a","text":"ever"},{"id":"b","text":"never"},{"id":"c","text":"yet"}],"correctOptionId":"b","explanationVi":"never = chưa bao giờ."}'::jsonb),
 ('a2-u09-l5-q6','a2-u09-l5','multiple_choice',6,'quiz','medium',true,'{"question":"\"I enjoy ___ books.\"","options":[{"id":"a","text":"reading"},{"id":"b","text":"to read"},{"id":"c","text":"read"}],"correctOptionId":"a","explanationVi":"enjoy + V-ing."}'::jsonb),
 ('a2-u09-l5-q7','a2-u09-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Điền dạng đúng của \"travel\": \"They want ___ to Japan.\"","acceptedAnswers":["to travel"],"explanationVi":"want + to-V."}'::jsonb),
 ('a2-u09-l5-q8','a2-u09-l5','vocabulary_match',8,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"never","right":"chưa bao giờ"},{"left":"already","right":"đã rồi"},{"left":"hiking","right":"leo núi"},{"left":"decide","right":"quyết định"}],"explanationVi":"Ôn từ vựng Unit 9."}'::jsonb),
 ('a2-u09-l5-q9','a2-u09-l5','sentence_ordering',9,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi đúng:","tokens":["you","Have","eaten","ever","sushi"],"correctOrder":[1,0,3,2,4],"explanationVi":"Câu đúng: Have you ever eaten sushi?"}'::jsonb),
 ('a2-u09-l5-q10','a2-u09-l5','multiple_choice',10,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"She has just arrived."},{"id":"b","text":"She have just arrive."},{"id":"c","text":"She has just arrive."}],"correctOptionId":"a","explanationVi":"has + just + V3 (arrived)."}'::jsonb);

-- ── UNIT 10 — Out & About / Ra ngoài & Khám phá ──
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u10-l1','A2','reading','a2-u10','normal',1,'Adverbs of Manner','Trạng từ chỉ cách thức',9,15,70,'{}'::jsonb,
  '{"warmup":"Bạn làm việc đó NHƯ THẾ NÀO? Nhanh, chậm, cẩn thận? Đó là trạng từ chỉ cách thức.",
    "objectives":["Tạo trạng từ chỉ cách thức từ tính từ (+ -ly)","Nhớ các dạng bất quy tắc good->well, fast->fast","Đặt trạng từ sau động từ thường"],
    "grammarHtml":"Trạng từ chỉ cách thức mô tả động từ xảy ra NHƯ THẾ NÀO. Quy tắc: tính từ + -ly (quick->quickly, slow->slowly, careful->carefully). Tính từ tận cùng -y đổi thành -ily (easy->easily, happy->happily). Bất quy tắc: good->well, fast->fast, hard->hard. Vị trí: thường đứng SAU động từ hoặc sau tân ngữ (She drives carefully).",
    "vocabBlock":[
      {"word":"quickly","ipa":"/ˈkwɪkli/","meaningVi":"một cách nhanh chóng","example":"She walks quickly to school."},
      {"word":"slowly","ipa":"/ˈsloʊli/","meaningVi":"một cách chậm rãi","example":"Please speak slowly."},
      {"word":"carefully","ipa":"/ˈkerfəli/","meaningVi":"một cách cẩn thận","example":"He drives carefully."},
      {"word":"well","ipa":"/wel/","meaningVi":"tốt, giỏi","example":"She sings well."},
      {"word":"hard","ipa":"/hɑːrd/","meaningVi":"chăm chỉ, vất vả","example":"They work hard every day."},
      {"word":"fast","ipa":"/fæst/","meaningVi":"nhanh","example":"He runs fast."}],
    "examples":[
      {"en":"She speaks English fluently.","vi":"Cô ấy nói tiếng Anh trôi chảy."},
      {"en":"He plays football well.","vi":"Anh ấy chơi bóng đá giỏi."},
      {"en":"Please drive slowly here.","vi":"Làm ơn lái xe chậm ở đây."}],
    "commonMistakes":["❌ \"She sings good.\" → ✅ \"She sings well.\" (good là tính từ, well là trạng từ).","❌ \"He runs quick.\" → ✅ \"He runs quickly.\""],
    "tips":["good là tính từ, well là trạng từ tương ứng.","fast và hard giữ nguyên, KHÔNG thêm -ly."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u10-l1-p1','a2-u10-l1','multiple_choice',1,'practice','easy',false,'{"question":"Trạng từ của \"quick\" là gì?","options":[{"id":"a","text":"quickly"},{"id":"b","text":"quicky"},{"id":"c","text":"quick"}],"correctOptionId":"a","explanationVi":"quick + -ly = quickly."}'::jsonb),
 ('a2-u10-l1-p2','a2-u10-l1','vocabulary_match',2,'practice','easy',false,'{"question":"Nối trạng từ với nghĩa tiếng Việt:","pairs":[{"left":"quickly","right":"nhanh chóng"},{"left":"slowly","right":"chậm rãi"},{"left":"carefully","right":"cẩn thận"},{"left":"well","right":"tốt, giỏi"}],"explanationVi":"Ghép đúng từng cặp trạng từ."}'::jsonb),
 ('a2-u10-l1-p3','a2-u10-l1','grammar_fill_blank',3,'practice','easy',false,'{"question":"Điền trạng từ của \"slow\": \"Please speak ___.\"","acceptedAnswers":["slowly"],"explanationVi":"slow + -ly = slowly."}'::jsonb),
 ('a2-u10-l1-p4','a2-u10-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền trạng từ của \"good\": \"She sings ___.\"","acceptedAnswers":["well"],"explanationVi":"good -> well (bất quy tắc)."}'::jsonb),
 ('a2-u10-l1-p5','a2-u10-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Anh ấy lái xe cẩn thận.","acceptedAnswers":["He drives carefully.","He drives carefully"],"explanationVi":"He drives carefully."}'::jsonb),
 ('a2-u10-l1-p6','a2-u10-l1','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu:","sourceText":"He runs quick.","acceptedAnswers":["He runs quickly.","He runs quickly"],"explanationVi":"Cần trạng từ quickly sau động từ runs."}'::jsonb),
 ('a2-u10-l1-q1','a2-u10-l1','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"She sings good."},{"id":"b","text":"She sings well."},{"id":"c","text":"She sings goodly."}],"correctOptionId":"b","explanationVi":"good là tính từ; trạng từ là well."}'::jsonb),
 ('a2-u10-l1-q2','a2-u10-l1','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền trạng từ của \"careful\": \"He listens ___.\"","acceptedAnswers":["carefully"],"explanationVi":"careful + -ly = carefully."}'::jsonb),
 ('a2-u10-l1-q3','a2-u10-l1','multiple_choice',9,'quiz','medium',true,'{"question":"Trạng từ của \"fast\" là:","options":[{"id":"a","text":"fastly"},{"id":"b","text":"fast"},{"id":"c","text":"fastily"}],"correctOptionId":"b","explanationVi":"fast giữ nguyên làm trạng từ, không thêm -ly."}'::jsonb),
 ('a2-u10-l1-q4','a2-u10-l1','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối tính từ với trạng từ tương ứng:","pairs":[{"left":"good","right":"well"},{"left":"easy","right":"easily"},{"left":"happy","right":"happily"},{"left":"slow","right":"slowly"}],"explanationVi":"good->well, đuôi -y đổi thành -ily."}'::jsonb),
 ('a2-u10-l1-q5','a2-u10-l1','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["drives","She","carefully"],"correctOrder":[1,0,2],"explanationVi":"Câu đúng: She drives carefully."}'::jsonb),
 ('a2-u10-l1-q6','a2-u10-l1','grammar_fill_blank',12,'quiz','hard',true,'{"question":"Điền trạng từ của \"easy\": \"She passed the test ___.\"","acceptedAnswers":["easily"],"explanationVi":"easy -> easily (đuôi -y đổi thành -ily)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u10-l2','A2','reading','a2-u10','normal',2,'Comparative Adverbs & Indefinite Pronouns','So sánh trạng từ & đại từ bất định',10,15,70,'{}'::jsonb,
  '{"warmup":"Ai chạy nhanh hơn? Có ai ở nhà không? Hôm nay ta học so sánh trạng từ và đại từ bất định.",
    "objectives":["So sánh hơn của trạng từ (more quickly than, harder)","Dùng đại từ bất định something/anyone/everywhere/nobody","Phân biệt some- (khẳng định) và any- (phủ định/nghi vấn)"],
    "grammarHtml":"So sánh hơn của trạng từ: trạng từ ngắn + -er (hard->harder, fast->faster); trạng từ tận cùng -ly dùng more + adverb + than (more quickly than, more carefully than). Bất quy tắc: well->better, badly->worse. Đại từ bất định: some- (something/someone/somewhere) cho câu khẳng định; any- (anything/anyone/anywhere) cho phủ định & nghi vấn; every- (everything/everyone/everywhere) = mọi; no- (nothing/nobody/nowhere) = không có.",
    "vocabBlock":[
      {"word":"something","ipa":"/ˈsʌmθɪŋ/","meaningVi":"cái gì đó","example":"I want to eat something."},
      {"word":"anyone","ipa":"/ˈeniwʌn/","meaningVi":"bất cứ ai","example":"Is anyone at home?"},
      {"word":"everywhere","ipa":"/ˈevriwer/","meaningVi":"khắp mọi nơi","example":"I looked everywhere for my keys."},
      {"word":"nobody","ipa":"/ˈnoʊbɑːdi/","meaningVi":"không ai","example":"Nobody knows the answer."},
      {"word":"harder","ipa":"/ˈhɑːrdər/","meaningVi":"chăm chỉ hơn","example":"He works harder than me."},
      {"word":"better","ipa":"/ˈbetər/","meaningVi":"tốt hơn, giỏi hơn","example":"She sings better than him."}],
    "examples":[
      {"en":"He runs faster than his brother.","vi":"Anh ấy chạy nhanh hơn anh trai."},
      {"en":"She speaks English more fluently than me.","vi":"Cô ấy nói tiếng Anh trôi chảy hơn tôi."},
      {"en":"Nobody was at the office.","vi":"Không có ai ở văn phòng."}],
    "commonMistakes":["❌ \"more harder\" → ✅ \"harder\" (trạng từ ngắn chỉ thêm -er).","❌ \"I don''t want nothing.\" → ✅ \"I don''t want anything.\" (phủ định dùng any-)."],
    "tips":["Trạng từ tận cùng -ly: dùng more ... than.","Câu phủ định và nghi vấn dùng any-, không dùng some-."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u10-l2-p1','a2-u10-l2','multiple_choice',1,'practice','easy',false,'{"question":"So sánh hơn của trạng từ \"hard\" là:","options":[{"id":"a","text":"more hard"},{"id":"b","text":"harder"},{"id":"c","text":"hardlier"}],"correctOptionId":"b","explanationVi":"hard là trạng từ ngắn -> harder."}'::jsonb),
 ('a2-u10-l2-p2','a2-u10-l2','vocabulary_match',2,'practice','easy',false,'{"question":"Nối đại từ bất định với nghĩa:","pairs":[{"left":"something","right":"cái gì đó"},{"left":"anyone","right":"bất cứ ai"},{"left":"everywhere","right":"khắp mọi nơi"},{"left":"nobody","right":"không ai"}],"explanationVi":"Ghép đúng từng đại từ bất định."}'::jsonb),
 ('a2-u10-l2-p3','a2-u10-l2','grammar_fill_blank',3,'practice','medium',false,'{"question":"Điền dạng so sánh: \"She speaks ___ quickly than me.\"","acceptedAnswers":["more"],"explanationVi":"Trạng từ tận cùng -ly dùng more ... than."}'::jsonb),
 ('a2-u10-l2-p4','a2-u10-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền đại từ bất định (câu hỏi): \"Is ___ at home?\"","acceptedAnswers":["anyone","anybody"],"explanationVi":"Câu nghi vấn dùng anyone/anybody."}'::jsonb),
 ('a2-u10-l2-p5','a2-u10-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Không ai biết câu trả lời.","acceptedAnswers":["Nobody knows the answer.","Nobody knows the answer","No one knows the answer."],"explanationVi":"Nobody knows the answer."}'::jsonb),
 ('a2-u10-l2-p6','a2-u10-l2','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu:","sourceText":"He works more harder than me.","acceptedAnswers":["He works harder than me.","He works harder than me"],"explanationVi":"harder đã là so sánh hơn, bỏ more."}'::jsonb),
 ('a2-u10-l2-q1','a2-u10-l2','multiple_choice',7,'quiz','easy',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"He runs more fast than me."},{"id":"b","text":"He runs faster than me."},{"id":"c","text":"He runs fastly than me."}],"correctOptionId":"b","explanationVi":"fast -> faster (trạng từ ngắn thêm -er)."}'::jsonb),
 ('a2-u10-l2-q2','a2-u10-l2','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền: \"She sings ___ than him.\" (so sánh hơn của well)","acceptedAnswers":["better"],"explanationVi":"well -> better (bất quy tắc)."}'::jsonb),
 ('a2-u10-l2-q3','a2-u10-l2','multiple_choice',9,'quiz','medium',true,'{"question":"\"I don''t want ___.\" Điền từ đúng.","options":[{"id":"a","text":"something"},{"id":"b","text":"anything"},{"id":"c","text":"everything"}],"correctOptionId":"b","explanationVi":"Câu phủ định dùng anything."}'::jsonb),
 ('a2-u10-l2-q4','a2-u10-l2','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối đại từ bất định với nghĩa:","pairs":[{"left":"someone","right":"ai đó"},{"left":"anything","right":"bất cứ thứ gì"},{"left":"everyone","right":"mọi người"},{"left":"nowhere","right":"không nơi nào"}],"explanationVi":"Ghép đúng từng cặp."}'::jsonb),
 ('a2-u10-l2-q5','a2-u10-l2','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["faster","He","runs","than","me"],"correctOrder":[1,2,0,3,4],"explanationVi":"Câu đúng: He runs faster than me."}'::jsonb),
 ('a2-u10-l2-q6','a2-u10-l2','grammar_fill_blank',12,'quiz','hard',true,'{"question":"Điền đại từ bất định: \"I looked ___ for my keys.\" (khắp mọi nơi)","acceptedAnswers":["everywhere"],"explanationVi":"everywhere = khắp mọi nơi."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u10-l3','A2','reading','a2-u10','normal',3,'Connectors','Liên từ nối câu',9,15,70,'{}'::jsonb,
  '{"warmup":"Vì sao? Cho nên? Nhưng? Mặc dù? Ta dùng liên từ để nối hai mệnh đề lại với nhau.",
    "objectives":["Nối mệnh đề bằng because, so, but, although","Phân biệt nguyên nhân (because) và kết quả (so)","Dùng but và although để diễn tả tương phản"],
    "grammarHtml":"Liên từ nối hai mệnh đề: <b>because</b> (vì - chỉ nguyên nhân): I stayed home because it rained. <b>so</b> (cho nên - chỉ kết quả): It rained, so I stayed home. <b>but</b> (nhưng - tương phản): It rained, but I went out. <b>although</b> (mặc dù - tương phản, đứng đầu mệnh đề): Although it rained, I went out.",
    "vocabBlock":[
      {"word":"because","ipa":"/bɪˈkɔːz/","meaningVi":"bởi vì","example":"I am tired because I worked late."},
      {"word":"so","ipa":"/soʊ/","meaningVi":"cho nên","example":"It was late, so we went home."},
      {"word":"but","ipa":"/bʌt/","meaningVi":"nhưng","example":"I like tea, but I prefer coffee."},
      {"word":"although","ipa":"/ɔːlˈðoʊ/","meaningVi":"mặc dù","example":"Although it was cold, we walked."},
      {"word":"travel","ipa":"/ˈtrævl/","meaningVi":"du lịch, đi lại","example":"We travel by train."},
      {"word":"shopping","ipa":"/ˈʃɑːpɪŋ/","meaningVi":"mua sắm","example":"She went shopping yesterday."}],
    "examples":[
      {"en":"I stayed home because it was raining.","vi":"Tôi ở nhà vì trời đang mưa."},
      {"en":"It was raining, so I stayed home.","vi":"Trời mưa, cho nên tôi ở nhà."},
      {"en":"Although it was raining, I went out.","vi":"Mặc dù trời mưa, tôi vẫn ra ngoài."}],
    "commonMistakes":["❌ \"Because it rained, so I stayed home.\" → ✅ Chỉ dùng MỘT liên từ: \"Because it rained, I stayed home.\"","❌ \"Although... but...\" → ✅ Không dùng but sau although."],
    "tips":["because + nguyên nhân; so + kết quả.","although và but đều chỉ tương phản nhưng không dùng cùng nhau."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u10-l3-p1','a2-u10-l3','multiple_choice',1,'practice','easy',false,'{"question":"\"I stayed home ___ it rained.\" (vì) Điền liên từ.","options":[{"id":"a","text":"because"},{"id":"b","text":"so"},{"id":"c","text":"but"}],"correctOptionId":"a","explanationVi":"because = vì, chỉ nguyên nhân."}'::jsonb),
 ('a2-u10-l3-p2','a2-u10-l3','vocabulary_match',2,'practice','easy',false,'{"question":"Nối liên từ với nghĩa:","pairs":[{"left":"because","right":"bởi vì"},{"left":"so","right":"cho nên"},{"left":"but","right":"nhưng"},{"left":"although","right":"mặc dù"}],"explanationVi":"Ghép đúng từng liên từ."}'::jsonb),
 ('a2-u10-l3-p3','a2-u10-l3','grammar_fill_blank',3,'practice','medium',false,'{"question":"Điền liên từ (kết quả): \"It was late, ___ we went home.\"","acceptedAnswers":["so"],"explanationVi":"so = cho nên, chỉ kết quả."}'::jsonb),
 ('a2-u10-l3-p4','a2-u10-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền liên từ (tương phản): \"I like tea, ___ I prefer coffee.\"","acceptedAnswers":["but"],"explanationVi":"but = nhưng, chỉ sự tương phản."}'::jsonb),
 ('a2-u10-l3-p5','a2-u10-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Mặc dù trời lạnh, chúng tôi vẫn đi bộ.","acceptedAnswers":["Although it was cold, we walked.","Although it was cold, we walked"],"explanationVi":"Although it was cold, we walked."}'::jsonb),
 ('a2-u10-l3-p6','a2-u10-l3','error_correction',6,'practice','hard',false,'{"question":"Sửa lỗi trong câu:","sourceText":"Because it rained, so I stayed home.","acceptedAnswers":["Because it rained, I stayed home.","Because it rained, I stayed home"],"explanationVi":"Chỉ dùng một liên từ, bỏ so."}'::jsonb),
 ('a2-u10-l3-q1','a2-u10-l3','multiple_choice',7,'quiz','easy',true,'{"question":"\"It was raining, ___ I took an umbrella.\" Điền liên từ chỉ kết quả.","options":[{"id":"a","text":"because"},{"id":"b","text":"so"},{"id":"c","text":"although"}],"correctOptionId":"b","explanationVi":"so = cho nên, chỉ kết quả."}'::jsonb),
 ('a2-u10-l3-q2','a2-u10-l3','grammar_fill_blank',8,'quiz','medium',true,'{"question":"Điền liên từ (nguyên nhân): \"I am tired ___ I worked late.\"","acceptedAnswers":["because"],"explanationVi":"because = vì, chỉ nguyên nhân."}'::jsonb),
 ('a2-u10-l3-q3','a2-u10-l3','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"Although it rained, but we went out."},{"id":"b","text":"Although it rained, we went out."},{"id":"c","text":"Although it rained so we went out."}],"correctOptionId":"b","explanationVi":"Không dùng but sau although."}'::jsonb),
 ('a2-u10-l3-q4','a2-u10-l3','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối liên từ với chức năng:","pairs":[{"left":"because","right":"nguyên nhân"},{"left":"so","right":"kết quả"},{"left":"but","right":"tương phản"},{"left":"although","right":"nhượng bộ"}],"explanationVi":"Ghép đúng chức năng từng liên từ."}'::jsonb),
 ('a2-u10-l3-q5','a2-u10-l3','sentence_ordering',11,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["because","home","I","stayed","it","rained"],"correctOrder":[2,3,1,0,4,5],"explanationVi":"Câu đúng: I stayed home because it rained."}'::jsonb),
 ('a2-u10-l3-q6','a2-u10-l3','grammar_fill_blank',12,'quiz','hard',true,'{"question":"Điền liên từ (mặc dù): \"___ it was expensive, she bought it.\"","acceptedAnswers":["Although"],"explanationVi":"Although = mặc dù, đứng đầu mệnh đề."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u10-l4','A2','listening','a2-u10','normal',4,'Making Plans to Meet','Hẹn gặp & đi chơi (nghe + đọc)',10,15,70,'{}'::jsonb,
  '{"warmup":"Bạn rủ bạn bè đi chơi cuối tuần thế nào? Nghe đoạn hội thoại hẹn gặp nhau.",
    "objectives":["Nghe hiểu hội thoại hẹn gặp đi chơi","Hiểu từ vựng về công việc, du lịch, mua sắm","Trả lời câu hỏi về thời gian và địa điểm hẹn"],
    "vocabBlock":[
      {"word":"meet","ipa":"/miːt/","meaningVi":"gặp gỡ","example":"Let''s meet at the cafe."},
      {"word":"plan","ipa":"/plæn/","meaningVi":"kế hoạch","example":"What are your plans for Saturday?"},
      {"word":"weekend","ipa":"/ˈwiːkend/","meaningVi":"cuối tuần","example":"I am free this weekend."},
      {"word":"downtown","ipa":"/ˌdaʊnˈtaʊn/","meaningVi":"trung tâm thành phố","example":"They went shopping downtown."},
      {"word":"museum","ipa":"/mjuˈziːəm/","meaningVi":"bảo tàng","example":"We visited the museum."},
      {"word":"around","ipa":"/əˈraʊnd/","meaningVi":"khoảng, quanh","example":"Let''s meet around ten."}],
    "examples":[
      {"en":"Are you free this weekend?","vi":"Cuối tuần này bạn rảnh không?"},
      {"en":"Let''s meet at the cafe at ten.","vi":"Hẹn gặp ở quán cà phê lúc mười giờ nhé."},
      {"en":"We can go shopping after lunch.","vi":"Chúng ta có thể đi mua sắm sau bữa trưa."}],
    "commonMistakes":["❌ \"Let''s to meet.\" → ✅ \"Let''s meet.\" (Let''s + động từ nguyên mẫu không to).","Chú ý phân biệt thời gian: ten (10) và at ten (lúc 10 giờ)."],
    "tips":["Nghe kỹ thời gian và địa điểm hẹn gặp.","Let''s + V (nguyên mẫu) để rủ rê: Let''s go, Let''s meet."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u10-l4-p1','a2-u10-l4','listening_choice',1,'practice','easy',false,'{"question":"Nghe và chọn câu bạn nghe được:","audioText":"Are you free this weekend?","options":[{"id":"a","text":"Are you free this weekend?"},{"id":"b","text":"Are you busy today?"},{"id":"c","text":"Were you free last week?"}],"correctOptionId":"a","explanationVi":"Câu nghe được: Are you free this weekend?"}'::jsonb),
 ('a2-u10-l4-p2','a2-u10-l4','listening_choice',2,'practice','medium',false,'{"question":"Nghe và chọn nơi họ hẹn gặp:","audioText":"Let''s meet at the cafe near the museum.","options":[{"id":"a","text":"Quán cà phê gần bảo tàng"},{"id":"b","text":"Ở nhà ga"},{"id":"c","text":"Trong bảo tàng"}],"correctOptionId":"a","explanationVi":"Họ hẹn ở quán cà phê gần bảo tàng (cafe near the museum)."}'::jsonb),
 ('a2-u10-l4-p3','a2-u10-l4','listening_choice',3,'practice','medium',false,'{"question":"Nghe và chọn thời gian hẹn gặp:","audioText":"Let''s meet around ten in the morning.","options":[{"id":"a","text":"Khoảng 10 giờ sáng"},{"id":"b","text":"Lúc 2 giờ chiều"},{"id":"c","text":"Khoảng 9 giờ tối"}],"correctOptionId":"a","explanationVi":"around ten in the morning = khoảng 10 giờ sáng."}'::jsonb),
 ('a2-u10-l4-p4','a2-u10-l4','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"meet","right":"gặp gỡ"},{"left":"weekend","right":"cuối tuần"},{"left":"downtown","right":"trung tâm thành phố"},{"left":"museum","right":"bảo tàng"}],"explanationVi":"Ghép đúng từng cặp từ vựng."}'::jsonb),
 ('a2-u10-l4-p5','a2-u10-l4','multiple_choice',5,'practice','medium',false,'{"question":"Đọc đoạn văn: \"Anna and Tom want to spend Saturday together. Anna calls Tom and asks about his plans. Tom is free in the afternoon because he works hard in the morning. They decide to meet at a cafe downtown around two o''clock. After coffee, they will go shopping for a birthday present, and then visit the new museum near the river. Although the weather is cold, they are excited. Tom says he will travel there by bus, but Anna prefers to walk because the cafe is close to her house.\" Tom rảnh vào lúc nào?","options":[{"id":"a","text":"Buổi sáng"},{"id":"b","text":"Buổi chiều"},{"id":"c","text":"Buổi tối"}],"correctOptionId":"b","explanationVi":"Tom is free in the afternoon = Tom rảnh buổi chiều."}'::jsonb),
 ('a2-u10-l4-p6','a2-u10-l4','multiple_choice',6,'practice','hard',false,'{"question":"Theo đoạn văn trên, vì sao Anna thích đi bộ?","options":[{"id":"a","text":"Vì quán cà phê gần nhà cô ấy"},{"id":"b","text":"Vì trời nóng"},{"id":"c","text":"Vì xe buýt đắt"}],"correctOptionId":"a","explanationVi":"Anna prefers to walk because the cafe is close to her house."}'::jsonb),
 ('a2-u10-l4-q1','a2-u10-l4','listening_choice',7,'quiz','easy',true,'{"question":"Nghe và chọn câu rủ rê đúng:","audioText":"Let''s go shopping this afternoon.","options":[{"id":"a","text":"Let''s go shopping this afternoon."},{"id":"b","text":"Let''s go home this morning."},{"id":"c","text":"Let''s stay here tonight."}],"correctOptionId":"a","explanationVi":"Câu nghe được: Let''s go shopping this afternoon."}'::jsonb),
 ('a2-u10-l4-q2','a2-u10-l4','listening_choice',8,'quiz','medium',true,'{"question":"Nghe và chọn phương tiện Tom sẽ đi:","audioText":"I will travel there by bus.","options":[{"id":"a","text":"Xe buýt"},{"id":"b","text":"Tàu hỏa"},{"id":"c","text":"Taxi"}],"correctOptionId":"a","explanationVi":"travel by bus = đi bằng xe buýt."}'::jsonb),
 ('a2-u10-l4-q3','a2-u10-l4','multiple_choice',9,'quiz','medium',true,'{"question":"Theo đoạn văn, sau khi uống cà phê họ sẽ làm gì?","options":[{"id":"a","text":"Đi mua quà sinh nhật"},{"id":"b","text":"Về nhà ngủ"},{"id":"c","text":"Đi học"}],"correctOptionId":"a","explanationVi":"they will go shopping for a birthday present."}'::jsonb),
 ('a2-u10-l4-q4','a2-u10-l4','multiple_choice',10,'quiz','easy',true,'{"question":"\"Are you free this weekend?\" nghĩa là gì?","options":[{"id":"a","text":"Cuối tuần này bạn rảnh không?"},{"id":"b","text":"Cuối tuần này bạn bận à?"},{"id":"c","text":"Tuần trước bạn rảnh không?"}],"correctOptionId":"a","explanationVi":"free = rảnh; this weekend = cuối tuần này."}'::jsonb),
 ('a2-u10-l4-q5','a2-u10-l4','vocabulary_match',11,'quiz','medium',true,'{"question":"Nối từ với nghĩa tiếng Việt:","pairs":[{"left":"plan","right":"kế hoạch"},{"left":"travel","right":"đi lại, du lịch"},{"left":"shopping","right":"mua sắm"},{"left":"around","right":"khoảng"}],"explanationVi":"Ghép đúng từng cặp từ vựng."}'::jsonb),
 ('a2-u10-l4-q6','a2-u10-l4','sentence_ordering',12,'quiz','hard',true,'{"question":"Sắp xếp thành câu rủ rê đúng:","tokens":["meet","Let''s","at","the","cafe"],"correctOrder":[1,0,2,3,4],"explanationVi":"Câu đúng: Let''s meet at the cafe."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-u10-l5','A2','reading','a2-u10','unit_review',5,'Unit 10 Review','Ôn tập Unit 10',10,25,75,'{}'::jsonb,
  '{"warmup":"Ôn lại trạng từ chỉ cách thức, so sánh trạng từ, đại từ bất định và liên từ.","objectives":["Tổng hợp can-do Unit 10","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-u10-l5-q1','a2-u10-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn câu đúng:","options":[{"id":"a","text":"She sings good."},{"id":"b","text":"She sings well."},{"id":"c","text":"She sings goodly."}],"correctOptionId":"b","explanationVi":"good là tính từ; trạng từ là well."}'::jsonb),
 ('a2-u10-l5-q2','a2-u10-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Điền trạng từ của \"quick\": \"He answered ___.\"","acceptedAnswers":["quickly"],"explanationVi":"quick + -ly = quickly."}'::jsonb),
 ('a2-u10-l5-q3','a2-u10-l5','multiple_choice',3,'quiz','medium',true,'{"question":"So sánh hơn của trạng từ \"hard\" là:","options":[{"id":"a","text":"more hard"},{"id":"b","text":"harder"},{"id":"c","text":"hardly"}],"correctOptionId":"b","explanationVi":"hard -> harder (trạng từ ngắn thêm -er)."}'::jsonb),
 ('a2-u10-l5-q4','a2-u10-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền liên từ (nguyên nhân): \"I stayed home ___ it rained.\"","acceptedAnswers":["because"],"explanationVi":"because = vì, chỉ nguyên nhân."}'::jsonb),
 ('a2-u10-l5-q5','a2-u10-l5','multiple_choice',5,'quiz','medium',true,'{"question":"\"I don''t want ___.\" Điền từ đúng.","options":[{"id":"a","text":"something"},{"id":"b","text":"anything"},{"id":"c","text":"everything"}],"correctOptionId":"b","explanationVi":"Câu phủ định dùng anything."}'::jsonb),
 ('a2-u10-l5-q6','a2-u10-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối liên từ với nghĩa:","pairs":[{"left":"because","right":"bởi vì"},{"left":"so","right":"cho nên"},{"left":"but","right":"nhưng"},{"left":"although","right":"mặc dù"}],"explanationVi":"Ghép đúng từng liên từ."}'::jsonb),
 ('a2-u10-l5-q7','a2-u10-l5','listening_choice',7,'quiz','medium',true,'{"question":"Nghe và chọn câu bạn nghe được:","audioText":"Let''s meet at the cafe at ten.","options":[{"id":"a","text":"Let''s meet at the cafe at ten."},{"id":"b","text":"Let''s go to the cafe at noon."},{"id":"c","text":"Let''s leave the cafe at ten."}],"correctOptionId":"a","explanationVi":"Câu nghe được: Let''s meet at the cafe at ten."}'::jsonb),
 ('a2-u10-l5-q8','a2-u10-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["faster","He","runs","than","me"],"correctOrder":[1,2,0,3,4],"explanationVi":"Câu đúng: He runs faster than me."}'::jsonb),
 ('a2-u10-l5-q9','a2-u10-l5','grammar_fill_blank',9,'quiz','hard',true,'{"question":"Điền đại từ bất định: \"___ knows the answer.\" (không ai)","acceptedAnswers":["Nobody","No one","Noone"],"explanationVi":"Nobody = không ai."}'::jsonb),
 ('a2-u10-l5-q10','a2-u10-l5','listening_choice',10,'quiz','hard',true,'{"question":"Nghe và chọn phương tiện được nhắc đến:","audioText":"I will travel there by bus.","options":[{"id":"a","text":"Xe buýt"},{"id":"b","text":"Tàu hỏa"},{"id":"c","text":"Máy bay"}],"correctOptionId":"a","explanationVi":"travel by bus = đi bằng xe buýt."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 2 — Gắn Unit Review (l5) làm review_lesson_id cho từng Unit            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = 'a2-u01-l5' WHERE id = 'a2-u01';
UPDATE learning_units SET review_lesson_id = 'a2-u02-l5' WHERE id = 'a2-u02';
UPDATE learning_units SET review_lesson_id = 'a2-u03-l5' WHERE id = 'a2-u03';
UPDATE learning_units SET review_lesson_id = 'a2-u04-l5' WHERE id = 'a2-u04';
UPDATE learning_units SET review_lesson_id = 'a2-u05-l5' WHERE id = 'a2-u05';
UPDATE learning_units SET review_lesson_id = 'a2-u06-l5' WHERE id = 'a2-u06';
UPDATE learning_units SET review_lesson_id = 'a2-u07-l5' WHERE id = 'a2-u07';
UPDATE learning_units SET review_lesson_id = 'a2-u08-l5' WHERE id = 'a2-u08';
UPDATE learning_units SET review_lesson_id = 'a2-u09-l5' WHERE id = 'a2-u09';
UPDATE learning_units SET review_lesson_id = 'a2-u10-l5' WHERE id = 'a2-u10';
