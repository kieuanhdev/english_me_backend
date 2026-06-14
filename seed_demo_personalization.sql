-- ============================================================================
-- SEED DEMO — Tài khoản đã có CÁ NHÂN HÓA (cho ảnh chụp luận văn / demo Home)
-- ----------------------------------------------------------------------------
-- Tạo 1 user có dữ liệu LỆCH đủ để Home hiện toàn bộ tín hiệu cá nhân hóa:
--   * XP per-skill lệch  -> "Kỹ năng của bạn" + "Cần luyện thêm: phát âm"
--   * flashcard đến hạn  -> banner SM-2 "Bạn có N thẻ cần ôn hôm nay"
--   * bài học dở (fail)  -> banner "Làm lại" trên Home
--   * recommendations    -> backend tự sinh reason "Bạn dành ít thời gian cho phát âm…"
--
-- CHẠY (máy dev có Postgres):
--   psql -U admin -d englishme_db -f seed_demo_personalization.sql
-- (pass admin / 2004 theo CLAUDE.md)
--
-- AN TOÀN: idempotent — chạy lại nhiều lần không nhân đôi (ON CONFLICT DO UPDATE).
-- XÓA data demo (giữ user, chỉ reset):  xem cuối file.
-- XÓA hẳn account:  DELETE FROM users WHERE firebase_uid = 'r9C1GVs1G6dF1ShF8JsO8yAFNi53';
--   (mọi bảng con FK ON DELETE CASCADE sẽ tự dọn theo)
--
-- LOGIN: firebase_uid = 'r9C1GVs1G6dF1ShF8JsO8yAFNi53' (account Firebase thật kkcj@gmail.com).
-- Đăng nhập app bằng tài khoản này -> Home hiện toàn bộ cá nhân hóa từ data seed dưới.
-- Nếu account đã từng login (đã có row trong users) -> ON CONFLICT chỉ UPDATE, không trùng.
-- ============================================================================

DO $$
DECLARE
    v_user_id   UUID;
    v_desk_id   UUID;
    v_today     DATE := CURRENT_DATE;
    v_now       TIMESTAMP := CURRENT_TIMESTAMP;
    r_card      RECORD;
    v_count     INT := 0;
