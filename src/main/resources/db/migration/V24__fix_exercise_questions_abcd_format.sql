-- Xóa toàn bộ seed cũ (options là array, correctAnswer là text)
-- và reseed với format chuẩn: options là object {A,B,C,D}, correctAnswer là label A/B/C/D

DELETE FROM exercise_answer;
DELETE FROM exercise_session;
DELETE FROM exercise_question;

-- vocabulary easy (A1)
INSERT INTO exercise_question (category, difficulty, question, options, correct_answer, explanation, level) VALUES
('vocabulary', 'easy', 'What does "apple" mean?',
 '{"A":"Quả táo","B":"Quả cam","C":"Quả chuối","D":"Quả nho"}', 'A', 'Apple = quả táo trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "book" mean?',
 '{"A":"Bàn","B":"Ghế","C":"Sách","D":"Cửa"}', 'C', 'Book = sách trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "water" mean?',
 '{"A":"Lửa","B":"Nước","C":"Đất","D":"Gió"}', 'B', 'Water = nước trong tiếng Việt', 'A1'),
('vocabulary', 'easy', 'What does "house" mean?',
 '{"A":"Trường học","B":"Bệnh viện","C":"Nhà","D":"Chợ"}', 'C', 'House = ngôi nhà', 'A1'),
('vocabulary', 'easy', 'What does "cat" mean?',
 '{"A":"Con chó","B":"Con mèo","C":"Con bò","D":"Con gà"}', 'B', 'Cat = con mèo', 'A1'),
('vocabulary', 'easy', 'Choose the correct word: "I ___ a student."',
 '{"A":"am","B":"is","C":"are","D":"be"}', 'A', 'Với chủ từ "I" ta dùng "am"', 'A1'),
('vocabulary', 'easy', 'What does "happy" mean?',
 '{"A":"Buồn","B":"Tức giận","C":"Vui vẻ","D":"Sợ hãi"}', 'C', 'Happy = vui vẻ, hạnh phúc', 'A1'),
('vocabulary', 'easy', 'What does "big" mean?',
 '{"A":"Nhỏ","B":"To lớn","C":"Dài","D":"Ngắn"}', 'B', 'Big = to, lớn', 'A1'),
('vocabulary', 'easy', 'What does "beautiful" mean?',
 '{"A":"Xấu","B":"Đẹp","C":"Cao","D":"Thấp"}', 'B', 'Beautiful = đẹp', 'A1'),
('vocabulary', 'easy', 'What does "fast" mean?',
 '{"A":"Chậm","B":"Nhanh","C":"Nhỏ","D":"Yếu"}', 'B', 'Fast = nhanh', 'A1'),

-- vocabulary medium (A2-B1)
('vocabulary', 'medium', 'Which word means "determined to succeed"?',
 '{"A":"Lazy","B":"Ambitious","C":"Careless","D":"Shy"}', 'B', 'Ambitious = có tham vọng, quyết tâm', 'B1'),
('vocabulary', 'medium', 'What is the synonym of "begin"?',
 '{"A":"End","B":"Finish","C":"Start","D":"Stop"}', 'C', 'Begin và start đều có nghĩa là bắt đầu', 'A2'),
('vocabulary', 'medium', 'What does "frequently" mean?',
 '{"A":"Rarely","B":"Sometimes","C":"Often","D":"Never"}', 'C', 'Frequently = thường xuyên = often', 'A2'),
('vocabulary', 'medium', 'Which word is an antonym of "ancient"?',
 '{"A":"Old","B":"Modern","C":"Historical","D":"Traditional"}', 'B', 'Ancient = cổ xưa, antonym là modern = hiện đại', 'B1'),
('vocabulary', 'medium', 'What does "collaborative" mean?',
 '{"A":"Working alone","B":"Competing","C":"Working together","D":"Disagreeing"}', 'C', 'Collaborative = hợp tác, làm việc cùng nhau', 'B1'),

-- vocabulary hard (B2-C1)
('vocabulary', 'hard', 'What does "benevolent" mean?',
 '{"A":"Kind and generous","B":"Angry","C":"Curious","D":"Lazy"}', 'A', '"Benevolent" means well-meaning and kindly.', 'B2'),
('vocabulary', 'hard', 'Choose the word closest in meaning to "ephemeral".',
 '{"A":"Permanent","B":"Transient","C":"Eternal","D":"Stable"}', 'B', 'Ephemeral = fleeting, short-lived = transient', 'C1'),
('vocabulary', 'hard', 'What does "ubiquitous" mean?',
 '{"A":"Rare","B":"Invisible","C":"Present everywhere","D":"Dangerous"}', 'C', 'Ubiquitous = seeming to appear everywhere at the same time', 'C1'),

-- grammar easy (A1-A2)
('grammar', 'easy', 'She ___ to school every day.',
 '{"A":"go","B":"goes","C":"going","D":"gone"}', 'B', 'Ngôi thứ 3 số ít (she) thêm -s vào động từ', 'A1'),
('grammar', 'easy', 'They ___ watching TV now.',
 '{"A":"is","B":"am","C":"are","D":"be"}', 'C', 'They là số nhiều nên dùng "are"', 'A1'),
('grammar', 'easy', 'I ___ a book yesterday.',
 '{"A":"reads","B":"reading","C":"readed","D":"read"}', 'D', '"Read" là động từ bất quy tắc, quá khứ vẫn là "read"', 'A1'),
('grammar', 'easy', 'There ___ a cat on the table.',
 '{"A":"am","B":"is","C":"are","D":"be"}', 'B', 'There is + danh từ số ít', 'A1'),
('grammar', 'easy', 'She has ___ her homework.',
 '{"A":"do","B":"did","C":"done","D":"does"}', 'C', 'have/has + past participle (done)', 'A2'),
('grammar', 'easy', '___ you speak English?',
 '{"A":"Do","B":"Does","C":"Is","D":"Are"}', 'A', 'Câu hỏi với "you" dùng Do', 'A1'),

-- grammar medium (B1)
('grammar', 'medium', 'If I ___ rich, I would travel the world.',
 '{"A":"am","B":"was","C":"were","D":"be"}', 'C', 'Câu điều kiện loại 2 dùng "were" với tất cả chủ từ', 'B1'),
('grammar', 'medium', 'She suggested ___ earlier.',
 '{"A":"leave","B":"leaving","C":"to leave","D":"left"}', 'B', 'suggest + V-ing', 'B1'),
('grammar', 'medium', 'The report ___ by the team last week.',
 '{"A":"wrote","B":"was written","C":"has written","D":"is written"}', 'B', 'Câu bị động thì quá khứ đơn', 'B1'),
('grammar', 'medium', 'He is used to ___ late.',
 '{"A":"work","B":"works","C":"working","D":"worked"}', 'C', 'be used to + V-ing', 'B1'),
('grammar', 'medium', 'No sooner ___ she arrived than it started raining.',
 '{"A":"had","B":"has","C":"did","D":"was"}', 'A', 'No sooner + had + S + V3/V-ed (đảo ngữ)', 'B2'),

-- grammar hard (B2-C1)
('grammar', 'hard', 'By the time she arrived, we ___ for two hours.',
 '{"A":"waited","B":"have waited","C":"had been waiting","D":"were waiting"}', 'C', 'Past Perfect Continuous diễn tả hành động kéo dài trước một mốc quá khứ', 'B2'),
('grammar', 'hard', 'Seldom ___ such a talented musician.',
 '{"A":"I have seen","B":"have I seen","C":"I had seen","D":"had I seen"}', 'B', 'Đảo ngữ với trạng từ phủ định "seldom": seldom + have + S + V3', 'C1');
