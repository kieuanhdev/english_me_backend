-- V41 — Thêm học phần bổ trợ "Luyện phát âm" vào màn Học tập.
-- Lý do: support_tracks (V19) chỉ có grammar/vocabulary/flashcard/test.
--        Bổ sung pronunciation để học viên luyện nói/phát âm trực tiếp từ hub.
-- Route '/learn/pronunciation' khớp AppRoutes.pronunciation (SpeakingChoiceScreen) ở FE.
-- An toàn: chèn idempotent (ON CONFLICT DO NOTHING theo PK type); dời 'test' xuống cuối.

-- Đẩy "Kiểm tra" xuống order 5 để nhường chỗ phát âm (order 4).
UPDATE support_tracks SET display_order = 5 WHERE type = 'test';

INSERT INTO support_tracks (type, title, description, route, display_order, enabled) VALUES
    ('pronunciation', 'Luyện phát âm', 'Luyện nói và chấm điểm phát âm theo từng âm, từ và câu.', '/learn/pronunciation', 4, TRUE)
ON CONFLICT (type) DO NOTHING;
