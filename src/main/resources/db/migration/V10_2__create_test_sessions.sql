-- test_sessions và test_answers được tạo bởi Hibernate ddl-auto=update trước khi dùng Flyway
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
