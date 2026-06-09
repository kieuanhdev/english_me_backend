-- ── UNIT 08 — People & Places I Know ──
-- ── UNIT 09 — It Must Be True! ──
-- Each normal lesson: 7 practice + 7 quiz activities
-- Unit review: 10 quiz-only activities

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ BƯỚC 0 — DỌN SẠCH B1 units 08-09 CŨ (idempotent)                        ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
UPDATE learning_units SET review_lesson_id = NULL WHERE level_code = 'B1' AND id IN ('b1-u08','b1-u09');

DELETE FROM learning_lesson_activities
 WHERE lesson_id IN (SELECT id FROM learning_lessons WHERE level_code = 'B1' AND unit_id IN ('b1-u08','b1-u09'));

DELETE FROM learning_lessons WHERE level_code = 'B1' AND unit_id IN ('b1-u08','b1-u09');

-- ══════════════════════════════════════════════════════════════════════════
-- UNIT 08 — People & Places I Know
-- Theme: description | Relative clauses (defining & non-defining), adjective order
-- ══════════════════════════════════════════════════════════════════════════

-- Lesson 08-L1: Defining Relative Clauses
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u08-l1','B1','reading','b1-u08','normal',1,'Defining Relative Clauses','who/which/that/where/whose — xác định danh từ',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn có thể mô tả một người mà không cần nói tên không? Đó chính là mệnh đề quan hệ xác định!",
    "objectives":["Dùng who/which/that để xác định người hoặc vật","Dùng where/whose trong mệnh đề quan hệ","Phân biệt mệnh đề quan hệ xác định và bổ sung"],
    "grammarHtml":"<b>Mệnh đề quan hệ xác định</b> cho biết danh từ nào được đề cập (không có dấu phẩy):<br>who/that → người: The woman <u>who works here</u> is my aunt.<br>which/that → vật: The book <u>which/that I read</u> was amazing.<br>where → nơi chốn: The café <u>where we met</u> is closed.<br>whose → sở hữu: The man <u>whose car broke down</u> called a mechanic.<br><b>Lưu ý:</b> that có thể thay cho who/which trong mệnh đề xác định. Khi relative pronoun là tân ngữ, có thể bỏ qua.",
    "vocabBlock":[
      {"word":"relative clause","ipa":"/ˈrelətɪv klɔːz/","meaningVi":"mệnh đề quan hệ","example":"The man who called is my boss."},
      {"word":"who","ipa":"/huː/","meaningVi":"người (chủ ngữ)","example":"The girl who sings is talented."},
      {"word":"which","ipa":"/wɪtʃ/","meaningVi":"vật","example":"The film which I watched was great."},
      {"word":"whose","ipa":"/huːz/","meaningVi":"mà... của anh/cô ấy","example":"The student whose work I marked passed."},
      {"word":"where","ipa":"/weə/","meaningVi":"nơi mà","example":"The town where I grew up is small."},
      {"word":"that","ipa":"/ðæt/","meaningVi":"người/vật (xác định)","example":"The car that I drive is new."}],
    "examples":[
      {"en":"The teacher who taught me English was very kind.","vi":"Người thầy dạy tiếng Anh cho tôi rất tốt bụng."},
      {"en":"The phone that I bought last week is broken.","vi":"Chiếc điện thoại tôi mua tuần trước bị hỏng."},
      {"en":"The restaurant where we had dinner was expensive.","vi":"Nhà hàng chúng tôi ăn tối khá đắt."},
      {"en":"The woman whose bag was stolen called the police.","vi":"Người phụ nữ bị mất túi đã gọi cảnh sát."}],
    "commonMistakes":["❌ The man which called. → ✅ The man who called. (người → who/that)","❌ The place where I live there. → ✅ The place where I live. (không lặp ''there'')","❌ The woman whose she works here. → ✅ The woman who works here."],
    "tips":["Mệnh đề xác định: không có dấu phẩy, không thể bỏ.","that có thể thay who/which trong mệnh đề xác định."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u08-l1-p1','b1-u08-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn từ đúng: ''The man ___ called is my uncle.''","options":[{"id":"a","text":"which"},{"id":"b","text":"who"},{"id":"c","text":"where"}],"correctOptionId":"b","explanationVi":"Người → who/that."}'::jsonb),
 ('b1-u08-l1-p2','b1-u08-l1','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền vào chỗ trống: ''The book ___ I read was fantastic.''","acceptedAnswers":["which","that"],"explanationVi":"Vật → which/that."}'::jsonb),
 ('b1-u08-l1-p3','b1-u08-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối đại từ quan hệ với chức năng:","pairs":[{"left":"who","right":"người"},{"left":"which","right":"vật"},{"left":"where","right":"nơi chốn"},{"left":"whose","right":"sở hữu"}],"explanationVi":"Ghép đúng từng đại từ quan hệ."}'::jsonb),
 ('b1-u08-l1-p4','b1-u08-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền vào chỗ trống: ''The town ___ I grew up is very small.''","acceptedAnswers":["where"],"explanationVi":"Nơi chốn → where."}'::jsonb),
 ('b1-u08-l1-p5','b1-u08-l1','multiple_choice',5,'practice','medium',false,'{"question":"Chọn câu ĐÚNG:","options":[{"id":"a","text":"The student whose notes I borrowed is helpful."},{"id":"b","text":"The student which notes I borrowed is helpful."},{"id":"c","text":"The student who notes I borrowed is helpful."}],"correctOptionId":"a","explanationVi":"Sở hữu → whose."}'::jsonb),
 ('b1-u08-l1-p6','b1-u08-l1','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''The city where I live there is polluted.''","acceptedAnswers":["The city where I live is polluted."],"explanationVi":"where đã thay thế ''there'', không lặp lại."}'::jsonb),
 ('b1-u08-l1-p7','b1-u08-l1','sentence_ordering',7,'practice','medium',false,'{"question":"Sắp xếp thành câu đúng:","tokens":["The","woman","who","teaches","us","is","kind"],"correctOrder":[0,1,2,3,4,5,6],"explanationVi":"The woman who teaches us is kind."}'::jsonb),
 ('b1-u08-l1-q1','b1-u08-l1','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn từ đúng: ''The film ___ we watched was boring.''","options":[{"id":"a","text":"who"},{"id":"b","text":"which"},{"id":"c","text":"whose"}],"correctOptionId":"b","explanationVi":"Vật → which/that."}'::jsonb),
 ('b1-u08-l1-q2','b1-u08-l1','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Điền vào chỗ trống: ''The doctor ___ treated me was very kind.''","acceptedAnswers":["who","that"],"explanationVi":"Người → who/that."}'::jsonb),
 ('b1-u08-l1-q3','b1-u08-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"The café where we met there is closed."},{"id":"b","text":"The café where we met is closed."},{"id":"c","text":"The café which we met is closed."}],"correctOptionId":"b","explanationVi":"where = nơi chốn; không lặp ''there''."}'::jsonb),
 ('b1-u08-l1-q4','b1-u08-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền vào chỗ trống: ''The man ___ car was stolen reported it.''","acceptedAnswers":["whose"],"explanationVi":"Sở hữu → whose."}'::jsonb),
 ('b1-u08-l1-q5','b1-u08-l1','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối đại từ với câu ví dụ:","pairs":[{"left":"who","right":"The girl ___ sings"},{"left":"which","right":"The book ___ I read"},{"left":"where","right":"The town ___ I live"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b1-u08-l1-q6','b1-u08-l1','error_correction',13,'quiz','hard',true,'{"question":"Sửa lỗi: ''The company which she works is large.''","acceptedAnswers":["The company where she works is large.","The company that she works for is large."],"explanationVi":"Nơi chốn → where; hoặc dùng that she works for."}'::jsonb),
 ('b1-u08-l1-q7','b1-u08-l1','sentence_ordering',14,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["The","student","whose","essay","I","marked","passed"],"correctOrder":[0,1,2,3,4,5,6],"explanationVi":"The student whose essay I marked passed."}'::jsonb);

-- Lesson 08-L2: Non-defining Relative Clauses
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u08-l2','B1','reading','b1-u08','normal',2,'Non-defining Relative Clauses','Thêm thông tin phụ — dùng dấu phẩy',10,20,70,'{}'::jsonb,
  '{"warmup":"Đôi khi bạn muốn thêm thông tin về một người/vật đã được xác định. Dấu phẩy giúp bạn làm điều đó!",
    "objectives":["Phân biệt mệnh đề quan hệ xác định và bổ sung","Dùng dấu phẩy đúng cách với mệnh đề bổ sung","Hiểu không dùng ''that'' trong mệnh đề bổ sung"],
    "grammarHtml":"<b>Mệnh đề quan hệ bổ sung</b> thêm thông tin về danh từ đã được xác định (có dấu phẩy):<br>My sister, <u>who lives in Paris</u>, is a doctor.<br>London, <u>which is the capital of England</u>, is very busy.<br><b>Khác biệt:</b><br>Xác định: no comma, xác định người/vật cụ thể nào.<br>Bổ sung: có dấu phẩy, thông tin thêm, có thể bỏ mà vẫn hiểu câu.<br><b>Lưu ý:</b> KHÔNG dùng ''that'' trong mệnh đề bổ sung.",
    "vocabBlock":[
      {"word":"non-defining","ipa":"/nɒn dɪˈfaɪnɪŋ/","meaningVi":"bổ sung, không xác định","example":"My dog, which is black, is friendly."},
      {"word":"comma","ipa":"/ˈkɒmə/","meaningVi":"dấu phẩy","example":"Use commas for non-defining clauses."},
      {"word":"extra information","ipa":"/ˈekstrə ˌɪnfəˈmeɪʃn/","meaningVi":"thông tin thêm","example":"This clause gives extra information."}],
    "examples":[
      {"en":"My brother, who is a doctor, lives in Hanoi.","vi":"Anh trai tôi, người là bác sĩ, sống ở Hà Nội."},
      {"en":"Hội An, which is in central Vietnam, is a beautiful town.","vi":"Hội An, nằm ở miền Trung Việt Nam, là một thị trấn đẹp."},
      {"en":"She gave me a book, which I found very interesting.","vi":"Cô ấy tặng tôi một cuốn sách, cuốn sách tôi thấy rất thú vị."}],
    "commonMistakes":["❌ My sister, that lives in Paris, is a doctor. → ✅ My sister, who lives in Paris, is a doctor. (không dùng that trong mệnh đề bổ sung)","❌ The city, where I live, there is hot. → ✅ The city, where I live, is hot."],
    "tips":["Mệnh đề bổ sung: dấu phẩy hai bên, không dùng that, có thể bỏ mà câu vẫn có nghĩa.","Mệnh đề xác định: không dấu phẩy, không thể bỏ."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u08-l2-p1','b1-u08-l2','multiple_choice',1,'practice','easy',false,'{"question":"Câu nào là mệnh đề quan hệ BỔ SUNG?","options":[{"id":"a","text":"The man who called is my uncle."},{"id":"b","text":"My uncle, who called, is a teacher."},{"id":"c","text":"The book that I read was boring."}],"correctOptionId":"b","explanationVi":"Có dấu phẩy → mệnh đề bổ sung."}'::jsonb),
 ('b1-u08-l2-p2','b1-u08-l2','error_correction',2,'practice','easy',false,'{"question":"Sửa lỗi: ''My sister, that lives in Paris, is a doctor.''","acceptedAnswers":["My sister, who lives in Paris, is a doctor."],"explanationVi":"Mệnh đề bổ sung không dùng that → who."}'::jsonb),
 ('b1-u08-l2-p3','b1-u08-l2','grammar_fill_blank',3,'practice','easy',false,'{"question":"Điền vào chỗ trống: ''Da Nang, ___ is in central Vietnam, has beautiful beaches.''","acceptedAnswers":["which"],"explanationVi":"Thành phố → which (mệnh đề bổ sung)."}'::jsonb),
 ('b1-u08-l2-p4','b1-u08-l2','multiple_choice',4,'practice','medium',false,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"My father, who is an engineer, works in HCMC."},{"id":"b","text":"My father, that is an engineer, works in HCMC."},{"id":"c","text":"My father who is an engineer, works in HCMC."}],"correctOptionId":"a","explanationVi":"Mệnh đề bổ sung: dấu phẩy + who (không dùng that)."}'::jsonb),
 ('b1-u08-l2-p5','b1-u08-l2','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: Hà Nội, là thủ đô của Việt Nam, là một thành phố đông đúc.","sourceText":"Hà Nội, là thủ đô của Việt Nam, là một thành phố đông đúc.","acceptedAnswers":["Hanoi, which is the capital of Vietnam, is a busy city."],"explanationVi":"Thành phố đã biết → mệnh đề bổ sung với which."}'::jsonb),
 ('b1-u08-l2-p6','b1-u08-l2','multiple_choice',6,'practice','medium',false,'{"question":"Câu bổ sung hay xác định? ''The café where we met is closed.''","options":[{"id":"a","text":"Xác định"},{"id":"b","text":"Bổ sung"},{"id":"c","text":"Không phân biệt được"}],"correctOptionId":"a","explanationVi":"Không có dấu phẩy → mệnh đề xác định."}'::jsonb),
 ('b1-u08-l2-p7','b1-u08-l2','sentence_ordering',7,'practice','medium',false,'{"question":"Sắp xếp thành câu đúng:","tokens":["My","dog","which","is","black","is","friendly"],"correctOrder":[0,1,3,4,2,5,6],"explanationVi":"My dog, which is black, is friendly. (cần dấu phẩy)"}'::jsonb),
 ('b1-u08-l2-q1','b1-u08-l2','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn từ đúng: ''London, ___ is the capital of England, is very busy.''","options":[{"id":"a","text":"that"},{"id":"b","text":"which"},{"id":"c","text":"who"}],"correctOptionId":"b","explanationVi":"Thành phố, mệnh đề bổ sung → which (không dùng that)."}'::jsonb),
 ('b1-u08-l2-q2','b1-u08-l2','error_correction',9,'quiz','easy',true,'{"question":"Sửa lỗi: ''My brother, that is a doctor, works in Hanoi.''","acceptedAnswers":["My brother, who is a doctor, works in Hanoi."],"explanationVi":"Mệnh đề bổ sung + người → who."}'::jsonb),
 ('b1-u08-l2-q3','b1-u08-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Câu nào là mệnh đề XÁC ĐỊNH?","options":[{"id":"a","text":"My cat, which is white, is lazy."},{"id":"b","text":"The cat that scratched me is gone."},{"id":"c","text":"My sister, who is a nurse, is kind."}],"correctOptionId":"b","explanationVi":"Không có dấu phẩy → xác định."}'::jsonb),
 ('b1-u08-l2-q4','b1-u08-l2','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền vào chỗ trống: ''She gave me flowers, ___ made me happy.''","acceptedAnswers":["which"],"explanationVi":"which thay cho toàn bộ hành động đi trước."}'::jsonb),
 ('b1-u08-l2-q5','b1-u08-l2','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối khái niệm với đặc điểm:","pairs":[{"left":"Xác định","right":"không dấu phẩy"},{"left":"Bổ sung","right":"có dấu phẩy"},{"left":"Bổ sung","right":"không dùng that"}],"explanationVi":"Phân biệt hai loại mệnh đề."}'::jsonb),
 ('b1-u08-l2-q6','b1-u08-l2','translation',13,'quiz','hard',true,'{"question":"Dịch sang tiếng Anh: Anh trai tôi, người sống ở Singapore, đang ghé thăm.","sourceText":"Anh trai tôi, người sống ở Singapore, đang ghé thăm.","acceptedAnswers":["My brother, who lives in Singapore, is visiting."],"explanationVi":"Mệnh đề bổ sung: My brother, who lives in Singapore, is visiting."}'::jsonb),
 ('b1-u08-l2-q7','b1-u08-l2','error_correction',14,'quiz','hard',true,'{"question":"Sửa lỗi: ''The Eiffel Tower, that is in Paris, is very tall.''","acceptedAnswers":["The Eiffel Tower, which is in Paris, is very tall."],"explanationVi":"Mệnh đề bổ sung không dùng that → which."}'::jsonb);

