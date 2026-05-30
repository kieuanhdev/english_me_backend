-- =============================================================================
-- V32 — LÀM DÀY LÝ THUYẾT A1 (grammarHtml chi tiết cho từng lesson)
-- =============================================================================
-- Lý do: (1) FE trước đây KHÔNG render grammarHtml (đã sửa ở lesson_player_screen);
--        (2) grammarHtml cũ chỉ 1 dòng → lý thuyết "qua loa".
-- Cách làm: UPDATE jsonb_set theory_content.grammarHtml bằng giải thích đầy đủ
--   (bảng chia dạng text, 3 thể khẳng/phủ/nghi vấn, cách dùng, lưu ý). Dùng \n xuống dòng.
-- An toàn: chỉ UPDATE cột theory_content của lesson đã tồn tại (không đụng câu hỏi/tiến độ).
-- =============================================================================

-- Helper pattern: UPDATE learning_lessons SET theory_content = jsonb_set(theory_content,'{grammarHtml}', to_jsonb(<text>)) WHERE id = ...;

-- ── Greetings L2 — Đại từ chủ ngữ ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'ĐẠI TỪ CHỦ NGỮ (Subject Pronouns) — dùng để thay cho người/vật làm chủ ngữ.

Số ít:
• I = tôi
• you = bạn
• he = anh ấy (nam)
• she = cô ấy (nữ)
• it = nó (vật, con vật)

Số nhiều:
• we = chúng tôi
• you = các bạn
• they = họ / chúng nó

CÁCH DÙNG: đặt đại từ ở đầu câu, trước động từ.
VD: She is a teacher. (Cô ấy là giáo viên.)
    They are my friends. (Họ là bạn của tôi.)

MẪU HỎI TÊN:
What''s your name? – I''m + tên.
(What''s = What is)
VD: What''s your name? – I''m Nam.'::text)) WHERE id = 'a1-unit-greetings-l2';

-- ── Greetings L3 — Verb to be (trọng tâm) ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'ĐỘNG TỪ TO BE (am / is / are) ở thì hiện tại.

BẢNG CHIA theo chủ ngữ:
• I            → am      (I am)
• He/She/It    → is      (He is)
• You/We/They  → are     (You are)

1) KHẲNG ĐỊNH: S + am/is/are + ...
   VD: I am a student.  •  She is from Japan.  •  They are happy.

2) PHỦ ĐỊNH: thêm "not" sau to be (viết tắt: isn''t, aren''t).
   VD: I am not tired.  •  He is not (isn''t) here.  •  We are not (aren''t) late.

3) NGHI VẤN: đảo to be lên trước chủ ngữ.
   VD: Are you a student? – Yes, I am. / No, I am not.
       Is she your friend? – Yes, she is.

VIẾT TẮT thường gặp: I''m, you''re, he''s, she''s, it''s, we''re, they''re.

LƯU Ý: mỗi chủ ngữ chỉ đi với MỘT dạng to be. Sai phổ biến: "She are" → đúng là "She is".'::text)) WHERE id = 'a1-unit-greetings-l3';

-- ── Greetings L4 — Introducing others ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'GIỚI THIỆU NGƯỜI KHÁC.

MẪU CÂU:
• This is + tên/người.  → Đây là...
  VD: This is my friend, Nam.
• He/She is + nghề nghiệp/quốc tịch.
  VD: He is a teacher.  •  She is Vietnamese.

HỎI QUÊ QUÁN:
Where are you from? – I''m from + nơi chốn.
VD: Where are you from? – I''m from Vietnam.

TRÌNH TỰ giới thiệu: This is [tên]. + He/She is [thông tin].
VD: This is Mai. She is my classmate. She is from Hue.

LƯU Ý: dùng "This is" khi giới thiệu lần đầu một người ở gần.'::text)) WHERE id = 'a1-unit-greetings-l4';

-- ── Family L2 — Possessive adjectives ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'TÍNH TỪ SỞ HỮU (Possessive Adjectives) — đứng TRƯỚC danh từ để chỉ "của ai".

Đại từ chủ ngữ → Tính từ sở hữu:
• I    → my      (của tôi)
• you  → your    (của bạn)
• he   → his     (của anh ấy)
• she  → her     (của cô ấy)
• it   → its     (của nó)
• we   → our     (của chúng tôi)
• they → their   (của họ)

