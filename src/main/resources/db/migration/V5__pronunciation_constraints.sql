ALTER TABLE pronunciation_attempts
    ADD CONSTRAINT chk_pron_attempt_overall_score
        CHECK (overall_score BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_pron_attempt_accuracy_score
        CHECK (accuracy_score BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_pron_attempt_fluency_score
        CHECK (fluency_score BETWEEN 0 AND 100);

ALTER TABLE pronunciation_word_feedback
    ADD CONSTRAINT chk_pron_word_score
        CHECK (score BETWEEN 0 AND 100),
    ADD CONSTRAINT chk_pron_word_timing
        CHECK (start_ms >= 0 AND end_ms >= start_ms);
