-- =============================================================================
-- V18 — Chuẩn hoá `questions.skill_category` về chữ thường.
-- =============================================================================
-- Lý do:
--   * LEARNING_PATH_BACKEND_SPEC mục 2.6 + 3 quy định skill_category là
--     'grammar' | 'vocabulary' | 'reading' | 'listening' (lowercase).
--   * Seed V16 dùng 'Grammar' / 'Vocabulary' (capitalize) khiến PlacementTestService
--     query lowercase trả về rỗng. Migration này chuẩn hoá toàn bộ về lowercase.
-- =============================================================================

UPDATE questions
SET skill_category = LOWER(skill_category)
WHERE skill_category <> LOWER(skill_category);
