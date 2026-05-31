-- Theo dõi các thẻ đã review trong phiên (study_session).
-- Phục vụ đổi cơ chế XP flashcard: XP chỉ cộng khi phiên HOÀN THÀNH, và mỗi thẻ
-- chỉ góp "pending XP" đúng 1 lần (retry review cùng thẻ không làm phình XP).
ALTER TABLE study_session
    ADD COLUMN IF NOT EXISTS reviewed_card_ids JSONB;
