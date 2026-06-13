-- =============================================================================
-- V69 — Thêm theta + max_questions vào test_sessions (CAT / IRT 1PL).
-- =============================================================================
--   * theta = ability estimate hiện tại của session (IRT 1PL), khởi đầu 0.0 (~B1).
--   * max_questions = số câu tối đa của 1 phiên CAT (mặc định 15).
-- =============================================================================

ALTER TABLE test_sessions ADD COLUMN theta DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE test_sessions ADD COLUMN max_questions INTEGER DEFAULT 15;
