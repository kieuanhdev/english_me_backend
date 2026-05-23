-- Entity Badge.java có `@CreationTimestamp private LocalDateTime createdAt`
-- nhưng V8 không tạo cột `created_at`. Hibernate `validate` báo missing.

ALTER TABLE badge ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
