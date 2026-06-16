-- V75 — Bỏ tính năng thông báo in-app (đề cương không yêu cầu).
-- Xóa bảng notification (tạo ở V43, seed ở V44). Index đi kèm tự drop theo bảng.
DROP TABLE IF EXISTS notification;
