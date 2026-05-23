-- Drift fix for placement-test `questions` table. The table was
-- originally created by Hibernate ddl-auto=update (no explicit Flyway
-- migration), so when Question.java grew new fields (audio_url,
-- passage, updated_at) the in-place ALTERs were silently applied —
-- until step 0.2 switched to ddl-auto=validate. This migration brings
-- the schema in sync with the current entity.

ALTER TABLE questions ADD COLUMN IF NOT EXISTS audio_url TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS passage TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP;
