-- Initial schema: tạo tất cả bảng gốc trước khi các migration V1+ ALTER

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    avatar_url TEXT,
    cefr_level VARCHAR(10),
    is_onboarded BOOLEAN NOT NULL DEFAULT false,
    account_locked BOOLEAN NOT NULL DEFAULT false,
    total_xp INTEGER NOT NULL DEFAULT 0,
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_active_date DATE,
    created_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS desk (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id),
    cefr_level VARCHAR(10) NOT NULL,
    title VARCHAR(255) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_desk_owner_cefr UNIQUE (owner_id, cefr_level)
);

CREATE TABLE IF NOT EXISTS flashcard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    desk_id UUID NOT NULL REFERENCES desk(id),
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
    vi_example TEXT
);

CREATE TABLE IF NOT EXISTS flashcard_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    flashcard_id UUID NOT NULL REFERENCES flashcard(id),
    easiness_factor DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    interval_days INTEGER NOT NULL DEFAULT 0,
    repetitions INTEGER NOT NULL DEFAULT 0,
    next_review_at TIMESTAMP,
    last_reviewed_at TIMESTAMP,
    CONSTRAINT uq_flashcard_progress_user_card UNIQUE (user_id, flashcard_id)
);

CREATE TABLE IF NOT EXISTS study_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    desk_id UUID NOT NULL REFERENCES desk(id),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    card_ids JSONB NOT NULL,
    total_cards INTEGER NOT NULL,
    mastered_cards INTEGER DEFAULT 0,
    again_cards INTEGER DEFAULT 0,
    hard_cards INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    new_words_learned INTEGER DEFAULT 0,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pronunciation_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    phonetic VARCHAR(512),
    meaning TEXT,
    audio_url VARCHAR(1024),
    difficulty VARCHAR(20) NOT NULL,
    level VARCHAR(4),
    tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pronunciation_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    exercise_id UUID,
    reference_text TEXT NOT NULL,
    overall_score INTEGER NOT NULL,
    accuracy_score INTEGER NOT NULL,
    fluency_score INTEGER NOT NULL,
    completeness_score INTEGER,
    transcription TEXT,
    provider VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pronunciation_word_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES pronunciation_attempts(id),
    word VARCHAR(128) NOT NULL,
    score INTEGER NOT NULL,
    start_ms INTEGER NOT NULL,
    end_ms INTEGER NOT NULL,
    issue_type VARCHAR(80) NOT NULL,
    suggestion TEXT
);

CREATE TABLE IF NOT EXISTS grammar_topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(120) NOT NULL UNIQUE,
    category VARCHAR(120) NOT NULL,
    level VARCHAR(16) NOT NULL,
    title VARCHAR(200) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS grammar_lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES grammar_topics(id),
    source_id VARCHAR(120) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    explanation_vi TEXT,
    when_to_use_vi TEXT,
    tips_vi TEXT,
    formulas JSONB,
    key_words JSONB,
    examples JSONB,
    common_mistakes JSONB,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS grammar_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES grammar_lessons(id),
    exercise_order INTEGER NOT NULL DEFAULT 0,
    exercise_type VARCHAR(50),
    content JSONB NOT NULL,
    created_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vocabulary_topic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    level VARCHAR(10),
    color_hex VARCHAR(7),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS vocabulary_word (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES vocabulary_topic(id),
    word VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),
    part_of_speech VARCHAR(50),
    definition_vi TEXT,
    definition_en TEXT,
    example_sentence TEXT,
    example_translation TEXT,
    level VARCHAR(10) NOT NULL,
    audio_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS exercise_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    hint TEXT,
    level VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS exercise_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    category VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    question_ids JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS exercise_answer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES exercise_session(id),
    question_id UUID NOT NULL REFERENCES exercise_question(id),
    selected_answer TEXT,
    is_correct BOOLEAN
);

CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cefr_level VARCHAR(10) NOT NULL,
    skill_category VARCHAR(255) NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer VARCHAR(1) NOT NULL,
    explanation TEXT,
    audio_url TEXT,
    passage TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS test_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    result_level VARCHAR(10),
    score INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS',
    question_ids JSONB
);

CREATE TABLE IF NOT EXISTS test_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_session_id UUID NOT NULL REFERENCES test_sessions(id),
    question_id UUID NOT NULL REFERENCES questions(id),
    selected_answer VARCHAR(10),
    is_correct BOOLEAN
);

CREATE TABLE IF NOT EXISTS user_test_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    topic VARCHAR(50) NOT NULL,
    level VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    question_ids JSONB NOT NULL,
    duration_seconds INTEGER NOT NULL DEFAULT 900,
    correct INTEGER,
    total INTEGER,
    xp_earned INTEGER,
    time_taken_seconds INTEGER,
    cefr_suggestion VARCHAR(10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    condition_type VARCHAR(50) NOT NULL,
    condition_value INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    badge_id UUID NOT NULL REFERENCES badge(id),
    earned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS xp_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    activity_date DATE NOT NULL,
    xp INTEGER NOT NULL DEFAULT 0
);
