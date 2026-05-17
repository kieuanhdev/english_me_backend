CREATE TABLE vocabulary_topic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    level VARCHAR(10),
    color_hex VARCHAR(7),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE vocabulary_word (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES vocabulary_topic(id) ON DELETE CASCADE,
    word VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),
    part_of_speech VARCHAR(50),
    definition_vi TEXT,
    definition_en TEXT,
    example_sentence TEXT,
    example_translation TEXT,
    level VARCHAR(10) NOT NULL,
    audio_url TEXT
);

CREATE INDEX idx_vocabulary_word_topic ON vocabulary_word(topic_id);
CREATE INDEX idx_vocabulary_word_level ON vocabulary_word(level);

-- ── Seed data ────────────────────────────────────────────────────────────────

INSERT INTO vocabulary_topic (id, name, name_en, icon, level, color_hex, sort_order) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'Chào hỏi', 'Greetings', '👋', 'A1', '#4CAF50', 1),
    ('a0000001-0000-0000-0000-000000000002', 'Ẩm thực', 'Food & Drinks', '🍜', 'A1', '#FF9800', 2),
    ('a0000001-0000-0000-0000-000000000003', 'Gia đình', 'Family', '👨‍👩‍👧', 'A1', '#E91E63', 3),
    ('a0000001-0000-0000-0000-000000000004', 'Du lịch', 'Travel', '✈️', 'A2', '#2196F3', 4),
    ('a0000001-0000-0000-0000-000000000005', 'Kinh doanh', 'Business', '💼', 'B1', '#9C27B0', 5);

-- Topic 1: Greetings (A1)
INSERT INTO vocabulary_word (topic_id, word, pronunciation, part_of_speech, definition_vi, definition_en, example_sentence, example_translation, level) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'hello', '/həˈloʊ/', 'exclamation', 'xin chào', 'used as a greeting', 'Hello, how are you?', 'Xin chào, bạn có khỏe không?', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'goodbye', '/ˌɡʊdˈbaɪ/', 'exclamation', 'tạm biệt', 'used when leaving', 'Goodbye, see you tomorrow!', 'Tạm biệt, hẹn gặp lại ngày mai!', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'thank you', '/ˈθæŋk juː/', 'phrase', 'cảm ơn', 'used to express gratitude', 'Thank you for your help.', 'Cảm ơn bạn đã giúp đỡ.', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'please', '/pliːz/', 'adverb', 'làm ơn', 'used to make a polite request', 'Please sit down.', 'Làm ơn hãy ngồi xuống.', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'sorry', '/ˈsɒri/', 'exclamation', 'xin lỗi', 'used to apologize', 'Sorry, I am late.', 'Xin lỗi, tôi bị trễ.', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'excuse me', '/ɪkˈskjuːz miː/', 'phrase', 'xin phép / xin lỗi', 'used to get attention or apologize', 'Excuse me, where is the station?', 'Xin lỗi, nhà ga ở đâu?', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'good morning', '/ˌɡʊd ˈmɔːrnɪŋ/', 'phrase', 'chào buổi sáng', 'a greeting said in the morning', 'Good morning! Did you sleep well?', 'Chào buổi sáng! Bạn ngủ ngon không?', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'good night', '/ˌɡʊd ˈnaɪt/', 'phrase', 'chúc ngủ ngon', 'said when going to bed or leaving at night', 'Good night, sweet dreams.', 'Chúc ngủ ngon, ngủ ngon nhé.', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'nice to meet you', '/naɪs tə miːt juː/', 'phrase', 'rất vui được gặp bạn', 'said when meeting someone for the first time', 'Nice to meet you, I am Anna.', 'Rất vui được gặp bạn, tôi là Anna.', 'a1'),
    ('a0000001-0000-0000-0000-000000000001', 'how are you', '/haʊ ɑːr juː/', 'phrase', 'bạn có khỏe không', 'used to ask about someone''s well-being', 'How are you today?', 'Hôm nay bạn có khỏe không?', 'a1');

