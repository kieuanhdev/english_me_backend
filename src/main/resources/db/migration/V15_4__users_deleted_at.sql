-- Drift fix: User.java has `deleted_at` for soft-delete, but the
-- `users` table predates it (originally created by Hibernate ddl-auto
-- update). Required by AdminUserService.softDelete() and
-- UserRepository queries that filter on `deletedAt IS NULL`.

ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
