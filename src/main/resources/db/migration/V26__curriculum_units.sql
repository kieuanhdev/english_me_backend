-- =============================================================================
-- V26 — Curriculum: cấp Unit + giai đoạn sư phạm (theory/practice/quiz) + mastery
-- =============================================================================
-- Bám KE_HOACH_BE_BAI_TAP_VA_DU_LIEU.md (§B, §C) và NAMING CONTRACT §11.
-- Quyết định đã chốt với chủ dự án:
--   * id của learning_units dùng VARCHAR(64) — ĐỒNG BỘ với learning_lessons.id
--     (không dùng bigint như bản nháp §4 để tránh trộn 2 kiểu id khi JOIN/seed).
--   * GIỮ learning_paths/learning_path_activities để flow cũ (/hub, /paths) KHÔNG vỡ.
--     Luồng giáo trình mới chạy SONG SONG qua các bảng/endpoint /curriculum/*.
-- =============================================================================

-- ── 1) Bảng learning_units (cấp "chương" giữa Level và Lesson) ────────────────
CREATE TABLE learning_units (
    id                    VARCHAR(64)  PRIMARY KEY,
    level_code            VARCHAR(2)   NOT NULL REFERENCES cefr_levels(code),
    title                 VARCHAR(160) NOT NULL,
    subtitle              VARCHAR(255),
    theme                 VARCHAR(60),
    skill_coverage        JSONB        NOT NULL DEFAULT '[]'::jsonb,
    display_order         INT          NOT NULL,
    required_review_score SMALLINT     NOT NULL DEFAULT 75,
    review_lesson_id      VARCHAR(64),
    is_active             BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_unit_level_order UNIQUE (level_code, display_order)
);
CREATE INDEX idx_learning_units_level ON learning_units(level_code, display_order);

-- ── 2) learning_lessons: gắn vào Unit + cột sư phạm ──────────────────────────
-- unit_id đã tồn tại dạng VARCHAR(64) (V19) nhưng chỉ là string tự do, KHÔNG FK.
-- Drop+recreate dưới dạng FK thật (DB hiện chỉ có dữ liệu demo, chưa có user thật).
ALTER TABLE learning_lessons DROP COLUMN IF EXISTS unit_id;
ALTER TABLE learning_lessons
    ADD COLUMN unit_id                VARCHAR(64) REFERENCES learning_units(id) ON DELETE SET NULL,
    ADD COLUMN lesson_type            VARCHAR(20)  NOT NULL DEFAULT 'normal',  -- normal | unit_review
    ADD COLUMN lesson_order           INT          NOT NULL DEFAULT 1,
    ADD COLUMN required_score_to_pass SMALLINT     NOT NULL DEFAULT 70,
    ADD COLUMN theory_content         JSONB        NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE learning_lessons
    ADD CONSTRAINT chk_lesson_type CHECK (lesson_type IN ('normal','unit_review'));
CREATE INDEX idx_lessons_unit_order ON learning_lessons(unit_id, lesson_order);

-- FK của review_lesson_id (sau khi learning_lessons đã có unit_id) — thêm ở đây
-- để tránh phụ thuộc vòng lúc CREATE TABLE.
ALTER TABLE learning_units
    ADD CONSTRAINT fk_unit_review_lesson
        FOREIGN KEY (review_lesson_id) REFERENCES learning_lessons(id) ON DELETE SET NULL;

-- ── 3) learning_lesson_activities: phase / difficulty / counts_toward_mastery ─
ALTER TABLE learning_lesson_activities
    ADD COLUMN phase                 VARCHAR(12) NOT NULL DEFAULT 'quiz',  -- theory|practice|quiz
    ADD COLUMN difficulty            VARCHAR(8),                            -- easy|medium|hard
    ADD COLUMN counts_toward_mastery BOOLEAN     NOT NULL DEFAULT TRUE;
ALTER TABLE learning_lesson_activities
    ADD CONSTRAINT chk_activity_phase CHECK (phase IN ('theory','practice','quiz'));
-- Bẫy backfill (xem §H bất biến #1): activity cũ V19/V25 mặc định phase='quiz',
-- counts_toward_mastery=true ⇒ lesson cũ vẫn có câu tính điểm, không kẹt mastery 0/0.
CREATE INDEX idx_lla_lesson_phase ON learning_lesson_activities(lesson_id, phase, display_order);

-- ── 4) user_lesson_progress: cờ mastery 3 giai đoạn ──────────────────────────
ALTER TABLE user_lesson_progress
    ADD COLUMN theory_viewed      BOOLEAN     NOT NULL DEFAULT FALSE,
    ADD COLUMN practice_completed BOOLEAN     NOT NULL DEFAULT FALSE,
    ADD COLUMN mastered_at        TIMESTAMPTZ;

-- ── 5) user_levels: audit mốc lên cấp (dùng ở Pha 4, thêm sẵn cho liền mạch) ──
ALTER TABLE user_levels
    ADD COLUMN last_level_up_at TIMESTAMPTZ;

-- ── 6) user_unit_progress (tiến độ cấp Unit của user) ────────────────────────
CREATE TABLE user_unit_progress (
    user_id           UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    unit_id           VARCHAR(64) NOT NULL REFERENCES learning_units(id) ON DELETE CASCADE,
    status            VARCHAR(20) NOT NULL DEFAULT 'locked',  -- locked|available|in_progress|completed
    completed_lessons INT         NOT NULL DEFAULT 0,
    total_lessons     INT         NOT NULL DEFAULT 0,
    review_score      SMALLINT,
    started_at        TIMESTAMPTZ,
    completed_at      TIMESTAMPTZ,
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, unit_id)
);
CREATE INDEX idx_uup_user_status ON user_unit_progress(user_id, status);
