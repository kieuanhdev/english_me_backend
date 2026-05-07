CREATE TABLE IF NOT EXISTS pronunciation_attempts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    lesson_item_id UUID NULL,
    reference_text TEXT NOT NULL,
    overall_score INTEGER NOT NULL,
    accuracy_score INTEGER NOT NULL,
    fluency_score INTEGER NOT NULL,
    provider VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pronunciation_attempts_user_created
    ON pronunciation_attempts (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_pronunciation_attempts_lesson_item
    ON pronunciation_attempts (lesson_item_id);

CREATE TABLE IF NOT EXISTS pronunciation_word_feedback (
    id UUID PRIMARY KEY,
    attempt_id UUID NOT NULL REFERENCES pronunciation_attempts (id) ON DELETE CASCADE,
    word VARCHAR(128) NOT NULL,
    score INTEGER NOT NULL,
    start_ms INTEGER NOT NULL,
    end_ms INTEGER NOT NULL,
    issue_type VARCHAR(80) NOT NULL,
    suggestion TEXT NULL
);

CREATE INDEX IF NOT EXISTS idx_pronunciation_word_feedback_attempt
    ON pronunciation_word_feedback (attempt_id);
