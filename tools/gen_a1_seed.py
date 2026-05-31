#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sinh migration Flyway V33__seed_a1_flashcards.sql từ vocabulary_oxford5000.json.

- Lọc cefr == "A1".
- Bỏ topic "Grammar & Function Words" (mạo từ / giới từ / đại từ — không hợp flashcard từ vựng).
- Gom các topic nguồn thành 13 BỘ (mỗi bộ = 1 Desk A1 hệ thống, owner_id = NULL).
- Cắt mỗi bộ <= MAX_PER_DECK từ, ưu tiên từ có đủ vietnamese + example + ipa.
- Sinh UUID cố định (uuid5) cho desk & flashcard => idempotent, dễ rollback.

Chạy 1 lần (không thuộc runtime app):
    python tools/gen_a1_seed.py
Output: src/main/resources/db/migration/V33__seed_a1_flashcards.sql
"""

import json
import os
import unicodedata
import uuid

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)  # backend/EnglishMe
SRC = os.path.join(ROOT, "src", "main", "resources", "vocabulary_oxford5000.json")
OUT = os.path.join(ROOT, "src", "main", "resources", "db", "migration",
                   "V33__seed_a1_flashcards.sql")

# Namespace cố định cho dự án -> uuid5 deterministic.
NS = uuid.UUID("a1a1a1a1-0000-4000-8000-000000000001")

MAX_PER_DECK = 50

# Topic ngữ pháp bị loại hoàn toàn.
EXCLUDE_TOPICS = {"Grammar & Function Words"}

# Định nghĩa 13 bộ: (title hiển thị, [danh sách topic nguồn gộp vào], sort_order).
# Topic nào không liệt kê ở đây sẽ rơi vào bộ "khác" cuối cùng nếu còn từ.
DECKS = [
    ("A1 · Chào hỏi & Giao tiếp",      ["Greetings & Communication", "Society & Culture"], 1),
    ("A1 · Gia đình & Quan hệ",        ["Family & Relationships"],                          2),
    ("A1 · Số, Đo lường & Thời gian",  ["Numbers & Measurement"],                           3),
    ("A1 · Sinh hoạt hằng ngày",       ["Time & Daily Routine"],                            4),
    ("A1 · Đồ ăn & Thức uống",         ["Food & Drink"],                                    5),
    ("A1 · Nhà cửa & Đồ đạc",          ["Home & Living"],                                   6),
    ("A1 · Cơ thể & Sức khỏe",         ["Health & Body"],                                   7),
    ("A1 · Ngoại hình & Mô tả",        ["Appearance & Description"],                         8),
    ("A1 · Cảm xúc & Tính cách",       ["Emotions & Feelings"],                             9),
    ("A1 · Học tập & Trường lớp",      ["Education & Learning"],                            10),
    ("A1 · Di chuyển & Du lịch",       ["Travel & Transport", "Shopping & Money"],          11),
    ("A1 · Thiên nhiên & Thời tiết",   ["Nature & Environment", "Weather & Climate"],       12),
    ("A1 · Giải trí & Sở thích",       ["Arts & Entertainment", "Sports & Hobbies"],        13),
    ("A1 · Công việc & Công nghệ",     ["Technology & Media", "Business & Economy",
                                        "Work & Career", "Science & Research",
                                        "Law & Politics"],                                  14),
]


def norm_text(s):
    """Chuẩn hoá: thay non-breaking space, bỏ khoảng trắng thừa."""
    if s is None:
        return ""
    s = str(s).replace("\xa0", " ")
    return " ".join(s.split()).strip()


def sql_str(s):
    """Escape literal cho Postgres (escape dấu nháy đơn). Trả về NULL nếu rỗng."""
    s = norm_text(s)
    if s == "":
        return "NULL"
    return "'" + s.replace("'", "''") + "'"


def sql_json(obj):
    """Tuần tự hoá list/dict thành literal jsonb. NULL nếu rỗng."""
    if not obj:
        return "NULL"
    raw = json.dumps(obj, ensure_ascii=False)
    return "'" + raw.replace("'", "''") + "'::jsonb"


def desk_uuid(title):
    return str(uuid.uuid5(NS, "desk:" + title))


def card_uuid(desk_id, word):
    return str(uuid.uuid5(NS, "card:" + desk_id + ":" + word.lower()))


def completeness_score(w):
    """Ưu tiên từ đủ thông tin khi phải cắt bớt."""
    score = 0
    if norm_text(w.get("vietnamese")):
        score += 4
    if norm_text(w.get("example")):
        score += 2
    if norm_text(w.get("ipa")):
        score += 2
    if norm_text(w.get("definition")):
        score += 1
    if norm_text(w.get("vi_example")):
        score += 1
    return score


def main():
    with open(SRC, encoding="utf-8") as f:
        data = json.load(f)

    a1 = [w for w in data if str(w.get("cefr", "")).upper() == "A1"]

    # Gom theo topic gốc.
    by_topic = {}
    for w in a1:
        topic = norm_text(w.get("topic")) or "UNTAGGED"
        by_topic.setdefault(topic, []).append(w)

    assigned_topics = set()
    deck_rows = []  # (title, sort, [words])
    total = 0
    seen_words_global = set()  # tránh trùng word giữa các bộ (gây nhầm khi học)

    for title, src_topics, sort in DECKS:
        words = []
        for t in src_topics:
            assigned_topics.add(t)
            words.extend(by_topic.get(t, []))
        # Lọc bỏ word rỗng + khử trùng theo word (giữ bản đủ thông tin hơn).
        dedup = {}
        for w in words:
            key = norm_text(w.get("word")).lower()
            if not key:
                continue
            if key in seen_words_global:
                continue
            if key not in dedup or completeness_score(w) > completeness_score(dedup[key]):
                dedup[key] = w
        picked = sorted(dedup.values(), key=completeness_score, reverse=True)[:MAX_PER_DECK]
        for w in picked:
            seen_words_global.add(norm_text(w.get("word")).lower())
        deck_rows.append((title, sort, picked))
        total += len(picked)

    # Cảnh báo topic A1 chưa được gán vào bộ nào (trừ loại trừ).
    leftover = {t: len(ws) for t, ws in by_topic.items()
                if t not in assigned_topics and t not in EXCLUDE_TOPICS}

    # ── Sinh SQL ──────────────────────────────────────────────────────────────
    lines = []
    lines.append("-- ============================================================")
    lines.append("-- V33: Seed 13 bộ thẻ A1 (owner_id NULL = desk hệ thống dùng chung).")
    lines.append("-- Sinh tự động từ vocabulary_oxford5000.json (cefr=A1) bằng tools/gen_a1_seed.py.")
    lines.append("-- Bỏ topic 'Grammar & Function Words'. Mỗi bộ <= %d từ. Tổng: %d từ." % (MAX_PER_DECK, total))
    lines.append("-- UUID cố định (uuid5) => chạy lại an toàn (ON CONFLICT DO NOTHING).")
    lines.append("-- ============================================================")
    lines.append("")
    lines.append("-- 1) Nới ràng buộc: cho phép NHIỀU desk hệ thống cùng CEFR, miễn khác title.")
    lines.append("DROP INDEX IF EXISTS uq_desk_global_cefr;")
    lines.append("CREATE UNIQUE INDEX IF NOT EXISTS uq_desk_global_cefr_title")
    lines.append("    ON desk (cefr_level, title) WHERE owner_id IS NULL;")
    lines.append("")
    lines.append("-- 2) Dọn 6 desk hệ thống RỖNG cũ (V2): 'Desk A1'..'Desk C2', owner NULL, không có flashcard.")
    lines.append("DELETE FROM desk")
    lines.append(" WHERE owner_id IS NULL")
    lines.append("   AND title IN ('Desk A1','Desk A2','Desk B1','Desk B2','Desk C1','Desk C2')")
    lines.append("   AND NOT EXISTS (SELECT 1 FROM flashcard f WHERE f.desk_id = desk.id);")
    lines.append("")

    for title, sort, picked in deck_rows:
        did = desk_uuid(title)
        lines.append("-- ── %s (%d từ) ─────────────────────────────" % (title, len(picked)))
        lines.append("INSERT INTO desk (id, owner_id, cefr_level, title, sort_order)")
        lines.append("VALUES ('%s', NULL, 'A1', %s, %d)" % (did, sql_str(title), sort))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")
        if not picked:
            continue
        lines.append("INSERT INTO flashcard")
        lines.append("    (id, desk_id, word, cefr, pos_json, all_levels_json, ipa, audio_url,")
        lines.append("     definition, example, topic, vietnamese, vi_definition, vi_example)")
        lines.append("VALUES")
        rows = []
        for w in picked:
            word = norm_text(w.get("word"))
            cid = card_uuid(did, word)
            row = "    ('%s', '%s', %s, 'A1', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % (
                cid, did,
                sql_str(word),
                sql_json(w.get("pos")),
                sql_json(w.get("all_levels")),
                sql_str(w.get("ipa")),
                sql_str(w.get("audio_url")),
                sql_str(w.get("definition")),
                sql_str(w.get("example")),
                sql_str(w.get("topic")),
                sql_str(w.get("vietnamese")),
                sql_str(w.get("vi_definition")),
                sql_str(w.get("vi_example")),
            )
            rows.append(row)
        lines.append(",\n".join(rows))
        lines.append("ON CONFLICT (desk_id, word) DO NOTHING;")
        lines.append("")

    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))

    # ── Báo cáo ra stdout (ASCII-safe cho console Windows) ─────────────────────
    print("OK -> %s" % OUT)
    print("Tong tu seed: %d" % total)
    print("So bo: %d" % len(deck_rows))
    for title, sort, picked in deck_rows:
        print("  [%2d] %-32s %3d tu" % (sort, title.encode("ascii", "replace").decode(), len(picked)))
    if leftover:
        print("Topic A1 CHUA gan vao bo nao (con du):")
        for t, n in sorted(leftover.items(), key=lambda x: -x[1]):
            print("  %3d  %s" % (n, t.encode("ascii", "replace").decode()))


if __name__ == "__main__":
    main()
