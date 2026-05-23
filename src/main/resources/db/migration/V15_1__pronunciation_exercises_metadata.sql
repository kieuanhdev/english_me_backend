-- Phase 0 / Step 1.14 drift fix:
-- Entity PronunciationExercise.java declares `level`, `tips`, and
-- `createdAt` (@CreationTimestamp), but V7 only created (id, text,
-- phonetic, meaning, audio_url, difficulty). With ddl-auto=validate,
-- Hibernate refuses startup until these columns exist.

ALTER TABLE pronunciation_exercises ADD COLUMN IF NOT EXISTS level VARCHAR(4);
ALTER TABLE pronunciation_exercises ADD COLUMN IF NOT EXISTS tips TEXT;
ALTER TABLE pronunciation_exercises ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