BEGIN
    -- ---------------------------------------------------------------------
    -- 1) USER demo (level A1, đã onboard, có streak + tổng XP)
    -- ---------------------------------------------------------------------
    INSERT INTO users (firebase_uid, email, full_name, cefr_level, is_onboarded,
                       total_xp, current_streak, longest_streak,
                       last_active_date, last_xp_date, created_at)
    VALUES ('r9C1GVs1G6dF1ShF8JsO8yAFNi53', 'kkcj@gmail.com',
            'Học Viên Demo', 'A1', TRUE,
            420, 5, 12, v_today, v_today, v_now)
    ON CONFLICT (firebase_uid) DO UPDATE
        SET full_name        = EXCLUDED.full_name,
            cefr_level       = EXCLUDED.cefr_level,
            is_onboarded     = TRUE,
            total_xp         = EXCLUDED.total_xp,
            current_streak   = EXCLUDED.current_streak,
            longest_streak   = EXCLUDED.longest_streak,
            last_active_date = EXCLUDED.last_active_date,
            last_xp_date     = EXCLUDED.last_xp_date
    RETURNING id INTO v_user_id;

    -- ---------------------------------------------------------------------
    -- 2) XP per-skill LỆCH — phát âm thấp nhất => "kỹ năng yếu nhất"
    --    (HomeDashboardService.buildRecommendations dùng share < 25% => đẩy lên đầu + reason)
    --    vocabulary 250 | grammar 140 | pronunciation 30  (tổng 420; pron = 7% => yếu rõ)
    -- ---------------------------------------------------------------------
    INSERT INTO user_skill_xp (user_id, skill, xp) VALUES
        (v_user_id, 'vocabulary',    250),
        (v_user_id, 'grammar',       140),
        (v_user_id, 'pronunciation',  30)
    ON CONFLICT (user_id, skill) DO UPDATE SET xp = EXCLUDED.xp;

    -- ---------------------------------------------------------------------
    -- 3) XP hôm nay + lịch sử 6 ngày (để "XP hôm nay / tuần này" có số)
    -- ---------------------------------------------------------------------
    INSERT INTO xp_history (user_id, activity_date, xp) VALUES
        (v_user_id, v_today,            45),
        (v_user_id, v_today - 1,        60),
        (v_user_id, v_today - 2,        30),
        (v_user_id, v_today - 3,        50),
        (v_user_id, v_today - 4,        25),
        (v_user_id, v_today - 5,        40)
    ON CONFLICT (user_id, activity_date) DO UPDATE SET xp = EXCLUDED.xp;

    -- ---------------------------------------------------------------------
    -- 4) Mục tiêu XP hôm nay (target 50, đã được 45 => progress bar ~90%)
    -- ---------------------------------------------------------------------
    INSERT INTO user_daily_goals (user_id, goal_date, target_xp, earned_xp,
                                  daily_bonus_granted, completed_activities)
    VALUES (v_user_id, v_today, 50, 45, FALSE, 3)
    ON CONFLICT (user_id, goal_date) DO UPDATE
        SET target_xp = EXCLUDED.target_xp,
            earned_xp = EXCLUDED.earned_xp;

    -- ---------------------------------------------------------------------
    -- 5) DESK người dùng (A1) — chứa thẻ để gắn progress đến hạn
    -- ---------------------------------------------------------------------
    SELECT id INTO v_desk_id FROM desk
        WHERE owner_id = v_user_id AND cefr_level = 'A1'
        LIMIT 1;
    IF v_desk_id IS NULL THEN
        INSERT INTO desk (owner_id, cefr_level, title)
        VALUES (v_user_id, 'A1', 'Bộ thẻ A1 của tôi')
        RETURNING id INTO v_desk_id;

        -- Copy 8 thẻ A1 từ desk HỆ THỐNG (owner_id IS NULL) sang desk user.
        -- Nếu chưa có desk hệ thống A1 nào, bỏ qua (không vỡ seed).
        INSERT INTO flashcard (desk_id, word, cefr, pos_json, ipa, definition,
                               example, vietnamese, vi_definition, vi_example)
        SELECT v_desk_id, f.word, f.cefr, f.pos_json, f.ipa, f.definition,
               f.example, f.vietnamese, f.vi_definition, f.vi_example
        FROM flashcard f
        JOIN desk d ON d.id = f.desk_id
        WHERE d.owner_id IS NULL AND d.cefr_level = 'A1'
        ORDER BY f.word
        LIMIT 8
        ON CONFLICT (desk_id, word) DO NOTHING;
    END IF;

    -- ---------------------------------------------------------------------
    -- 6) flashcard_progress — đặt next_review_at QUÁ KHỨ => tất cả "đến hạn ôn".
    --    easiness lệch để có thẻ "yếu" (Word-of-day cá nhân hóa ưu tiên thẻ này).
    --    => Home: "Bạn có N thẻ cần ôn hôm nay".
    -- ---------------------------------------------------------------------
    FOR r_card IN
        SELECT id FROM flashcard WHERE desk_id = v_desk_id ORDER BY word
    LOOP
        v_count := v_count + 1;
        INSERT INTO flashcard_progress (user_id, flashcard_id, easiness_factor,
                                        interval_days, repetitions,
                                        next_review_at, last_reviewed_at)
        VALUES (
            v_user_id, r_card.id,
            -- thẻ đầu để easiness thấp = "yếu nhất" (lên Word-of-day)
            CASE WHEN v_count = 1 THEN 1.6 ELSE 2.2 END,
            CASE WHEN v_count = 1 THEN 0 ELSE 2 END,
            CASE WHEN v_count = 1 THEN 1 ELSE 2 END,
            v_now - INTERVAL '1 day',     -- đã quá hạn => due
            v_now - INTERVAL '3 day'      -- đã ôn trước đó (gap thật)
        )
        ON CONFLICT (user_id, flashcard_id) DO UPDATE
            SET next_review_at  = EXCLUDED.next_review_at,
                last_reviewed_at = EXCLUDED.last_reviewed_at,
                easiness_factor  = EXCLUDED.easiness_factor;
    END LOOP;

    -- ---------------------------------------------------------------------
    -- 7) Bài học DỞ (status='in_progress', last_score < required) => Home "Làm lại".
    --    Gắn vào lesson A1 seed sẵn 'a1-unit-greetings-l1' nếu tồn tại.
    -- ---------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM learning_lessons WHERE id = 'a1-unit-greetings-l1') THEN
        INSERT INTO user_lesson_progress (user_id, lesson_id, status,
                                          last_score, best_score, attempts, xp_earned)
        VALUES (v_user_id, 'a1-unit-greetings-l1', 'in_progress', 55, 55, 1, 0)
        ON CONFLICT (user_id, lesson_id) DO UPDATE
            SET status     = 'in_progress',
                last_score = 55,
                attempts   = user_lesson_progress.attempts;
    END IF;

    RAISE NOTICE 'Seed demo done. user_id=% , flashcards_due=%', v_user_id, v_count;
END $$;

-- ============================================================================
-- RESET data demo (KHÔNG xóa account) — bỏ comment để chạy khi muốn làm lại sạch:
-- ============================================================================
-- DO $$
-- DECLARE v_uid UUID;
-- BEGIN
--   SELECT id INTO v_uid FROM users WHERE firebase_uid = 'r9C1GVs1G6dF1ShF8JsO8yAFNi53';
--   IF v_uid IS NOT NULL THEN
--     DELETE FROM flashcard_progress   WHERE user_id = v_uid;
--     DELETE FROM flashcard            WHERE desk_id IN (SELECT id FROM desk WHERE owner_id = v_uid);
--     DELETE FROM desk                 WHERE owner_id = v_uid;
--     DELETE FROM user_skill_xp        WHERE user_id = v_uid;
--     DELETE FROM xp_history           WHERE user_id = v_uid;
--     DELETE FROM user_daily_goals     WHERE user_id = v_uid;
--     DELETE FROM user_lesson_progress WHERE user_id = v_uid;
--   END IF;
-- END $$;
