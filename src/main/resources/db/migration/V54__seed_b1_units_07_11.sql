-- ── UNIT 07 — He Said, She Said ──
-- B1 units 07-11: 5 units × 5 lessons = 25 lessons
-- Each normal lesson: 7 practice + 7 quiz activities
-- Unit review: 10 quiz-only activities

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 0 — DỌN SẠCH B1 units 07-11 CŨ (idempotent)                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = NULL WHERE level_code = 'B1' AND id IN ('b1-u07','b1-u08','b1-u09','b1-u10','b1-u11');

DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'B1' AND unit_id IN ('b1-u07','b1-u08','b1-u09','b1-u10','b1-u11'));

DELETE FROM learning_lessons WHERE level_code = 'B1' AND unit_id IN ('b1-u07','b1-u08','b1-u09','b1-u10','b1-u11');

DELETE FROM learning_units WHERE level_code = 'B1' AND id IN ('b1-u07','b1-u08','b1-u09','b1-u10','b1-u11');

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 1 — 5 UNIT B1 (07–11)                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
INSERT INTO learning_units (id, level_code, title, subtitle, theme, skill_coverage, display_order, required_review_score) VALUES
 ('b1-u07','B1','He Said, She Said','Lời nói gián tiếp','communication','["grammar","vocabulary","reading"]'::jsonb,7,75),
 ('b1-u08','B1','People & Places I Know','Người và nơi chốn quen thuộc','description','["grammar","vocabulary","listening"]'::jsonb,8,75),
 ('b1-u09','B1','It Must Be True!','Suy luận & Phỏng đoán','deduction','["grammar","vocabulary","reading"]'::jsonb,9,75),
 ('b1-u10','B1','Dealing With Problems','Giải quyết vấn đề','functional','["grammar","vocabulary","listening"]'::jsonb,10,75),
 ('b1-u11','B1','The World Around Us','Thế giới xung quanh','environment','["grammar","vocabulary","reading"]'::jsonb,11,75);

