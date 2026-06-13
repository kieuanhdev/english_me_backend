-- =============================================================================
-- V67 — Thêm cột difficulty (IRT 1PL / Rasch b-parameter) vào questions.
-- =============================================================================
-- Nâng cấp Placement Test sang CAT (Computerized Adaptive Testing).
-- Xem docs/placement-test-cat-upgrade.md.
--   * difficulty (b_i) = tham số độ khó IRT, map từ cefr_level làm proxy.
--   * Bootstrap: A1=-2.0, A2=-1.0, B1=0.0, B2=1.0, C1=2.0 (C2 chưa dùng → 0.0).
--   * Sau này có data calibration thực nghiệm thì update lại cột này.
-- =============================================================================

ALTER TABLE questions ADD COLUMN difficulty DOUBLE PRECISION;

UPDATE questions SET difficulty = CASE cefr_level
    WHEN 'A1' THEN -2.0
    WHEN 'A2' THEN -1.0
    WHEN 'B1' THEN  0.0
    WHEN 'B2' THEN  1.0
    WHEN 'C1' THEN  2.0
    ELSE 0.0
END;

ALTER TABLE questions ALTER COLUMN difficulty SET NOT NULL;
