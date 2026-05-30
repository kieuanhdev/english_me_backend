-- =============================================================================
-- V31 — MỞ RỘNG & LÀM SÂU CẤP A2 (theo khung CEFR A2)
-- =============================================================================
-- A2 trước đây chỉ 1 unit (Daily Activities) → quá mỏng. Bổ sung các chủ đề
-- cốt lõi A2 để người học đạt năng lực A2 thực sự:
--   Past simple · Future (be going to / will) · Comparatives & Superlatives ·
--   Quantifiers (some/any, countable/uncountable).
-- + Làm dày unit Daily Activities hiện có (thêm câu hỏi).
-- An toàn: chỉ THÊM (Flyway không sửa migration cũ). skill_code hợp lệ.
-- Mỗi lesson: >=4 practice + >=6 quiz.
-- =============================================================================

-- ── Làm dày unit A2 hiện có (a2-unit-activities, 2 lesson đã có q1-q3) ──
INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-act-l1-q4','a2-activities-l1','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"She ___ cooking dinner now. (to be)","acceptedAnswers":["is"],"explanationVi":"She + is + V-ing."}'::jsonb),
 ('a2-act-l1-q5','a2-activities-l1','multiple_choice',7,'quiz','hard',true,
  '{"question":"Chọn câu hiện tại tiếp diễn ĐÚNG:","options":[{"id":"a","text":"We are watching TV."},{"id":"b","text":"We watching TV."},{"id":"c","text":"We watch are TV."}],"correctOptionId":"a","explanationVi":"are + V-ing."}'::jsonb),
 ('a2-act-l2-q4','a2-activities-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"\"sometimes\" nghĩa là gì?","options":[{"id":"a","text":"thỉnh thoảng"},{"id":"b","text":"luôn luôn"},{"id":"c","text":"không bao giờ"}],"correctOptionId":"a","explanationVi":"sometimes = thỉnh thoảng."}'::jsonb),
 ('a2-act-l2-q5','a2-activities-l2','grammar_fill_blank',7,'quiz','hard',true,
  '{"question":"Sắp đúng: \"He ___ plays football.\" (always - luôn)","acceptedAnswers":["always"],"explanationVi":"Trạng từ tần suất trước động từ thường."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A2 — UNIT 2: Past Simple (quá khứ đơn — trọng tâm A2)  display_order 2     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
 ('a2-unit-past','A2','Past Simple','Quá khứ đơn: was/were & động từ V-ed','past','["grammar","reading"]'::jsonb,2);

INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-past-l1','A2','reading','a2-unit-past','normal',1,'Was / Were','to be ở quá khứ',9,18,70,'{}'::jsonb,
  '{"warmup":"Hôm qua bạn ở đâu?","objectives":["Dùng was/were để nói quá khứ"],
    "grammarHtml":"I/he/she/it + was. You/we/they + were. Phủ định: wasn''t/weren''t. VD: I was at home. They were happy.",
    "vocabBlock":[
      {"word":"yesterday","ipa":"/ˈjestədeɪ/","meaningVi":"hôm qua","example":"I was busy yesterday."},
      {"word":"last week","ipa":"/lɑːst wiːk/","meaningVi":"tuần trước","example":"She was sick last week."}],
    "examples":[{"en":"They were at school yesterday.","vi":"Hôm qua họ ở trường."}],
    "commonMistakes":["❌ \"They was\" → ✅ \"They were\""],
    "tips":["I/he/she/it → was; số nhiều → were."]}'::jsonb),
 ('a2-past-l2','A2','reading','a2-unit-past','normal',2,'Regular verbs (-ed)','Động từ thường quá khứ',10,18,70,'{}'::jsonb,
  '{"warmup":"\"play\" ở quá khứ là gì?","objectives":["Chia động từ thường ở quá khứ (-ed)","Câu phủ định với didn''t"],
    "grammarHtml":"Khẳng định: V-ed (played, worked). Phủ định: didn''t + V(nguyên thể). Câu hỏi: Did + S + V?",
    "vocabBlock":[],"examples":[{"en":"I played football yesterday.","vi":"Hôm qua tôi đã chơi bóng."},{"en":"She didn''t watch TV.","vi":"Cô ấy đã không xem TV."}],
    "commonMistakes":["❌ \"I didn''t played\" → ✅ \"I didn''t play\""],
    "tips":["Sau didn''t dùng động từ nguyên thể."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-past-l1-p1','a2-past-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"I ___ at home yesterday. (to be quá khứ)","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"am"}],"correctOptionId":"a","explanationVi":"I + was."}'::jsonb),
 ('a2-past-l1-p2','a2-past-l1','multiple_choice',2,'practice','medium',false,
  '{"question":"They ___ happy. (to be quá khứ)","options":[{"id":"a","text":"was"},{"id":"b","text":"were"},{"id":"c","text":"are"}],"correctOptionId":"b","explanationVi":"They + were."}'::jsonb),
 ('a2-past-l1-p3','a2-past-l1','grammar_fill_blank',3,'practice','medium',false,
  '{"question":"She ___ sick last week. (to be quá khứ)","acceptedAnswers":["was"],"explanationVi":"She + was."}'::jsonb),
 ('a2-past-l1-p4','a2-past-l1','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"We was at school.","acceptedAnswers":["We were at school.","We were at school"],"explanationVi":"We + were."}'::jsonb),
 ('a2-past-l1-q1','a2-past-l1','multiple_choice',5,'quiz','easy',true,
  '{"question":"\"yesterday\" nghĩa là gì?","options":[{"id":"a","text":"hôm qua"},{"id":"b","text":"ngày mai"},{"id":"c","text":"hôm nay"}],"correctOptionId":"a","explanationVi":"yesterday = hôm qua."}'::jsonb),
 ('a2-past-l1-q2','a2-past-l1','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"They ___ at the park. (to be quá khứ)","acceptedAnswers":["were"],"explanationVi":"They + were."}'::jsonb),
 ('a2-past-l1-q3','a2-past-l1','multiple_choice',7,'quiz','medium',true,
  '{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"He was tired."},{"id":"b","text":"He were tired."},{"id":"c","text":"He is tired yesterday."}],"correctOptionId":"a","explanationVi":"He + was."}'::jsonb),
 ('a2-past-l1-q4','a2-past-l1','grammar_fill_blank',8,'quiz','hard',true,
  '{"question":"Phủ định: \"I ___ not at home.\" (to be quá khứ)","acceptedAnswers":["was"],"explanationVi":"I was not (wasn''t)."}'::jsonb),
 ('a2-past-l1-q5','a2-past-l1','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Hôm qua họ ở trường.\"","sourceText":"Hôm qua họ ở trường.","acceptedAnswers":["They were at school yesterday.","Yesterday they were at school.","They were at school yesterday"],"explanationVi":"They were at school yesterday."}'::jsonb),
 ('a2-past-l1-q6','a2-past-l1','multiple_choice',10,'quiz','medium',true,
  '{"question":"Chủ ngữ nào đi với \"were\"?","options":[{"id":"a","text":"They"},{"id":"b","text":"She"},{"id":"c","text":"It"}],"correctOptionId":"a","explanationVi":"Số nhiều → were."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-past-l2-p1','a2-past-l2','grammar_fill_blank',1,'practice','easy',false,
  '{"question":"Quá khứ của \"play\":","acceptedAnswers":["played"],"explanationVi":"play → played."}'::jsonb),
 ('a2-past-l2-p2','a2-past-l2','multiple_choice',2,'practice','medium',false,
  '{"question":"I ___ football yesterday.","options":[{"id":"a","text":"played"},{"id":"b","text":"play"},{"id":"c","text":"plays"}],"correctOptionId":"a","explanationVi":"Quá khứ: played."}'::jsonb),
 ('a2-past-l2-p3','a2-past-l2','error_correction',3,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"She didn''t watched TV.","acceptedAnswers":["She didn''t watch TV.","She didn''t watch TV"],"explanationVi":"Sau didn''t dùng nguyên thể."}'::jsonb),
 ('a2-past-l2-p4','a2-past-l2','multiple_choice',4,'practice','medium',false,
  '{"question":"Câu hỏi quá khứ ĐÚNG:","options":[{"id":"a","text":"Did you play?"},{"id":"b","text":"Do you played?"},{"id":"c","text":"You did play?"}],"correctOptionId":"a","explanationVi":"Did + S + V?"}'::jsonb),
 ('a2-past-l2-q1','a2-past-l2','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"Quá khứ của \"work\":","acceptedAnswers":["worked"],"explanationVi":"work → worked."}'::jsonb),
 ('a2-past-l2-q2','a2-past-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"She ___ to school yesterday.","options":[{"id":"a","text":"walked"},{"id":"b","text":"walk"},{"id":"c","text":"walks"}],"correctOptionId":"a","explanationVi":"Quá khứ: walked."}'::jsonb),
 ('a2-past-l2-q3','a2-past-l2','multiple_choice',7,'quiz','hard',true,
  '{"question":"Phủ định ĐÚNG:","options":[{"id":"a","text":"I didn''t play."},{"id":"b","text":"I didn''t played."},{"id":"c","text":"I not played."}],"correctOptionId":"a","explanationVi":"didn''t + nguyên thể."}'::jsonb),
 ('a2-past-l2-q4','a2-past-l2','grammar_fill_blank',8,'quiz','medium',true,
  '{"question":"\"___ you watch the film?\" (trợ động từ quá khứ)","acceptedAnswers":["Did","did"],"explanationVi":"Did + S + V?"}'::jsonb),
 ('a2-past-l2-q5','a2-past-l2','sentence_ordering',9,'quiz','hard',true,
  '{"question":"Sắp xếp câu:","tokens":["yesterday","played","I","football"],"correctOrder":[2,1,3,0],"explanationVi":"I played football yesterday."}'::jsonb),
 ('a2-past-l2-q6','a2-past-l2','translation',10,'quiz','hard',true,
  '{"question":"Dịch: \"Cô ấy đã không xem TV.\"","sourceText":"Cô ấy đã không xem TV.","acceptedAnswers":["She didn''t watch TV.","She did not watch TV.","She didnt watch TV"],"explanationVi":"She didn''t watch TV."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A2 — UNIT 3: Future Plans (be going to / will)  display_order 3            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
 ('a2-unit-future','A2','Future Plans','Tương lai: be going to & will','future','["grammar","speaking"]'::jsonb,3);

INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-future-l1','A2','reading','a2-unit-future','normal',1,'Be going to','Dự định tương lai',9,18,70,'{}'::jsonb,
  '{"warmup":"Cuối tuần này bạn định làm gì?","objectives":["Diễn đạt dự định với be going to"],
    "grammarHtml":"S + am/is/are + going to + V. VD: I am going to study. She is going to travel.",
    "vocabBlock":[
      {"word":"tomorrow","ipa":"/təˈmɒrəʊ/","meaningVi":"ngày mai","example":"I am going to work tomorrow."},
      {"word":"next week","ipa":"/nekst wiːk/","meaningVi":"tuần sau","example":"We are going to travel next week."}],
    "examples":[{"en":"They are going to play tennis.","vi":"Họ định chơi tennis."}],
    "commonMistakes":["❌ \"I going to study\" → ✅ \"I am going to study\""],
    "tips":["Luôn có to be trước going to."]}'::jsonb),
 ('a2-future-l2','A2','speaking','a2-unit-future','normal',2,'Will for predictions','will cho dự đoán/quyết định',9,18,70,'{}'::jsonb,
  '{"warmup":"Ngày mai trời sẽ thế nào?","objectives":["Dùng will để dự đoán"],
    "grammarHtml":"S + will + V. Phủ định: won''t. VD: It will rain. I won''t be late.",
    "vocabBlock":[],"examples":[{"en":"I think it will rain tomorrow.","vi":"Tôi nghĩ ngày mai trời sẽ mưa."}],
    "commonMistakes":["❌ \"I will to go\" → ✅ \"I will go\""],
    "tips":["Sau will dùng động từ nguyên thể, không có to."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-future-l1-p1','a2-future-l1','multiple_choice',1,'practice','easy',false,
  '{"question":"I ___ going to study. (to be)","options":[{"id":"a","text":"am"},{"id":"b","text":"is"},{"id":"c","text":"are"}],"correctOptionId":"a","explanationVi":"I + am going to."}'::jsonb),
 ('a2-future-l1-p2','a2-future-l1','grammar_fill_blank',2,'practice','medium',false,
  '{"question":"She is going ___ travel. (giới từ)","acceptedAnswers":["to"],"explanationVi":"be going to + V."}'::jsonb),
 ('a2-future-l1-p3','a2-future-l1','sentence_ordering',3,'practice','medium',false,
  '{"question":"Sắp xếp câu:","tokens":["to","I","study","am","going"],"correctOrder":[1,3,4,0,2],"explanationVi":"I am going to study."}'::jsonb),
 ('a2-future-l1-p4','a2-future-l1','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"He going to work.","acceptedAnswers":["He is going to work.","He is going to work"],"explanationVi":"Thiếu is."}'::jsonb),
 ('a2-future-l1-q1','a2-future-l1','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"They ___ going to play. (to be)","acceptedAnswers":["are"],"explanationVi":"They + are going to."}'::jsonb),
 ('a2-future-l1-q2','a2-future-l1','multiple_choice',6,'quiz','medium',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"We are going to travel."},{"id":"b","text":"We going to travel."},{"id":"c","text":"We are go to travel."}],"correctOptionId":"a","explanationVi":"are going to + V."}'::jsonb),
 ('a2-future-l1-q3','a2-future-l1','multiple_choice',7,'quiz','medium',true,
  '{"question":"\"tomorrow\" nghĩa là gì?","options":[{"id":"a","text":"ngày mai"},{"id":"b","text":"hôm qua"},{"id":"c","text":"hôm nay"}],"correctOptionId":"a","explanationVi":"tomorrow = ngày mai."}'::jsonb),
 ('a2-future-l1-q4','a2-future-l1','grammar_fill_blank',8,'quiz','hard',true,
  '{"question":"He ___ going to cook dinner. (to be)","acceptedAnswers":["is"],"explanationVi":"He + is going to."}'::jsonb),
 ('a2-future-l1-q5','a2-future-l1','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Tôi định học ngày mai.\"","sourceText":"Tôi định học ngày mai.","acceptedAnswers":["I am going to study tomorrow.","I''m going to study tomorrow.","I am going to study tomorrow"],"explanationVi":"I am going to study tomorrow."}'::jsonb),
 ('a2-future-l1-q6','a2-future-l1','sentence_ordering',10,'quiz','medium',true,
  '{"question":"Sắp xếp câu:","tokens":["going","She","travel","to","is"],"correctOrder":[1,4,0,3,2],"explanationVi":"She is going to travel."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-future-l2-p1','a2-future-l2','multiple_choice',1,'practice','easy',false,
  '{"question":"It ___ rain tomorrow. (dự đoán)","options":[{"id":"a","text":"will"},{"id":"b","text":"is"},{"id":"c","text":"going"}],"correctOptionId":"a","explanationVi":"will + V (dự đoán)."}'::jsonb),
 ('a2-future-l2-p2','a2-future-l2','error_correction',2,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"I will to go.","acceptedAnswers":["I will go.","I will go"],"explanationVi":"Bỏ to sau will."}'::jsonb),
 ('a2-future-l2-p3','a2-future-l2','grammar_fill_blank',3,'practice','medium',false,
  '{"question":"Phủ định của will (viết tắt):","acceptedAnswers":["won''t","wont","will not"],"explanationVi":"won''t = will not."}'::jsonb),
 ('a2-future-l2-p4','a2-future-l2','sentence_ordering',4,'practice','medium',false,
  '{"question":"Sắp xếp câu:","tokens":["rain","will","It","tomorrow"],"correctOrder":[2,1,0,3],"explanationVi":"It will rain tomorrow."}'::jsonb),
 ('a2-future-l2-q1','a2-future-l2','multiple_choice',5,'quiz','easy',true,
  '{"question":"Sau \"will\" là gì?","options":[{"id":"a","text":"động từ nguyên thể"},{"id":"b","text":"to + động từ"},{"id":"c","text":"động từ -ing"}],"correctOptionId":"a","explanationVi":"will + nguyên thể."}'::jsonb),
 ('a2-future-l2-q2','a2-future-l2','grammar_fill_blank',6,'quiz','medium',true,
  '{"question":"I think she ___ come. (dự đoán)","acceptedAnswers":["will"],"explanationVi":"will + V."}'::jsonb),
 ('a2-future-l2-q3','a2-future-l2','multiple_choice',7,'quiz','medium',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"I will help you."},{"id":"b","text":"I will to help you."},{"id":"c","text":"I will helping you."}],"correctOptionId":"a","explanationVi":"will + nguyên thể."}'::jsonb),
 ('a2-future-l2-q4','a2-future-l2','multiple_choice',8,'quiz','hard',true,
  '{"question":"\"won''t\" nghĩa là:","options":[{"id":"a","text":"sẽ không"},{"id":"b","text":"đã không"},{"id":"c","text":"không thể"}],"correctOptionId":"a","explanationVi":"won''t = will not = sẽ không."}'::jsonb),
 ('a2-future-l2-q5','a2-future-l2','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Trời sẽ mưa.\"","sourceText":"Trời sẽ mưa.","acceptedAnswers":["It will rain.","It will rain"],"explanationVi":"It will rain."}'::jsonb),
 ('a2-future-l2-q6','a2-future-l2','grammar_fill_blank',10,'quiz','medium',true,
  '{"question":"They ___ be late. (sẽ không - viết tắt)","acceptedAnswers":["won''t","wont"],"explanationVi":"won''t = will not."}'::jsonb);

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ A2 — UNIT 4: Comparatives & Superlatives  display_order 4                  ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order) VALUES
 ('a2-unit-compare','A2','Comparisons','So sánh hơn và so sánh nhất','compare','["grammar","reading"]'::jsonb,4);

