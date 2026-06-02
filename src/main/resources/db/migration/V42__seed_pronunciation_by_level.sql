-- V42 — Gán CEFR level cho bài luyện phát âm cũ + sinh thêm dữ liệu theo từng level.
-- Lý do: trước đây bài luyện âm chỉ có `difficulty` (beginner/intermediate/advanced),
--        cột `level` (A1–C2) để NULL. Mobile cần lọc theo level người học (thấy level <= mình).
-- Quy ước difficulty <-> level: A1/A2 = beginner, B1/B2 = intermediate, C1/C2 = advanced.

-- ── 1. Gán level cho 12 bài cũ (match theo text) ─────────────────────────────
UPDATE pronunciation_exercises SET level = 'A1' WHERE text = 'Hello, how are you?';
UPDATE pronunciation_exercises SET level = 'A1' WHERE text = 'Good morning, nice to meet you.';
UPDATE pronunciation_exercises SET level = 'A1' WHERE text = 'What time is it?';
UPDATE pronunciation_exercises SET level = 'A2' WHERE text = 'I would like a cup of coffee, please.';
UPDATE pronunciation_exercises SET level = 'A2' WHERE text = 'Where is the nearest bus station?';
UPDATE pronunciation_exercises SET level = 'B1' WHERE text = 'Could you repeat that more slowly, please?';
UPDATE pronunciation_exercises SET level = 'B1' WHERE text = 'I have been learning English for three years.';
UPDATE pronunciation_exercises SET level = 'B1' WHERE text = 'The weather is beautiful today, is not it?';
UPDATE pronunciation_exercises SET level = 'B2' WHERE text = 'Could you tell me how to get to the museum?';
UPDATE pronunciation_exercises SET level = 'B2' WHERE text = 'I would appreciate it if you could help me with this problem.';
UPDATE pronunciation_exercises SET level = 'C1' WHERE text = 'The presentation was incredibly insightful and well-structured.';
UPDATE pronunciation_exercises SET level = 'C1' WHERE text = 'Nevertheless, we should consider the long-term implications.';

-- Bài cũ nào còn sót level NULL -> mặc định A1 để không lọt khỏi bộ lọc.
UPDATE pronunciation_exercises SET level = 'A1' WHERE level IS NULL;