-- Topic 2: Food & Drinks (A1)
INSERT INTO vocabulary_word (topic_id, word, pronunciation, part_of_speech, definition_vi, definition_en, example_sentence, example_translation, level) VALUES
    ('a0000001-0000-0000-0000-000000000002', 'rice', '/raɪs/', 'noun', 'cơm / gạo', 'a common grain used as food', 'I eat rice every day.', 'Tôi ăn cơm mỗi ngày.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'water', '/ˈwɔːtər/', 'noun', 'nước', 'a clear liquid essential for life', 'Can I have a glass of water?', 'Cho tôi một ly nước được không?', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'bread', '/brɛd/', 'noun', 'bánh mì', 'food made from baked dough', 'I have bread for breakfast.', 'Tôi ăn bánh mì vào bữa sáng.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'milk', '/mɪlk/', 'noun', 'sữa', 'a white liquid produced by mammals', 'Children should drink milk daily.', 'Trẻ em nên uống sữa mỗi ngày.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'chicken', '/ˈtʃɪkɪn/', 'noun', 'thịt gà', 'meat from a chicken', 'I ordered grilled chicken.', 'Tôi gọi gà nướng.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'vegetable', '/ˈvɛdʒtəbəl/', 'noun', 'rau củ', 'a plant used as food', 'Eat more vegetables for good health.', 'Ăn nhiều rau để có sức khỏe tốt.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'fruit', '/fruːt/', 'noun', 'trái cây', 'the sweet part of a plant', 'I like tropical fruit.', 'Tôi thích trái cây nhiệt đới.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'coffee', '/ˈkɒfi/', 'noun', 'cà phê', 'a hot drink made from roasted beans', 'I drink coffee every morning.', 'Tôi uống cà phê mỗi buổi sáng.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'egg', '/ɛɡ/', 'noun', 'trứng', 'an oval object laid by a bird', 'I had two fried eggs for breakfast.', 'Tôi ăn hai quả trứng chiên vào bữa sáng.', 'a1'),
    ('a0000001-0000-0000-0000-000000000002', 'soup', '/suːp/', 'noun', 'canh / súp', 'a liquid food made by boiling ingredients', 'The soup is very hot.', 'Canh này rất nóng.', 'a1');

-- Topic 3: Family (A1)
INSERT INTO vocabulary_word (topic_id, word, pronunciation, part_of_speech, definition_vi, definition_en, example_sentence, example_translation, level) VALUES
    ('a0000001-0000-0000-0000-000000000003', 'mother', '/ˈmʌðər/', 'noun', 'mẹ', 'a female parent', 'My mother is a teacher.', 'Mẹ tôi là giáo viên.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'father', '/ˈfɑːðər/', 'noun', 'bố / cha', 'a male parent', 'My father works in a hospital.', 'Bố tôi làm việc trong bệnh viện.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'sister', '/ˈsɪstər/', 'noun', 'chị / em gái', 'a female sibling', 'I have one older sister.', 'Tôi có một chị gái.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'brother', '/ˈbrʌðər/', 'noun', 'anh / em trai', 'a male sibling', 'My brother plays football.', 'Anh trai tôi chơi bóng đá.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'grandmother', '/ˈɡrænˌmʌðər/', 'noun', 'bà', 'the mother of one''s parent', 'My grandmother lives in the countryside.', 'Bà tôi sống ở nông thôn.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'grandfather', '/ˈɡrænˌfɑːðər/', 'noun', 'ông', 'the father of one''s parent', 'My grandfather is 80 years old.', 'Ông tôi 80 tuổi.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'children', '/ˈtʃɪldrən/', 'noun', 'con cái / trẻ em', 'plural of child', 'They have three children.', 'Họ có ba đứa con.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'husband', '/ˈhʌzbənd/', 'noun', 'chồng', 'a married man', 'Her husband is very kind.', 'Chồng cô ấy rất tốt bụng.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'wife', '/waɪf/', 'noun', 'vợ', 'a married woman', 'His wife is a doctor.', 'Vợ anh ấy là bác sĩ.', 'a1'),
    ('a0000001-0000-0000-0000-000000000003', 'family', '/ˈfæməli/', 'noun', 'gia đình', 'a group of related people', 'We spend time together as a family.', 'Chúng tôi dành thời gian cùng nhau như một gia đình.', 'a1');

-- Topic 4: Travel (A2)
INSERT INTO vocabulary_word (topic_id, word, pronunciation, part_of_speech, definition_vi, definition_en, example_sentence, example_translation, level) VALUES
    ('a0000001-0000-0000-0000-000000000004', 'airport', '/ˈɛərˌpɔːrt/', 'noun', 'sân bay', 'a place where aircraft take off and land', 'We arrived at the airport early.', 'Chúng tôi đến sân bay sớm.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'passport', '/ˈpɑːspɔːrt/', 'noun', 'hộ chiếu', 'an official document for international travel', 'Don''t forget your passport.', 'Đừng quên hộ chiếu của bạn.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'hotel', '/hoʊˈtɛl/', 'noun', 'khách sạn', 'a place to stay when travelling', 'We booked a hotel near the beach.', 'Chúng tôi đặt khách sạn gần bãi biển.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'ticket', '/ˈtɪkɪt/', 'noun', 'vé', 'a document allowing entry or travel', 'I bought a return ticket.', 'Tôi mua vé khứ hồi.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'luggage', '/ˈlʌɡɪdʒ/', 'noun', 'hành lý', 'bags and cases taken on a journey', 'My luggage is too heavy.', 'Hành lý của tôi quá nặng.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'destination', '/ˌdɛstɪˈneɪʃən/', 'noun', 'điểm đến', 'the place you are travelling to', 'Our destination is Paris.', 'Điểm đến của chúng tôi là Paris.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'journey', '/ˈdʒɜːrni/', 'noun', 'hành trình', 'travel from one place to another', 'The journey took five hours.', 'Hành trình mất năm tiếng.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'boarding pass', '/ˈbɔːrdɪŋ pæs/', 'noun', 'thẻ lên máy bay', 'a document needed to board a flight', 'Please show your boarding pass.', 'Vui lòng xuất trình thẻ lên máy bay.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'customs', '/ˈkʌstəmz/', 'noun', 'hải quan', 'the place where goods are checked at borders', 'We passed through customs quickly.', 'Chúng tôi qua hải quan nhanh chóng.', 'a2'),
    ('a0000001-0000-0000-0000-000000000004', 'reservation', '/ˌrɛzərˈveɪʃən/', 'noun', 'đặt chỗ / đặt phòng', 'an arrangement to keep something for you', 'I made a reservation for two nights.', 'Tôi đặt phòng cho hai đêm.', 'a2');

-- Topic 5: Business (B1)
INSERT INTO vocabulary_word (topic_id, word, pronunciation, part_of_speech, definition_vi, definition_en, example_sentence, example_translation, level) VALUES
    ('a0000001-0000-0000-0000-000000000005', 'meeting', '/ˈmiːtɪŋ/', 'noun', 'cuộc họp', 'a gathering to discuss something', 'We have a meeting at 9 a.m.', 'Chúng tôi có cuộc họp lúc 9 giờ sáng.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'deadline', '/ˈdɛdlaɪn/', 'noun', 'hạn chót', 'the latest time for completing a task', 'The deadline is Friday.', 'Hạn chót là thứ Sáu.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'negotiate', '/nɪˈɡoʊʃieɪt/', 'verb', 'đàm phán', 'to discuss in order to reach an agreement', 'We need to negotiate the price.', 'Chúng tôi cần đàm phán giá cả.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'contract', '/ˈkɒntrækt/', 'noun', 'hợp đồng', 'a legal agreement between parties', 'Please sign the contract.', 'Vui lòng ký hợp đồng.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'client', '/ˈklaɪənt/', 'noun', 'khách hàng', 'a person who uses a service', 'We need to satisfy our clients.', 'Chúng tôi cần làm hài lòng khách hàng.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'budget', '/ˈbʌdʒɪt/', 'noun', 'ngân sách', 'an estimate of income and expenditure', 'We are within budget this quarter.', 'Chúng tôi trong ngân sách trong quý này.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'proposal', '/prəˈpoʊzəl/', 'noun', 'đề xuất', 'a plan or suggestion put forward', 'She submitted a detailed proposal.', 'Cô ấy đã nộp một đề xuất chi tiết.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'revenue', '/ˈrɛvənjuː/', 'noun', 'doanh thu', 'income generated from business activities', 'Revenue increased by 20% this year.', 'Doanh thu tăng 20% trong năm nay.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'strategy', '/ˈstræt̬ədʒi/', 'noun', 'chiến lược', 'a plan to achieve a long-term goal', 'We need a new marketing strategy.', 'Chúng tôi cần một chiến lược marketing mới.', 'b1'),
    ('a0000001-0000-0000-0000-000000000005', 'stakeholder', '/ˈsteɪkˌhoʊldər/', 'noun', 'các bên liên quan', 'a person with an interest in a project', 'We presented results to all stakeholders.', 'Chúng tôi trình bày kết quả cho tất cả các bên liên quan.', 'b1');