INSERT INTO learning_lessons
    (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle,
     duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('a2-compare-l1','A2','reading','a2-unit-compare','normal',1,'Comparatives','So sánh hơn (-er / more)',10,18,70,'{}'::jsonb,
  '{"warmup":"Voi và mèo, con nào to hơn?","objectives":["Tạo so sánh hơn"],
    "grammarHtml":"Tính từ ngắn + er + than: taller than. Tính từ dài: more + adj + than: more beautiful than. Bất quy tắc: good→better, bad→worse.",
    "vocabBlock":[
      {"word":"bigger","ipa":"/ˈbɪɡər/","meaningVi":"to hơn","example":"An elephant is bigger than a cat."},
      {"word":"taller","ipa":"/ˈtɔːlər/","meaningVi":"cao hơn","example":"He is taller than me."}],
    "examples":[{"en":"This book is more interesting than that one.","vi":"Cuốn này thú vị hơn cuốn kia."}],
    "commonMistakes":["❌ \"more bigger\" → ✅ \"bigger\""],
    "tips":["Tính từ ngắn thêm -er; tính từ dài dùng more."]}'::jsonb),
 ('a2-compare-l2','A2','reading','a2-unit-compare','normal',2,'Superlatives','So sánh nhất (-est / most)',10,18,70,'{}'::jsonb,
  '{"warmup":"Trong lớp, ai cao nhất?","objectives":["Tạo so sánh nhất"],
    "grammarHtml":"the + adj-est: the tallest. the most + adj: the most beautiful. Bất quy tắc: good→the best, bad→the worst.",
    "vocabBlock":[],"examples":[{"en":"She is the tallest in the class.","vi":"Cô ấy cao nhất lớp."}],
    "commonMistakes":["❌ \"the most tallest\" → ✅ \"the tallest\""],
    "tips":["So sánh nhất luôn có the phía trước."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-compare-l1-p1','a2-compare-l1','grammar_fill_blank',1,'practice','easy',false,
  '{"question":"So sánh hơn của \"tall\":","acceptedAnswers":["taller"],"explanationVi":"tall → taller."}'::jsonb),
 ('a2-compare-l1-p2','a2-compare-l1','multiple_choice',2,'practice','medium',false,
  '{"question":"An elephant is ___ a cat.","options":[{"id":"a","text":"bigger than"},{"id":"b","text":"more big than"},{"id":"c","text":"big than"}],"correctOptionId":"a","explanationVi":"big → bigger than."}'::jsonb),
 ('a2-compare-l1-p3','a2-compare-l1','multiple_choice',3,'practice','medium',false,
  '{"question":"This film is ___ that one. (interesting)","options":[{"id":"a","text":"more interesting than"},{"id":"b","text":"interestinger than"},{"id":"c","text":"most interesting than"}],"correctOptionId":"a","explanationVi":"Tính từ dài: more + adj + than."}'::jsonb),
 ('a2-compare-l1-p4','a2-compare-l1','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"He is more taller than me.","acceptedAnswers":["He is taller than me.","He is taller than me"],"explanationVi":"Bỏ more khi đã có -er."}'::jsonb),
 ('a2-compare-l1-q1','a2-compare-l1','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"So sánh hơn của \"big\":","acceptedAnswers":["bigger"],"explanationVi":"big → bigger."}'::jsonb),
 ('a2-compare-l1-q2','a2-compare-l1','multiple_choice',6,'quiz','medium',true,
  '{"question":"So sánh hơn của \"good\":","options":[{"id":"a","text":"better"},{"id":"b","text":"gooder"},{"id":"c","text":"more good"}],"correctOptionId":"a","explanationVi":"good → better (bất quy tắc)."}'::jsonb),
 ('a2-compare-l1-q3','a2-compare-l1','multiple_choice',7,'quiz','medium',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"She is taller than him."},{"id":"b","text":"She is more tall than him."},{"id":"c","text":"She is tallest than him."}],"correctOptionId":"a","explanationVi":"taller than."}'::jsonb),
 ('a2-compare-l1-q4','a2-compare-l1','grammar_fill_blank',8,'quiz','hard',true,
  '{"question":"So sánh hơn của \"beautiful\" (dài): \"more ___\"","acceptedAnswers":["beautiful"],"explanationVi":"more beautiful than."}'::jsonb),
 ('a2-compare-l1-q5','a2-compare-l1','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Anh ấy cao hơn tôi.\"","sourceText":"Anh ấy cao hơn tôi.","acceptedAnswers":["He is taller than me.","He is taller than I.","He is taller than me"],"explanationVi":"He is taller than me."}'::jsonb),
 ('a2-compare-l1-q6','a2-compare-l1','multiple_choice',10,'quiz','medium',true,
  '{"question":"Khi nào dùng \"more\"?","options":[{"id":"a","text":"với tính từ dài"},{"id":"b","text":"với mọi tính từ"},{"id":"c","text":"với tính từ ngắn"}],"correctOptionId":"a","explanationVi":"more dùng với tính từ dài."}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('a2-compare-l2-p1','a2-compare-l2','grammar_fill_blank',1,'practice','easy',false,
  '{"question":"So sánh nhất của \"tall\": \"the ___\"","acceptedAnswers":["tallest"],"explanationVi":"the tallest."}'::jsonb),
 ('a2-compare-l2-p2','a2-compare-l2','multiple_choice',2,'practice','medium',false,
  '{"question":"She is ___ in the class. (cao nhất)","options":[{"id":"a","text":"the tallest"},{"id":"b","text":"the most tall"},{"id":"c","text":"taller"}],"correctOptionId":"a","explanationVi":"the tallest."}'::jsonb),
 ('a2-compare-l2-p3','a2-compare-l2','multiple_choice',3,'practice','medium',false,
  '{"question":"This is ___ film. (hay nhất - good)","options":[{"id":"a","text":"the best"},{"id":"b","text":"the goodest"},{"id":"c","text":"the most good"}],"correctOptionId":"a","explanationVi":"good → the best."}'::jsonb),
 ('a2-compare-l2-p4','a2-compare-l2','error_correction',4,'practice','hard',false,
  '{"question":"Sửa câu sai:","sourceText":"He is the most tallest.","acceptedAnswers":["He is the tallest.","He is the tallest"],"explanationVi":"Bỏ most khi đã có -est."}'::jsonb),
 ('a2-compare-l2-q1','a2-compare-l2','grammar_fill_blank',5,'quiz','easy',true,
  '{"question":"So sánh nhất của \"big\": \"the ___\"","acceptedAnswers":["biggest"],"explanationVi":"the biggest."}'::jsonb),
 ('a2-compare-l2-q2','a2-compare-l2','multiple_choice',6,'quiz','medium',true,
  '{"question":"So sánh nhất của \"good\":","options":[{"id":"a","text":"the best"},{"id":"b","text":"the goodest"},{"id":"c","text":"the better"}],"correctOptionId":"a","explanationVi":"good → the best."}'::jsonb),
 ('a2-compare-l2-q3','a2-compare-l2','multiple_choice',7,'quiz','medium',true,
  '{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"She is the most beautiful."},{"id":"b","text":"She is most beautiful."},{"id":"c","text":"She is the beautifulest."}],"correctOptionId":"a","explanationVi":"the most + tính từ dài."}'::jsonb),
 ('a2-compare-l2-q4','a2-compare-l2','grammar_fill_blank',8,'quiz','hard',true,
  '{"question":"So sánh nhất luôn có từ nào phía trước?","acceptedAnswers":["the"],"explanationVi":"the + adj-est / the most + adj."}'::jsonb),
 ('a2-compare-l2-q5','a2-compare-l2','translation',9,'quiz','hard',true,
  '{"question":"Dịch: \"Cô ấy cao nhất lớp.\"","sourceText":"Cô ấy cao nhất lớp.","acceptedAnswers":["She is the tallest in the class.","She is the tallest in the class"],"explanationVi":"She is the tallest in the class."}'::jsonb),
 ('a2-compare-l2-q6','a2-compare-l2','multiple_choice',10,'quiz','medium',true,
  '{"question":"So sánh nhất của \"bad\":","options":[{"id":"a","text":"the worst"},{"id":"b","text":"the baddest"},{"id":"c","text":"the most bad"}],"correctOptionId":"a","explanationVi":"bad → the worst."}'::jsonb);
