CREATE TABLE IF NOT EXISTS grammar_topics (
    id UUID PRIMARY KEY,
    slug VARCHAR(120) NOT NULL UNIQUE,
    category VARCHAR(120) NOT NULL,
    level VARCHAR(16) NOT NULL,
    title VARCHAR(200) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_grammar_topics_category_level
    ON grammar_topics (category, level);

CREATE TABLE IF NOT EXISTS grammar_lessons (
    id UUID PRIMARY KEY,
    topic_id UUID NOT NULL REFERENCES grammar_topics (id) ON DELETE CASCADE,
    source_id VARCHAR(120) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    explanation_vi TEXT NULL,
    when_to_use_vi TEXT NULL,
    tips_vi TEXT NULL,
    formulas JSONB NULL,
    key_words JSONB NULL,
    examples JSONB NULL,
    common_mistakes JSONB NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_grammar_lessons_topic_sort
    ON grammar_lessons (topic_id, sort_order, created_at);

CREATE TABLE IF NOT EXISTS grammar_exercises (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL REFERENCES grammar_lessons (id) ON DELETE CASCADE,
    exercise_order INTEGER NOT NULL,
    exercise_type VARCHAR(50) NULL,
    content JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_grammar_exercises_lesson_order
    ON grammar_exercises (lesson_id, exercise_order);