-- Lesson 08-L3: Adjective Order
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u08-l3','B1','reading','b1-u08','normal',3,'Describing People & Places','Adjective order: opinion-size-age-shape-colour-origin-material',10,20,70,'{}'::jsonb,
  '{"warmup":"Tại sao ''a lovely small old Italian silver antique round vase'' nghe không tự nhiên bằng ''a lovely little old Italian silver round antique vase''? Thứ tự tính từ rất quan trọng!",
    "objectives":["Nhớ thứ tự tính từ trong tiếng Anh","Mô tả người và nơi chốn bằng nhiều tính từ","Tránh lỗi sắp xếp tính từ"],
    "grammarHtml":"<b>Thứ tự tính từ:</b> Opinion → Size → Age → Shape → Colour → Origin → Material → (Purpose) → Noun<br>Ví dụ: a <u>beautiful</u> (opinion) <u>big</u> (size) <u>old</b> (age) <u>round</u> (shape) <u>black</u> (colour) <u>Japanese</u> (origin) <u>wooden</u> (material) table.<br><b>Mẹo nhớ:</b> OSASCOMP — Opinion, Size, Age, Shape, Colour, Origin, Material, Purpose.",
    "vocabBlock":[
      {"word":"stunning","ipa":"/ˈstʌnɪŋ/","meaningVi":"tuyệt đẹp (opinion)","example":"a stunning view"},
      {"word":"tiny","ipa":"/ˈtaɪni/","meaningVi":"rất nhỏ (size)","example":"a tiny room"},
      {"word":"ancient","ipa":"/ˈeɪnʃənt/","meaningVi":"cổ xưa (age)","example":"an ancient temple"},
      {"word":"oval","ipa":"/ˈəʊvl/","meaningVi":"hình bầu dục (shape)","example":"an oval table"},
      {"word":"Vietnamese","ipa":"/ˌvjetnəˈmiːz/","meaningVi":"Việt Nam (origin)","example":"a Vietnamese dish"},
      {"word":"wooden","ipa":"/ˈwʊdn/","meaningVi":"bằng gỗ (material)","example":"a wooden chair"}],
    "examples":[
      {"en":"She has long black hair.","vi":"Cô ấy có mái tóc dài màu đen."},
      {"en":"It''s a beautiful old French city.","vi":"Đây là một thành phố Pháp cổ đẹp."},
      {"en":"He lives in a small modern apartment.","vi":"Anh ấy sống trong một căn hộ hiện đại nhỏ."},
      {"en":"They found a lovely little wooden box.","vi":"Họ tìm thấy một chiếc hộp gỗ nhỏ xinh."}],
    "commonMistakes":["❌ a wooden small old box → ✅ a small old wooden box (size trước age trước material)","❌ a French beautiful city → ✅ a beautiful French city (opinion đứng trước origin)"],
    "tips":["Thứ tự: Opinion → Size → Age → Shape → Colour → Origin → Material.","Hiếm khi dùng hơn 3 tính từ liên tiếp trong văn nói."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u08-l3-p1','b1-u08-l3','multiple_choice',1,'practice','easy',false,'{"question":"Thứ tự đúng là gì? (opinion/size/colour)","options":[{"id":"a","text":"a red big beautiful bag"},{"id":"b","text":"a beautiful big red bag"},{"id":"c","text":"a big beautiful red bag"}],"correctOptionId":"b","explanationVi":"Opinion (beautiful) → Size (big) → Colour (red)."}'::jsonb),
 ('b1-u08-l3-p2','b1-u08-l3','sentence_ordering',2,'practice','easy',false,'{"question":"Sắp xếp tính từ đúng thứ tự: (old / French / beautiful / city)","tokens":["a","beautiful","old","French","city"],"correctOrder":[0,1,2,3,4],"explanationVi":"a beautiful (opinion) old (age) French (origin) city."}'::jsonb),
 ('b1-u08-l3-p3','b1-u08-l3','vocabulary_match',3,'practice','easy',false,'{"question":"Nối tính từ với loại:","pairs":[{"left":"stunning","right":"opinion"},{"left":"tiny","right":"size"},{"left":"ancient","right":"age"},{"left":"wooden","right":"material"}],"explanationVi":"Ghép đúng loại tính từ."}'::jsonb),
 ('b1-u08-l3-p4','b1-u08-l3','error_correction',4,'practice','medium',false,'{"question":"Sửa thứ tự: ''a wooden small old box''","acceptedAnswers":["a small old wooden box"],"explanationVi":"Size (small) → Age (old) → Material (wooden)."}'::jsonb),
 ('b1-u08-l3-p5','b1-u08-l3','multiple_choice',5,'practice','medium',false,'{"question":"Câu nào ĐÚNG thứ tự tính từ?","options":[{"id":"a","text":"She has black long hair."},{"id":"b","text":"She has long black hair."},{"id":"c","text":"She has hair long black."}],"correctOptionId":"b","explanationVi":"Size/length (long) → Colour (black)."}'::jsonb),
 ('b1-u08-l3-p6','b1-u08-l3','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: Một căn hộ hiện đại nhỏ","sourceText":"Một căn hộ hiện đại nhỏ","acceptedAnswers":["a small modern apartment","a small modern flat"],"explanationVi":"Size (small) → Age/type (modern)."}'::jsonb),
 ('b1-u08-l3-p7','b1-u08-l3','sentence_ordering',7,'practice','medium',false,'{"question":"Sắp xếp thành cụm danh từ đúng:","tokens":["a","lovely","little","Italian","restaurant"],"correctOrder":[0,1,2,3,4],"explanationVi":"a lovely (opinion) little (size) Italian (origin) restaurant."}'::jsonb),
 ('b1-u08-l3-q1','b1-u08-l3','multiple_choice',8,'quiz','easy',true,'{"question":"Thứ tự đúng:","options":[{"id":"a","text":"a Japanese old beautiful car"},{"id":"b","text":"a beautiful old Japanese car"},{"id":"c","text":"a old beautiful Japanese car"}],"correctOptionId":"b","explanationVi":"Opinion → Age → Origin."}'::jsonb),
 ('b1-u08-l3-q2','b1-u08-l3','error_correction',9,'quiz','easy',true,'{"question":"Sửa thứ tự: ''a French beautiful old building''","acceptedAnswers":["a beautiful old French building"],"explanationVi":"Opinion (beautiful) → Age (old) → Origin (French)."}'::jsonb),
 ('b1-u08-l3-q3','b1-u08-l3','vocabulary_match',10,'quiz','medium',true,'{"question":"Nối tính từ với loại:","pairs":[{"left":"oval","right":"shape"},{"left":"Vietnamese","right":"origin"},{"left":"tiny","right":"size"}],"explanationVi":"Ghép đúng loại tính từ."}'::jsonb),
 ('b1-u08-l3-q4','b1-u08-l3','sentence_ordering',11,'quiz','medium',true,'{"question":"Sắp xếp cụm danh từ:","tokens":["a","beautiful","big","round","black","table"],"correctOrder":[0,1,2,3,4,5],"explanationVi":"Opinion → Size → Shape → Colour → noun."}'::jsonb),
 ('b1-u08-l3-q5','b1-u08-l3','grammar_fill_blank',12,'quiz','medium',true,'{"question":"Điền đúng thứ tự: ''She wore a ___ (red/long) dress.''","acceptedAnswers":["long red"],"explanationVi":"Size/length (long) → Colour (red)."}'::jsonb),
 ('b1-u08-l3-q6','b1-u08-l3','multiple_choice',13,'quiz','hard',true,'{"question":"Câu nào ĐÚNG?","options":[{"id":"a","text":"They found a lovely little old French silver cross."},{"id":"b","text":"They found a silver little old French lovely cross."},{"id":"c","text":"They found a little lovely old silver French cross."}],"correctOptionId":"a","explanationVi":"Opinion(lovely) → Size(little) → Age(old) → Origin(French) → Material(silver)."}'::jsonb),
 ('b1-u08-l3-q7','b1-u08-l3','translation',14,'quiz','hard',true,'{"question":"Dịch: Một ngôi đền cổ nhỏ của Việt Nam","sourceText":"Một ngôi đền cổ nhỏ của Việt Nam","acceptedAnswers":["a small ancient Vietnamese temple","a tiny ancient Vietnamese temple"],"explanationVi":"Size → Age → Origin."}'::jsonb);

-- Lesson 08-L4: Reading — My Favourite Place
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u08-l4','B1','reading','b1-u08','normal',4,'My Favourite Place','Đọc hiểu: Mô tả nơi chốn yêu thích',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn có một nơi yêu thích không? Hãy đọc bài viết của Linh về nơi cô ấy yêu thích.",
    "objectives":["Đọc hiểu bài miêu tả nơi chốn B1","Nhận biết mệnh đề quan hệ và thứ tự tính từ trong văn bản","Ôn từ vựng miêu tả nơi chốn"],
    "vocabBlock":[
      {"word":"atmosphere","ipa":"/ˈætməsfɪə/","meaningVi":"không khí, bầu không khí","example":"The café has a warm atmosphere."},
      {"word":"remind of","ipa":"/rɪˈmaɪnd ɒv/","meaningVi":"gợi nhớ về","example":"It reminds me of my childhood."},
      {"word":"stroll","ipa":"/strəʊl/","meaningVi":"dạo bộ","example":"I love to stroll along the lake."},
      {"word":"peaceful","ipa":"/ˈpiːsfl/","meaningVi":"yên bình","example":"The garden is very peaceful."}],
    "examples":[
      {"en":"My favourite place is a small old Vietnamese café in the Old Quarter of Hanoi, which I discovered when I was a student. The café, which is run by an elderly couple, serves the best egg coffee I have ever tasted. The street where the café is located is narrow and quiet. There are beautiful old French colonial buildings on both sides, which remind me of a different era. Inside, there are lovely little wooden tables and chairs. The woman who runs the café always greets customers with a warm smile. When I feel stressed, I go there to stroll through the narrow streets and sit quietly with a cup of coffee. It is the place where I feel most peaceful.","vi":"Nơi yêu thích của tôi là một quán cà phê Việt Nam nhỏ cổ xưa ở Phố Cổ Hà Nội, nơi tôi khám phá khi còn là sinh viên. Quán cà phê, do một cặp đôi lớn tuổi điều hành, phục vụ cà phê trứng ngon nhất tôi từng nếm. Con phố nơi quán cà phê tọa lạc hẹp và yên tĩnh. Hai bên đường có những tòa nhà kiểu Pháp cổ đẹp, gợi nhớ tôi về một thời đại khác. Bên trong, có những chiếc bàn và ghế gỗ nhỏ xinh. Người phụ nữ điều hành quán luôn chào đón khách hàng bằng nụ cười ấm áp. Khi cảm thấy căng thẳng, tôi đến đó để dạo bộ qua những con phố hẹp và ngồi yên lặng với một tách cà phê. Đó là nơi tôi cảm thấy bình yên nhất."}],
    "commonMistakes":["Đọc kỹ các mệnh đề quan hệ để hiểu đúng thông tin mô tả."],
    "tips":["Chú ý các đại từ quan hệ: which, who, where trong bài đọc.","Nhận biết thứ tự tính từ trong các cụm danh từ."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u08-l4-p1','b1-u08-l4','multiple_choice',1,'practice','easy',false,'{"question":"Quán cà phê trong bài nằm ở đâu?","options":[{"id":"a","text":"Hội An"},{"id":"b","text":"Phố Cổ Hà Nội"},{"id":"c","text":"Đà Lạt"}],"correctOptionId":"b","explanationVi":"''in the Old Quarter of Hanoi.''"}'::jsonb),
 ('b1-u08-l4-p2','b1-u08-l4','multiple_choice',2,'practice','easy',false,'{"question":"Ai điều hành quán cà phê?","options":[{"id":"a","text":"Linh"},{"id":"b","text":"Một cặp đôi trẻ"},{"id":"c","text":"Một cặp đôi lớn tuổi"}],"correctOptionId":"c","explanationVi":"''run by an elderly couple.''"}'::jsonb),
 ('b1-u08-l4-p3','b1-u08-l4','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"atmosphere","right":"không khí, bầu không khí"},{"left":"remind of","right":"gợi nhớ về"},{"left":"stroll","right":"dạo bộ"},{"left":"peaceful","right":"yên bình"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u08-l4-p4','b1-u08-l4','multiple_choice',4,'practice','medium',false,'{"question":"Linh đến quán khi nào?","options":[{"id":"a","text":"Khi vui"},{"id":"b","text":"Khi căng thẳng"},{"id":"c","text":"Mỗi buổi sáng"}],"correctOptionId":"b","explanationVi":"''When I feel stressed, I go there.''"}'::jsonb),
 ('b1-u08-l4-p5','b1-u08-l4','grammar_fill_blank',5,'practice','medium',false,'{"question":"Hoàn thành theo bài: ''The woman ___ runs the café always smiles.''","acceptedAnswers":["who","that"],"explanationVi":"Người → who/that."}'::jsonb),
 ('b1-u08-l4-p6','b1-u08-l4','multiple_choice',6,'practice','medium',false,'{"question":"Những tòa nhà Pháp gợi nhớ Linh về điều gì?","options":[{"id":"a","text":"Thời sinh viên"},{"id":"b","text":"Một thời đại khác"},{"id":"c","text":"Cha mẹ cô ấy"}],"correctOptionId":"b","explanationVi":"''remind me of a different era.''"}'::jsonb),
 ('b1-u08-l4-p7','b1-u08-l4','multiple_choice',7,'practice','medium',false,'{"question":"Loại tính từ nào trong cụm ''small old Vietnamese café''?","options":[{"id":"a","text":"size, age, opinion"},{"id":"b","text":"size, age, origin"},{"id":"c","text":"opinion, age, origin"}],"correctOptionId":"b","explanationVi":"small (size) old (age) Vietnamese (origin)."}'::jsonb),
 ('b1-u08-l4-q1','b1-u08-l4','multiple_choice',8,'quiz','easy',true,'{"question":"Loại cà phê nào được đề cập trong bài?","options":[{"id":"a","text":"Cà phê sữa đá"},{"id":"b","text":"Cà phê trứng"},{"id":"c","text":"Cà phê đen"}],"correctOptionId":"b","explanationVi":"''serves the best egg coffee.''"}'::jsonb),
 ('b1-u08-l4-q2','b1-u08-l4','multiple_choice',9,'quiz','easy',true,'{"question":"Con phố nơi quán cà phê tọa lạc như thế nào?","options":[{"id":"a","text":"Rộng và náo nhiệt"},{"id":"b","text":"Hẹp và yên tĩnh"},{"id":"c","text":"Mới và hiện đại"}],"correctOptionId":"b","explanationVi":"''narrow and quiet.''"}'::jsonb),
 ('b1-u08-l4-q3','b1-u08-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Đại từ quan hệ nào dùng cho ''the café'' trong câu bổ sung?","options":[{"id":"a","text":"who"},{"id":"b","text":"that"},{"id":"c","text":"which"}],"correctOptionId":"c","explanationVi":"Vật + mệnh đề bổ sung → which."}'::jsonb),
 ('b1-u08-l4-q4','b1-u08-l4','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Hoàn thành: ''It is the place ___ I feel most peaceful.''","acceptedAnswers":["where"],"explanationVi":"Nơi chốn → where."}'::jsonb),
 ('b1-u08-l4-q5','b1-u08-l4','multiple_choice',12,'quiz','medium',true,'{"question":"Cụm ''lovely little wooden tables'' có thứ tự tính từ đúng không?","options":[{"id":"a","text":"Đúng"},{"id":"b","text":"Sai"},{"id":"c","text":"Không xác định được"}],"correctOptionId":"a","explanationVi":"Opinion (lovely) → Size (little) → Material (wooden) — đúng thứ tự."}'::jsonb),
 ('b1-u08-l4-q6','b1-u08-l4','vocabulary_match',13,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"atmosphere","right":"bầu không khí"},{"left":"stroll","right":"dạo bộ"},{"left":"peaceful","right":"yên bình"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b1-u08-l4-q7','b1-u08-l4','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Hoàn thành mệnh đề bổ sung: ''The café, ___ is run by an elderly couple, is famous.''","acceptedAnswers":["which"],"explanationVi":"Mệnh đề bổ sung + vật → which."}'::jsonb);

-- Lesson 08-L5: Unit Review
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u08-l5','B1','reading','b1-u08','unit_review',5,'Unit 8 Review','Ôn tập Unit 8: People & Places I Know',12,30,75,'{}'::jsonb,
  '{"warmup":"Ôn tập Unit 8: mệnh đề quan hệ xác định, bổ sung và thứ tự tính từ.","objectives":["Tổng hợp can-do Unit 8","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u08-l5-q1','b1-u08-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn từ đúng: ''The girl ___ won the prize is my sister.''","options":[{"id":"a","text":"which"},{"id":"b","text":"who"},{"id":"c","text":"whose"}],"correctOptionId":"b","explanationVi":"Người → who/that."}'::jsonb),
 ('b1-u08-l5-q2','b1-u08-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Điền vào chỗ trống: ''The house ___ I grew up is now a shop.''","acceptedAnswers":["where"],"explanationVi":"Nơi chốn → where."}'::jsonb),
 ('b1-u08-l5-q3','b1-u08-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Câu nào là mệnh đề BỔ SUNG?","options":[{"id":"a","text":"The man who called is my boss."},{"id":"b","text":"My boss, who called, is angry."},{"id":"c","text":"The book that I read was long."}],"correctOptionId":"b","explanationVi":"Có dấu phẩy → bổ sung."}'::jsonb),
 ('b1-u08-l5-q4','b1-u08-l5','error_correction',4,'quiz','medium',true,'{"question":"Sửa lỗi: ''My mother, that is a nurse, works nights.''","acceptedAnswers":["My mother, who is a nurse, works nights."],"explanationVi":"Mệnh đề bổ sung + người → who."}'::jsonb),
 ('b1-u08-l5-q5','b1-u08-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Thứ tự tính từ ĐÚNG:","options":[{"id":"a","text":"a wooden old small box"},{"id":"b","text":"a small old wooden box"},{"id":"c","text":"a old small wooden box"}],"correctOptionId":"b","explanationVi":"Size (small) → Age (old) → Material (wooden)."}'::jsonb),
 ('b1-u08-l5-q6','b1-u08-l5','grammar_fill_blank',6,'quiz','medium',true,'{"question":"Điền vào chỗ trống: ''The student ___ essay was best got a prize.''","acceptedAnswers":["whose"],"explanationVi":"Sở hữu → whose."}'::jsonb),
 ('b1-u08-l5-q7','b1-u08-l5','multiple_choice',7,'quiz','medium',true,'{"question":"Câu ĐÚNG về thứ tự tính từ:","options":[{"id":"a","text":"a French beautiful old city"},{"id":"b","text":"a beautiful old French city"},{"id":"c","text":"a old French beautiful city"}],"correctOptionId":"b","explanationVi":"Opinion → Age → Origin."}'::jsonb),
 ('b1-u08-l5-q8','b1-u08-l5','error_correction',8,'quiz','hard',true,'{"question":"Sửa lỗi: ''The city, that I visited, was amazing.''","acceptedAnswers":["The city, which I visited, was amazing."],"explanationVi":"Mệnh đề bổ sung không dùng that → which."}'::jsonb),
 ('b1-u08-l5-q9','b1-u08-l5','sentence_ordering',9,'quiz','medium',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["The","woman","whose","bag","was","stolen","called","the","police"],"correctOrder":[0,1,2,3,4,5,6,7,8],"explanationVi":"The woman whose bag was stolen called the police."}'::jsonb),
 ('b1-u08-l5-q10','b1-u08-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"Điền đúng thứ tự tính từ: ''She wore a ___ (Italian/beautiful/silk) dress.''","acceptedAnswers":["beautiful Italian silk","beautiful silk Italian"],"explanationVi":"Opinion (beautiful) → Origin (Italian) → Material (silk)."}'::jsonb);

UPDATE learning_units SET review_lesson_id = 'b1-u08-l5' WHERE id = 'b1-u08';

-- ══════════════════════════════════════════════════════════════════════════
-- UNIT 09 — It Must Be True!
-- Theme: deduction | Modal verbs for deduction/possibility (must/might/could/can't)
-- ══════════════════════════════════════════════════════════════════════════

-- Lesson 09-L1: Must/Can't for Deduction (Present)
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u09-l1','B1','reading','b1-u09','normal',1,'Must & Can''t for Deduction','Suy luận hiện tại: must/can''t + be/verb',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn nhìn thấy đèn phòng bật. Bạn nghĩ ''ai đó đang ở trong nhà''. Bạn không chắc chắn 100% nhưng bạn suy luận. Đó là deduction!",
    "objectives":["Dùng must để suy luận điều gần như chắc chắn là đúng","Dùng can''t để suy luận điều gần như chắc chắn là sai","Phân biệt must (certainty) với might/could (possibility)"],
    "grammarHtml":"<b>Must + base verb</b> = suy luận tích cực (gần như chắc chắn đúng):<br>The light is on. She must be home.<br><b>Can''t + base verb</b> = suy luận phủ định (gần như chắc chắn sai):<br>He just ate a huge meal. He can''t be hungry.<br><b>Lưu ý:</b> Đây là MODAL VERB dùng để suy luận, khác với must (obligation) và can''t (prohibition).<br>Dấu hiệu nhận biết: câu có bằng chứng → suy luận.",
    "vocabBlock":[
      {"word":"must","ipa":"/mʌst/","meaningVi":"chắc hẳn là (suy luận)","example":"She must be tired — she worked all day."},
      {"word":"can''t","ipa":"/kɑːnt/","meaningVi":"không thể nào là (suy luận phủ định)","example":"He can''t be serious."},
      {"word":"deduction","ipa":"/dɪˈdʌkʃn/","meaningVi":"suy luận","example":"We use must/can''t for deduction."},
      {"word":"evidence","ipa":"/ˈevɪdəns/","meaningVi":"bằng chứng","example":"Based on the evidence, she must be guilty."},
      {"word":"exhausted","ipa":"/ɪɡˈzɔːstɪd/","meaningVi":"kiệt sức","example":"You must be exhausted after that run."}],
    "examples":[
      {"en":"She''s been studying all night. She must be exhausted.","vi":"Cô ấy học suốt đêm. Chắc hẳn cô ấy kiệt sức rồi."},
      {"en":"He just had a big lunch. He can''t be hungry already.","vi":"Anh ấy vừa ăn trưa no. Không thể nào anh ấy đã đói được."},
      {"en":"She knows six languages. She must be very intelligent.","vi":"Cô ấy biết sáu thứ tiếng. Chắc hẳn cô ấy rất thông minh."},
      {"en":"That can''t be true — I saw him here five minutes ago.","vi":"Điều đó không thể đúng — tôi thấy anh ấy ở đây năm phút trước."}],
    "commonMistakes":["❌ She must be tiredly. → ✅ She must be tired. (must + adj, không thêm -ly)","❌ He mustn''t be hungry. → ✅ He can''t be hungry. (suy luận phủ định → can''t)","❌ She must know six language. → ✅ She must know six languages."],
    "tips":["must = bạn gần như chắc chắn đó là sự thật.","can''t = bạn gần như chắc chắn đó KHÔNG phải sự thật.","Suy luận phủ định dùng can''t, KHÔNG dùng mustn''t."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u09-l1-p1','b1-u09-l1','multiple_choice',1,'practice','easy',false,'{"question":"Chọn từ đúng: ''She''s been working for 12 hours. She ___ be tired.''","options":[{"id":"a","text":"can''t"},{"id":"b","text":"must"},{"id":"c","text":"might not"}],"correctOptionId":"b","explanationVi":"Bằng chứng rõ ràng → suy luận tích cực: must."}'::jsonb),
 ('b1-u09-l1-p2','b1-u09-l1','multiple_choice',2,'practice','easy',false,'{"question":"Chọn từ đúng: ''He just ate two pizzas. He ___ be hungry.''","options":[{"id":"a","text":"must"},{"id":"b","text":"can''t"},{"id":"c","text":"should"}],"correctOptionId":"b","explanationVi":"Mâu thuẫn với bằng chứng → suy luận phủ định: can''t."}'::jsonb),
 ('b1-u09-l1-p3','b1-u09-l1','vocabulary_match',3,'practice','easy',false,'{"question":"Nối modal với nghĩa:","pairs":[{"left":"must","right":"chắc hẳn là (đúng)"},{"left":"can''t","right":"không thể nào là (sai)"}],"explanationVi":"Phân biệt hai modal suy luận."}'::jsonb),
 ('b1-u09-l1-p4','b1-u09-l1','grammar_fill_blank',4,'practice','medium',false,'{"question":"Điền must hoặc can''t: ''The lights are all off. They ___ be home.''","acceptedAnswers":["can''t"],"explanationVi":"Bằng chứng phủ nhận → can''t."}'::jsonb),
 ('b1-u09-l1-p5','b1-u09-l1','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: ''Cô ấy biết câu trả lời. Chắc hẳn cô ấy rất thông minh.''","sourceText":"Cô ấy biết câu trả lời. Chắc hẳn cô ấy rất thông minh.","acceptedAnswers":["She knows the answer. She must be very smart.","She knows the answer. She must be very intelligent."],"explanationVi":"must + be + adjective."}'::jsonb),
 ('b1-u09-l1-p6','b1-u09-l1','error_correction',6,'practice','medium',false,'{"question":"Sửa lỗi: ''He mustn''t be home — his car isn''t here.''","acceptedAnswers":["He can''t be home — his car isn''t here."],"explanationVi":"Suy luận phủ định → can''t (không phải mustn''t)."}'::jsonb),
 ('b1-u09-l1-p7','b1-u09-l1','multiple_choice',7,'practice','medium',false,'{"question":"Chọn câu suy luận ĐÚNG: ''She speaks perfect French.''","options":[{"id":"a","text":"She can''t be French."},{"id":"b","text":"She must be French or have lived in France."},{"id":"c","text":"She should be French."}],"correctOptionId":"b","explanationVi":"Bằng chứng → suy luận tích cực hợp lý."}'::jsonb),
 ('b1-u09-l1-q1','b1-u09-l1','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền must hoặc can''t: ''She''s shivering. She ___ be cold.''","acceptedAnswers":["must"],"explanationVi":"Bằng chứng rõ → must."}'::jsonb),
 ('b1-u09-l1-q2','b1-u09-l1','multiple_choice',9,'quiz','easy',true,'{"question":"Chọn câu đúng: ''That can''t be Mark — he''s in New York.''","options":[{"id":"a","text":"Đúng"},{"id":"b","text":"Sai — phải dùng mustn''t"},{"id":"c","text":"Sai — phải dùng shouldn''t"}],"correctOptionId":"a","explanationVi":"Suy luận phủ định → can''t là đúng."}'::jsonb),
 ('b1-u09-l1-q3','b1-u09-l1','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn từ đúng: ''She passed every exam with 100%. She ___ be very clever.''","options":[{"id":"a","text":"can''t"},{"id":"b","text":"must"},{"id":"c","text":"mustn''t"}],"correctOptionId":"b","explanationVi":"Bằng chứng → suy luận tích cực: must."}'::jsonb),
 ('b1-u09-l1-q4','b1-u09-l1','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Điền must hoặc can''t: ''He''s been awake for 30 hours. He ___ be exhausted.''","acceptedAnswers":["must"],"explanationVi":"Bằng chứng rõ → must."}'::jsonb),
 ('b1-u09-l1-q5','b1-u09-l1','error_correction',12,'quiz','medium',true,'{"question":"Sửa lỗi: ''She must be tiredly after the marathon.''","acceptedAnswers":["She must be tired after the marathon."],"explanationVi":"must + be + adjective (không thêm -ly)."}'::jsonb),
 ('b1-u09-l1-q6','b1-u09-l1','translation',13,'quiz','hard',true,'{"question":"Dịch: ''Đèn vẫn bật. Chắc hẳn ai đó vẫn còn ở nhà.''","sourceText":"Đèn vẫn bật. Chắc hẳn ai đó vẫn còn ở nhà.","acceptedAnswers":["The lights are still on. Someone must still be home.","The lights are still on. Someone must be home."],"explanationVi":"must be home = suy luận tích cực."}'::jsonb),
 ('b1-u09-l1-q7','b1-u09-l1','multiple_choice',14,'quiz','hard',true,'{"question":"Tình huống: Bạn gọi điện cho bạn 5 lần không được. Suy luận đúng?","options":[{"id":"a","text":"She must be busy or her phone must be off."},{"id":"b","text":"She can''t be busy."},{"id":"c","text":"She mustn''t answer."}],"correctOptionId":"a","explanationVi":"Bằng chứng → must be busy / must be off."}'::jsonb);

-- Lesson 09-L2: Might/Could for Possibility
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u09-l2','B1','reading','b1-u09','normal',2,'Might & Could for Possibility','Có thể là... (không chắc chắn)',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn nghe tiếng động ngoài cửa. Có thể là gió, có thể là mèo, có thể là ai đó. Bạn không chắc — đó là possibility!",
    "objectives":["Dùng might/could để diễn đạt khả năng (có thể là)","Phân biệt mức độ chắc chắn: must > might/could > can''t","Dùng might not cho khả năng phủ định"],
    "grammarHtml":"<b>Might/Could + base verb</b> = có thể là (50/50 hoặc ít chắc hơn):<br>That might be Tom — I''m not sure.<br>She could be in the library.<br><b>Might not</b> = có thể không là:<br>He might not be coming tonight.<br><b>Bậc thang chắc chắn:</b><br>must (90%+) → might/could (50%) → can''t (gần như 0%)<br><b>Lưu ý:</b> could not (couldn''t) dùng cho PAST ability hoặc emphatic impossibility — KHÔNG dùng couldn''t cho present deduction như can''t.",
    "vocabBlock":[
      {"word":"might","ipa":"/maɪt/","meaningVi":"có thể là (không chắc)","example":"She might be at home."},
      {"word":"could","ipa":"/kʊd/","meaningVi":"có thể là (khả năng)","example":"That could be the answer."},
      {"word":"possibility","ipa":"/ˌpɒsəˈbɪlɪti/","meaningVi":"khả năng","example":"There''s a possibility he''s wrong."},
      {"word":"uncertain","ipa":"/ʌnˈsɜːtn/","meaningVi":"không chắc chắn","example":"I''m uncertain about the answer."}],
    "examples":[
      {"en":"I can''t find my keys. They might be in my bag.","vi":"Tôi không tìm thấy chìa khóa. Có thể chúng ở trong túi."},
      {"en":"She''s not answering. She could be sleeping.","vi":"Cô ấy không trả lời. Có thể cô ấy đang ngủ."},
      {"en":"He might not come — he seems busy.","vi":"Anh ấy có thể không đến — anh ấy trông có vẻ bận."},
      {"en":"The answer could be B or C — I''m not sure.","vi":"Đáp án có thể là B hoặc C — tôi không chắc."}],
    "commonMistakes":["❌ She might to be tired. → ✅ She might be tired. (modal + bare infinitive)","❌ He couldn''t be at home. → ✅ He might not be at home. (present possibility phủ định)","❌ Dùng might và must như nhau → phân biệt mức độ chắc chắn."],
    "tips":["might/could = có thể đúng, có thể sai (không chắc).","might not = có thể không đúng.","Modal + bare infinitive (không ''to'')."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u09-l2-p1','b1-u09-l2','multiple_choice',1,'practice','easy',false,'{"question":"Chọn từ phù hợp (không chắc chắn): ''I can''t find my phone. It ___ be in the car.''","options":[{"id":"a","text":"must"},{"id":"b","text":"might"},{"id":"c","text":"can''t"}],"correctOptionId":"b","explanationVi":"Không chắc → might/could."}'::jsonb),
 ('b1-u09-l2-p2','b1-u09-l2','vocabulary_match',2,'practice','easy',false,'{"question":"Nối modal với mức độ chắc chắn:","pairs":[{"left":"must","right":"gần như chắc chắn đúng"},{"left":"might/could","right":"có thể đúng hoặc sai"},{"left":"can''t","right":"gần như chắc chắn sai"}],"explanationVi":"Bậc thang chắc chắn."}'::jsonb),
 ('b1-u09-l2-p3','b1-u09-l2','grammar_fill_blank',3,'practice','easy',false,'{"question":"Điền might hoặc could: ''She''s not here. She ___ be at the library.''","acceptedAnswers":["might","could"],"explanationVi":"Khả năng không chắc → might/could."}'::jsonb),
 ('b1-u09-l2-p4','b1-u09-l2','error_correction',4,'practice','medium',false,'{"question":"Sửa lỗi: ''He might to be at home.''","acceptedAnswers":["He might be at home."],"explanationVi":"Modal + bare infinitive (không ''to'')."}'::jsonb),
 ('b1-u09-l2-p5','b1-u09-l2','multiple_choice',5,'practice','medium',false,'{"question":"Chọn câu diễn đạt KHÔNG CHẮC CHẮN tốt nhất: ''Cô ấy có thể không đến.''","options":[{"id":"a","text":"She can''t come."},{"id":"b","text":"She might not come."},{"id":"c","text":"She must not come."}],"correctOptionId":"b","explanationVi":"Không chắc → might not."}'::jsonb),
 ('b1-u09-l2-p6','b1-u09-l2','translation',6,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: ''Đáp án có thể là A hoặc B — tôi không chắc.''","sourceText":"Đáp án có thể là A hoặc B — tôi không chắc.","acceptedAnswers":["The answer might be A or B — I''m not sure.","The answer could be A or B — I''m not sure."],"explanationVi":"might/could cho khả năng không chắc."}'::jsonb),
 ('b1-u09-l2-p7','b1-u09-l2','multiple_choice',7,'practice','medium',false,'{"question":"Chọn modal đúng nhất: ''Tôi thấy bóng người ngoài cửa. Có thể là cô hàng xóm.''","options":[{"id":"a","text":"It must be the neighbour."},{"id":"b","text":"It could be the neighbour."},{"id":"c","text":"It can''t be the neighbour."}],"correctOptionId":"b","explanationVi":"Không chắc chắn → could/might."}'::jsonb),
 ('b1-u09-l2-q1','b1-u09-l2','grammar_fill_blank',8,'quiz','easy',true,'{"question":"Điền might hoặc must: ''I''m not sure where she is. She ___ be at work.'' (không chắc)","acceptedAnswers":["might","could"],"explanationVi":"Không chắc → might/could."}'::jsonb),
 ('b1-u09-l2-q2','b1-u09-l2','multiple_choice',9,'quiz','easy',true,'{"question":"Mức độ chắc chắn nào cao hơn?","options":[{"id":"a","text":"might"},{"id":"b","text":"must"},{"id":"c","text":"Bằng nhau"}],"correctOptionId":"b","explanationVi":"must (90%+) > might (50%)."}'::jsonb),
 ('b1-u09-l2-q3','b1-u09-l2','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn câu diễn đạt khả năng phủ định đúng: ''Anh ấy có thể không biết đường.''","options":[{"id":"a","text":"He can''t know the way."},{"id":"b","text":"He might not know the way."},{"id":"c","text":"He mustn''t know the way."}],"correctOptionId":"b","explanationVi":"Khả năng phủ định (không chắc) → might not."}'::jsonb),
 ('b1-u09-l2-q4','b1-u09-l2','error_correction',11,'quiz','medium',true,'{"question":"Sửa lỗi: ''She could to be sleeping.''","acceptedAnswers":["She could be sleeping."],"explanationVi":"Modal + bare infinitive, không ''to''."}'::jsonb),
 ('b1-u09-l2-q5','b1-u09-l2','vocabulary_match',12,'quiz','medium',true,'{"question":"Nối câu với loại suy luận:","pairs":[{"left":"She must be home.","right":"gần như chắc chắn"},{"left":"She might be home.","right":"có thể đúng/sai"},{"left":"She can''t be home.","right":"gần như chắc chắn sai"}],"explanationVi":"Phân biệt ba bậc."}'::jsonb),
 ('b1-u09-l2-q6','b1-u09-l2','translation',13,'quiz','hard',true,'{"question":"Dịch: ''Họ không trả lời. Có thể họ đang bận.''","sourceText":"Họ không trả lời. Có thể họ đang bận.","acceptedAnswers":["They''re not answering. They might be busy.","They''re not answering. They could be busy."],"explanationVi":"might/could be busy."}'::jsonb),
 ('b1-u09-l2-q7','b1-u09-l2','multiple_choice',14,'quiz','hard',true,'{"question":"Chọn câu đúng nhất cho tình huống: ''Chìa khóa mất. Tôi kiểm tra khắp nơi rồi, chỉ còn một chỗ chưa kiểm tra — ngăn kéo.''","options":[{"id":"a","text":"They might be in the drawer."},{"id":"b","text":"They must be in the drawer."},{"id":"c","text":"They can''t be in the drawer."}],"correctOptionId":"a","explanationVi":"Chỉ là khả năng, chưa kiểm tra → might."}'::jsonb);

-- Lesson 09-L3: Must/Might/Could/Can't for Past Deduction
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u09-l3','B1','reading','b1-u09','normal',3,'Deduction About the Past','must/might/could/can''t + have + V3',10,20,70,'{}'::jsonb,
  '{"warmup":"Bạn đến nhà bạn và thấy cửa mở, đèn bật, nhưng không có ai. Chuyện gì đã xảy ra?",
    "objectives":["Dùng must/might/could/can''t + have + V3 để suy luận về quá khứ","Phân biệt suy luận hiện tại và quá khứ","Áp dụng các bậc chắc chắn vào quá khứ"],
    "grammarHtml":"<b>Suy luận quá khứ:</b><br>must have + V3 = chắc hẳn đã...: She must have left early — her bag is gone.<br>might/could have + V3 = có thể đã...: He might have missed the bus.<br>can''t have + V3 = không thể nào đã...: She can''t have said that — she''s so kind.<br><b>So sánh:</b><br>Present: She must be tired. (bây giờ)<br>Past: She must have been tired. (khi đó)",
    "vocabBlock":[
      {"word":"must have","ipa":"/mʌst həv/","meaningVi":"chắc hẳn đã","example":"He must have forgotten."},
      {"word":"might have","ipa":"/maɪt həv/","meaningVi":"có thể đã","example":"She might have left already."},
      {"word":"can''t have","ipa":"/kɑːnt həv/","meaningVi":"không thể nào đã","example":"He can''t have done that."},
      {"word":"could have","ipa":"/kʊd həv/","meaningVi":"có thể đã (khả năng)","example":"They could have taken a different route."}],
    "examples":[
      {"en":"The window is broken. Someone must have broken it.","vi":"Cửa sổ bị vỡ. Chắc hẳn ai đó đã làm vỡ nó."},
      {"en":"She didn''t answer. She might have been asleep.","vi":"Cô ấy không trả lời. Có thể cô ấy đã ngủ."},
      {"en":"He can''t have cheated — he always follows the rules.","vi":"Anh ấy không thể nào đã gian lận — anh ấy luôn tuân thủ quy tắc."},
      {"en":"They could have taken the wrong train.","vi":"Họ có thể đã đi nhầm tàu."}],
    "commonMistakes":["❌ She must has left. → ✅ She must have left.","❌ He mustn''t have done it. → ✅ He can''t have done it. (suy luận phủ định)","❌ They might had gone. → ✅ They might have gone."],
    "tips":["Công thức: modal + have + past participle (V3).","Suy luận phủ định quá khứ: can''t have + V3.","might have và could have tương đương cho khả năng quá khứ."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u09-l3-p1','b1-u09-l3','multiple_choice',1,'practice','easy',false,'{"question":"Chọn câu suy luận quá khứ đúng: Cửa sổ bị vỡ.","options":[{"id":"a","text":"Someone must break it."},{"id":"b","text":"Someone must have broken it."},{"id":"c","text":"Someone must broke it."}],"correctOptionId":"b","explanationVi":"Suy luận quá khứ: must have + V3."}'::jsonb),
 ('b1-u09-l3-p2','b1-u09-l3','grammar_fill_blank',2,'practice','easy',false,'{"question":"Điền vào chỗ trống: ''She didn''t come. She ___ (might/forget) the meeting.''","acceptedAnswers":["might have forgotten"],"explanationVi":"might + have + V3: might have forgotten."}'::jsonb),
 ('b1-u09-l3-p3','b1-u09-l3','vocabulary_match',3,'practice','easy',false,'{"question":"Nối cấu trúc với nghĩa:","pairs":[{"left":"must have + V3","right":"chắc hẳn đã"},{"left":"might have + V3","right":"có thể đã"},{"left":"can''t have + V3","right":"không thể nào đã"}],"explanationVi":"Ghép đúng từng cấu trúc."}'::jsonb),
 ('b1-u09-l3-p4','b1-u09-l3','error_correction',4,'practice','medium',false,'{"question":"Sửa lỗi: ''He must has left already.''","acceptedAnswers":["He must have left already."],"explanationVi":"must + have (không phải has) + V3."}'::jsonb),
 ('b1-u09-l3-p5','b1-u09-l3','translation',5,'practice','medium',false,'{"question":"Dịch sang tiếng Anh: ''Cô ấy không thể nào đã nói điều đó — cô ấy rất tốt bụng.''","sourceText":"Cô ấy không thể nào đã nói điều đó — cô ấy rất tốt bụng.","acceptedAnswers":["She can''t have said that — she is so kind.","She can''t have said that — she''s very kind."],"explanationVi":"can''t have said = suy luận phủ định quá khứ."}'::jsonb),
 ('b1-u09-l3-p6','b1-u09-l3','multiple_choice',6,'practice','medium',false,'{"question":"Chọn câu ĐÚNG: Họ không ở đây. Họ có thể đã đi rồi.","options":[{"id":"a","text":"They might go already."},{"id":"b","text":"They might have gone already."},{"id":"c","text":"They might had gone already."}],"correctOptionId":"b","explanationVi":"might + have + V3: might have gone."}'::jsonb),
 ('b1-u09-l3-p7','b1-u09-l3','grammar_fill_blank',7,'practice','medium',false,'{"question":"Điền vào chỗ trống: ''The food is all gone. Someone ___ (must/eat) it.''","acceptedAnswers":["must have eaten"],"explanationVi":"must + have + V3: must have eaten."}'::jsonb),
 ('b1-u09-l3-q1','b1-u09-l3','multiple_choice',8,'quiz','easy',true,'{"question":"Chọn câu suy luận quá khứ đúng: Cô ấy mặt đỏ bừng.","options":[{"id":"a","text":"She must have been embarrassed."},{"id":"b","text":"She must has been embarrassed."},{"id":"c","text":"She must be embarrassed."}],"correctOptionId":"a","explanationVi":"Suy luận quá khứ: must have + V3."}'::jsonb),
 ('b1-u09-l3-q2','b1-u09-l3','grammar_fill_blank',9,'quiz','easy',true,'{"question":"Điền vào chỗ trống: ''No one saw him. He ___ (can''t/come) to the party.''","acceptedAnswers":["can''t have come"],"explanationVi":"can''t + have + V3."}'::jsonb),
 ('b1-u09-l3-q3','b1-u09-l3','multiple_choice',10,'quiz','medium',true,'{"question":"Chọn suy luận hợp lý nhất: ''The phone is dead.''","options":[{"id":"a","text":"It might have run out of battery."},{"id":"b","text":"It must run out of battery."},{"id":"c","text":"It can''t have had a battery."}],"correctOptionId":"a","explanationVi":"Khả năng quá khứ → might have + V3."}'::jsonb),
 ('b1-u09-l3-q4','b1-u09-l3','error_correction',11,'quiz','medium',true,'{"question":"Sửa lỗi: ''They mustn''t have known the answer.''","acceptedAnswers":["They can''t have known the answer."],"explanationVi":"Suy luận phủ định quá khứ → can''t have."}'::jsonb),
 ('b1-u09-l3-q5','b1-u09-l3','translation',12,'quiz','medium',true,'{"question":"Dịch: ''Anh ấy chắc hẳn đã quên đường.''","sourceText":"Anh ấy chắc hẳn đã quên đường.","acceptedAnswers":["He must have forgotten the way.","He must have forgotten the road."],"explanationVi":"must have forgotten."}'::jsonb),
 ('b1-u09-l3-q6','b1-u09-l3','sentence_ordering',13,'quiz','hard',true,'{"question":"Sắp xếp thành câu đúng:","tokens":["She","must","have","taken","the","wrong","bus"],"correctOrder":[0,1,2,3,4,5,6],"explanationVi":"She must have taken the wrong bus."}'::jsonb),
 ('b1-u09-l3-q7','b1-u09-l3','multiple_choice',14,'quiz','hard',true,'{"question":"Chọn modal đúng: ''Tôi không chắc. Có thể họ đã đi bằng taxi.''","options":[{"id":"a","text":"They must have taken a taxi."},{"id":"b","text":"They could have taken a taxi."},{"id":"c","text":"They can''t have taken a taxi."}],"correctOptionId":"b","explanationVi":"Không chắc → could/might have."}'::jsonb);

-- Lesson 09-L4: Reading — The Mystery Parcel
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u09-l4','B1','reading','b1-u09','normal',4,'The Mystery Parcel','Đọc hiểu: Suy luận về bưu kiện bí ẩn',10,20,70,'{}'::jsonb,
  '{"warmup":"Một bưu kiện xuất hiện trước cửa nhà bạn mà không có tên người gửi. Bạn nghĩ gì?",
    "objectives":["Đọc hiểu đoạn văn B1 về suy luận","Nhận biết modal verbs suy luận trong văn bản","Ôn từ vựng về sự tò mò và giải đố"],
    "vocabBlock":[
      {"word":"parcel","ipa":"/ˈpɑːsl/","meaningVi":"bưu kiện","example":"A mysterious parcel arrived today."},
      {"word":"sender","ipa":"/ˈsendə/","meaningVi":"người gửi","example":"There was no sender''s name."},
      {"word":"wrap","ipa":"/ræp/","meaningVi":"bọc, gói","example":"The gift was wrapped in brown paper."},
      {"word":"puzzled","ipa":"/ˈpʌzld/","meaningVi":"bối rối, thắc mắc","example":"She was puzzled by the package."},
      {"word":"clue","ipa":"/kluː/","meaningVi":"manh mối","example":"There was no clue about the sender."}],
    "examples":[
      {"en":"One morning, Minh found a small brown parcel outside his door. There was no sender''s name on it, just his address written in neat handwriting. Minh was puzzled. He thought about who might have sent it. It must have been someone who knows his address. It couldn''t have been his family — they would have told him. It might have been a friend who was being secretive. Inside the parcel, he found a beautiful old Vietnamese silk scarf and a small note that said: ''You must have been cold last winter.'' Minh smiled. He suddenly knew — it could only have been his former teacher, who had seen him shivering at the school reunion. He must have remembered and sent it as a kind surprise. Minh thought it must be the most thoughtful gift he had ever received.","vi":"Một buổi sáng, Minh tìm thấy một bưu kiện nhỏ màu nâu trước cửa. Không có tên người gửi trên đó, chỉ có địa chỉ của anh được viết bằng nét chữ ngăn nắp. Minh bối rối. Anh nghĩ về người có thể đã gửi nó. Chắc hẳn là ai đó biết địa chỉ của anh. Không thể là gia đình anh — họ đã nói với anh rồi. Có thể là một người bạn đang muốn giữ bí mật. Bên trong bưu kiện, anh tìm thấy một chiếc khăn lụa Việt Nam cổ đẹp và một mảnh giấy nhỏ viết: ''Anh chắc hẳn đã lạnh mùa đông vừa rồi.'' Minh mỉm cười. Anh đột nhiên nhận ra — chỉ có thể là thầy giáo cũ của anh, người đã thấy anh run rẩy tại buổi họp trường. Thầy chắc hẳn đã nhớ và gửi nó như một món quà bất ngờ ấm áp. Minh nghĩ đây chắc hẳn là món quà chu đáo nhất anh từng nhận."}],
    "commonMistakes":["Phân biệt must have (quá khứ) với must be (hiện tại) trong bài đọc."],
    "tips":["Chú ý các cấu trúc: must have been, couldn''t have been, might have been, could only have been."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u09-l4-p1','b1-u09-l4','multiple_choice',1,'practice','easy',false,'{"question":"Bưu kiện được tìm thấy ở đâu?","options":[{"id":"a","text":"Trong hòm thư"},{"id":"b","text":"Trước cửa nhà"},{"id":"c","text":"Ở bưu điện"}],"correctOptionId":"b","explanationVi":"''outside his door.''"}'::jsonb),
 ('b1-u09-l4-p2','b1-u09-l4','multiple_choice',2,'practice','easy',false,'{"question":"Tại sao Minh loại trừ gia đình?","options":[{"id":"a","text":"Họ ở xa"},{"id":"b","text":"Họ sẽ nói với anh trước"},{"id":"c","text":"Họ không biết địa chỉ"}],"correctOptionId":"b","explanationVi":"''they would have told him.''"}'::jsonb),
 ('b1-u09-l4-p3','b1-u09-l4','vocabulary_match',3,'practice','easy',false,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"parcel","right":"bưu kiện"},{"left":"sender","right":"người gửi"},{"left":"puzzled","right":"bối rối"},{"left":"clue","right":"manh mối"}],"explanationVi":"Ghép đúng từng từ."}'::jsonb),
 ('b1-u09-l4-p4','b1-u09-l4','multiple_choice',4,'practice','medium',false,'{"question":"Ai Minh nghĩ đã gửi bưu kiện?","options":[{"id":"a","text":"Bạn cùng lớp"},{"id":"b","text":"Thầy giáo cũ"},{"id":"c","text":"Hàng xóm"}],"correctOptionId":"b","explanationVi":"''it could only have been his former teacher.''"}'::jsonb),
 ('b1-u09-l4-p5','b1-u09-l4','multiple_choice',5,'practice','medium',false,'{"question":"Vì sao thầy gửi bưu kiện?","options":[{"id":"a","text":"Vì Minh sinh nhật"},{"id":"b","text":"Vì thầy thấy Minh run lạnh ở buổi họp trường"},{"id":"c","text":"Vì đây là truyền thống"}],"correctOptionId":"b","explanationVi":"''had seen him shivering at the school reunion.''"}'::jsonb),
 ('b1-u09-l4-p6','b1-u09-l4','grammar_fill_blank',6,'practice','medium',false,'{"question":"Hoàn thành theo bài: ''It ___ (can''t/be) his family — they would have told him.''","acceptedAnswers":["couldn''t have been","can''t have been"],"explanationVi":"can''t have been = suy luận phủ định quá khứ."}'::jsonb),
 ('b1-u09-l4-p7','b1-u09-l4','multiple_choice',7,'practice','medium',false,'{"question":"Cụm từ nào trong bài là suy luận quá khứ TÍCH CỰC?","options":[{"id":"a","text":"couldn''t have been"},{"id":"b","text":"might have been"},{"id":"c","text":"must have been"}],"correctOptionId":"c","explanationVi":"must have been = chắc hẳn đã."}'::jsonb),
 ('b1-u09-l4-q1','b1-u09-l4','multiple_choice',8,'quiz','easy',true,'{"question":"Trong bưu kiện có gì?","options":[{"id":"a","text":"Sách cũ"},{"id":"b","text":"Khăn lụa"},{"id":"c","text":"Áo ấm"}],"correctOptionId":"b","explanationVi":"''a beautiful old Vietnamese silk scarf.''"}'::jsonb),
 ('b1-u09-l4-q2','b1-u09-l4','multiple_choice',9,'quiz','easy',true,'{"question":"Mảnh giấy trong bưu kiện nói gì?","options":[{"id":"a","text":"Chúc mừng sinh nhật"},{"id":"b","text":"Anh chắc hẳn đã lạnh mùa đông vừa rồi"},{"id":"c","text":"Hãy giữ ấm mùa đông tới"}],"correctOptionId":"b","explanationVi":"''You must have been cold last winter.''"}'::jsonb),
 ('b1-u09-l4-q3','b1-u09-l4','multiple_choice',10,'quiz','medium',true,'{"question":"Cấu trúc ''must have been'' diễn đạt điều gì?","options":[{"id":"a","text":"Suy luận hiện tại"},{"id":"b","text":"Suy luận quá khứ chắc chắn"},{"id":"c","text":"Khả năng tương lai"}],"correctOptionId":"b","explanationVi":"must have + V3 = suy luận quá khứ chắc chắn."}'::jsonb),
 ('b1-u09-l4-q4','b1-u09-l4','grammar_fill_blank',11,'quiz','medium',true,'{"question":"Hoàn thành: ''He ___ (must/remember) and sent it as a surprise.''","acceptedAnswers":["must have remembered"],"explanationVi":"must + have + V3."}'::jsonb),
 ('b1-u09-l4-q5','b1-u09-l4','multiple_choice',12,'quiz','medium',true,'{"question":"Cấu trúc ''could only have been'' diễn đạt mức độ chắc chắn nào?","options":[{"id":"a","text":"Gần như chắc chắn"},{"id":"b","text":"Không chắc"},{"id":"c","text":"Chắc chắn sai"}],"correctOptionId":"a","explanationVi":"could only have been = chỉ có thể là, gần như chắc chắn."}'::jsonb),
 ('b1-u09-l4-q6','b1-u09-l4','vocabulary_match',13,'quiz','easy',true,'{"question":"Nối từ với nghĩa:","pairs":[{"left":"wrap","right":"bọc, gói"},{"left":"puzzled","right":"bối rối"},{"left":"sender","right":"người gửi"}],"explanationVi":"Ghép đúng."}'::jsonb),
 ('b1-u09-l4-q7','b1-u09-l4','grammar_fill_blank',14,'quiz','hard',true,'{"question":"Chuyển sang suy luận quá khứ: ''She must be tired.'' → She ___ tired.","acceptedAnswers":["must have been"],"explanationVi":"Hiện tại → quá khứ: must be → must have been."}'::jsonb);

-- Lesson 09-L5: Unit Review
INSERT INTO learning_lessons (id, level_code, skill_code, unit_id, lesson_type, lesson_order, title, subtitle, duration_minutes, xp_reward, required_score_to_pass, content, theory_content) VALUES
 ('b1-u09-l5','B1','reading','b1-u09','unit_review',5,'Unit 9 Review','Ôn tập Unit 9: It Must Be True!',12,30,75,'{}'::jsonb,
  '{"warmup":"Ôn tập Unit 9: must/might/could/can''t cho suy luận hiện tại và quá khứ.","objectives":["Tổng hợp can-do Unit 9","Đạt ≥ 75% để hoàn thành Unit"],"vocabBlock":[],"examples":[],"commonMistakes":[],"tips":["Cần đúng ≥ 8/10 để qua Unit."]}'::jsonb);

INSERT INTO learning_lesson_activities (id, lesson_id, activity_type, display_order, phase, difficulty, counts_toward_mastery, payload) VALUES
 ('b1-u09-l5-q1','b1-u09-l5','multiple_choice',1,'quiz','easy',true,'{"question":"Chọn từ đúng: ''She''s been awake all night. She ___ be exhausted.''","options":[{"id":"a","text":"can''t"},{"id":"b","text":"must"},{"id":"c","text":"might not"}],"correctOptionId":"b","explanationVi":"Bằng chứng rõ → must."}'::jsonb),
 ('b1-u09-l5-q2','b1-u09-l5','grammar_fill_blank',2,'quiz','easy',true,'{"question":"Điền vào chỗ trống: ''The lights are all off. They ___ be home.'' (chắc chắn sai)","acceptedAnswers":["can''t"],"explanationVi":"Suy luận phủ định → can''t."}'::jsonb),
 ('b1-u09-l5-q3','b1-u09-l5','multiple_choice',3,'quiz','easy',true,'{"question":"Modal nào diễn đạt khả năng KHÔNG CHẮC?","options":[{"id":"a","text":"must"},{"id":"b","text":"might"},{"id":"c","text":"can''t"}],"correctOptionId":"b","explanationVi":"might/could = không chắc chắn."}'::jsonb),
 ('b1-u09-l5-q4','b1-u09-l5','error_correction',4,'quiz','medium',true,'{"question":"Sửa lỗi: ''He must has left already.''","acceptedAnswers":["He must have left already."],"explanationVi":"must + have (không phải has) + V3."}'::jsonb),
 ('b1-u09-l5-q5','b1-u09-l5','multiple_choice',5,'quiz','medium',true,'{"question":"Chọn câu suy luận quá khứ ĐÚNG: Cửa sổ bị vỡ.","options":[{"id":"a","text":"Someone must break it."},{"id":"b","text":"Someone must have broken it."},{"id":"c","text":"Someone must broke it."}],"correctOptionId":"b","explanationVi":"Suy luận quá khứ: must have + V3."}'::jsonb),
 ('b1-u09-l5-q6','b1-u09-l5','vocabulary_match',6,'quiz','medium',true,'{"question":"Nối cấu trúc với nghĩa:","pairs":[{"left":"must have + V3","right":"chắc hẳn đã"},{"left":"might have + V3","right":"có thể đã"},{"left":"can''t have + V3","right":"không thể nào đã"}],"explanationVi":"Suy luận quá khứ."}'::jsonb),
 ('b1-u09-l5-q7','b1-u09-l5','grammar_fill_blank',7,'quiz','medium',true,'{"question":"Điền vào chỗ trống: ''She didn''t answer. She ___ (might/sleep) at the time.''","acceptedAnswers":["might have been sleeping","might have been asleep"],"explanationVi":"might + have + been + V-ing."}'::jsonb),
 ('b1-u09-l5-q8','b1-u09-l5','multiple_choice',8,'quiz','hard',true,'{"question":"Chọn suy luận hợp lý: Anh ấy rất giỏi tiếng Nhật nhưng chưa bao giờ học.","options":[{"id":"a","text":"He must have lived in Japan."},{"id":"b","text":"He can''t have lived in Japan."},{"id":"c","text":"He might not have learned Japanese."}],"correctOptionId":"a","explanationVi":"Bằng chứng mạnh → must have lived."}'::jsonb),
 ('b1-u09-l5-q9','b1-u09-l5','error_correction',9,'quiz','medium',true,'{"question":"Sửa lỗi: ''They mustn''t have known — tell them.''","acceptedAnswers":["They can''t have known — tell them."],"explanationVi":"Suy luận phủ định quá khứ → can''t have."}'::jsonb),
 ('b1-u09-l5-q10','b1-u09-l5','grammar_fill_blank',10,'quiz','hard',true,'{"question":"Điền vào chỗ trống: ''The car is gone. He ___ (must/take) it to work.''","acceptedAnswers":["must have taken"],"explanationVi":"must + have + V3."}'::jsonb);

UPDATE learning_units SET review_lesson_id = 'b1-u09-l5' WHERE id = 'b1-u09';
