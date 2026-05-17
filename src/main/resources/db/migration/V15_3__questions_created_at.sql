-- Follow-up to V15_2: `created_at` was also missing on questions
-- (separate migration because V15_2 already applied with a different
-- checksum and Flyway forbids edits to applied versions).

ALTER TABLE questions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP;