-- ── UNIT 07 — He Said, She Said ──

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u07-l1','B1','reading','b1-u07','normal',1,'Reported Speech – Statements','say/tell; backshift tenses; pronoun & time changes',10,20,70,'{}'::jsonb,
  '{"warmup":"Ai đó vừa nói gì đó với bạn. Bạn kể lại cho người khác nghe thế nào? Đó chính là câu gián tiếp!",
    "objectives":["Dùng say/tell để tường thuật câu nói","Lùi thì khi chuyển sang lời gián tiếp","Thay đổi đại từ và trạng từ thời gian phù hợp"],
    "grammarHtml":"<b>Lời trực tiếp → Gián tiếp:</b><br>He said: ''I am tired.'' → He said (that) he was tired.<br><b>Backshift thì:</b> am/is/are → was/were | do/does → did | will → would | can → could | have done → had done | is doing → was doing.<br><b>Thay đổi đại từ:</b> I → he/she | we → they | my → his/her.<br><b>Thay đổi trạng từ:</b> now → then | today → that day | yesterday → the day before | tomorrow → the next day | here → there | this → that.",
    "vocabBlock":[
      {"word":"say","ipa":"/seɪ/","meaningVi":"nói (dùng say + that)","example":"She said that she was tired."},
      {"word":"tell","ipa":"/tel/","meaningVi":"kể, nói với (dùng tell + người + that)","example":"He told me that he was leaving."},
      {"word":"that","ipa":"/ðæt/","meaningVi":"rằng (có thể bỏ qua)","example":"She said (that) she would come."},
      {"word":"backshift","ipa":"/ˈbækʃɪft/","meaningVi":"lùi thì","example":"''I am'' → she said she was."},
      {"word":"the day before","ipa":"/ðə deɪ bɪˈfɔː/","meaningVi":"ngày hôm trước","example":"She said she had left the day before."},
      {"word":"the next day","ipa":"/ðə nekst deɪ/","meaningVi":"ngày hôm sau","example":"He said he would call the next day."}],
    "examples":[
      {"en":"Direct: ''I am happy.'' → Reported: She said she was happy.","vi":"Trực tiếp: ''Tôi vui.'' → Gián tiếp: Cô ấy nói cô ấy đang vui."},
      {"en":"Direct: ''We will arrive tomorrow.'' → Reported: They said they would arrive the next day.","vi":"Trực tiếp: ''Chúng tôi sẽ đến ngày mai.'' → Gián tiếp: Họ nói họ sẽ đến vào ngày hôm sau."},
      {"en":"Direct: ''I have finished.'' → Reported: He said he had finished.","vi":"Trực tiếp: ''Tôi đã xong.'' → Gián tiếp: Anh ấy nói anh ấy đã xong."}],
    "commonMistakes":["❌ ''She said me that...'' → ✅ ''She told me that...'' (tell + người, say không có người)","❌ Quên lùi thì: ''He said he is tired.'' → ✅ ''He said he was tired.''","❌ Quên đổi trạng từ: ''She said she was here.'' → ✅ ''...she was there.''"],
    "tips":["say + (that): She said (that)... | tell + người + (that): She told me (that)...","Nếu câu trực tiếp là sự thật phổ quát, không cần backshift."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u07-l1-p1','b1-u07-l1','grammar_fill_blank',1,'practice','easy',false,'{"question":"Chuyển sang lời gián tiếp: ''I am tired.'' → She said she ___ tired.","acceptedAnswers":["was"],"explanationVi":"am → was (backshift present simple → past simple)."}'::jsonb),
 ('b1-u07-l1-p2','b1-u07-l1','multiple_choice',2,'practice','easy',false,'{"question":"Chọn câu gián tiếp ĐÚNG: Direct: ''I will call you tomorrow.''","options":[{"id":"a","text":"He said he will call me the next day."},{"id":"b","text":"He said he would call me the next day."},{"id":"c","text":"He said he would call me tomorrow."}],"correctOptionId":"b","explanationVi":"will → would; tomorrow → the next day."}'::jsonb),
 ('b1-u07-l1-p3','b1-u07-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối trạng từ trực tiếp với dạng gián tiếp:","pairs":[{"left":"now","right":"then"},{"left":"today","right":"that day"},{"left":"yesterday","right":"the day before"},{"left":"tomorrow","right":"the next day"}],"explanationVi":"Các cặp trạng từ thay đổi khi dùng lời gián tiếp."}'::jsonb),
 ('b1-u07-l1-p4','b1-u07-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Hoàn thành: Direct: ''We have finished.'' → They said they ___ finished.","acceptedAnswers":["had"],"explanationVi":"have/has → had (present perfect → past perfect)."}'::jsonb),
 ('b1-u07-l1-p5','b1-u07-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh (lời gián tiếp): Direct: ''I can swim.''","sourceText":"Anh ấy nói rằng anh ấy có thể bơi.","acceptedAnswers":["He said that he could swim.","He said he could swim."],"explanationVi":"can → could: He said he could swim."}'::jsonb),
 ('b1-u07-l1-p6','b1-u07-l1','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''She said me she was hungry.''","acceptedAnswers":["She told me she was hungry.","She told me that she was hungry."],"explanationVi":"say + (that), tell + người + (that): She told me she was hungry."}'::jsonb),
 ('b1-u07-l1-p7','b1-u07-l1','grammar_fill_blank',7,'practice','medium',false,'{"question":"Chuyển sang gián tiếp: ''I was here yesterday.'' → He said he ___ there the day before.","acceptedAnswers":["had been"],"explanationVi":"was → had been; here → there; yesterday → the day before."}'::jsonb),
 ('b1-u07-l1-q1','b1-u07-l1','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu gián tiếp ĐÚNG: Direct: ''I am studying.''","options":[{"id":"a","text":"She said she is studying."},{"id":"b","text":"She said she was studying."},{"id":"c","text":"She said she studied."}],"correctOptionId":"b","explanationVi":"am studying → was studying (backshift)."}'::jsonb),
 ('b1-u07-l1-q2','b1-u07-l1','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Chuyển thì: ''They will come.'' → She said they ___ come.","acceptedAnswers":["would"],"explanationVi":"will → would."}'::jsonb),
 ('b1-u07-l1-q3','b1-u07-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Câu gián tiếp nào đúng: Direct: ''I can help you.''","options":[{"id":"a","text":"He said he can help me."},{"id":"b","text":"He said he could help me."},{"id":"c","text":"He told he could help me."}],"correctOptionId":"b","explanationVi":"can → could; say (không dùng tell mà không có tân ngữ người)."}'::jsonb),
 ('b1-u07-l1-q4','b1-u07-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Chuyển trạng từ: ''I saw her today.'' → He said he had seen her ___.","acceptedAnswers":["that day"],"explanationVi":"today → that day trong lời gián tiếp."}'::jsonb),
 ('b1-u07-l1-q5','b1-u07-l1','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối trạng từ với dạng gián tiếp:","pairs":[{"left":"here","right":"there"},{"left":"this","right":"that"},{"left":"tomorrow","right":"the next day"}],"explanationVi":"Ghép đúng các cặp trạng từ."}'::jsonb),
 ('b1-u07-l1-q6','b1-u07-l1','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu gián tiếp đúng: Direct: ''I have done my homework.''","tokens":["said","She","had","she","her homework","done"],"correctOrder":[1,0,3,2,5,4],"explanationVi":"She said she had done her homework."}'::jsonb),
 ('b1-u07-l1-q7','b1-u07-l1','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Chuyển sang gián tiếp: ''I do not like it.'' → She said she ___ like it.","acceptedAnswers":["did not","didn''t"],"explanationVi":"do not → did not (backshift)."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u07-l2','B1','reading','b1-u07','normal',2,'Reported Questions','asked where/if/whether; word order changes',10,20,70,'{}'::jsonb,
  '{"warmup":"Khi bạn hỏi ai đó và kể lại câu hỏi đó cho người khác, bạn dùng reported questions!",
    "objectives":["Tường thuật câu hỏi Wh- và Yes/No","Nhận biết sự thay đổi trật tự từ trong câu hỏi gián tiếp","Dùng if/whether với câu hỏi Yes/No"],
    "grammarHtml":"<b>Câu hỏi Wh-:</b><br>Direct: ''Where do you live?'' → Reported: She asked where I lived.<br><b>Câu hỏi Yes/No:</b><br>Direct: ''Are you coming?'' → Reported: He asked if/whether I was coming.<br><b>Trật tự từ:</b> Câu hỏi gián tiếp dùng trật tự từ câu khẳng định (không đảo ngữ).<br>❌ She asked where did I live. → ✅ She asked where I lived.<br><b>Động từ:</b> ask + người + wh-word/if/whether + S + V (backshift).",
    "vocabBlock":[
      {"word":"ask","ipa":"/ɑːsk/","meaningVi":"hỏi","example":"She asked me where I lived."},
      {"word":"wonder","ipa":"/ˈwʌndə/","meaningVi":"tự hỏi","example":"I wondered if he was coming."},
      {"word":"whether","ipa":"/ˈweðə/","meaningVi":"liệu có... không","example":"He asked whether I was free."},
      {"word":"if","ipa":"/ɪf/","meaningVi":"có... không (câu hỏi Yes/No gián tiếp)","example":"She asked if I had eaten."},
      {"word":"want to know","ipa":"/wɒnt tə nəʊ/","meaningVi":"muốn biết","example":"He wanted to know why she was late."}],
    "examples":[
      {"en":"Direct: ''What time is it?'' → Reported: She asked what time it was.","vi":"Trực tiếp: ''Mấy giờ rồi?'' → Gián tiếp: Cô ấy hỏi mấy giờ rồi."},
      {"en":"Direct: ''Do you like coffee?'' → Reported: He asked if I liked coffee.","vi":"Trực tiếp: ''Bạn có thích cà phê không?'' → Gián tiếp: Anh ấy hỏi tôi có thích cà phê không."},
      {"en":"Direct: ''Where does she work?'' → Reported: I asked where she worked.","vi":"Trực tiếp: ''Cô ấy làm việc ở đâu?'' → Gián tiếp: Tôi hỏi cô ấy làm việc ở đâu."}],
    "commonMistakes":["❌ She asked where did I live. → ✅ She asked where I lived. (không đảo ngữ)","❌ He asked if was I coming. → ✅ He asked if I was coming."],
    "tips":["Câu hỏi gián tiếp = câu khẳng định về trật tự từ.","Yes/No question → dùng if hoặc whether."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u07-l2-p1','b1-u07-l2','grammar_fill_blank',1,'practice','easy',false,'{"question":"Chuyển sang câu hỏi gián tiếp: ''Where do you live?'' → She asked where I ___.","acceptedAnswers":["lived"],"explanationVi":"do live → lived (backshift); trật tự từ: I lived (không đảo ngữ)."}'::jsonb),
 ('b1-u07-l2-p2','b1-u07-l2','multiple_choice',2,'practice','easy',false,'{"question":"Chọn câu hỏi gián tiếp ĐÚNG: Direct: ''Are you coming?''","options":[{"id":"a","text":"He asked if I was coming."},{"id":"b","text":"He asked if was I coming."},{"id":"c","text":"He asked if I am coming."}],"correctOptionId":"a","explanationVi":"Yes/No → if; backshift; không đảo ngữ."}'::jsonb),
 ('b1-u07-l2-p3','b1-u07-l2','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"ask","right":"hỏi"},{"left":"wonder","right":"tự hỏi"},{"left":"whether","right":"liệu có không"},{"left":"if","right":"có không (Yes/No)"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u07-l2-p4','b1-u07-l2','grammar_fill_blank',4,'practice','medium',false,'{"question":"Chuyển sang gián tiếp: ''What time does the film start?'' → He asked what time the film ___.","acceptedAnswers":["started"],"explanationVi":"does start → started (backshift); trật tự câu khẳng định."}'::jsonb),
 ('b1-u07-l2-p5','b1-u07-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: Direct: ''Do you have a pen?''","sourceText":"Cô ấy hỏi tôi có bút không.","acceptedAnswers":["She asked if I had a pen.","She asked whether I had a pen."],"explanationVi":"Yes/No → if/whether; do have → had."}'::jsonb),
 ('b1-u07-l2-p6','b1-u07-l2','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''She asked where did he work.''","acceptedAnswers":["She asked where he worked."],"explanationVi":"Không đảo ngữ trong câu hỏi gián tiếp: where he worked."}'::jsonb),
 ('b1-u07-l2-p7','b1-u07-l2','multiple_choice',7,'practice','medium',false,'{"question":"Chọn câu ĐÚNG: Direct: ''Why are you late?''","options":[{"id":"a","text":"She asked why was I late."},{"id":"b","text":"She asked why I was late."},{"id":"c","text":"She asked why I am late."}],"correctOptionId":"b","explanationVi":"Backshift + không đảo ngữ: why I was late."}'::jsonb),
 ('b1-u07-l2-q1','b1-u07-l2','multiple_choice',8,'quiz','easy',true,'{"question":"Câu hỏi gián tiếp ĐÚNG: Direct: ''Do you speak French?''","options":[{"id":"a","text":"He asked if I speak French."},{"id":"b","text":"He asked if I spoke French."},{"id":"c","text":"He asked if spoke I French."}],"correctOptionId":"b","explanationVi":"if + S + V (backshift); không đảo ngữ."}'::jsonb),
 ('b1-u07-l2-q2','b1-u07-l2','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Chuyển sang gián tiếp: ''Where is the station?'' → She asked where the station ___.","acceptedAnswers":["was"],"explanationVi":"is → was (backshift)."}'::jsonb),
 ('b1-u07-l2-q3','b1-u07-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG: Direct: ''Have you eaten?''","options":[{"id":"a","text":"He asked if I have eaten."},{"id":"b","text":"He asked if I had eaten."},{"id":"c","text":"He asked whether had I eaten."}],"correctOptionId":"b","explanationVi":"if/whether + S + had eaten (past perfect)."}'::jsonb),
 ('b1-u07-l2-q4','b1-u07-l2','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Chuyển sang gián tiếp: ''Who is your teacher?'' → She asked who my teacher ___.","acceptedAnswers":["was"],"explanationVi":"is → was (backshift)."}'::jsonb),
 ('b1-u07-l2-q5','b1-u07-l2','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối từ với cách dùng:","pairs":[{"left":"if","right":"câu hỏi Yes/No gián tiếp"},{"left":"whether","right":"câu hỏi Yes/No (trang trọng hơn)"},{"left":"ask","right":"hỏi người khác"}],"explanationVi":"Ghép đúng từng cách dùng."}'::jsonb),
 ('b1-u07-l2-q6','b1-u07-l2','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi gián tiếp đúng: Direct: ''Where does she live?''","tokens":["asked","He","where","lived","she"],"correctOrder":[1,0,2,4,3],"explanationVi":"He asked where she lived."}'::jsonb),
 ('b1-u07-l2-q7','b1-u07-l2','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Chuyển sang gián tiếp: ''Will you help me?'' → She asked if I ___ her.","acceptedAnswers":["would help"],"explanationVi":"will → would; if I would help her."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u07-l3','B1','reading','b1-u07','normal',3,'Reporting Verbs & Communication','admit, suggest, complain, promise, warn, refuse...',10,20,70,'{}'::jsonb,
  '{"warmup":"Không phải lúc nào cũng dùng say/tell. Khi ai đó hứa, cảnh báo hay từ chối — bạn dùng từ gì?",
    "objectives":["Học 10 động từ tường thuật phổ biến ở B1","Dùng đúng cấu trúc sau mỗi động từ tường thuật","Phân biệt nghĩa và ngữ cảnh của từng động từ"],
    "vocabBlock":[
      {"word":"admit","ipa":"/ədˈmɪt/","meaningVi":"thừa nhận","example":"She admitted that she had made a mistake."},
      {"word":"suggest","ipa":"/səˈdʒest/","meaningVi":"gợi ý, đề xuất","example":"He suggested going to a café."},
      {"word":"complain","ipa":"/kəmˈpleɪn/","meaningVi":"phàn nàn","example":"She complained that the room was too cold."},
      {"word":"promise","ipa":"/ˈprɒmɪs/","meaningVi":"hứa","example":"He promised to call me."},
      {"word":"warn","ipa":"/wɔːn/","meaningVi":"cảnh báo","example":"She warned me not to be late."},
      {"word":"refuse","ipa":"/rɪˈfjuːz/","meaningVi":"từ chối","example":"He refused to answer the question."},
      {"word":"agree","ipa":"/əˈɡriː/","meaningVi":"đồng ý","example":"She agreed to help me."},
      {"word":"explain","ipa":"/ɪkˈspleɪn/","meaningVi":"giải thích","example":"He explained that the train was delayed."},
      {"word":"mention","ipa":"/ˈmenʃn/","meaningVi":"đề cập","example":"She mentioned that she was moving."},
      {"word":"remind","ipa":"/rɪˈmaɪnd/","meaningVi":"nhắc nhở","example":"He reminded me to lock the door."}],
    "examples":[
      {"en":"She admitted that she had broken the vase.","vi":"Cô ấy thừa nhận đã làm vỡ bình hoa."},
      {"en":"He warned me not to touch the wire.","vi":"Anh ấy cảnh báo tôi không được chạm vào dây điện."},
      {"en":"They refused to leave the building.","vi":"Họ từ chối rời khỏi tòa nhà."},
      {"en":"She reminded him to take his medicine.","vi":"Cô ấy nhắc anh ấy uống thuốc."}],
    "commonMistakes":["suggest + V-ing (không dùng to): He suggested going. ❌ He suggested to go.","warn + người + not to: She warned me not to be late.","remind + người + to: He reminded me to call."],
    "tips":["Động từ + to-inf: agree, promise, refuse, warn (not to), remind (to).","Động từ + that: admit, complain, explain, mention.","suggest + V-ing hoặc that."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u07-l3-p1','b1-u07-l3','vocabulary_match',1,'practice','easy',false,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"admit","right":"thừa nhận"},{"left":"promise","right":"hứa"},{"left":"warn","right":"cảnh báo"},{"left":"refuse","right":"từ chối"}],"explanationVi":"Ghép đúng từng động từ tường thuật."}'::jsonb),
 ('b1-u07-l3-p2','b1-u07-l3','vocabulary_match',2,'practice','easy',false,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"suggest","right":"gợi ý"},{"left":"complain","right":"phàn nàn"},{"left":"agree","right":"đồng ý"},{"left":"remind","right":"nhắc nhở"}],"explanationVi":"Ghép đúng từng động từ tường thuật."}'::jsonb),
 ('b1-u07-l3-p3','b1-u07-l3','multiple_choice',3,'practice','easy',false,'{"question":"Chọn động từ đúng: ''She ___ that she had forgotten her keys.'' (thừa nhận)","options":[{"id":"a","text":"warned"},{"id":"b","text":"admitted"},{"id":"c","text":"refused"}],"correctOptionId":"b","explanationVi":"admit = thừa nhận."}'::jsonb),
 ('b1-u07-l3-p4','b1-u07-l3','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền đúng cấu trúc: ''He suggested ___ (go) to the cinema.''","acceptedAnswers":["going"],"explanationVi":"suggest + V-ing: suggested going."}'::jsonb),
 ('b1-u07-l3-p5','b1-u07-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh:","sourceText":"Cô ấy nhắc tôi đóng cửa.","acceptedAnswers":["She reminded me to close the door.","She reminded me to shut the door."],"explanationVi":"remind + người + to: She reminded me to close the door."}'::jsonb),
 ('b1-u07-l3-p6','b1-u07-l3','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''He refused leaving the room.''","acceptedAnswers":["He refused to leave the room."],"explanationVi":"refuse + to-infinitive: refused to leave."}'::jsonb),
 ('b1-u07-l3-p7','b1-u07-l3','multiple_choice',7,'practice','medium',false,'{"question":"Chọn từ phù hợp: ''She ___ me not to be late for the meeting.''","options":[{"id":"a","text":"reminded"},{"id":"b","text":"warned"},{"id":"c","text":"suggested"}],"correctOptionId":"b","explanationVi":"warn not to = cảnh báo không nên."}'::jsonb),
 ('b1-u07-l3-q1','b1-u07-l3','vocabulary_match',8,'quiz','easy',true,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"explain","right":"giải thích"},{"left":"mention","right":"đề cập"},{"left":"complain","right":"phàn nàn"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u07-l3-q2','b1-u07-l3','multiple_choice',9,'quiz','easy',true,'{"question":"Từ nào có nghĩa là ''hứa''?","options":[{"id":"a","text":"refuse"},{"id":"b","text":"promise"},{"id":"c","text":"admit"}],"correctOptionId":"b","explanationVi":"promise = hứa."}'::jsonb),
 ('b1-u07-l3-q3','b1-u07-l3','grammar_fill_blank',10,'quiz','medium',true,'{"question":"Điền đúng cấu trúc: ''She agreed ___ (help) me with the project.''","acceptedAnswers":["to help"],"explanationVi":"agree + to-infinitive: agreed to help."}'::jsonb),
 ('b1-u07-l3-q4','b1-u07-l3','multiple_choice',11,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"He suggested to take a break."},{"id":"b","text":"He suggested taking a break."},{"id":"c","text":"He suggested take a break."}],"correctOptionId":"b","explanationVi":"suggest + V-ing: suggested taking."}'::jsonb),
 ('b1-u07-l3-q5','b1-u07-l3','grammar_fill_blank',12,'quiz','medium',true,'{"question":"Điền động từ phù hợp: ''She ___ that she had made an error.'' (thừa nhận)","acceptedAnswers":["admitted"],"explanationVi":"admit + that: admitted that."}'::jsonb),
 ('b1-u07-l3-q6','b1-u07-l3','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["warned","She","not to","him","the wire","touch"],"correctOrder":[1,0,3,2,5,4],"explanationVi":"She warned him not to touch the wire."}'::jsonb),
 ('b1-u07-l3-q7','b1-u07-l3','vocabulary_match',14,'quiz','medium',true,'{"question":"Nối động từ tường thuật với cấu trúc đúng:","pairs":[{"left":"promise","right":"+ to-inf"},{"left":"suggest","right":"+ V-ing"},{"left":"remind","right":"+ người + to-inf"}],"explanationVi":"Ghép đúng cấu trúc theo sau mỗi động từ."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u07-l4','B1','reading','b1-u07','normal',4,'A Misunderstanding by Text','Đọc hiểu: Hiểu lầm qua tin nhắn',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn đã bao giờ bị hiểu lầm qua tin nhắn chưa? Hãy đọc câu chuyện của Minh và Lan.",
    "objectives":["Đọc hiểu đoạn văn B1 về chủ đề giao tiếp và hiểu lầm","Nhận biết lời gián tiếp và động từ tường thuật trong văn bản","Ôn từ vựng về communication"],
    "vocabBlock":[
      {"word":"misunderstanding","ipa":"/ˌmɪsʌndəˈstændɪŋ/","meaningVi":"sự hiểu lầm","example":"It was all a misunderstanding."},
      {"word":"apologise","ipa":"/əˈpɒlədʒaɪz/","meaningVi":"xin lỗi","example":"She apologised for being late."},
      {"word":"clear up","ipa":"/klɪər ʌp/","meaningVi":"giải quyết, làm rõ","example":"They cleared up the misunderstanding."},
      {"word":"upset","ipa":"/ʌpˈset/","meaningVi":"buồn bã, khó chịu","example":"She was upset about the message."}],
    "examples":[
      {"en":"Last week, Minh sent Lan a text message saying he couldn''t come to her birthday party. Lan read the message quickly and thought Minh had said he didn''t want to come. She told her friends that Minh had refused to come and didn''t care about her. The next day, Minh called her and explained that he had said he couldn''t come because he had to work late, not that he didn''t want to. Lan admitted that she had misread the message. She apologised and said she was sorry for telling others the wrong thing. Minh said he understood and suggested meeting at the weekend to celebrate. In the end, they cleared up the misunderstanding and both agreed that talking directly was better than texting.","vi":"Tuần trước, Minh nhắn tin cho Lan nói anh không thể đến tiệc sinh nhật của cô. Lan đọc tin nhắn vội và nghĩ Minh nói anh không muốn đến. Cô kể với bạn bè rằng Minh từ chối đến và không quan tâm đến cô. Hôm sau, Minh gọi điện giải thích rằng anh nói không thể đến vì phải làm thêm giờ, không phải vì không muốn. Lan thừa nhận cô đã đọc nhầm tin nhắn. Cô xin lỗi và nói cô tiếc vì đã nói sai cho người khác. Minh nói anh hiểu và gợi ý gặp nhau cuối tuần để ăn mừng. Cuối cùng, họ giải quyết được hiểu lầm và đều đồng ý rằng nói chuyện trực tiếp tốt hơn nhắn tin."}],
    "commonMistakes":["Đọc kỹ để phân biệt điều Minh thực sự nói và điều Lan nghĩ anh nói."],
    "tips":["Chú ý các động từ tường thuật: explained, admitted, apologised, suggested, agreed."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u07-l4-p1','b1-u07-l4','multiple_choice',1,'practice','easy',false,'{"question":"Tại sao Minh không thể đến tiệc sinh nhật?","options":[{"id":"a","text":"Anh ấy không muốn đến"},{"id":"b","text":"Anh ấy phải làm thêm giờ"},{"id":"c","text":"Anh ấy bị ốm"}],"correctOptionId":"b","explanationVi":"''he couldn''t come because he had to work late.''"}'::jsonb),
 ('b1-u07-l4-p2','b1-u07-l4','multiple_choice',2,'practice','easy',false,'{"question":"Lan đã nói gì với bạn bè?","options":[{"id":"a","text":"Minh sẽ đến muộn"},{"id":"b","text":"Minh từ chối đến và không quan tâm"},{"id":"c","text":"Minh đang bận họp"}],"correctOptionId":"b","explanationVi":"''told her friends that Minh had refused to come.''"}'::jsonb),
 ('b1-u07-l4-p3','b1-u07-l4','multiple_choice',3,'practice','medium',false,'{"question":"Lan thừa nhận điều gì?","options":[{"id":"a","text":"Cô ấy đã không đọc tin nhắn"},{"id":"b","text":"Cô ấy đã đọc nhầm tin nhắn"},{"id":"c","text":"Cô ấy đã xóa tin nhắn"}],"correctOptionId":"b","explanationVi":"''Lan admitted that she had misread the message.''"}'::jsonb),
 ('b1-u07-l4-p4','b1-u07-l4','vocabulary_match',4,'practice','easy',false,'{"question":"Nối từ trong bài với nghĩa:","pairs":[{"left":"misunderstanding","right":"sự hiểu lầm"},{"left":"apologise","right":"xin lỗi"},{"left":"clear up","right":"giải quyết, làm rõ"},{"left":"upset","right":"buồn bã"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u07-l4-p5','b1-u07-l4','multiple_choice',5,'practice','medium',false,'{"question":"Minh gợi ý điều gì?","options":[{"id":"a","text":"Gặp nhau cuối tuần"},{"id":"b","text":"Gọi điện mỗi ngày"},{"id":"c","text":"Không nhắn tin nữa"}],"correctOptionId":"a","explanationVi":"''suggested meeting at the weekend to celebrate.''"}'::jsonb),
 ('b1-u07-l4-p6','b1-u07-l4','multiple_choice',6,'practice','medium',false,'{"question":"Cả hai đồng ý rằng điều gì tốt hơn?","options":[{"id":"a","text":"Nhắn tin nhiều hơn"},{"id":"b","text":"Gọi điện thay vì nhắn tin"},{"id":"c","text":"Nói chuyện trực tiếp"}],"correctOptionId":"c","explanationVi":"''talking directly was better than texting.''"}'::jsonb),
 ('b1-u07-l4-p7','b1-u07-l4','grammar_fill_blank',7,'practice','medium',false,'{"question":"Hoàn thành theo bài: ''Minh explained that he ___ (have to) work late.''","acceptedAnswers":["had to"],"explanationVi":"have to → had to (backshift)."}'::jsonb),
 ('b1-u07-l4-q1','b1-u07-l4','multiple_choice',8,'quiz','easy',true,'{"question":"Điều gì gây ra hiểu lầm?","options":[{"id":"a","text":"Minh không gọi điện"},{"id":"b","text":"Lan đọc nhầm tin nhắn"},{"id":"c","text":"Minh đến muộn"}],"correctOptionId":"b","explanationVi":"''she had misread the message'' → đọc nhầm tin nhắn."}'::jsonb),
 ('b1-u07-l4-q2','b1-u07-l4','multiple_choice',9,'quiz','easy',true,'{"question":"Động từ tường thuật nào Lan dùng khi kể với bạn bè?","options":[{"id":"a","text":"admitted"},{"id":"b","text":"told"},{"id":"c","text":"suggested"}],"correctOptionId":"b","explanationVi":"''told her friends that...''"}'::jsonb),
 ('b1-u07-l4-q3','b1-u07-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Chuyển câu sau sang lời gián tiếp: ''I can''t come.'' → Minh said he ___ come.","options":[{"id":"a","text":"can''t"},{"id":"b","text":"couldn''t"},{"id":"c","text":"won''t"}],"correctOptionId":"b","explanationVi":"can''t → couldn''t (backshift)."}'::jsonb),
 ('b1-u07-l4-q4','b1-u07-l4','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Hoàn thành: ''She apologised for ___ (tell) others the wrong thing.''","acceptedAnswers":["telling"],"explanationVi":"apologise for + V-ing: apologised for telling."}'::jsonb),
 ('b1-u07-l4-q5','b1-u07-l4','multiple_choice',12,'quiz','medium',true,'{"question":"Minh gọi điện để làm gì?","options":[{"id":"a","text":"Xin lỗi Lan"},{"id":"b","text":"Giải thích lý do thực sự"},{"id":"c","text":"Hủy kế hoạch cuối tuần"}],"correctOptionId":"b","explanationVi":"''Minh called her and explained that...''"}'::jsonb),
 ('b1-u07-l4-q6','b1-u07-l4','vocabulary_match',13,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"misunderstanding","right":"sự hiểu lầm"},{"left":"apologise","right":"xin lỗi"},{"left":"clear up","right":"giải quyết"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u07-l4-q7','b1-u07-l4','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Hoàn thành lời gián tiếp: ''I will call tomorrow.'' → Minh said he ___ call the next day.","acceptedAnswers":["would"],"explanationVi":"will → would; tomorrow → the next day."}'::jsonb);

INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u07-l5','B1','reading','b1-u07','unit_review',5,'Unit 7 Review','Ôn tập Unit 7: He Said, She Said',12,30,75,'{}'::jsonb,
  '{"warmup":"Ôn tập Unit 7: lời gián tiếp, câu hỏi gián tiếp và động từ tường thuật.","objectives":["Tổng hợp can-do Unit 7","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u07-l5-q1','b1-u07-l5','grammar_fill_blank',1,'quiz','easy',true,'{"question":"Chuyển sang gián tiếp: ''I am busy.'' → She said she ___ busy.","acceptedAnswers":["was"],"explanationVi":"am → was (backshift)."}'::jsonb),
 ('b1-u07-l5-q2','b1-u07-l5','multiple_choice',2,'quiz','easy',true,'{"question":"Chọn câu gián tiếp ĐÚNG: Direct: ''I will help you.''","options":[{"id":"a","text":"She said she will help me."},{"id":"b","text":"She said she would help me."},{"id":"c","text":"She told she would help me."}],"correctOptionId":"b","explanationVi":"will → would; say (không dùng told mà không có tân ngữ người)."}'::jsonb),
 ('b1-u07-l5-q3','b1-u07-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Câu hỏi gián tiếp ĐÚNG: Direct: ''Where do you live?''","options":[{"id":"a","text":"She asked where did I live."},{"id":"b","text":"She asked where I lived."},{"id":"c","text":"She asked where I live."}],"correctOptionId":"b","explanationVi":"Không đảo ngữ; backshift: I lived."}'::jsonb),
 ('b1-u07-l5-q4','b1-u07-l5','grammar_fill_blank',4,'quiz','medium',true,'{"question":"Điền từ đúng: ''He suggested ___ (take) a different route.''","acceptedAnswers":["taking"],"explanationVi":"suggest + V-ing: suggested taking."}'::jsonb),
 ('b1-u07-l5-q5','b1-u07-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu ĐÚNG: Direct: ''Are you free tonight?''","options":[{"id":"a","text":"She asked if I am free tonight."},{"id":"b","text":"She asked if I was free that night."},{"id":"c","text":"She asked whether was I free."}],"correctOptionId":"b","explanationVi":"if + backshift; tonight → that night."}'::jsonb),
 ('b1-u07-l5-q6','b1-u07-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối động từ với nghĩa:","pairs":[{"left":"admit","right":"thừa nhận"},{"left":"warn","right":"cảnh báo"},{"left":"remind","right":"nhắc nhở"},{"left":"refuse","right":"từ chối"}],"explanationVi":"Ghép đúng từng động từ tường thuật."}'::jsonb),
 ('b1-u07-l5-q7','b1-u07-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Chuyển trạng từ: ''She said she was coming now.'' → Câu trực tiếp: ''I am coming ___.''","acceptedAnswers":["now"],"explanationVi":"now → then (gián tiếp); then → now (trực tiếp)."}'::jsonb),
 ('b1-u07-l5-q8','b1-u07-l5','sentence_ordering',8,'quiz','hard',true,'{"question":"Sắp xếp thành câu hỏi gián tiếp đúng: Direct: ''Have you finished?''","tokens":["asked","He","if","finished","had","I"],"correctOrder":[1,0,2,5,4,3],"explanationVi":"He asked if I had finished."}'::jsonb),
 ('b1-u07-l5-q9','b1-u07-l5','multiple_choice',9,'quiz','medium',true,'{"question":"Câu ĐÚNG với refuse:","options":[{"id":"a","text":"She refused answering."},{"id":"b","text":"She refused to answer."},{"id":"c","text":"She refused answer."}],"correctOptionId":"b","explanationVi":"refuse + to-infinitive: refused to answer."}'::jsonb),
 ('b1-u07-l5-q10','b1-u07-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"Chuyển sang gián tiếp: ''I have never been to Paris.'' → She said she ___ never been to Paris.","acceptedAnswers":["had"],"explanationVi":"have → had (present perfect → past perfect)."}'::jsonb);

UPDATE learning_units SET review_lesson_id = 'b1-u07-l5' WHERE id = 'b1-u07';