CÁCH DÙNG: tính từ sở hữu + danh từ.
VD: my book (sách của tôi)  •  her mother (mẹ của cô ấy)  •  their house (nhà của họ).

LƯU Ý: KHÔNG đổi theo số ít/số nhiều của danh từ.
VD: my book / my books (đều dùng "my").
Sai phổ biến: "she book" → đúng là "her book".'::text)) WHERE id = 'a1-family-l2';

-- ── Family L3 — Describing people ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'MIÊU TẢ NGƯỜI với tính từ.

CẤU TRÚC: S + to be (am/is/are) + tính từ.
VD: She is tall.  •  They are young.

TÍNH TỪ NGOẠI HÌNH thường gặp:
• tall (cao) ↔ short (thấp)
• young (trẻ) ↔ old (già)
• big (to) ↔ small (nhỏ)

LƯU Ý QUAN TRỌNG: KHÔNG dùng mạo từ a/an trước tính từ đứng một mình.
Sai: "She is a tall." → Đúng: "She is tall."

Tính từ KHÔNG thêm -s ở số nhiều:
VD: They are tall. (KHÔNG phải "talls").'::text)) WHERE id = 'a1-family-l3';

-- ── Daily L2 — Present simple ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'THÌ HIỆN TẠI ĐƠN (Present Simple) — diễn tả thói quen, sự thật.

1) KHẲNG ĐỊNH:
   • I/You/We/They + V (nguyên thể):  I play.  They work.
   • He/She/It + V-s/es:  He plays.  She goes.
   Quy tắc thêm -s: thường +s; sau o/s/x/ch/sh thì +es (go→goes, watch→watches).

2) PHỦ ĐỊNH: S + do/does + not + V(nguyên thể).
   • I/you/we/they → don''t:  They don''t play.
   • he/she/it → doesn''t:  She doesn''t play. (động từ KHÔNG còn -s)

3) NGHI VẤN: Do/Does + S + V(nguyên thể)?
   • Do you work? – Yes, I do.
   • Does she work? – Yes, she does.

LƯU Ý: ngôi thứ 3 số ít (he/she/it) thêm -s ở câu khẳng định, nhưng KHÔNG thêm -s sau does/doesn''t.
Sai: "He go" → Đúng: "He goes". Sai: "She doesn''t goes" → Đúng: "She doesn''t go".'::text)) WHERE id = 'a1-daily-l2';

-- ── Daily L3 — Routine with time ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'KỂ THÓI QUEN KÈM THỜI GIAN.

GIỚI TỪ CHỈ GIỜ: dùng "at" + giờ cụ thể.
VD: at 6 o''clock, at 7, at noon.
   I wake up at 6. (Tôi thức dậy lúc 6 giờ.)

NỐI CHUỖI hoạt động bằng: then, after that, and.
VD: I wake up at 6. Then I have breakfast. After that, I go to school.

CỤM ĐỘNG TỪ thường dùng: wake up, get up, have breakfast/lunch/dinner, go to school, go home, go to bed.

LƯU Ý: dùng "at" với giờ, KHÔNG dùng "in".
Sai: "in 6 o''clock" → Đúng: "at 6 o''clock".'::text)) WHERE id = 'a1-daily-l3';

-- ── Food L2 — I like / I don't like ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'DIỄN ĐẠT SỞ THÍCH với "like".

1) KHẲNG ĐỊNH: S + like(s) + danh từ.
   VD: I like tea.  •  She likes coffee. (he/she/it thêm -s)

2) PHỦ ĐỊNH: S + don''t/doesn''t + like + danh từ.
   VD: I don''t like coffee.  •  He doesn''t like fish.

3) NGHI VẤN: Do/Does + S + like + ...?
   VD: Do you like tea? – Yes, I do. / No, I don''t.

MỨC ĐỘ: love (rất thích) > like (thích) > don''t like (không thích) > hate (ghét).

LƯU Ý: sau like dùng danh từ hoặc V-ing.
Sai: "I no like coffee." → Đúng: "I don''t like coffee."'::text)) WHERE id = 'a1-food-l2';

-- ── Numbers L2 — Telling time ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'HỎI VÀ NÓI GIỜ.

HỎI: What time is it? (Mấy giờ rồi?)
TRẢ LỜI: It''s + giờ.

CÁCH NÓI GIỜ:
• Giờ chẵn: It''s seven o''clock. (7:00)
• Giờ rưỡi: It''s half past seven. (7:30)
• Hơn ... phút: It''s ten past seven. (7:10)
• Kém ... phút: It''s a quarter to eight. (7:45)

