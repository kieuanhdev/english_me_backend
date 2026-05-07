-- Khoa tai khoan (admin), tach biet voi is_onboarded (placement test)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS account_locked BOOLEAN NOT NULL DEFAULT false;
