-- ══════════════════════════════════════════════════════════════════════════
-- B2 Curriculum: 10 units × 5 lessons = 50 lessons
-- Each normal lesson: 7 practice + 7 quiz activities
-- Unit review: 10 quiz-only activities
-- ══════════════════════════════════════════════════════════════════════════

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 0 — DỌN SẠCH B2 CŨ (idempotent)                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = NULL WHERE level_code = 'B2';

DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'B2');

-- learning_path_activities.lesson_id KHÔNG có ON DELETE CASCADE (V19) → xóa tay trước,
-- nếu không FK learning_path_activities_lesson_id_fkey chặn DELETE learning_lessons.
-- B2 path-based cũ (V19 seed b*-path lessons) trỏ qua bảng này.
DELETE FROM learning_path_activities
 WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'B2');

DELETE FROM learning_lessons WHERE level_code = 'B2';
DELETE FROM learning_units WHERE level_code = 'B2';

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 1 — 10 UNIT B2                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order, required_review_score) VALUES
 ('b2-u01','B2','Looking Back, Moving Forward','Nhìn lại & tiến về phía trước','narrative','["grammar","vocabulary","reading"]'::jsonb,1,75),
 ('b2-u02','B2','What Lies Ahead','Điều gì đang chờ phía trước','future','["grammar","vocabulary","listening"]'::jsonb,2,75),
 ('b2-u03','B2','What If? — Speculating','Nếu như? — Suy đoán & giả định','speculation','["grammar","vocabulary","reading"]'::jsonb,3,75),
 ('b2-u04','B2','On Condition That','Với điều kiện là','negotiation','["grammar","vocabulary","listening"]'::jsonb,4,75),
 ('b2-u05','B2','It Is Said That...','Người ta cho rằng...','media','["grammar","vocabulary","reading"]'::jsonb,5,75),
 ('b2-u06','B2','Getting Things Done','Nhờ người khác làm việc','services','["grammar","vocabulary","listening"]'::jsonb,6,75),
 ('b2-u07','B2','Detective Work — Past Deduction','Suy luận về quá khứ','deduction','["grammar","vocabulary","reading"]'::jsonb,7,75),
 ('b2-u08','B2','In Other Words','Mô tả chính xác bằng mệnh đề','description','["grammar","vocabulary","reading"]'::jsonb,8,75),
 ('b2-u09','B2','Building an Argument','Xây dựng lập luận & tranh luận','argument','["grammar","vocabulary","reading"]'::jsonb,9,75),
 ('b2-u10','B2','The More You Learn','Càng học càng giỏi — Tổng hợp','consolidation','["grammar","vocabulary","listening"]'::jsonb,10,75);

