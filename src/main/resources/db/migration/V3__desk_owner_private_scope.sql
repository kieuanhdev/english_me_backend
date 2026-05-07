-- Make desk private per user account
ALTER TABLE desk ADD COLUMN owner_id UUID;

ALTER TABLE desk
    ADD CONSTRAINT fk_desk_owner
    FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE;

-- Old global uniqueness is no longer valid for private desks
ALTER TABLE desk DROP CONSTRAINT IF EXISTS desk_cefr_level_key;

-- Each user can have one desk per CEFR level
CREATE UNIQUE INDEX IF NOT EXISTS uq_desk_owner_cefr
    ON desk (owner_id, cefr_level);

-- Keep legacy admin desks (owner_id IS NULL) unique by CEFR too
CREATE UNIQUE INDEX IF NOT EXISTS uq_desk_global_cefr
    ON desk (cefr_level)
    WHERE owner_id IS NULL;
