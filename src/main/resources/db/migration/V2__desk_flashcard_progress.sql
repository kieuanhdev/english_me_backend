-- Bộ thẻ (desk/deck) gom theo mức CEFR
CREATE TABLE desk (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cefr_level VARCHAR(10) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO desk (id, cefr_level, title, sort_order)
VALUES
    (gen_random_uuid(), 'A1', 'Desk A1', 1),
    (gen_random_uuid(), 'A2', 'Desk A2', 2),
    (gen_random_uuid(), 'B1', 'Desk B1', 3),
    (gen_random_uuid(), 'B2', 'Desk B2', 4),
    (gen_random_uuid(), 'C1', 'Desk C1', 5),
    (gen_random_uuid(), 'C2', 'Desk C2', 6);

CREATE TABLE flashcard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    desk_id UUID NOT NULL REFERENCES desk (id) ON DELETE CASCADE,
    word TEXT NOT NULL,
    cefr VARCHAR(10) NOT NULL,
    pos_json JSONB,
    all_levels_json JSONB,
    ipa TEXT,
    audio_url TEXT,
    definition TEXT,
    example TEXT,
    topic VARCHAR(512),
    vietnamese TEXT,
    vi_definition TEXT,
    vi_example TEXT,
    CONSTRAINT uq_flashcard_desk_word UNIQUE (desk_id, word)
);

CREATE INDEX idx_flashcard_desk ON flashcard (desk_id);
CREATE INDEX idx_flashcard_cefr ON flashcard (cefr);

-- SM-2: trạng thái ôn tập theo user / thẻ
CREATE TABLE flashcard_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES flashcard (id) ON DELETE CASCADE,
    easiness_factor DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    interval_days INTEGER NOT NULL DEFAULT 0,
    repetitions INTEGER NOT NULL DEFAULT 0,
    next_review_at TIMESTAMP,
    last_reviewed_at TIMESTAMP,
    CONSTRAINT uq_flashcard_progress_user_card UNIQUE (user_id, flashcard_id)
);

CREATE INDEX idx_flashcard_progress_user_next ON flashcard_progress (user_id, next_review_at);