LƯU Ý: "o''clock" chỉ dùng cho giờ chẵn (đúng giờ).
Sai: "What time is?" → Đúng: "What time is it?" (cần có "it").'::text)) WHERE id = 'a1-numbers-l2';

-- ── Things L1 — This/That/These/Those ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'TỪ CHỈ ĐỊNH (Demonstratives) — chỉ vật ở gần hay xa, số ít hay số nhiều.

         | Số ít        | Số nhiều
GẦN      | this (này)   | these (những...này)
XA       | that (kia)   | those (những...kia)

CÁCH DÙNG:
• this/that + danh từ số ít + is:  This is a book.  That is a pen.
• these/those + danh từ số nhiều + are:  These are books.  Those are pens.

VD: This is my phone. (gần, 1 cái)
    Those are her shoes. (xa, nhiều cái)

LƯU Ý: this/that đi với "is"; these/those đi với "are".
Sai: "This are books." → Đúng: "These are books."'::text)) WHERE id = 'a1-things-l1';

-- ── Things L2 — Plural nouns ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'DANH TỪ SỐ NHIỀU (Plural Nouns).

QUY TẮC:
1) Thường thêm -s:  book → books, pen → pens.
2) Sau s, x, ch, sh thêm -es:  box → boxes, watch → watches, dish → dishes.
3) Tận cùng phụ âm + y → đổi y thành -ies:  city → cities, baby → babies.
4) BẤT QUY TẮC (học thuộc):
   • man → men      • woman → women
   • child → children   • foot → feet
   • tooth → teeth   • person → people

VD: I have two books.  •  There are three children.

LƯU Ý: số đếm > 1 thì danh từ phải ở số nhiều.
Sai: "two book" → Đúng: "two books".'::text)) WHERE id = 'a1-things-l2';

-- ── Can L1 — Can for ability ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'ĐỘNG TỪ KHUYẾT THIẾU "CAN" — diễn tả khả năng (biết làm gì).

1) KHẲNG ĐỊNH: S + can + V(nguyên thể).
   VD: I can swim.  •  She can sing.
   (can dùng chung cho MỌI chủ ngữ — không thêm -s)

2) PHỦ ĐỊNH: S + can''t (cannot) + V.
   VD: He can''t cook.  •  I can''t drive.

3) NGHI VẤN: Can + S + V?
   VD: Can you swim? – Yes, I can. / No, I can''t.

LƯU Ý QUAN TRỌNG: sau "can" LUÔN là động từ nguyên thể, KHÔNG có "to".
Sai: "I can to swim." → Đúng: "I can swim."
can dùng như nhau cho I/you/he/she/we/they (KHÔNG có "cans").'::text)) WHERE id = 'a1-can-l1';

-- ── Can L2 — Can questions ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'HỎI ĐÁP VỀ KHẢ NĂNG với "can".

CÂU HỎI: Can + S + V(nguyên thể)?
VD: Can you cook?  •  Can she dance?

TRẢ LỜI NGẮN:
• Có: Yes, S + can.  → Yes, I can.
• Không: No, S + can''t.  → No, I can''t.

LƯU Ý QUAN TRỌNG: câu hỏi với "can" KHÔNG dùng do/does.
Sai: "Do you can swim?" → Đúng: "Can you swim?"

WH-question với can: What can you do? (Bạn làm được gì?)'::text)) WHERE id = 'a1-can-l2';

-- ── Places L2 — Prepositions of place ──
UPDATE learning_lessons SET theory_content = jsonb_set(theory_content, '{grammarHtml}', to_jsonb(
'GIỚI TỪ CHỈ NƠI CHỐN (Prepositions of Place) — chỉ vị trí của vật.

• in (trong):  The pen is in the box.
• on (trên bề mặt):  The book is on the table.
• under (dưới):  The cat is under the chair.
• next to (cạnh):  The lamp is next to the bed.
• behind (phía sau) / in front of (phía trước).

CẤU TRÚC: S + to be + giới từ + nơi chốn.
VD: The keys are on the desk.

PHÂN BIỆT in vs on:
• in = bên trong (in the box, in the room).
• on = tiếp xúc bề mặt (on the table, on the wall).
Sai: "in the table" (khi ý là trên) → Đúng: "on the table".'::text)) WHERE id = 'a1-places-l2';
