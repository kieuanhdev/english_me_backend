CREATE TABLE word_of_day_cache (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cache_date  DATE        NOT NULL,
    cefr_level  VARCHAR(10) NOT NULL,
    word        VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),
    part_of_speech VARCHAR(50),
    definition_vi  TEXT,
    definition_en  TEXT,
    example_sentence TEXT,
    example_translation TEXT,
    audio_url   TEXT,
    CONSTRAINT uq_word_of_day_date_level UNIQUE (cache_date, cefr_level)
);

CREATE INDEX idx_word_of_day_date_level ON word_of_day_cache (cache_date, cefr_level);