-- ── 2. Sinh thêm dữ liệu theo level (idempotent: chỉ chèn khi text chưa tồn tại) ─
INSERT INTO pronunciation_exercises (id, text, phonetic, meaning, audio_url, difficulty, level, tips)
SELECT gen_random_uuid(), v.text, v.phonetic, v.meaning, NULL, v.difficulty, v.level, v.tips
FROM (VALUES
    -- A1 (beginner)
    ('My name is Anna.', 'maɪ neɪm ɪz ˈænə', 'Tên tôi là Anna.', 'beginner', 'A1', 'Nói rõ âm /m/ cuối "name".'),
    ('I am a student.', 'aɪ æm ə ˈstuːdənt', 'Tôi là sinh viên.', 'beginner', 'A1', 'Nhấn âm đầu "STU-dent".'),
    ('Thank you very much.', 'θæŋk juː ˈvɛri mʌtʃ', 'Cảm ơn rất nhiều.', 'beginner', 'A1', 'Chú ý âm /θ/ trong "thank" — đặt lưỡi giữa răng.'),
    ('See you tomorrow.', 'siː juː təˈmɒroʊ', 'Hẹn gặp ngày mai.', 'beginner', 'A1', 'Kéo dài âm /iː/ trong "see".'),
    ('This is my family.', 'ðɪs ɪz maɪ ˈfæməli', 'Đây là gia đình tôi.', 'beginner', 'A1', 'Phân biệt /ð/ trong "this" với /θ/.'),
    ('I like apples and oranges.', 'aɪ laɪk ˈæpəlz ænd ˈɒrɪndʒɪz', 'Tôi thích táo và cam.', 'beginner', 'A1', 'Nối âm "apples_and".'),
    -- A2 (beginner)
    ('Can I have the menu, please?', 'kæn aɪ hæv ðə ˈmɛnjuː pliːz', 'Cho tôi xem thực đơn được không?', 'beginner', 'A2', 'Lên giọng cuối câu hỏi.'),
    ('How much does this cost?', 'haʊ mʌtʃ dʌz ðɪs kɒst', 'Cái này giá bao nhiêu?', 'beginner', 'A2', 'Nói gọn "does" thành /dʌz/.'),
    ('I usually wake up at seven.', 'aɪ ˈjuːʒuəli weɪk ʌp æt ˈsɛvən', 'Tôi thường thức dậy lúc bảy giờ.', 'beginner', 'A2', 'Nối "wake_up".'),
    ('What do you do for a living?', 'wɒt duː juː duː fɔːr ə ˈlɪvɪŋ', 'Bạn làm nghề gì?', 'beginner', 'A2', 'Giảm âm "for_a" thành /fərə/.'),
    ('It is raining outside today.', 'ɪt ɪz ˈreɪnɪŋ ˌaʊtˈsaɪd təˈdeɪ', 'Hôm nay trời đang mưa.', 'beginner', 'A2', 'Nhấn "out-SIDE".'),
    ('My favourite colour is blue.', 'maɪ ˈfeɪvərɪt ˈkʌlər ɪz bluː', 'Màu tôi thích là xanh dương.', 'beginner', 'A2', 'Đọc gọn "favourite" 2 âm tiết /ˈfeɪv-rɪt/.'),
    -- B1 (intermediate)
    ('I am thinking about changing my job.', 'aɪ æm ˈθɪŋkɪŋ əˈbaʊt ˈtʃeɪndʒɪŋ maɪ dʒɒb', 'Tôi đang nghĩ đến việc đổi việc.', 'intermediate', 'B1', 'Giữ /ŋ/ trong "thinking, changing".'),
    ('Could you give me some advice?', 'kʊd juː ɡɪv miː sʌm ədˈvaɪs', 'Bạn cho tôi vài lời khuyên được không?', 'intermediate', 'B1', '"advice" nhấn âm cuối /ədˈvaɪs/.'),
    ('I have already finished my homework.', 'aɪ hæv ɔːlˈrɛdi ˈfɪnɪʃt maɪ ˈhoʊmwɜːrk', 'Tôi đã làm xong bài tập rồi.', 'intermediate', 'B1', 'Âm /t/ cuối "finished" đọc nhẹ.'),
    ('We should leave before it gets dark.', 'wiː ʃʊd liːv bɪˈfɔːr ɪt ɡɛts dɑːrk', 'Chúng ta nên đi trước khi trời tối.', 'intermediate', 'B1', 'Nối "gets_dark".'),
    ('The film was more interesting than I expected.', 'ðə fɪlm wɒz mɔːr ˈɪntrəstɪŋ ðæn aɪ ɪkˈspɛktɪd', 'Bộ phim thú vị hơn tôi nghĩ.', 'intermediate', 'B1', '"interesting" đọc 3 âm tiết /ˈɪn-trə-stɪŋ/.'),
    ('I would rather stay at home tonight.', 'aɪ wʊd ˈræðər steɪ æt hoʊm təˈnaɪt', 'Tối nay tôi thà ở nhà còn hơn.', 'intermediate', 'B1', 'Âm /ð/ trong "rather".'),
    -- B2 (intermediate)
    ('Despite the rain, we enjoyed the trip.', 'dɪˈspaɪt ðə reɪn wiː ɪnˈdʒɔɪd ðə trɪp', 'Dù trời mưa, chúng tôi vẫn tận hưởng chuyến đi.', 'intermediate', 'B2', 'Nhấn "des-PITE".'),
    ('She speaks English fluently and confidently.', 'ʃiː spiːks ˈɪŋɡlɪʃ ˈfluːəntli ænd ˈkɒnfɪdəntli', 'Cô ấy nói tiếng Anh trôi chảy và tự tin.', 'intermediate', 'B2', 'Giữ nhịp đều ở các trạng từ dài.'),
    ('If I had known earlier, I would have helped.', 'ɪf aɪ hæd noʊn ˈɜːrliər aɪ wʊd hæv hɛlpt', 'Nếu tôi biết sớm hơn, tôi đã giúp.', 'intermediate', 'B2', 'Nối "would_have" thành /ˈwʊdəv/.'),
    ('The company is investing in renewable energy.', 'ðə ˈkʌmpəni ɪz ɪnˈvɛstɪŋ ɪn rɪˈnuːəbəl ˈɛnərdʒi', 'Công ty đang đầu tư vào năng lượng tái tạo.', 'intermediate', 'B2', '"renewable" nhấn âm thứ hai /rɪˈnuː/.'),
    ('I appreciate your patience and understanding.', 'aɪ əˈpriːʃieɪt jɔːr ˈpeɪʃəns ænd ˌʌndərˈstændɪŋ', 'Tôi trân trọng sự kiên nhẫn và thông cảm của bạn.', 'intermediate', 'B2', '"appreciate" nhấn /əˈpriː/.'),
    ('We need to address this issue immediately.', 'wiː niːd tuː əˈdrɛs ðɪs ˈɪʃuː ɪˈmiːdiətli', 'Chúng ta cần giải quyết vấn đề này ngay.', 'intermediate', 'B2', '"address" (động từ) nhấn cuối /əˈdrɛs/.'),
    -- C1 (advanced)
    ('The negotiations reached a satisfactory conclusion.', 'ðə nɪˌɡoʊʃiˈeɪʃənz riːtʃt ə ˌsætɪsˈfæktəri kənˈkluːʒən', 'Cuộc đàm phán đạt kết quả thỏa đáng.', 'advanced', 'C1', 'Giữ trọng âm rõ ở từ dài đa âm tiết.'),
    ('Her argument was both coherent and persuasive.', 'hɜːr ˈɑːrɡjumənt wɒz boʊθ koʊˈhɪərənt ænd pərˈsweɪsɪv', 'Lập luận của cô ấy vừa mạch lạc vừa thuyết phục.', 'advanced', 'C1', '"coherent" nhấn /koʊˈhɪə/.'),
    ('We must take into account the broader context.', 'wiː mʌst teɪk ˈɪntuː əˈkaʊnt ðə ˈbrɔːdər ˈkɒntɛkst', 'Chúng ta phải xét đến bối cảnh rộng hơn.', 'advanced', 'C1', 'Nối "take_into".'),
    ('The findings have significant implications for policy.', 'ðə ˈfaɪndɪŋz hæv sɪɡˈnɪfɪkənt ˌɪmplɪˈkeɪʃənz fɔːr ˈpɒlɪsi', 'Kết quả có hàm ý quan trọng đối với chính sách.', 'advanced', 'C1', '"significant" nhấn /sɪɡˈnɪf/.'),
    ('He approached the problem with remarkable ingenuity.', 'hiː əˈproʊtʃt ðə ˈprɒbləm wɪð rɪˈmɑːrkəbl ˌɪndʒɪˈnjuːəti', 'Anh ấy xử lý vấn đề với sự khéo léo đáng nể.', 'advanced', 'C1', '"ingenuity" 5 âm tiết, nhấn /ˌɪndʒɪˈnjuː/.'),
    ('Their collaboration yielded impressive results.', 'ðɛr kəˌlæbəˈreɪʃən ˈjiːldɪd ɪmˈprɛsɪv rɪˈzʌlts', 'Sự hợp tác của họ mang lại kết quả ấn tượng.', 'advanced', 'C1', '"collaboration" nhấn /ˌreɪ/.'),
    -- C2 (advanced)
    ('The intricacies of the legislation baffled even the experts.', 'ðiː ˈɪntrɪkəsiz ʌv ðə ˌlɛdʒɪsˈleɪʃən ˈbæfəld ˈiːvən ðiː ˈɛkspɜːrts', 'Sự phức tạp của bộ luật khiến cả chuyên gia bối rối.', 'advanced', 'C2', 'Đọc trôi chảy cụm danh từ dài, giữ trọng âm chính.'),
    ('Notwithstanding the obstacles, the venture flourished.', 'ˌnɒtwɪðˈstændɪŋ ðiː ˈɒbstəkəlz ðə ˈvɛntʃər ˈflʌrɪʃt', 'Bất chấp trở ngại, dự án vẫn phát đạt.', 'advanced', 'C2', '"notwithstanding" nhấn /ˈstænd/.'),
    ('Her eloquence captivated the entire audience.', 'hɜːr ˈɛləkwəns ˈkæptɪveɪtɪd ðiː ɪnˈtaɪər ˈɔːdiəns', 'Tài hùng biện của cô ấy mê hoặc cả khán phòng.', 'advanced', 'C2', '"eloquence" nhấn âm đầu /ˈɛl/.'),
    ('The phenomenon defies any straightforward explanation.', 'ðə fɪˈnɒmɪnən dɪˈfaɪz ˈɛni ˌstreɪtˈfɔːrwərd ˌɛkspləˈneɪʃən', 'Hiện tượng này không thể giải thích đơn giản.', 'advanced', 'C2', '"phenomenon" nhấn /fɪˈnɒm/.'),
    ('They scrutinised every clause meticulously.', 'ðeɪ ˈskruːtɪnaɪzd ˈɛvri klɔːz mɪˈtɪkjələsli', 'Họ xem xét tỉ mỉ từng điều khoản.', 'advanced', 'C2', '"meticulously" nhấn /mɪˈtɪk/.'),
    ('His unprecedented achievement reshaped the industry.', 'hɪz ʌnˈprɛsɪdɛntɪd əˈtʃiːvmənt riːˈʃeɪpt ðiː ˈɪndəstri', 'Thành tựu chưa từng có của anh đã định hình lại ngành.', 'advanced', 'C2', '"unprecedented" nhấn /ʌnˈprɛs/.')
) AS v(text, phonetic, meaning, difficulty, level, tips)
WHERE NOT EXISTS (
    SELECT 1 FROM pronunciation_exercises e WHERE e.text = v.text
);
