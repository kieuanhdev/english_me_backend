-- SCOPE_REDUCTION_PLAN step 1.14 — drop tables backing modules retired
-- in steps 1.2 → 1.10 of Phase 1. Entity classes already deleted; with
-- ddl-auto=validate Hibernate will fail startup if any of these tables
-- still exist without a matching entity, so this migration is the
-- companion runtime fix.

-- Step 1.10 (Audit + Admin DB Management)
DROP TABLE IF EXISTS admin_audit_log;
DROP TABLE IF EXISTS admin_account;

-- Step 1.9 (System Configuration)
DROP TABLE IF EXISTS app_config;

-- Steps 1.2 + 1.3 (FCM Push + Announcement)
DROP TABLE IF EXISTS app_announcement;
DROP TABLE IF EXISTS admin_notification;
DROP TABLE IF EXISTS user_device_token;

-- Step 1.4 (Home Dashboard Content)
DROP TABLE IF EXISTS home_banner;
DROP TABLE IF EXISTS home_recommendation;
DROP TABLE IF EXISTS home_word_of_day;
