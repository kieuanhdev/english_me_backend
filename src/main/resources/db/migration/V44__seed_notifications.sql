-- =============================================================================
-- V44 — Demo seed cho chuông thông báo
-- =============================================================================
-- Nhắm vào demo user V16 (B1 = ...0003, B2 = ...0004) để DB fresh sau migrate
-- đã có chuông populate sẵn (mix read/unread → badge > 0) khi thuyết trình.
-- Thông báo sinh thật (REVIEW_DUE/STREAK_RISK) được tạo LAZY lúc GET; các seed
-- này chỉ đảm bảo dữ liệu ban đầu.
-- dedup_key seed dùng hậu tố ':seed' để KHÔNG đụng key date-based mà generator
-- sinh ra (vd 'review_due:2026-06-03'), nên generator vẫn tạo row thật độc lập.
-- ON CONFLICT DO NOTHING để an toàn (theo style V16).
-- =============================================================================
INSERT INTO notification (user_id, type, title, body, action_route, dedup_key, is_read, created_at)
VALUES
    ('11111111-1111-1111-1111-000000000003', 'SYSTEM', 'Chào mừng đến EnglishMe',
     'Khám phá lộ trình học của bạn ngay hôm nay.', '/learn', 'system:welcome', FALSE,
     CURRENT_TIMESTAMP - INTERVAL '2 hours'),
    ('11111111-1111-1111-1111-000000000003', 'STREAK_RISK', 'Giữ chuỗi học tập',
     'Chuỗi 7 ngày của bạn sắp mất! Học một chút để giữ streak.', '/vocab', 'streak_risk:seed', FALSE,
     CURRENT_TIMESTAMP - INTERVAL '1 hours'),
    ('11111111-1111-1111-1111-000000000003', 'REVIEW_DUE', 'Ôn tập từ vựng',
     'Bạn có thẻ cần ôn tập hôm nay.', '/vocab', 'review_due:seed', TRUE,
     CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('11111111-1111-1111-1111-000000000004', 'SYSTEM', 'Chào mừng đến EnglishMe',
     'Khám phá lộ trình học của bạn ngay hôm nay.', '/learn', 'system:welcome', FALSE,
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, dedup_key) DO NOTHING;