-- ══════════════════════════════════════════════════════════════════════════
-- UNIT 01 — Looking Back, Moving Forward
-- Theme: narrative | Narrative tenses; used to/be used to/get used to
-- ══════════════════════════════════════════════════════════════════════════

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b2-u01-l1','B2','reading','b2-u01','normal',1,'Narrative Tenses','Kể chuyện: past simple, continuous, perfect & perfect continuous',12,25,70,'{}'::jsonb,
  '{"warmup":"Hãy nghĩ về một câu chuyện đáng nhớ. Bạn sẽ kể nó như thế nào? Dùng thì nào để phân biệt ''bối cảnh'' và ''hành động chính''?",
    "objectives":["Phối hợp 4 thì quá khứ trong 1 câu chuyện","Phân biệt hành động chính (past simple) vs bối cảnh (past continuous) vs sự kiện trước (past perfect) vs quá trình trước (past perfect continuous)","Nhận biết cách dùng trong văn tự sự"],
    "grammarHtml":"<b>Bốn thì quá khứ trong kể chuyện:</b><br><b>Past simple:</b> S + V2/V-ed → hành động chính trong chuỗi sự kiện.<br><b>Past continuous:</b> S + was/were + V-ing → bối cảnh đang diễn ra khi hành động chính xảy ra.<br><b>Past perfect:</b> S + had + V3 → hành động xảy ra TRƯỚC hành động chính.<br><b>Past perfect continuous:</b> S + had been + V-ing → hành động đang diễn ra TRƯỚC và giải thích trạng thái.<br><b>Ví dụ tổng hợp:</b> While she was walking home (past cont.), she realised (past simple) she had forgotten (past perf.) her keys. She had been searching (past perf. cont.) for them all morning.",
    "vocabBlock":[
      {"word":"realise","ipa":"/ˈrɪəlaɪz/","meaningVi":"nhận ra","example":"She suddenly realised what had happened."},
      {"word":"turning point","ipa":"/ˈtɜːnɪŋ pɔɪnt/","meaningVi":"bước ngoặt","example":"That moment was a turning point in his life."},
      {"word":"in hindsight","ipa":"/ɪn ˈhaɪndsaɪt/","meaningVi":"nhìn lại thì thấy","example":"In hindsight, I should have left earlier."},
      {"word":"look back on","ipa":"/lʊk bæk ɒn/","meaningVi":"nhìn lại (quá khứ)","example":"I look back on that year with fond memories."},
      {"word":"meanwhile","ipa":"/ˈmiːnwaɪl/","meaningVi":"trong khi đó","example":"Meanwhile, the others were waiting outside."},
      {"word":"eventually","ipa":"/ɪˈventʃuəli/","meaningVi":"cuối cùng","example":"Eventually, he found what he was looking for."}],
    "examples":[
      {"en":"When I arrived, she had already left.","vi":"Khi tôi đến, cô ấy đã đi rồi."},
      {"en":"He was reading when the phone rang.","vi":"Anh ấy đang đọc sách thì điện thoại reo."},
      {"en":"She was exhausted because she had been running.","vi":"Cô ấy mệt vì đã chạy bộ liên tục."},
      {"en":"While they were talking, he slipped out.","vi":"Trong khi họ nói chuyện, anh ấy lén rời đi."}],
    "commonMistakes":["❌ Dùng past simple cho bối cảnh: ''He read when she called.'' → ✅ ''He was reading when she called.''","❌ Quên had cho sự kiện trước: ''When I arrived, she left.'' → ✅ ''...she had left.''","❌ Dùng past perfect cho cả hai sự kiện → chỉ sự kiện XẢY RA TRƯỚC mới dùng had + V3."],
    "tips":["While/when + past continuous = bối cảnh; hành động chính = past simple.","Tìm hai sự kiện quá khứ: cái nào trước → had + V3.","had been + V-ing = giải thích nguyên nhân của trạng thái."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b2-u01-l1-p1','b2-u01-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn thì đúng: ''She ___ (read) when he came in.''","options":[{"id":"a","text":"read"},{"id":"b","text":"was reading"},{"id":"c","text":"had read"}],"correctOptionId":"b","explanationVi":"Đang đọc (bối cảnh) khi anh ấy vào (hành động chính) → past continuous."}'::jsonb),
 ('b2-u01-l1-p2','b2-u01-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Chia động từ: ''By the time we arrived, they ___ (finish) dinner.''","acceptedAnswers":["had finished"],"explanationVi":"Ăn xong trước khi chúng tôi đến → past perfect."}'::jsonb),
 ('b2-u01-l1-p3','b2-u01-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"turning point","right":"bước ngoặt"},{"left":"in hindsight","right":"nhìn lại thì thấy"},{"left":"eventually","right":"cuối cùng"},{"left":"meanwhile","right":"trong khi đó"}],"explanationVi":"Từ vựng kể chuyện quan trọng."}'::jsonb),
 ('b2-u01-l1-p4','b2-u01-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Chia động từ: ''She was tired because she ___ (work) all day.''","acceptedAnswers":["had been working"],"explanationVi":"Làm việc liên tục trước trạng thái mệt → past perfect continuous."}'::jsonb),
 ('b2-u01-l1-p5','b2-u01-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Anh ấy đang đọc sách khi điện thoại reo.","acceptedAnswers":["He was reading when the phone rang.","He was reading a book when the phone rang."],"explanationVi":"Bối cảnh = was reading; hành động chính = rang."}'::jsonb),
 ('b2-u01-l1-p6','b2-u01-l1','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''When I arrived, she already left.''","acceptedAnswers":["When I arrived, she had already left."],"explanationVi":"Rời đi trước khi tôi đến → had already left."}'::jsonb),
 ('b2-u01-l1-p7','b2-u01-l1','sentence_ordering',7,'practice','medium',false,'{"question":"Sắp xếp thành câu đúng:","tokens":["had been","She","because","all morning","tired","searching","was","she"],"correctOrder":[1,6,0,2,3,5,4,7],"explanationVi":"She was tired because she had been searching all morning."}'::jsonb),
 ('b2-u01-l1-q1','b2-u01-l1','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu ĐÚNG cho bối cảnh đang xảy ra:","options":[{"id":"a","text":"It rained when she left the house."},{"id":"b","text":"It was raining when she left the house."},{"id":"c","text":"It had rained when she left the house."}],"correctOptionId":"b","explanationVi":"Bối cảnh đang mưa → was raining."}'::jsonb),
 ('b2-u01-l1-q2','b2-u01-l1','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Chia động từ: ''The thief ___ (escape) before the police arrived.''","acceptedAnswers":["had escaped"],"explanationVi":"Trốn thoát trước khi cảnh sát đến → had escaped."}'::jsonb),
 ('b2-u01-l1-q3','b2-u01-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Thì nào giải thích nguyên nhân của trạng thái quá khứ bằng quá trình kéo dài?","options":[{"id":"a","text":"Past simple"},{"id":"b","text":"Past perfect"},{"id":"c","text":"Past perfect continuous"}],"correctOptionId":"c","explanationVi":"Past perfect continuous nhấn thời lượng hành động diễn ra trước."}'::jsonb),
 ('b2-u01-l1-q4','b2-u01-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Chia động từ: ''While she ___ (walk) home, it started to rain.''","acceptedAnswers":["was walking"],"explanationVi":"Bối cảnh đang đi → was walking."}'::jsonb),
 ('b2-u01-l1-q5','b2-u01-l1','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối cụm từ với nghĩa:","pairs":[{"left":"look back on","right":"nhìn lại quá khứ"},{"left":"turning point","right":"bước ngoặt"},{"left":"in hindsight","right":"nhìn lại thì thấy"}],"explanationVi":"Ghép đúng từng cụm."}'::jsonb),
 ('b2-u01-l1-q6','b2-u01-l1','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["she","had","While","waiting","been","fell","asleep","was","she"],"correctOrder":[2,0,7,4,1,5,6,3,8],"explanationVi":"While she was waiting, she had been falling asleep / While she was waiting she fell asleep — pick correct parse: While she was waiting, she fell asleep."}'::jsonb),
 ('b2-u01-l1-q7','b2-u01-l1','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Chia động từ: ''His hands were dirty because he ___ (repair) the engine.''","acceptedAnswers":["had been repairing"],"explanationVi":"Sửa động cơ liên tục → had been repairing."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b2-u01-l2','B2','reading','b2-u01','normal',2,'Used to / Be Used to / Get Used to','Thói quen quá khứ vs sự quen thuộc',12,25,70,'{}'::jsonb,
  '{"warmup":"''Tôi thường đi bộ đến trường.'' / ''Tôi quen với việc thức khuya rồi.'' / ''Tôi đang dần quen với thời tiết lạnh.'' — ba câu này khác nhau thế nào?",
    "objectives":["Phân biệt used to, be used to, get used to","Dùng đúng cấu trúc sau mỗi dạng","Áp dụng trong ngữ cảnh kể chuyện và mô tả thay đổi"],
    "grammarHtml":"<b>used to + V (base):</b> thói quen hoặc trạng thái trong quá khứ (bây giờ không còn nữa).<br>He used to smoke. (đã từng hút, giờ không hút.)<br><b>be used to + V-ing/N:</b> quen với điều gì đó (đã quen rồi — trạng thái hiện tại hay quá khứ).<br>She is used to working night shifts. (đã quen rồi.)<br><b>get used to + V-ing/N:</b> dần dần quen với (quá trình thích nghi).<br>He is getting used to the cold weather. (đang dần quen.)<br><b>Lưu ý:</b> be/get used to dùng V-ing hoặc danh từ — KHÔNG dùng base verb.",
    "vocabBlock":[
      {"word":"used to","ipa":"/ˈjuːst tə/","meaningVi":"đã từng (quá khứ)","example":"I used to live in Hanoi."},
      {"word":"be used to","ipa":"/biː juːst tə/","meaningVi":"quen với","example":"She is used to getting up early."},
      {"word":"get used to","ipa":"/ɡet juːst tə/","meaningVi":"dần dần quen với","example":"It takes time to get used to a new city."},
      {"word":"adapt","ipa":"/əˈdæpt/","meaningVi":"thích nghi","example":"He quickly adapted to the new environment."},
      {"word":"adjust","ipa":"/əˈdʒʌst/","meaningVi":"điều chỉnh, thích nghi","example":"It took weeks to adjust to the new schedule."}],
    "examples":[
      {"en":"I used to play football every weekend.","vi":"Tôi đã từng chơi bóng đá mỗi cuối tuần."},
      {"en":"She is used to living alone.","vi":"Cô ấy đã quen sống một mình."},
      {"en":"He is getting used to the new job.","vi":"Anh ấy đang dần quen với công việc mới."},
      {"en":"I didn''t use to like coffee, but now I love it.","vi":"Trước đây tôi không thích cà phê, nhưng giờ tôi thích rồi."}],
    "commonMistakes":["❌ I am used to wake up early. → ✅ I am used to waking up early. (be used to + V-ing)","❌ I used to be living there. → ✅ I used to live there. (used to + base verb)","❌ She got used to work late. → ✅ She got used to working late."],
    "tips":["used to + bare infinitive: chỉ quá khứ.","be/get used to + V-ing/noun: hiện tại/quá khứ.","Dấu hiệu: ''at first / eventually'' → get used to (quá trình)."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b2-u01-l2-p1','b2-u01-l2','multiple_choice',1,'practice','easy',false,'{"question":"Chọn câu ĐÚNG diễn tả thói quen quá khứ (giờ không còn):","options":[{"id":"a","text":"I am used to walking to school."},{"id":"b","text":"I used to walk to school."},{"id":"c","text":"I got used to walk to school."}],"correctOptionId":"b","explanationVi":"Thói quen quá khứ không còn → used to + base verb."}'::jsonb),
 ('b2-u01-l2-p2','b2-u01-l2','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền đúng: ''She ___ (be used to / get up) early — it''s no problem for her.''","acceptedAnswers":["is used to getting up"],"explanationVi":"Đã quen rồi → be used to + V-ing."}'::jsonb),
 ('b2-u01-l2-p3','b2-u01-l2','vocabulary_match',3,'practice','easy',false,'{"question":"Nối cấu trúc với ý nghĩa:","pairs":[{"left":"used to + V","right":"thói quen quá khứ, không còn"},{"left":"be used to + V-ing","right":"đã quen rồi"},{"left":"get used to + V-ing","right":"đang dần quen"}],"explanationVi":"Phân biệt ba cấu trúc."}'::jsonb),
 ('b2-u01-l2-p4','b2-u01-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền đúng: ''It took him months to ___ (get used to / drive) on the left.''","acceptedAnswers":["get used to driving"],"explanationVi":"Quá trình thích nghi → get used to + V-ing."}'::jsonb),
 ('b2-u01-l2-p5','b2-u01-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Trước đây cô ấy không thích cà phê, nhưng giờ đã quen rồi.","acceptedAnswers":["She didn''t use to like coffee, but now she is used to it.","She used not to like coffee, but now she is used to it."],"explanationVi":"Quá khứ: didn''t use to like; hiện tại quen: is used to it."}'::jsonb),
 ('b2-u01-l2-p6','b2-u01-l2','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''I am used to wake up at 6 am.''","acceptedAnswers":["I am used to waking up at 6 am."],"explanationVi":"be used to + V-ing: waking up."}'::jsonb),
 ('b2-u01-l2-p7','b2-u01-l2','multiple_choice',7,'practice','medium',false,'{"question":"Chọn câu đúng cho quá trình thích nghi:","options":[{"id":"a","text":"She used to live in a big city."},{"id":"b","text":"She is used to the noise."},{"id":"c","text":"She is getting used to the busy traffic."}],"correctOptionId":"c","explanationVi":"Đang dần quen → get used to (quá trình)."}'::jsonb),
 ('b2-u01-l2-q1','b2-u01-l2','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu ĐÚNG: ''He ___ a lot of sport when he was young.''","options":[{"id":"a","text":"is used to playing"},{"id":"b","text":"used to play"},{"id":"c","text":"got used to play"}],"correctOptionId":"b","explanationVi":"Thói quen quá khứ → used to play."}'::jsonb),
 ('b2-u01-l2-q2','b2-u01-l2','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Điền đúng: ''After six months, she ___ (get used to / work) night shifts.''","acceptedAnswers":["got used to working"],"explanationVi":"Sau 6 tháng đã quen → got used to working."}'::jsonb),
 ('b2-u01-l2-q3','b2-u01-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Câu nào có nghĩa ''anh ấy đã quen với thức ăn cay rồi''?","options":[{"id":"a","text":"He used to eat spicy food."},{"id":"b","text":"He is used to eating spicy food."},{"id":"c","text":"He is getting used to eating spicy food."}],"correctOptionId":"b","explanationVi":"Đã quen rồi → be used to."}'::jsonb),
 ('b2-u01-l2-q4','b2-u01-l2','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền đúng: ''They ___ (not/use to) have a car — they cycled everywhere.''","acceptedAnswers":["didn''t use to","used not to"],"explanationVi":"Phủ định quá khứ: didn''t use to."}'::jsonb),
 ('b2-u01-l2-q5','b2-u01-l2','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"adapt","right":"thích nghi"},{"left":"adjust","right":"điều chỉnh, thích nghi"},{"left":"get used to","right":"dần dần quen với"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b2-u01-l2-q6','b2-u01-l2','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["to","It","him","used","took","long","get","to","driving","time"],"correctOrder":[1,4,9,2,7,6,0,5,8,3],"explanationVi":"It took him a long time to get used to driving."}'::jsonb),
 ('b2-u01-l2-q7','b2-u01-l2','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Điền đúng: ''At first I found it strange, but now I ___ (get used to / the schedule).''","acceptedAnswers":["am used to the schedule","have got used to the schedule"],"explanationVi":"Đã quen rồi (kết quả) → am used to / have got used to."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b2-u01-l3','B2','reading','b2-u01','normal',3,'Words for Experiences','Từ vựng trải nghiệm & cảm xúc B2',12,25,70,'{}'::jsonb,
  '{"warmup":"Khi bạn nhìn lại quá khứ, bạn dùng những từ nào? ''Nếu tôi biết trước...'' hay ''Bước ngoặt là khi...''?",
    "objectives":["Học 10 từ/cụm từ B2 về trải nghiệm sống","Dùng collocations trong ngữ cảnh kể chuyện","Phân biệt sắc thái giữa các từ đồng nghĩa"],
    "vocabBlock":[
      {"word":"turning point","ipa":"/ˈtɜːnɪŋ pɔɪnt/","meaningVi":"bước ngoặt, điểm chuyển đổi","example":"Meeting her was a turning point in my career."},
      {"word":"look back on","ipa":"/lʊk bæk ɒn/","meaningVi":"nhìn lại (quá khứ với cảm xúc)","example":"I look back on those years with nostalgia."},
      {"word":"in hindsight","ipa":"/ɪn ˈhaɪndsaɪt/","meaningVi":"nhìn lại mới thấy","example":"In hindsight, I made the wrong decision."},
      {"word":"broaden one''s horizons","ipa":"/ˈbrɔːdən wʌnz həˈraɪzənz/","meaningVi":"mở rộng tầm nhìn","example":"Travelling abroad broadened my horizons."},
      {"word":"life-changing","ipa":"/ˈlaɪf tʃeɪndʒɪŋ/","meaningVi":"thay đổi cuộc đời","example":"It was a life-changing experience."},
      {"word":"overcome","ipa":"/ˌəʊvəˈkʌm/","meaningVi":"vượt qua (thử thách)","example":"She overcame many obstacles to succeed."},
      {"word":"reflect on","ipa":"/rɪˈflekt ɒn/","meaningVi":"suy ngẫm về","example":"He reflected on his past mistakes."},
      {"word":"resilient","ipa":"/rɪˈzɪliənt/","meaningVi":"kiên cường, có sức bật","example":"She is incredibly resilient under pressure."},
      {"word":"setback","ipa":"/ˈsetbæk/","meaningVi":"thất bại tạm thời, trở ngại","example":"Every setback taught him something new."},
      {"word":"perspective","ipa":"/pəˈspektɪv/","meaningVi":"quan điểm, góc nhìn","example":"Travel gives you a new perspective on life."}],
    "examples":[
      {"en":"In hindsight, taking that job was the best decision I ever made.","vi":"Nhìn lại, nhận công việc đó là quyết định tốt nhất tôi từng đưa ra."},
      {"en":"She overcame every setback with resilience.","vi":"Cô ấy vượt qua mọi trở ngại với tinh thần kiên cường."},
      {"en":"Travelling broadened my horizons and changed my perspective.","vi":"Đi du lịch đã mở rộng tầm nhìn và thay đổi góc nhìn của tôi."}],
    "commonMistakes":["setback ≠ failure hoàn toàn — setback là trở ngại tạm thời có thể vượt qua.","resilient (tính từ) → resilience (danh từ): Her resilience is admirable.","reflect on + N/V-ing: He reflected on making that decision."],
    "tips":["turning point + in + bối cảnh: a turning point in my life/career/studies.","look back on + N/V-ing với cảm xúc (nostalgia/regret/pride)."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b2-u01-l3-p1','b2-u01-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"turning point","right":"bước ngoặt"},{"left":"setback","right":"trở ngại tạm thời"},{"left":"resilient","right":"kiên cường"},{"left":"perspective","right":"góc nhìn"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b2-u01-l3-p2','b2-u01-l3','vocabulary_match',2,'practice','easy',false,'{"question":"Nối cụm từ với nghĩa:","pairs":[{"left":"look back on","right":"nhìn lại quá khứ"},{"left":"in hindsight","right":"nhìn lại mới thấy"},{"left":"broaden horizons","right":"mở rộng tầm nhìn"},{"left":"reflect on","right":"suy ngẫm về"}],"explanationVi":"Ghép đúng từng cụm."}'::jsonb),
 ('b2-u01-l3-p3','b2-u01-l3','multiple_choice',3,'practice','easy',false,'{"question":"Từ nào có nghĩa là ''vượt qua'' (thử thách)?","options":[{"id":"a","text":"reflect"},{"id":"b","text":"overcome"},{"id":"c","text":"broaden"}],"correctOptionId":"b","explanationVi":"overcome = vượt qua thử thách."}'::jsonb),
 ('b2-u01-l3-p4','b2-u01-l3','multiple_choice',4,'practice','medium',false,'{"question":"Điền từ phù hợp: ''Every ___ taught him to be stronger.''","options":[{"id":"a","text":"turning point"},{"id":"b","text":"setback"},{"id":"c","text":"perspective"}],"correctOptionId":"b","explanationVi":"setback = trở ngại tạm thời có thể học hỏi từ đó."}'::jsonb),
 ('b2-u01-l3-p5','b2-u01-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Nhìn lại, tôi thấy đó là bước ngoặt quan trọng nhất trong cuộc đời.","acceptedAnswers":["In hindsight, it was the most important turning point in my life.","Looking back, it was the most important turning point in my life."],"explanationVi":"In hindsight + turning point in my life."}'::jsonb),
 ('b2-u01-l3-p6','b2-u01-l3','multiple_choice',6,'practice','medium',false,'{"question":"Cụm từ nào phù hợp: ''Travelling ___ and gave me a new ___ on life.''","options":[{"id":"a","text":"overcame my setbacks / turning point"},{"id":"b","text":"broadened my horizons / perspective"},{"id":"c","text":"reflected on / resilience"}],"correctOptionId":"b","explanationVi":"broadened my horizons + new perspective on life."}'::jsonb),
 ('b2-u01-l3-p7','b2-u01-l3','vocabulary_match',7,'practice','easy',false,'{"question":"Nối từ còn lại:","pairs":[{"left":"life-changing","right":"thay đổi cuộc đời"},{"left":"overcome","right":"vượt qua"}],"explanationVi":"Ghép đúng hai từ còn lại."}'::jsonb),
 ('b2-u01-l3-q1','b2-u01-l3','vocabulary_match',8,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"resilient","right":"kiên cường"},{"left":"setback","right":"trở ngại tạm thời"},{"left":"turning point","right":"bước ngoặt"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b2-u01-l3-q2','b2-u01-l3','multiple_choice',9,'quiz','easy',true,'{"question":"Từ nào có nghĩa là ''nhìn lại mới thấy''?","options":[{"id":"a","text":"meanwhile"},{"id":"b","text":"in hindsight"},{"id":"c","text":"eventually"}],"correctOptionId":"b","explanationVi":"in hindsight = nhìn lại thì mới thấy."}'::jsonb),
 ('b2-u01-l3-q3','b2-u01-l3','multiple_choice',10,'quiz','medium',true,'{"question":"Điền từ đúng: ''She ___ on her years abroad with great fondness.''","options":[{"id":"a","text":"looks back"},{"id":"b","text":"overcomes"},{"id":"c","text":"reflects back"}],"correctOptionId":"a","explanationVi":"look back on + N/period = nhìn lại với cảm xúc."}'::jsonb),
 ('b2-u01-l3-q4','b2-u01-l3','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền từ đúng: ''Travelling really ___ (broaden) my ___ and changed me.''","acceptedAnswers":["broadened my horizons"],"explanationVi":"broaden one''s horizons = mở rộng tầm nhìn."}'::jsonb),
 ('b2-u01-l3-q5','b2-u01-l3','multiple_choice',12,'quiz','medium',true,'{"question":"Từ nào mô tả người có khả năng phục hồi sau khó khăn?","options":[{"id":"a","text":"life-changing"},{"id":"b","text":"resilient"},{"id":"c","text":"overcome"}],"correctOptionId":"b","explanationVi":"resilient = kiên cường, có sức bật."}'::jsonb),
 ('b2-u01-l3-q6','b2-u01-l3','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["hindsight","In","the","was","decision","right","that"],"correctOrder":[1,0,3,6,2,5,4],"explanationVi":"In hindsight, that was the right decision."}'::jsonb),
 ('b2-u01-l3-q7','b2-u01-l3','vocabulary_match',14,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"perspective","right":"góc nhìn"},{"left":"reflect on","right":"suy ngẫm về"},{"left":"life-changing","right":"thay đổi cuộc đời"}],"explanationVi":"Ghép đúng."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b2-u01-l4','B2','reading','b2-u01','normal',4,'A Life-Changing Moment','Đọc hiểu: Khoảnh khắc đổi đời',12,25,70,'{}'::jsonb,
  '{"warmup":"Đọc câu chuyện về một khoảnh khắc thay đổi cuộc đời của David — chú ý cách dùng narrative tenses và từ vựng trải nghiệm.",
    "objectives":["Đọc hiểu văn bản tự sự B2 về trải nghiệm sống","Nhận biết narrative tenses và từ vựng trải nghiệm trong ngữ cảnh","Suy luận thái độ và cảm xúc của tác giả"],
    "vocabBlock":[
      {"word":"spontaneous","ipa":"/spɒnˈteɪniəs/","meaningVi":"tự phát, bột phát","example":"It was a spontaneous decision."},
      {"word":"embrace","ipa":"/ɪmˈbreɪs/","meaningVi":"đón nhận, chấp nhận","example":"He embraced the challenge with open arms."},
      {"word":"daunting","ipa":"/ˈdɔːntɪŋ/","meaningVi":"đáng sợ, khó khăn","example":"Moving to a new country is daunting."},
      {"word":"profound","ipa":"/prəˈfaʊnd/","meaningVi":"sâu sắc","example":"The experience had a profound effect on her."}],
    "examples":[
      {"en":"David had been working in the same office for ten years when he finally decided to make a change. He had always dreamed of travelling, but something had held him back — fear, routine, and the comfort of a stable job. One morning, while he was reading the news, he saw an advertisement for a teaching position in Vietnam. Without thinking too much, he applied. Three months later, he was standing in a classroom in Hanoi, nervous but excited. Looking back now, he says it was the best decision of his life. In hindsight, he had been waiting for that turning point without even knowing it. The experience broadened his horizons, taught him resilience, and gave him a completely new perspective on what matters in life.","vi":"David đã làm ở cùng một văn phòng được mười năm khi anh cuối cùng quyết định thay đổi. Anh luôn mơ ước được đi du lịch, nhưng có điều gì đó đã kìm hãm anh — nỗi sợ, thói quen, và sự thoải mái của công việc ổn định. Một buổi sáng, trong khi đang đọc tin tức, anh thấy một quảng cáo về vị trí giảng dạy ở Việt Nam. Không suy nghĩ nhiều, anh nộp đơn. Ba tháng sau, anh đứng trong lớp học ở Hà Nội, hồi hộp nhưng hào hứng. Nhìn lại bây giờ, anh nói đó là quyết định tốt nhất trong cuộc đời mình. Nhìn lại, anh đã chờ đợi bước ngoặt đó mà không hề biết. Trải nghiệm đó đã mở rộng tầm nhìn của anh, dạy anh về sự kiên cường, và cho anh một góc nhìn hoàn toàn mới về những gì quan trọng trong cuộc sống."}],
    "commonMistakes":["Đọc kỹ để phân biệt trạng thái (had been working) và hành động chính (decided)."],
    "tips":["Chú ý past perfect và past perfect continuous trong bài để hiểu thứ tự sự kiện.","Từ ''In hindsight'' và ''Looking back'' dẫn vào nhận xét của tác giả."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b2-u01-l4-p1','b2-u01-l4','multiple_choice',1,'practice','easy',false,'{"question":"David đã làm ở văn phòng bao lâu trước khi quyết định thay đổi?","options":[{"id":"a","text":"5 năm"},{"id":"b","text":"10 năm"},{"id":"c","text":"3 năm"}],"correctOptionId":"b","explanationVi":"''had been working in the same office for ten years.''"}'::jsonb),
 ('b2-u01-l4-p2','b2-u01-l4','multiple_choice',2,'practice','easy',false,'{"question":"David tìm thấy quảng cáo công việc như thế nào?","options":[{"id":"a","text":"Qua bạn bè"},{"id":"b","text":"Trong khi đọc tin tức"},{"id":"c","text":"Qua email"}],"correctOptionId":"b","explanationVi":"''while he was reading the news, he saw an advertisement.''"}'::jsonb),
 ('b2-u01-l4-p3','b2-u01-l4','multiple_choice',3,'practice','medium',false,'{"question":"Điều gì đã kìm hãm David suốt những năm qua?","options":[{"id":"a","text":"Thiếu tiền"},{"id":"b","text":"Sợ, thói quen, và sự thoải mái"},{"id":"c","text":"Gia đình phản đối"}],"correctOptionId":"b","explanationVi":"''fear, routine, and the comfort of a stable job.''"}'::jsonb),
 ('b2-u01-l4-p4','b2-u01-l4','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ trong bài với nghĩa:","pairs":[{"left":"spontaneous","right":"tự phát"},{"left":"daunting","right":"đáng sợ, khó khăn"},{"left":"embrace","right":"đón nhận"},{"left":"profound","right":"sâu sắc"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b2-u01-l4-p5','b2-u01-l4','multiple_choice',5,'practice','medium',false,'{"question":"Thì nào được dùng để diễn tả David đang đọc tin và thấy quảng cáo?","options":[{"id":"a","text":"Past simple + past simple"},{"id":"b","text":"Past continuous + past simple"},{"id":"c","text":"Past perfect + past simple"}],"correctOptionId":"b","explanationVi":"was reading (bối cảnh) + saw (hành động chính)."}'::jsonb),
 ('b2-u01-l4-p6','b2-u01-l4','multiple_choice',6,'practice','medium',false,'{"question":"David nói gì về quyết định đó khi nhìn lại?","options":[{"id":"a","text":"Anh ấy hối hận"},{"id":"b","text":"Đó là quyết định tốt nhất trong đời"},{"id":"c","text":"Anh ấy muốn về lại cũ"}],"correctOptionId":"b","explanationVi":"''it was the best decision of his life.''"}'::jsonb),
 ('b2-u01-l4-p7','b2-u01-l4','grammar_fill_blank',7,'practice','medium',false,'{"question":"Hoàn thành theo bài: ''He ___ (always/dream) of travelling but something ___ (hold) him back.''","acceptedAnswers":["had always dreamed / had held"],"explanationVi":"Cả hai hành động xảy ra trước quyết định → past perfect."}'::jsonb),
 ('b2-u01-l4-q1','b2-u01-l4','multiple_choice',8,'quiz','easy',true,'{"question":"David đi dạy ở thành phố nào?","options":[{"id":"a","text":"Hồ Chí Minh"},{"id":"b","text":"Đà Nẵng"},{"id":"c","text":"Hà Nội"}],"correctOptionId":"c","explanationVi":"''standing in a classroom in Hanoi.''"}'::jsonb),
 ('b2-u01-l4-q2','b2-u01-l4','multiple_choice',9,'quiz','easy',true,'{"question":"Câu ''he had been waiting for that turning point'' dùng thì nào?","options":[{"id":"a","text":"Past perfect"},{"id":"b","text":"Past perfect continuous"},{"id":"c","text":"Past continuous"}],"correctOptionId":"b","explanationVi":"had been waiting = past perfect continuous."}'::jsonb),
 ('b2-u01-l4-q3','b2-u01-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Từ ''daunting'' trong bài có nghĩa gần với từ nào?","options":[{"id":"a","text":"exciting"},{"id":"b","text":"challenging and scary"},{"id":"c","text":"boring"}],"correctOptionId":"b","explanationVi":"daunting = intimidating, challenging."}'::jsonb),
 ('b2-u01-l4-q4','b2-u01-l4','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Hoàn thành: ''Three months later, he was standing there, nervous ___ excited.''","acceptedAnswers":["but"],"explanationVi":"nervous but excited = đối lập hai trạng thái."}'::jsonb),
 ('b2-u01-l4-q5','b2-u01-l4','multiple_choice',12,'quiz','medium',true,'{"question":"Trải nghiệm đã mang lại cho David điều gì?","options":[{"id":"a","text":"Chỉ tiền bạc"},{"id":"b","text":"Resilience, broader horizons, new perspective"},{"id":"c","text":"Một công việc mới ở Mỹ"}],"correctOptionId":"b","explanationVi":"broadened horizons, taught resilience, new perspective."}'::jsonb),
 ('b2-u01-l4-q6','b2-u01-l4','vocabulary_match',13,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"profound","right":"sâu sắc"},{"left":"embrace","right":"đón nhận"},{"left":"spontaneous","right":"tự phát"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b2-u01-l4-q7','b2-u01-l4','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Chia động từ: ''While he ___ (read) the news, he ___ (see) an advert.''","acceptedAnswers":["was reading / saw"],"explanationVi":"was reading (bối cảnh) + saw (hành động chính)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b2-u01-l5','B2','reading','b2-u01','unit_review',5,'Unit 1 Review','Ôn tập Unit 1: Nhìn lại & tiến về phía trước',15,35,75,'{}'::jsonb,
  '{"warmup":"Ôn tập Unit 1: narrative tenses, used to/be used to/get used to và từ vựng trải nghiệm.","objectives":["Tổng hợp can-do Unit 1","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b2-u01-l5-q1','b2-u01-l5','grammar_fill_blank',1,'quiz','easy',true,'{"question":"Chia động từ: ''She ___ (read) when the news broke.''","acceptedAnswers":["was reading"],"explanationVi":"Bối cảnh đang đọc → was reading."}'::jsonb),
 ('b2-u01-l5-q2','b2-u01-l5','multiple_choice',2,'quiz','easy',true,'{"question":"Chọn câu ĐÚNG cho thói quen quá khứ không còn:","options":[{"id":"a","text":"I am used to cycling to work."},{"id":"b","text":"I used to cycle to work."},{"id":"c","text":"I get used to cycling to work."}],"correctOptionId":"b","explanationVi":"Thói quen quá khứ không còn → used to."}'::jsonb),
 ('b2-u01-l5-q3','b2-u01-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Từ nào có nghĩa là ''bước ngoặt''?","options":[{"id":"a","text":"setback"},{"id":"b","text":"turning point"},{"id":"c","text":"perspective"}],"correctOptionId":"b","explanationVi":"turning point = bước ngoặt."}'::jsonb),
 ('b2-u01-l5-q4','b2-u01-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Chia động từ: ''By the time he arrived, we ___ (wait) for an hour.''","acceptedAnswers":["had been waiting"],"explanationVi":"Chờ kéo dài trước khi anh đến → had been waiting."}'::jsonb),
 ('b2-u01-l5-q5','b2-u01-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Câu nào có nghĩa ''cô ấy đang dần quen với múi giờ mới''?","options":[{"id":"a","text":"She used to work night shifts."},{"id":"b","text":"She is used to the new time zone."},{"id":"c","text":"She is getting used to the new time zone."}],"correctOptionId":"c","explanationVi":"Quá trình thích nghi → getting used to."}'::jsonb),
 ('b2-u01-l5-q6','b2-u01-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"resilient","right":"kiên cường"},{"left":"in hindsight","right":"nhìn lại mới thấy"},{"left":"overcome","right":"vượt qua"},{"left":"reflect on","right":"suy ngẫm về"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b2-u01-l5-q7','b2-u01-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Điền đúng: ''After two years, he ___ (get used to / live) abroad.''","acceptedAnswers":["got used to living","had got used to living"],"explanationVi":"Kết quả sau 2 năm → got used to living."}'::jsonb),
 ('b2-u01-l5-q8','b2-u01-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["had","While","waiting","she","been","she","arrived","he"],"correctOrder":[1,3,0,4,2,6,5,7],"explanationVi":"While she had been waiting, he arrived."}'::jsonb),
 ('b2-u01-l5-q9','b2-u01-l5','multiple_choice',9,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG: ''He ___ not ___ to wake up early — it was a new experience.''","options":[{"id":"a","text":"was / used"},{"id":"b","text":"did / use"},{"id":"c","text":"got / used"}],"correctOptionId":"a","explanationVi":"was not used to = chưa quen → be used to."}'::jsonb),
 ('b2-u01-l5-q10','b2-u01-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"Chia động từ: ''In hindsight, she realised she ___ (make) a mistake.''","acceptedAnswers":["had made"],"explanationVi":"Nhận ra sau sự kiện → had made (past perfect)."}'::jsonb);

UPDATE learning_units SET review_lesson_id = 'b2-u01-l5' WHERE id = 'b2-u01';
