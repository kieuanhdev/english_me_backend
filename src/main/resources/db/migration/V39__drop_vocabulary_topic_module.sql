-- Gỡ tính năng "bộ từ vựng" (vocabulary topic/word).
-- Mobile đã bỏ màn Khám phá theo chủ đề, chỉ còn Flashcard/Desk.
-- "Từ vựng của ngày" nay lấy từ Oxford 5000 JSON (WordOfDayService), không cần bảng này.
-- vocabulary_word có FK NOT NULL tới vocabulary_topic → drop word trước, topic sau.

DROP TABLE IF EXISTS vocabulary_word CASCADE;
DROP TABLE IF EXISTS vocabulary_topic CASCADE;
