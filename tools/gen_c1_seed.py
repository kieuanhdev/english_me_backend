#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sinh migration Flyway V38__seed_c1_flashcards.sql từ vocabulary_oxford5000.json.

- Lọc cefr == "C1" (1283 từ, bỏ Grammar 88 -> 1195 nội dung).
- Bỏ "Grammar & Function Words".
- Gom topic thành 14 BỘ C1 hệ thống (owner_id = NULL), cap 50 từ/bộ
  => tự nhiên cắt còn ~700 từ (chọn từ đủ thông tin nhất qua completeness_score).
- UUID cố định (uuid5) => idempotent.

KHÁC V33 (A1): không đụng index. V38 chỉ INSERT — cùng kiểu V35/V36/V37.
Đây là cấp cao nhất seed được (nguồn KHÔNG có từ C2 nào).

Chạy 1 lần:
    python tools/gen_c1_seed.py
Output: src/main/resources/db/migration/V38__seed_c1_flashcards.sql
"""

import json
import os
import uuid

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SRC = os.path.join(ROOT, "src", "main", "resources", "vocabulary_oxford5000.json")
OUT = os.path.join(ROOT, "src", "main", "resources", "db", "migration",
                   "V38__seed_c1_flashcards.sql")

# Namespace riêng cho C1 (KHÁC A1/A2/B1/B2).
NS = uuid.UUID("c1c1c1c1-0000-4000-8000-000000000005")

CEFR = "C1"
MAX_PER_DECK = 50
EXCLUDE_TOPICS = {"Grammar & Function Words"}

# sort_order tiếp nối: ... B2 43..56 -> C1 57..70.
# Phân bố C1 (bỏ Grammar): Law 170, Society 155, Emotions 114, Health 82, Business 81,
#   Science 78, Appearance 70, Work 62, Arts 60, Nature 50, Home 50, Education 46,
#   Tech 44, Time 25, Sports 25, Travel 24, Numbers 18, Family 16, Greetings 10,
#   Food 7, Shopping 3, Weather 2, Communication 1, General 1, UNTAGGED 1.
# Topic lớn (>50) tự bị cap 50. Gộp topic nhỏ + nhãn rác cho đủ bộ.
DECKS = [
    ("C1 · Luật pháp & Chính trị",      ["Law & Politics"],                                  57),
    ("C1 · Xã hội & Văn hóa",           ["Society & Culture"],                               58),
    ("C1 · Cảm xúc & Tính cách",        ["Emotions & Feelings"],                             59),
    ("C1 · Cơ thể & Sức khỏe",          ["Health & Body"],                                   60),
    ("C1 · Kinh doanh & Kinh tế",       ["Business & Economy"],                              61),
    ("C1 · Khoa học & Nghiên cứu",      ["Science & Research"],                              62),
    ("C1 · Ngoại hình & Mô tả",         ["Appearance & Description"],                         63),
    ("C1 · Công việc & Sự nghiệp",      ["Work & Career"],                                   64),
    ("C1 · Giải trí & Nghệ thuật",      ["Arts & Entertainment"],                            65),
    ("C1 · Thiên nhiên & Thời tiết",    ["Nature & Environment", "Weather & Climate"],       66),
    ("C1 · Nhà cửa & Đời sống",         ["Home & Living"],                                   67),
    ("C1 · Học tập & Trường lớp",       ["Education & Learning"],                            68),
    ("C1 · Công nghệ & Di chuyển",      ["Technology & Media", "Travel & Transport"],        69),
    ("C1 · Đời sống thường ngày",       ["Time & Daily Routine", "Sports & Hobbies",
                                         "Numbers & Measurement", "Family & Relationships",
                                         "Greetings & Communication", "Food & Drink",
                                         "Shopping & Money", "Communication", "General"],     70),
]


def norm_text(s):
    if s is None:
        return ""
    s = str(s).replace("\xa0", " ")
    return " ".join(s.split()).strip()


def sql_str(s):
    s = norm_text(s)
    if s == "":
        return "NULL"
    return "'" + s.replace("'", "''") + "'"


def sql_json(obj):
    if not obj:
        return "NULL"
    raw = json.dumps(obj, ensure_ascii=False)
    return "'" + raw.replace("'", "''") + "'::jsonb"


def desk_uuid(title):
    return str(uuid.uuid5(NS, "desk:" + title))


def card_uuid(desk_id, word):
    return str(uuid.uuid5(NS, "card:" + desk_id + ":" + word.lower()))


def completeness_score(w):
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

    rows_in = [w for w in data if str(w.get("cefr", "")).upper() == CEFR]

    by_topic = {}
    for w in rows_in:
        topic = norm_text(w.get("topic")) or "UNTAGGED"
        by_topic.setdefault(topic, []).append(w)

    assigned_topics = set()
    deck_rows = []
    total = 0
    seen_words_global = set()

    for title, src_topics, sort in DECKS:
        words = []
        for t in src_topics:
            assigned_topics.add(t)
            words.extend(by_topic.get(t, []))
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

    leftover = {t: len(ws) for t, ws in by_topic.items()
                if t not in assigned_topics and t not in EXCLUDE_TOPICS}

    lines = []
    lines.append("-- ============================================================")
    lines.append("-- V38: Seed %d bộ thẻ C1 (owner_id NULL = desk hệ thống dùng chung)." % len(deck_rows))
    lines.append("-- Sinh tự động từ vocabulary_oxford5000.json (cefr=C1) bằng tools/gen_c1_seed.py.")
    lines.append("-- Bỏ topic 'Grammar & Function Words'. Mỗi bộ <= %d từ. Tổng: %d từ." % (MAX_PER_DECK, total))
    lines.append("-- (Nguồn C1 ~1195 từ nội dung -> cap 50/bộ để giữ ~14 bộ như A1-B1.)")
    lines.append("-- C1 là cấp cao nhất: nguồn oxford5000 KHÔNG có từ C2 nào.")
    lines.append("-- UUID cố định (uuid5) => chạy lại an toàn (ON CONFLICT DO NOTHING).")
    lines.append("-- Index uq_desk_global_cefr_title đã tạo ở V33 (A1) => V38 chỉ INSERT.")
    lines.append("-- ============================================================")
    lines.append("")

    for title, sort, picked in deck_rows:
        did = desk_uuid(title)
        lines.append("-- ── %s (%d từ) ─────────────────────────────" % (title, len(picked)))
        lines.append("INSERT INTO desk (id, owner_id, cefr_level, title, sort_order)")
        lines.append("VALUES ('%s', NULL, '%s', %s, %d)" % (did, CEFR, sql_str(title), sort))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")
        if not picked:
            continue
        lines.append("INSERT INTO flashcard")
        lines.append("    (id, desk_id, word, cefr, pos_json, all_levels_json, ipa, audio_url,")
        lines.append("     definition, example, topic, vietnamese, vi_definition, vi_example)")
        lines.append("VALUES")
        rs = []
        for w in picked:
            word = norm_text(w.get("word"))
            cid = card_uuid(did, word)
            rs.append("    ('%s', '%s', %s, '%s', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % (
                cid, did, sql_str(word), CEFR,
                sql_json(w.get("pos")), sql_json(w.get("all_levels")),
                sql_str(w.get("ipa")), sql_str(w.get("audio_url")),
                sql_str(w.get("definition")), sql_str(w.get("example")),
                sql_str(w.get("topic")), sql_str(w.get("vietnamese")),
                sql_str(w.get("vi_definition")), sql_str(w.get("vi_example")),
            ))
        lines.append(",\n".join(rs))
        lines.append("ON CONFLICT (desk_id, word) DO NOTHING;")
        lines.append("")

    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))

    print("OK -> %s" % OUT)
    print("Tong tu seed: %d" % total)
    print("So bo: %d" % len(deck_rows))
    for title, sort, picked in deck_rows:
        print("  [%2d] %-40s %3d tu" % (sort, title.encode("ascii", "replace").decode(), len(picked)))
    if leftover:
        print("Topic %s CHUA gan vao bo nao (con du):" % CEFR)
        for t, n in sorted(leftover.items(), key=lambda x: -x[1]):
            print("  %3d  %s" % (n, t.encode("ascii", "replace").decode()))


if __name__ == "__main__":
    main()
