-- Đồng bộ schema bảng `badge` với entity Badge.java.
-- V8 chỉ tạo (id, name, description, icon_url, condition_type), nhưng entity
-- map thêm `conditionValue` (Integer) và `isActive` (Boolean NOT NULL).
-- Hibernate `ddl-auto: validate` báo missing column, cần ALTER tại đây.

ALTER TABLE badge ADD COLUMN IF NOT EXISTS condition_value INTEGER;
ALTER TABLE badge ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
