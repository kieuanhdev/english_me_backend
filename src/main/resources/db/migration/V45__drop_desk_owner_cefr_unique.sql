-- V45: Bỏ ràng buộc "mỗi user 1 desk / CEFR".
-- User tự do tạo nhiều bộ thẻ cá nhân, không cần phân theo trình độ.
-- Desk hệ thống (owner_id IS NULL) vẫn giữ uniqueness riêng (uq_desk_global_cefr_title từ V33).
DROP INDEX IF EXISTS uq_desk_owner_cefr;
