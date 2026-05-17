# BÁO CÁO DỰ ÁN ENGLISHME & YÊU CẦU CHO ADMIN PANEL

> **Ngày phân tích:** 2026-05-17
> **Tác giả:** AI Analysis
> **Phạm vi:** Toàn bộ chức năng admin cần có trên web (CRUD + Statistics + Configuration)

---

## 1. TỔNG QUAN DỰ ÁN

### 1.1 Mô tả ngắn
**EnglishMe** là ứng dụng học tiếng Anh đa nền tảng (mobile + web admin). Backend xây bằng **Spring Boot (Java)**, database **PostgreSQL**, dùng **Flyway** migration, xác thực bằng **Firebase Auth**, có tích hợp **Google Cloud Pronunciation Assessment** và **DeepSeek Chat AI**.

### 1.2 Kiến trúc tổng thể

```
┌────────────────┐    ┌─────────────────────┐    ┌──────────────────┐
│  Mobile App    │───▶│  Spring Boot API    │───▶│  PostgreSQL DB   │
│  (Flutter?)    │    │  /api/**            │    │  (Flyway V1-V10) │
└────────────────┘    │                     │    └──────────────────┘
                      │  /admin/**  (JSP)   │
┌────────────────┐    │                     │    ┌──────────────────┐
│  Admin Web     │───▶│  Firebase Auth      │◀──▶│  Firebase        │
│  (Browser)     │    │  Google Pronunc.    │    │  Google Cloud    │
└────────────────┘    │  DeepSeek Chat      │    │  DeepSeek AI     │
                      └─────────────────────┘    └──────────────────┘
```

### 1.3 Các module nghiệp vụ hiện có

| # | Module | Entity chính | API mobile | Admin UI hiện tại |
|---|--------|--------------|------------|-------------------|
| 1 | User & Auth | `User` | `/api/auth/sync`, `/api/users/me/**` | ✅ List + Lock/Unlock |
| 2 | Desk & Flashcard | `Desk`, `Flashcard` | `/api/desks/**` | ✅ Full CRUD |
| 3 | Vocabulary | `VocabularyTopic`, `VocabularyWord` | `/api/vocabulary/**` | ❌ **Chưa có** |
| 4 | Grammar | `GrammarTopic`, `GrammarLesson`, `GrammarExercise` | `/api/grammar/**` | ⚠️ Chỉ xem (read-only) |
| 5 | Placement Test | `TestSession`, `Question`, `TestAnswer` | `/api/placement-test/**` | ⚠️ Chỉ xem |
| 6 | Exercise | `ExerciseQuestion`, `ExerciseSession` | `/api/exercises/**` | ❌ **Chưa có** |
| 7 | User Test (có giờ) | `UserTestSession` | `/api/tests/**` | ❌ **Chưa có** |
| 8 | Study Session (SM-2) | `StudySession`, `FlashcardProgress` | `/api/study-sessions/**` | ❌ **Chưa có** |
| 9 | Pronunciation | `PronunciationExercise`, `PronunciationAttempt` | `/api/pronunciation/**` | ✅ Xem attempts |
| 10 | XP / Streak / Badges | `XpHistory`, `Badge`, `UserBadge` | `/api/users/me/xp-history`, `/api/users/me/streak-calendar` | ❌ **Chưa có** |
| 11 | Home Dashboard | (composite) | `/api/home/dashboard` | ❌ **Chưa có** |
| 12 | Chat AI | (in-memory) | `/api/chat` | ❌ Skip (theo plan) |

---

## 2. HIỆN TRẠNG ADMIN PANEL

### 2.1 Đã có (tại `/admin`)

| Route | Chức năng | Trạng thái |
|-------|-----------|-----------|
| `GET /admin` | Dashboard với 6 chỉ số cơ bản | ✅ Có |
| `GET /admin/desks` | List desks + tạo mới | ✅ Có |
| `GET /admin/desks/{id}` | Chi tiết desk + flashcards (phân trang) | ✅ Có |
| `POST /admin/desks` | Tạo desk | ✅ Có |
| `POST /admin/desks/{id}/flashcards` | Thêm flashcard | ✅ Có |
| `POST /admin/desks/{id}/flashcards/{fid}/delete` | Xóa flashcard | ✅ Có |
| `GET /admin/users` | List users + filter (cefr/status/keyword) | ✅ Có |
| `POST /admin/users/{id}/lock` | Khóa user | ✅ Có |
| `POST /admin/users/{id}/unlock` | Mở khóa | ✅ Có |
| `GET /admin/pronunciation` | List attempts + filter | ✅ Có |
| `GET /admin/grammar` | Topics list (read-only) | ⚠️ Chỉ xem |
| `GET /admin/grammar/topics/{id}` | Lessons trong topic | ⚠️ Chỉ xem |
| `GET /admin/grammar/lessons/{id}` | Chi tiết lesson | ⚠️ Chỉ xem |
| `GET /admin/placement-test` | List test sessions | ⚠️ Chỉ xem |
| `GET /admin/placement-test/{id}` | Chi tiết session | ⚠️ Chỉ xem |

### 2.2 Đánh giá

**Điểm mạnh:**
- Có sườn JSP + Tailwind, layout sidebar/topbar rõ ràng
- Đã có authentication cho admin (`AdminAuthService`)
- Đã có Material Design Icons

**Điểm yếu nghiêm trọng:**
1. **Thiếu CRUD cho 70% nội dung học:** Vocabulary, Grammar (chỉ xem), Exercise, Test bank, Badge → không thể quản trị nội dung qua web
2. **Dashboard quá nghèo:** Chỉ 6 con số đơn giản, không có biểu đồ, không có xu hướng, không có top-N
3. **Không có User Detail:** Click vào 1 user không xem được XP, streak, lịch sử học, badges
4. **Không có cấu hình hệ thống:** Mọi config đều trong `application.yaml` hoặc hardcoded
5. **Không có audit log / activity log:** Không biết admin nào đã làm gì
6. **Không có export / report:** Không xuất được CSV/Excel
7. **Không có quản lý nội dung "Word of Day"** trong khi Home Dashboard mobile có hiển thị
8. **Không có quản lý announcement / push notification**

---

## 3. YÊU CẦU MỚI: ADMIN CẦN ĐIỀU KHIỂN GÌ?

### 3.1 NGUYÊN TẮC THIẾT KẾ

1. **Admin phải làm được mọi thứ trên web — không cần SSH vào server**
2. **Phân quyền rõ ràng** — SUPER_ADMIN / EDITOR / VIEWER
3. **Mọi thay đổi đều có audit log** — ai làm, làm gì, khi nào
4. **Có thể export dữ liệu** ra CSV/Excel cho báo cáo
5. **Có thể seeding nội dung nhanh** — bulk import JSON cho vocabulary/grammar

---

### 3.2 MODULE 1 — DASHBOARD ANALYTICS (mở rộng) — ✅ ĐÃ TRIỂN KHAI 2026-05-17

**Mục tiêu:** Admin mở dashboard biết ngay sức khỏe hệ thống.

> **Trạng thái:** P0 hoàn thành ở giai đoạn 1. Xem chi tiết các hạng mục đã làm tại mục **9. CHANGELOG TRIỂN KHAI** ở cuối tài liệu.

#### A. KPI cards (hàng trên cùng)
- [x] Tổng số user (đã có)
- [x] User mới hôm nay (đã có)
- [x] Active today (đã có — đếm pronunciation attempt, **nên đổi sang đếm bất kỳ activity**)
- [ ] **DAU / WAU / MAU** (Daily/Weekly/Monthly Active Users)
- [ ] Tỷ lệ retention 7 ngày / 30 ngày
- [ ] Số session học tập hôm nay (study + exercise + test)
- [ ] Tổng XP cấp ra hôm nay
- [ ] Trung bình streak hiện tại

#### B. Biểu đồ (Chart.js / ApexCharts)
- [ ] **Line chart:** Số user mới theo ngày (14/30/90 ngày)
- [ ] **Line chart:** Active users theo ngày
- [ ] **Bar chart:** Phân bố user theo CEFR level (A1/A2/B1/B2/C1/C2)
- [ ] **Donut chart:** Phân bố nội dung học (% người học Vocab / Grammar / Pronunciation / Test)
- [ ] **Heatmap:** Hoạt động theo giờ trong ngày × ngày trong tuần
- [ ] **Stacked bar:** XP cấp ra theo nguồn (study / exercise / test) trong 7 ngày

#### C. Top-N tables
- [ ] Top 10 user có streak cao nhất
- [ ] Top 10 user có XP cao nhất
- [ ] Top 10 từ vựng được học nhiều nhất
- [ ] Top 10 bài grammar được truy cập nhiều nhất
- [ ] Top 10 từ phát âm sai nhiều nhất (từ `pronunciation_attempt`)
- [ ] Top 10 user inactive (có dấu hiệu sắp churn)

#### D. System Health
- [ ] Trạng thái Firebase (connected / error)
- [ ] Trạng thái Google Pronunciation API (quota còn lại)
- [ ] Trạng thái DeepSeek API (response time trung bình)
- [ ] Database size, số connection
- [ ] Disk usage (audio files)

---

### 3.3 MODULE 2 — VOCABULARY MANAGEMENT (MỚI 100%) — ✅ ĐÃ TRIỂN KHAI 2026-05-17

> **Trạng thái:** P0 hoàn thành ở giai đoạn 1 (CRUD đầy đủ + import JSON + export CSV + duplicate detection). Xem chi tiết tại mục **9. CHANGELOG TRIỂN KHAI**.

**Đang thiếu hoàn toàn UI admin.** Mobile đã có endpoint `/api/vocabulary/topics` nhưng admin không thể quản lý.

#### Route cần tạo
```
GET    /admin/vocabulary                      → List topics + filter
POST   /admin/vocabulary/topics               → Tạo topic
PUT    /admin/vocabulary/topics/{id}          → Sửa topic
DELETE /admin/vocabulary/topics/{id}          → Xóa topic (soft delete?)
GET    /admin/vocabulary/topics/{id}          → Chi tiết + list từ
POST   /admin/vocabulary/topics/{id}/words    → Thêm từ
PUT    /admin/vocabulary/words/{id}           → Sửa từ
DELETE /admin/vocabulary/words/{id}           → Xóa từ
POST   /admin/vocabulary/topics/{id}/import   → Bulk import từ JSON/CSV
GET    /admin/vocabulary/topics/{id}/export   → Export CSV
```

#### Fields quản lý
**Topic:** `name`, `name_en`, `icon` (emoji picker), `level` (A1-C2), `color_hex` (color picker), `sort_order`
**Word:** `word`, `pronunciation` (IPA), `part_of_speech`, `definition_vi`, `definition_en`, `example_sentence`, `example_translation`, `level`, `audio_url` (upload audio)

#### Tính năng nâng cao
- [ ] Bulk edit level / topic
- [ ] Auto-generate IPA bằng API (nếu có)
- [ ] Upload audio file → tự lưu vào storage, sinh `audio_url`
- [x] Preview audio ngay trên list (HTML5 `<audio controls>`)
- [x] Tìm kiếm từ trùng (duplicate detection) — đánh dấu badge "Trùng" trên cùng `topic` (so sánh case-insensitive)

---

### 3.4 MODULE 3 — GRAMMAR MANAGEMENT (UPGRADE) — ✅ ĐÃ TRIỂN KHAI 2026-05-17

> **Trạng thái:** P0 hoàn thành ở giai đoạn 1 (CRUD đầy đủ cho topic / lesson / exercise + bulk import JSON lồng nhau). Xem chi tiết tại mục **9. CHANGELOG TRIỂN KHAI**.

**Hiện chỉ xem được — cần thêm CRUD.**

#### Route cần thêm
```
POST   /admin/grammar/topics                  → Tạo topic
PUT    /admin/grammar/topics/{id}             → Sửa topic
DELETE /admin/grammar/topics/{id}             → Xóa
POST   /admin/grammar/topics/{id}/lessons     → Thêm lesson
PUT    /admin/grammar/lessons/{id}            → Sửa lesson (rich text editor)
DELETE /admin/grammar/lessons/{id}            → Xóa lesson
POST   /admin/grammar/lessons/{id}/exercises  → Thêm bài tập
PUT    /admin/grammar/exercises/{id}          → Sửa bài tập
DELETE /admin/grammar/exercises/{id}          → Xóa
POST   /admin/grammar/import                  → Bulk import từ JSON
```

#### Cần
- [ ] **Rich text editor** (TinyMCE / Quill / TipTap) cho nội dung lesson
- [ ] **Markdown support** với preview
- [ ] **Reorder** lesson trong topic (drag-drop)
- [ ] **Versioning** — giữ lịch sử thay đổi của lesson

---

### 3.5 MODULE 4 — EXERCISE BANK MANAGEMENT (MỚI 100%) — ✅ ĐÃ TRIỂN KHAI 2026-05-17

> **Trạng thái:** P1 hoàn thành ở giai đoạn 1 (CRUD đầy đủ + import JSON + export CSV + xem lịch sử session học viên + thống kê accuracy theo câu hỏi). Xem chi tiết tại mục **9. CHANGELOG TRIỂN KHAI**.

**Quản lý ngân hàng câu hỏi exercise** (multiple choice).

#### Route cần tạo
```
GET    /admin/exercises                       → List questions + filter (category/difficulty/level)
POST   /admin/exercises                       → Tạo question
PUT    /admin/exercises/{id}                  → Sửa
DELETE /admin/exercises/{id}                  → Xóa
POST   /admin/exercises/import                → Bulk import JSON
GET    /admin/exercises/export                → Export CSV
GET    /admin/exercises/sessions              → Xem lịch sử session học viên
GET    /admin/exercises/sessions/{id}         → Chi tiết session (đáp án + thời gian)
```

#### Fields
- `category`: vocabulary | grammar
- `difficulty`: easy | medium | hard
- `question`: text
- `options`: JSON array `["A. ...", "B. ...", ...]`
- `correct_answer`: text
- `explanation`: text
- `hint`: text
- `level`: A1-C2

#### Phân tích
- [x] Tỉ lệ làm đúng từng câu (để phát hiện câu quá khó / quá dễ / sai đáp án) — cột "Đúng %" trên list, badge đỏ nếu < 30%, badge vàng nếu > 95%
- [ ] Thời gian trung bình làm mỗi câu — chưa lưu `answered_at` ở entity `ExerciseAnswer`, cần thêm cột (đẩy sang giai đoạn sau)
- [ ] Câu hay bị skip nhất — cần kết hợp `question_ids` của session với `exercise_answer` để tính skip rate (đẩy sang giai đoạn sau)

---

### 3.6 MODULE 5 — TEST BANK MANAGEMENT (✅ ĐÃ LÀM — 2026-05-17)

Hiện `Question` (placement test) được seed từ JSON file `dauvaotest.json` → cần UI quản trị.

#### Route — đã triển khai
- [x] `GET    /admin/test-bank` → List questions (filter theo CEFR / skill / keyword)
- [x] `POST   /admin/test-bank` → Tạo
- [x] `POST   /admin/test-bank/{id}/update` → Sửa (form-based, thay cho PUT vì JSP form)
- [x] `POST   /admin/test-bank/{id}/delete` → Xóa (form-based, thay cho DELETE)
- [x] `POST   /admin/test-bank/import` → Bulk import JSON (mảng hoặc `{ "questions": [...] }`)
- [x] `GET    /admin/test-bank/export` → Export CSV (kèm BOM cho Excel)
- [x] `GET    /admin/test-bank/stats` → Trang thống kê độ khó / độ chính xác

#### Fields cần quản lý — đã triển khai
- [x] `cefr_level` (A1–C2, validate enum)
- [x] `skill_category` (grammar | vocabulary | reading | listening)
- [x] `question_text`
- [x] `options` JSONB — object `{"A":"...","B":"...","C":"...","D":"..."}`
- [x] `correct_answer` (A/B/C/D, bắt buộc khớp 1 khóa options)
- [x] `explanation`
- [x] `audio_url` (cho listening)
- [x] `passage` (cho reading)
- [x] `created_at` / `updated_at` (audit, tự set qua `@PrePersist` / `@PreUpdate`)

#### Phân tích chất lượng câu hỏi
- [x] % học viên trả lời đúng theo từng CEFR level — bảng "Phân bố theo CEFR" trên `/admin/test-bank/stats`
- [x] Phân nhóm độ khó (proxy đơn giản cho difficulty index): "Quá khó (<30%)", "Bình thường", "Quá dễ (>95%)", "Chưa có dữ liệu"
- [x] Cột "Đúng %" trên list, badge đỏ nếu < 30%, vàng nếu > 95%, xanh ở khoảng giữa
- [ ] Item Response Theory metrics: discrimination index (cần thêm cột `answered_at` ở `TestAnswer` và mô hình IRT — đẩy sang giai đoạn sau)
- [ ] Câu bị bỏ qua / skip rate — `TestAnswer` hiện chỉ lưu khi user submit, không lưu skip; cần đối chiếu `question_ids` của session với bảng answer (đẩy sang giai đoạn sau)

#### Files đã thay đổi
- `src/main/java/com/kiovant/englishme/entity/Question.java` — thêm `audioUrl`, `passage`, `createdAt`, `updatedAt`
- `src/main/java/com/kiovant/englishme/repository/QuestionRepository.java` — thêm `searchQuestions`, `countByCefrLevel`, `countBySkillCategory`
- `src/main/java/com/kiovant/englishme/repository/TestAnswerRepository.java` — thêm `aggregateStatsByQuestionIds`, `aggregateStatsByCefrLevel`
- `src/main/java/com/kiovant/englishme/dto/AdminTestBankQuestionRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/CreateTestBankQuestionRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/UpdateTestBankQuestionRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/TestBankImportResult.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/TestBankStats.java` *(mới)*
- `src/main/java/com/kiovant/englishme/service/AdminTestBankService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminTestBankController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/test-bank.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/test-bank-stats.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` — thêm mục "Test Bank"

---

### 3.7 MODULE 6 — USER MANAGEMENT (✅ ĐÃ LÀM — 2026-05-17)

**Hiện chỉ list + lock/unlock — cần mở rộng.**

#### Route mở rộng — đã triển khai
- [x] `GET  /admin/users/{id}` → User detail page (gộp luôn activity/sessions/xp-history/desks ở các tab)
- [x] `GET  /admin/users/{id}/activity` → alias trỏ về detail (hiển thị bảng 50 hoạt động gần nhất)
- [x] `GET  /admin/users/{id}/sessions` → alias trỏ về detail
- [x] `GET  /admin/users/{id}/xp-history` → alias trỏ về detail (biểu đồ XP 30 ngày)
- [x] `GET  /admin/users/{id}/desks` → alias trỏ về detail (section Desks)
- [x] `POST /admin/users/{id}/reset-progress` → xóa session/badge/progress + reset XP/streak/lastActiveDate. Có confirm hai bước trên UI. **KHÔNG xóa** desk/flashcard (đó là content user tạo, không phải progress).
- [x] `POST /admin/users/{id}/grant-xp` → cộng XP thủ công (param `amount` > 0)
- [x] `POST /admin/users/{id}/award-badge` → gắn badge thủ công (param `badgeId`, chặn double-award)
- [x] `POST /admin/users/{id}/change-level` → đổi CEFR level (validate A1–C2)
- [x] `POST /admin/users/{id}/delete` → soft delete (set `deleted_at` + `account_locked = true`). Dùng POST thay cho `DELETE` vì JSP form không hỗ trợ DELETE native.
- [x] `GET  /admin/users/export` → export CSV (kèm BOM cho Excel), tôn trọng filter `cefr`/`status`/`q`

#### User Detail page hiển thị — đã triển khai
- [x] Profile (email, name, avatar, CEFR, created_at, last_active, firebase UID, trạng thái lock/onboarded/deleted)
- [x] Stats: total XP, current streak, longest streak, tổng số session theo từng loại (study/exercise/test/pronunciation)
- [x] Badges đã đạt (icon + condition_type + earned_at)
- [x] Biểu đồ XP 30 ngày (bar chart CSS, derive từ `study_session.xp_earned` gộp theo ngày)
- [x] Streak calendar 90 ngày (grid 7×N ô, ngày có study session = ô xanh)
- [x] Lịch sử 50 hoạt động gần nhất (merge từ study / exercise / placement test / pronunciation, sort desc theo timestamp)
- [x] Danh sách desk + số flashcard mỗi desk (sort theo `sort_order`)

#### Soft delete behavior
- [x] User bị soft-deleted bị loại khỏi `findUsersByFilter` và mọi dashboard query (`countCreatedSince`, `countByCefrLevel`, `findTopByStreak`, ...)
- [x] `UserService.syncUser` chặn Firebase token nếu `deleted_at != null` (trả `403`)
- [x] `AdminUserService.getUserOrThrow` trả `404` khi user đã bị soft-deleted

#### Files đã thay đổi
- `src/main/java/com/kiovant/englishme/entity/User.java` — thêm cột `deletedAt`
- `src/main/java/com/kiovant/englishme/repository/UserRepository.java` — toàn bộ query agg đã thêm `u.deletedAt IS NULL`
- `src/main/java/com/kiovant/englishme/repository/StudySessionRepository.java` — thêm `countByUser_Id`, `sumXpByDayForUser`, `findActiveDaysForUser`, `findTop50ByUser_IdOrderByStartedAtDesc`, `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/repository/ExerciseSessionRepository.java` — thêm `countByUser_Id`, `findTop50…`, `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/repository/TestSessionRepository.java` — thêm `countByUser_Id`, `findTop50…`, `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/repository/PronunciationAttemptRepository.java` — thêm `countByUser_Id`, `findTop50…`, `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/repository/UserBadgeRepository.java` — thêm `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/repository/FlashcardProgressRepository.java` — thêm `deleteByUser_Id`
- `src/main/java/com/kiovant/englishme/service/UserService.java` — chặn user soft-deleted ở `syncUser`, filter spec mặc định bỏ qua deleted
- `src/main/java/com/kiovant/englishme/dto/UserDetailDto.java` *(mới)*
- `src/main/java/com/kiovant/englishme/service/AdminUserService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminUserController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/user-detail.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/users.jsp` — thêm nút "Export CSV", cột XP/Streak, link "Chi tiết", hiển thị flash messages

#### Đẩy sang giai đoạn sau
- [ ] XP history dài hạn / chính xác hơn cho mọi nguồn — hiện chỉ derive từ `study_session.xp_earned`. Exercise/test/pronunciation chưa lưu `xp_earned` per-record, nên không gộp được vào biểu đồ. Cần thêm cột riêng (hoặc bảng `xp_event`) nếu muốn full attribution.
- [ ] Hard delete (xóa hoàn toàn DB) — hiện chỉ soft delete; chưa có tooling khôi phục hoặc purge sau N ngày.

---

### 3.8 MODULE 7 — BADGE MANAGEMENT (MỚI) ✅ DONE 2026-05-17

**Tạo, sửa, kích hoạt badge.**

#### Route
```
GET    /admin/badges                          → List badges + số user đã đạt
POST   /admin/badges                          → Tạo badge
PUT    /admin/badges/{id}                     → Sửa
DELETE /admin/badges/{id}                     → Xóa
POST   /admin/badges/{id}/icon                → Upload icon
GET    /admin/badges/{id}/users               → User đã đạt badge
```

#### Fields
- `name`, `description`, `icon_url`
- `condition_type`: dropdown enum (`streak_7`, `streak_30`, `xp_1000`, `xp_5000`, `first_lesson`, `grammar_10`, `pronunciation_50`, v.v.)
- `condition_value` (numeric, dùng cho điều kiện tùy chỉnh)
- `is_active` (bật/tắt)

#### Cần backend
- Cron job đánh giá lại condition khi badge mới tạo
- Trigger event khi user đạt điều kiện → gắn badge

#### Đã làm (2026-05-17)
- **Entity** `Badge` bổ sung: `conditionValue (Integer)`, `isActive (Boolean, default true)`, `createdAt (LocalDateTime)`. Hibernate `ddl-auto: update` sẽ tự thêm cột.
- **Routes (Spring MVC form POST, không phải REST PUT):**
  - `GET  /admin/badges` — list + số user đã đạt.
  - `POST /admin/badges` — tạo + backfill ngay (re-evaluate cho mọi user thỏa điều kiện).
  - `POST /admin/badges/{id}/update` — sửa + re-evaluate.
  - `POST /admin/badges/{id}/delete` — xóa, kèm cascade `user_badge`.
  - `POST /admin/badges/{id}/icon` — upload icon (png/jpg/svg/webp, ≤ 1 MB) lưu vào `uploads/badges/{badgeId}_{ts}.{ext}`, set `iconUrl=/uploads/badges/...`.
  - `GET  /admin/badges/{id}/users` — list user đã đạt + earned_at.
  - `POST /admin/badges/{id}/reevaluate` — quét lại thủ công (thay cron job).
- **Re-evaluate**: gắn badge cho user dựa theo `condition_type` đang hỗ trợ:
  - `streak_7` / `streak_30` — match `currentStreak` HOẶC `longestStreak ≥ ngưỡng`.
  - `xp_1000` / `xp_5000` — match `totalXp`.
  - `streak_custom` / `xp_custom` — dùng `conditionValue` numeric.
  - `first_lesson` — proxy: `totalXp > 0`.
  - `grammar_10` / `pronunciation_50` — chưa có nguồn dữ liệu counter; hiện return false để chờ Module 8/4 thêm hook khi user submit.
- **Re-evaluate trigger** chạy ngay sau khi `create` / `update` thành công, không cần cron. Có thêm nút "Quét" trên UI để admin trigger thủ công.

#### Files đã thêm
- `src/main/java/com/kiovant/englishme/entity/Badge.java` *(updated — thêm field)*
- `src/main/java/com/kiovant/englishme/repository/BadgeRepository.java` *(updated — thêm `findAllByOrderByCreatedAtDesc`, `existsByNameIgnoreCase`, `countAwardedGroupByBadge`)*
- `src/main/java/com/kiovant/englishme/repository/UserBadgeRepository.java` *(updated — thêm `findByBadge_IdOrderByEarnedAtDesc`, `countByBadge_Id`, `deleteByBadge_Id`)*
- `src/main/java/com/kiovant/englishme/dto/AdminBadgeRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminBadgeUserRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/CreateBadgeRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/UpdateBadgeRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/service/AdminBadgeService.java` *(mới — CRUD + icon upload + re-evaluate)*
- `src/main/java/com/kiovant/englishme/controller/AdminBadgeController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/badges.jsp` *(mới — list + create/edit modal + upload icon form)*
- `src/main/webapp/WEB-INF/views/admin/badge-users.jsp` *(mới — list user đã đạt, link sang admin/users/{id})*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` *(thêm link "Badges")*

#### Đẩy sang giai đoạn sau
- [ ] Trigger event tự động khi user đạt mốc XP/streak ở thời điểm hoạt động (đã có `ProgressService.evaluateBadges` cho `streak_7/30` và `xp_1000`, nhưng chưa cover các badge custom mới hoặc `grammar_10`/`pronunciation_50`). Tạm thời admin có thể bấm "Quét" sau khi tạo.
- [ ] Cron schedule (vd Spring `@Scheduled`) gọi `reevaluateBadge` cho mọi badge active mỗi N giờ.
- [ ] Đếm "grammar lesson đã hoàn thành" / "pronunciation attempts" theo user — cần thêm cột/bảng counter hoặc derive từ session table.
- [ ] Serve `/uploads/badges/**` qua `WebMvcConfigurer.addResourceHandlers` (hiện file lưu ngoài classpath nên cần config resource handler nếu chạy embedded; với `mvn spring-boot:run` từ working dir hiện tại sẽ đọc được từ `./uploads/`).

---

### 3.9 MODULE 8 — PRONUNCIATION EXERCISE MANAGEMENT (MỚI) ✅ DONE 2026-05-17

Hiện list attempts có sẵn nhưng **chưa quản lý được danh sách bài tập phát âm**.

#### Route
```
GET    /admin/pronunciation/exercises         → List bài tập
POST   /admin/pronunciation/exercises         → Tạo
PUT    /admin/pronunciation/exercises/{id}    → Sửa
DELETE /admin/pronunciation/exercises/{id}    → Xóa
POST   /admin/pronunciation/exercises/{id}/audio → Upload audio mẫu
```

#### Fields
- `text` (câu/từ cần phát âm)
- `expected_phonetic` (IPA)
- `level`
- `difficulty`
- `reference_audio_url`
- `tips` (gợi ý phát âm)

#### Phân tích attempt
- [x] Biểu đồ phân bố điểm pronunciation (bucket 0–9, 10–19, …, 90–100)
- [x] Phoneme/word có tỉ lệ sai cao nhất (top 20 word có avg score thấp nhất, ≥ 3 attempts)
- [x] So sánh provider (đếm + avg overall/accuracy/fluency theo provider)

#### Đã làm (2026-05-17)
- **Entity `PronunciationExercise` bổ sung** `level (CEFR, nullable)`, `tips (TEXT)`, `createdAt`. Cột cũ giữ tên: `phonetic` đóng vai trò `expected_phonetic`, `audio_url` đóng vai trò `reference_audio_url`. Hibernate `ddl-auto: update` sẽ tự thêm cột mới.
- **Routes (Spring MVC form POST):**
  - `GET  /admin/pronunciation/exercises` — list + filter `level`/`difficulty`/`q`, kèm `attemptCount` & `avgScore` per exercise.
  - `POST /admin/pronunciation/exercises` — tạo.
  - `POST /admin/pronunciation/exercises/{id}/update` — sửa.
  - `POST /admin/pronunciation/exercises/{id}/delete` — xóa.
  - `POST /admin/pronunciation/exercises/{id}/audio` — upload audio mẫu (mp3/wav/ogg/m4a/webm ≤ 5 MB) → `/uploads/pronunciation/{id}_{ts}.{ext}`.
  - `GET  /admin/pronunciation/exercises/analytics` — biểu đồ phân bố điểm + weakest words + issue types + provider comparison.
- **Validate:** `text` không trống, `difficulty ∈ {easy, medium, hard}`, `level ∈ {A1..C2}` nếu set.

#### Files đã thêm
- `src/main/java/com/kiovant/englishme/entity/PronunciationExercise.java` *(updated — thêm `level`, `tips`, `createdAt`)*
- `src/main/java/com/kiovant/englishme/repository/PronunciationExerciseRepository.java` *(updated — `searchForAdmin`)*
- `src/main/java/com/kiovant/englishme/repository/PronunciationAttemptRepository.java` *(updated — `aggregateStatsByExercise`, `scoreDistributionBuckets`, `providerComparison`, `countAll`, `averageOverallScore`)*
- `src/main/java/com/kiovant/englishme/repository/PronunciationWordFeedbackRepository.java` *(updated — `findWeakestWords`, `countByIssueType`)*
- `src/main/java/com/kiovant/englishme/dto/AdminPronunciationExerciseRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/CreatePronunciationExerciseRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/UpdatePronunciationExerciseRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/PronunciationAnalytics.java` *(mới — nested records cho 4 nhóm phân tích)*
- `src/main/java/com/kiovant/englishme/service/AdminPronunciationExerciseService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminPronunciationExerciseController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/pronunciation-exercises.jsp` *(mới — list + filter + modal create/edit + form upload audio)*
- `src/main/webapp/WEB-INF/views/admin/pronunciation-analytics.jsp` *(mới — score distribution bar chart + weakest words + issue types + provider compare)*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` *(thêm link "Pronunciation Exercises" tách khỏi "Pronunciation" attempts)*

#### Đẩy sang giai đoạn sau
- [ ] Phân tích **phoneme-level** chính xác hơn — hiện gom theo `word` từ `pronunciation_word_feedback`. Nếu provider trả phoneme array thì cần thêm bảng/cột riêng để group theo IPA symbol.
- [ ] Bulk import / export bài tập (giống Test Bank). Hiện chỉ thêm thủ công.
- [ ] Serve `/uploads/pronunciation/**` qua `WebMvcConfigurer.addResourceHandlers` (chung với Module 7 `/uploads/badges/**`); chưa làm trong scope module này.
- [ ] Link "Mock attempt" / preview ngay từ trang list để admin nghe thử reference audio rồi compare giọng học viên — hiện chỉ có audio player inline.

---

### 3.10 MODULE 9 — STUDY SESSION MONITORING (MỚI — read only) ✅ DONE 2026-05-17

**Theo dõi hoạt động học flashcard SM-2.**

#### Route
```
GET    /admin/study-sessions                  → List sessions + filter (user/desk/status)
GET    /admin/study-sessions/{id}             → Chi tiết session (cards reviewed, quality)
```

#### Hiển thị
- User, desk, started_at, completed_at
- Total cards, mastered, again, hard
- XP earned, new words learned
- Biểu đồ phân bố quality (1-5)

#### Đã làm (2026-05-17)
- **Routes (read-only):**
  - `GET /admin/study-sessions` — paged list (size mặc định 20, tối đa 100), filter `status (active|completed)`, `q` (full name / email / firebase UID), `deskId` (UUID).
  - `GET /admin/study-sessions/{id}` — detail: stat cards (Total, XP, New words, Duration), timeline (started/completed), biểu đồ bucket "Again / Hard / Mastered / Chưa review".
- **Repository:** `StudySessionRepository.searchForAdmin(status, keyword, deskId, pageable)` dùng `@EntityGraph` để load user + desk (tránh N+1), `findWithUserAndDeskById` cho trang detail, `countByStatus()` cho thống kê.
- **Quality 1-5 (lưu ý):** schema hiện tại của `StudySession` không lưu quality per-card — chỉ có 3 counter aggregated (`mastered_cards`, `hard_cards`, `again_cards`). UI map:
  - `q 1-2` → bucket **Again** (counter `again_cards`)
  - `q 3` → bucket **Hard** (counter `hard_cards`)
  - `q 4-5` → bucket **Mastered** (counter `mastered_cards`)
  - `total - reviewed` → bucket **Chưa review**

  Có note explicit trong trang detail để admin hiểu giới hạn.

#### Files đã thêm
- `src/main/java/com/kiovant/englishme/repository/StudySessionRepository.java` *(updated — thêm `searchForAdmin`, `findWithUserAndDeskById`, `countByStatus`)*
- `src/main/java/com/kiovant/englishme/dto/AdminStudySessionRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminStudySessionDetail.java` *(mới — kèm nested record `QualityBucket`)*
- `src/main/java/com/kiovant/englishme/service/AdminStudySessionService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminStudySessionController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/study-sessions.jsp` *(mới — list + filter + pagination)*
- `src/main/webapp/WEB-INF/views/admin/study-session-detail.jsp` *(mới — stat cards + timeline + quality bar chart)*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` *(thêm link "Study Sessions")*

#### Đẩy sang giai đoạn sau
- [ ] Quality per-card chính xác — cần thêm bảng `study_card_review (session_id, flashcard_id, quality, reviewed_at)` được insert tại [StudySessionService.review()](src/main/java/com/kiovant/englishme/service/StudySessionService.java#L121). Sau đó detail page chuyển sang đếm theo q=1..5 thật.
- [ ] Lọc theo desk bằng dropdown (hiện chỉ paste UUID). Cần endpoint trả danh sách desk active hoặc gắn `ownerId` user mới chọn được.
- [ ] Biểu đồ thời gian thực hiện trung bình mỗi card (ms) — cần lưu `responseTimeMs` per review (hiện chỉ truyền vào API, không persist).

---

### 3.11 MODULE 10 — HOME DASHBOARD CONTENT (MỚI) ✅ DONE 2026-05-17

**Quản lý nội dung động hiển thị trên Home Mobile.**

#### Route
```
GET    /admin/home-content/word-of-day                    → Quản lý "Từ vựng của ngày"
POST   /admin/home-content/word-of-day                    → Lên lịch từ theo ngày
POST   /admin/home-content/word-of-day/{id}/delete        → Xóa lịch
GET    /admin/home-content/recommendations                → Quản lý gợi ý theo CEFR
POST   /admin/home-content/recommendations                → Tạo gợi ý
POST   /admin/home-content/recommendations/{id}/update    → Sửa
POST   /admin/home-content/recommendations/{id}/delete    → Xóa
GET    /admin/home-content/banners                        → Banner trên home
POST   /admin/home-content/banners                        → Tạo banner + lên lịch
POST   /admin/home-content/banners/{id}/update            → Sửa
POST   /admin/home-content/banners/{id}/delete            → Xóa
POST   /admin/home-content/banners/{id}/image             → Upload ảnh banner (3 MB)
```

#### Đã làm (2026-05-17)
- **Migration V11** (`V11__home_content.sql`):
  - Bảng `home_word_of_day (id, scheduled_date, word_id → vocabulary_word, level, note, created_at)` với unique constraint `(scheduled_date, level)` để cho phép Word of Day khác nhau theo CEFR cùng ngày.
  - Bảng `home_recommendation (id, level, type, title, description, action_url, sort_order, is_active, created_at, updated_at)` — phép admin override block recommendation mặc định đang hard-coded trong [HomeDashboardService.buildRecommendations()](src/main/java/com/kiovant/englishme/service/HomeDashboardService.java#L130).
  - Bảng `home_banner (id, title, image_url, action_url, start_at, end_at, sort_order, is_active, created_at)` — lịch hiển thị banner.
- **Form-style CRUD admin:** mỗi recommendation/banner là 1 row chỉnh inline (form per-row), bấm "Lưu" để update. Banner còn có upload ảnh trực tiếp lưu vào `uploads/banners/` (giới hạn 3 MB, ext: png/jpg/jpeg/webp/gif).
- **Validation tại service:**
  - `level` whitelist: A1–C2 (uppercase). `level` ở Word of Day có thể null → áp dụng cho mọi CEFR.
  - `type` whitelist: `vocabulary | grammar | pronunciation | exercise | test`.
  - Banner `endAt` phải sau `startAt`; `startAt` bắt buộc.
- **3 trang JSP** đều có tab điều hướng (Word of Day / Recommendations / Banners) để admin chuyển nhanh giữa các nội dung Home.
- **Lưu ý chưa wire vào Mobile API:** [HomeDashboardService](src/main/java/com/kiovant/englishme/service/HomeDashboardService.java) vẫn dùng logic mặc định (random vocabulary word theo CEFR + recommendations hard-code). Admin tạo data nhưng mobile chưa đọc — sẽ wire ở bước sau (xem "Đẩy sang giai đoạn sau").

#### Files đã thêm
- `src/main/resources/db/migration/V11__home_content.sql` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/HomeWordOfDay.java` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/HomeRecommendation.java` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/HomeBanner.java` *(mới)*
- `src/main/java/com/kiovant/englishme/repository/HomeWordOfDayRepository.java` *(mới)*
- `src/main/java/com/kiovant/englishme/repository/HomeRecommendationRepository.java` *(mới)*
- `src/main/java/com/kiovant/englishme/repository/HomeBannerRepository.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminWordOfDayRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminRecommendationRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminBannerRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/service/AdminHomeContentService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminHomeContentController.java` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/home-word-of-day.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/home-recommendations.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/home-banners.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` *(thêm link "Home Content")*

#### Đẩy sang giai đoạn sau
- [ ] Wire `HomeDashboardService` đọc từ 3 bảng mới — fallback về logic cũ nếu không có data cho ngày/CEFR hiện tại. Cần thêm method `findActiveBanners(now)` ở repository (filter `is_active=TRUE AND start_at <= now AND (end_at IS NULL OR end_at >= now)`).
- [ ] Trang Word of Day: thêm filter dropdown theo level để picker từ vựng gọn hơn (hiện list toàn bộ).
- [ ] Recommendation: cho phép drag-drop sắp xếp `sort_order` thay vì gõ số.
- [ ] Banner: preview thumbnail full-size trên modal khi click ảnh; thêm endpoint `GET /api/home/banners` trả danh sách banner đang active cho mobile.

---

### 3.12 MODULE 11 — ANNOUNCEMENT & PUSH NOTIFICATION (MỚI) ✅ DONE 2026-05-17

**Gửi thông báo cho học viên qua FCM.**

#### Route admin
```
GET    /admin/notifications                       → Lịch sử push
POST   /admin/notifications/broadcast             → Gửi toàn bộ user
POST   /admin/notifications/targeted              → Gửi theo segment (cefr | inactive)
GET    /admin/notifications/{id}/stats            → Chi tiết stats từng push
GET    /admin/announcements                       → List announcement
POST   /admin/announcements                       → Tạo banner trong app (không push)
POST   /admin/announcements/{id}/update           → Sửa
POST   /admin/announcements/{id}/delete           → Xóa
```

#### Route mobile (mới)
```
POST   /api/users/me/devices                      → Register device token (body: {token, platform})
DELETE /api/users/me/devices                      → Unregister token
GET    /api/announcements/active                  → Mobile lấy announcement đang active
```

#### Đã làm (2026-05-17)
- **Migration V12** (`V12__notifications.sql`):
  - `user_device_token (id, user_id, token UNIQUE, platform, created_at, last_used_at)` — 1 user có nhiều device (Android/iOS/Web). Token unique để upsert.
  - `admin_notification (id, title, body, image_url, action_url, segment_type, segment_value, target_count, success_count, failure_count, sent_by_email, sent_at)` — history mỗi lần push.
  - `app_announcement (id, title, body, severity, start_at, end_at, is_active, created_by_email, created_at)` — banner in-app.
- **FCM gửi đa thiết bị** ([FcmPushService](src/main/java/com/kiovant/englishme/service/FcmPushService.java)):
  - Dùng `FirebaseMessaging.sendEachForMulticast` (FCM giới hạn 500 token/batch — tự chia batch).
  - Auto cleanup token invalid (`UNREGISTERED`, `INVALID_ARGUMENT`) khỏi `user_device_token` → tránh false-positive failure cho lần gửi sau.
  - Notification payload kèm `data.action_url` cho deep-link client xử lý.
- **Segment hỗ trợ** ([AdminNotificationService](src/main/java/com/kiovant/englishme/service/AdminNotificationService.java)):
  - `broadcast` — tất cả token active.
  - `cefr` (A1..C2) — JPQL filter `u.cefrLevel = :level`.
  - `inactive` — value là số ngày, filter `lastActiveDate < today - N` (NULL coi như inactive).
  - `custom` — placeholder, raise 400 nếu được gọi (cần userIds — đẩy sang giai đoạn sau).
- **Audit nhẹ:** mọi lần gửi đều ghi `sent_by_email` từ `session.ADMIN_EMAIL`; mọi announcement ghi `created_by_email`.
- **Admin UI** 3 trang JSP:
  - `notifications.jsp` — 2 form (broadcast / targeted) + bảng lịch sử (target/OK/fail/segment).
  - `notification-stats.jsp` — stat cards (Target, Success, Fail, Deliver-rate), nội dung gốc, có note "open/click chưa wire".
  - `announcements.jsp` — form-style CRUD inline mỗi row (giống Module 10).
- **Sidebar:** thêm 2 link "Push Notifications" và "Announcements".

#### Files đã thêm
- `src/main/resources/db/migration/V12__notifications.sql` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/UserDeviceToken.java` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/AdminNotification.java` *(mới)*
- `src/main/java/com/kiovant/englishme/entity/AppAnnouncement.java` *(mới)*
- `src/main/java/com/kiovant/englishme/repository/UserDeviceTokenRepository.java` *(mới — có sẵn 3 query: all/cefr/inactive)*
- `src/main/java/com/kiovant/englishme/repository/AdminNotificationRepository.java` *(mới)*
- `src/main/java/com/kiovant/englishme/repository/AppAnnouncementRepository.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminNotificationRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/AdminAnnouncementRow.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/PushSendResult.java` *(mới)*
- `src/main/java/com/kiovant/englishme/dto/DeviceTokenRequest.java` *(mới)*
- `src/main/java/com/kiovant/englishme/service/FcmPushService.java` *(mới — multicast + cleanup invalid)*
- `src/main/java/com/kiovant/englishme/service/AdminNotificationService.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/AdminNotificationController.java` *(mới)*
- `src/main/java/com/kiovant/englishme/controller/DeviceTokenApiController.java` *(mới — POST/DELETE `/api/users/me/devices`)*
- `src/main/java/com/kiovant/englishme/controller/AnnouncementApiController.java` *(mới — GET `/api/announcements/active`)*
- `src/main/webapp/WEB-INF/views/admin/notifications.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/notification-stats.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/announcements.jsp` *(mới)*
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` *(thêm link "Push Notifications" + "Announcements")*

#### Đẩy sang giai đoạn sau
- [ ] Job queue async (Spring `@Async` + ThreadPool) cho push hàng loạt — hiện gửi sync trong request, push 10k+ user sẽ timeout HTTP. Cần wrap `fcm.sendToTokens()` vào `@Async` và trả về 202 Accepted ngay, update stats khi xong.
- [ ] Open-rate / click-rate thật — cần endpoint `POST /api/notifications/{id}/opened` và `POST /api/notifications/{id}/clicked` (client tracking), thêm 2 cột `open_count`, `click_count`.
- [ ] Segment `custom` — UI chọn nhiều user qua autocomplete, lưu `segment_value` dạng JSON array userIds.
- [ ] Schedule push gửi sau (cron) — bảng `scheduled_notification` + cron job đọc.
- [ ] Dedupe token theo `user_id + token` (hiện UNIQUE token toàn cục — đã đúng cho FCM nhưng nếu cùng device 2 user login thì user cũ mất token → cần policy rõ).

---

### 3.13 MODULE 12 — SYSTEM CONFIGURATION (MỚI)

**Cấu hình hệ thống không cần đụng `application.yaml`.**

#### Route
```
GET    /admin/config                          → List configs
PUT    /admin/config/{key}                    → Update value
```

#### Configs cần quản lý qua UI
- `xp.per_study_card_correct` = 2
- `xp.per_study_card_perfect` = 3
- `xp.per_exercise_correct` = 5
- `xp.per_test_correct` = 10
- `streak.grace_hours` = 6 (giờ ân hạn để giữ streak)
- `pronunciation.rate_limit_per_minute` = 30
- `pronunciation.provider` = `google` | `azure`
- `chat.daily_limit_free` = 20
- `chat.daily_limit_premium` = 200
- `feature.exercise_enabled` = true
- `feature.chat_enabled` = true
- `maintenance.mode` = false
- `maintenance.message` = "..."
- API keys (masked, chỉ SUPER_ADMIN sửa):
  - `DEEPSEEK_API_KEY`
  - `GOOGLE_CLOUD_PROJECT_ID`
  - `FIREBASE_SERVICE_ACCOUNT_PATH`

#### Cần backend
- Bảng `app_config` (key, value, type, description, updated_at, updated_by)
- `@ConfigurationPropertiesRefresh` hoặc cache Caffeine + invalidation
- Validation theo `type` (boolean / int / string / json)

---

### 3.14 MODULE 13 — AUDIT LOG & ADMIN MANAGEMENT (MỚI)

**Bảo mật & traceability.**

#### Route
```
GET    /admin/audit-log                       → Tất cả action của admin (filter user/action/date)
GET    /admin/admins                          → List admin accounts
POST   /admin/admins                          → Tạo admin
PUT    /admin/admins/{id}/role                → Đổi role (SUPER_ADMIN/EDITOR/VIEWER)
POST   /admin/admins/{id}/reset-password      → Reset password
DELETE /admin/admins/{id}                     → Vô hiệu hóa admin
```

#### Audit log capture
- Mọi `POST/PUT/DELETE` trong `/admin/**`
- Trường: `admin_id`, `action`, `entity_type`, `entity_id`, `before_value`, `after_value`, `ip`, `user_agent`, `timestamp`
- Có thể implement bằng Spring AOP / `@EventListener`

#### Role-based access
- `SUPER_ADMIN`: tất cả
- `EDITOR`: CRUD nội dung, không thấy config/audit/admin management
- `VIEWER`: read-only

---

### 3.15 MODULE 14 — REPORTS & EXPORTS (MỚI)

**Xuất báo cáo theo nhu cầu kinh doanh.**

#### Route
```
GET    /admin/reports                         → Trang chính
POST   /admin/reports/user-activity           → Custom report (date range, filters) → CSV/Excel
POST   /admin/reports/content-usage           → Báo cáo nội dung được học
POST   /admin/reports/pronunciation           → Báo cáo phát âm
POST   /admin/reports/revenue                 → (nếu có) thanh toán
GET    /admin/reports/scheduled               → Báo cáo định kỳ (gửi email)
```

#### Format
- CSV (mặc định)
- Excel (Apache POI)
- PDF (iText / OpenPDF) — báo cáo định kỳ

---

### 3.16 MODULE 15 — CONTENT MODERATION (MỚI — nếu có UGC)

**Nếu user có thể tạo desk public / comment, cần moderation.**

Hiện tại `Desk` có `owner` private — nếu có public sharing trong tương lai cần module này. **Tạm thời chưa cần.**

---

## 4. PRIORITY ROADMAP (thứ tự triển khai)

| Ưu tiên | Module | Effort | Tác động |
|---------|--------|--------|----------|
| **P0** | Dashboard Analytics (charts + KPI) | 3 ngày | Cao — admin nhìn ra sức khỏe ngay |
| **P0** | Vocabulary CRUD | 4 ngày | Cao — module mobile đã dùng |
| **P0** | Grammar CRUD (upgrade) | 3 ngày | Cao — nội dung lõi |
| **P1** | User Detail page | 2 ngày | Cao — debug user support |
| **P1** | Exercise Bank CRUD | 3 ngày | Trung — gameplay phụ thuộc |
| **P1** | Test Bank CRUD | 3 ngày | Trung |
| **P1** | Badge Management | 2 ngày | Trung |
| **P2** | System Configuration | 3 ngày | Cao — giảm phụ thuộc deploy |
| **P2** | Audit Log + Admin Roles | 4 ngày | Cao — bảo mật |
| **P2** | Pronunciation Exercise CRUD | 2 ngày | Trung |
| **P3** | Study Session monitor | 2 ngày | Thấp — read only |
| **P3** | Home Content (Word of Day) | 2 ngày | Trung |
| **P3** | Push Notification | 4 ngày | Trung — cần FCM setup |
| **P3** | Reports & Exports | 3 ngày | Trung |

**Tổng effort ước tính: ~40 ngày công** cho 1 dev full-stack.

---

## 5. TECH STACK GỢI Ý CHO ADMIN UI

### Hiện tại (giữ)
- **JSP + Tailwind CSS** — đơn giản, đã có sườn
- **Material Symbols Icons**

### Cần thêm
- **Chart.js** (CDN) — cho biểu đồ dashboard
- **TinyMCE / Quill** — rich text editor cho grammar lesson
- **DataTables.js** (CDN) — sort/filter/paginate client-side cho bảng nhỏ
- **Alpine.js** (CDN) — interactivity nhẹ thay React
- **HTMX** (tùy chọn) — partial reload, không cần full SPA
- **Dropzone.js** — upload file (audio, icon)

### Hoặc rewrite (lựa chọn dài hạn)
- **React + Vite + shadcn/ui** — SPA tách biệt, gọi `/admin/api/**`
- **Refine.dev** — admin framework chuyên dụng cho React
- **Hilla (Vaadin)** — tích hợp tốt Spring Boot

> **Khuyến nghị:** Giai đoạn 1 dùng JSP + Tailwind + Alpine + HTMX để tăng tốc. Sau khi ổn định mới rewrite SPA nếu cần.

---

## 6. DATABASE MIGRATION CẦN THÊM

```sql
-- V11: Audit log
CREATE TABLE admin_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL,
    admin_email VARCHAR(255),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id VARCHAR(100),
    before_value JSONB,
    after_value JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_audit_log_admin ON admin_audit_log(admin_id, created_at DESC);
CREATE INDEX idx_audit_log_entity ON admin_audit_log(entity_type, entity_id);

-- V12: Admin accounts + roles
CREATE TABLE admin_account (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(20) NOT NULL DEFAULT 'VIEWER', -- SUPER_ADMIN | EDITOR | VIEWER
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- V13: App config
CREATE TABLE app_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    value_type VARCHAR(20) NOT NULL, -- boolean | integer | string | json
    description TEXT,
    is_secret BOOLEAN NOT NULL DEFAULT false, -- masked when read by non-SUPER_ADMIN
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES admin_account(id)
);

-- Seed configs cơ bản
INSERT INTO app_config (config_key, config_value, value_type, description) VALUES
  ('xp.per_study_card_correct', '2', 'integer', 'XP cấp khi trả lời flashcard quality>=3'),
  ('xp.per_study_card_perfect', '3', 'integer', 'XP cấp khi quality=5'),
  ('xp.per_exercise_correct', '5', 'integer', 'XP cho mỗi câu exercise đúng'),
  ('xp.per_test_correct', '10', 'integer', 'XP cho mỗi câu test đúng'),
  ('streak.grace_hours', '6', 'integer', 'Số giờ ân hạn để giữ streak'),
  ('feature.chat_enabled', 'true', 'boolean', 'Bật/tắt tính năng chat AI'),
  ('feature.exercise_enabled', 'true', 'boolean', 'Bật/tắt exercise'),
  ('maintenance.mode', 'false', 'boolean', 'Bật chế độ bảo trì'),
  ('maintenance.message', 'Hệ thống đang bảo trì, vui lòng quay lại sau.', 'string', 'Thông báo bảo trì');

-- V14: Push notification
CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    body TEXT,
    target_type VARCHAR(50) NOT NULL, -- broadcast | segment | individual
    target_filter JSONB, -- {"cefr": "A1", "inactive_days": 7}
    sent_count INTEGER DEFAULT 0,
    delivered_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    sent_by UUID REFERENCES admin_account(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending | sent | failed
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Thêm FCM token vào users
ALTER TABLE users ADD COLUMN fcm_token TEXT;
ALTER TABLE users ADD COLUMN fcm_token_updated_at TIMESTAMP;

-- V15: Word of Day scheduler (optional)
CREATE TABLE word_of_day (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_date DATE NOT NULL UNIQUE,
    word_id UUID NOT NULL REFERENCES vocabulary_word(id),
    cefr_target VARCHAR(10), -- nullable = all levels
    created_by UUID REFERENCES admin_account(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 7. SIDEBAR MỚI ĐỀ XUẤT

```
Admin Panel
├── 📊 Dashboard
├── 👥 Users
│   ├── All Users
│   └── Admin Accounts        (SUPER_ADMIN only)
├── 📚 Content
│   ├── Vocabulary
│   ├── Grammar
│   ├── Pronunciation Exercises
│   ├── Exercise Bank
│   ├── Test Bank
│   └── Desks & Flashcards
├── 🏆 Gamification
│   ├── Badges
│   └── XP & Streak Settings
├── 📈 Monitoring
│   ├── Study Sessions
│   ├── Placement Tests
│   ├── Exercise Sessions
│   └── User Tests
├── 📢 Engagement
│   ├── Push Notifications
│   ├── Announcements
│   └── Word of Day
├── 📊 Reports
│   ├── User Activity
│   ├── Content Usage
│   └── Exports
└── ⚙️ System
    ├── Configuration         (SUPER_ADMIN only)
    ├── Audit Log
    └── Health & Status
```

---

## 8. KẾT LUẬN

### Tóm tắt
Admin panel hiện tại **mới chỉ đáp ứng ~25% nhu cầu quản trị** — đủ cho MVP nhưng không thể vận hành sản phẩm lâu dài. Để admin **"điều khiển mọi thứ trên web"** như yêu cầu, cần triển khai **15 module** với:
- **8 module CRUD nội dung mới** (vocab, grammar upgrade, exercise, test, badge, pronunciation ex, home content, admin accounts)
- **3 module analytics & monitoring** (dashboard charts, user detail, study session monitor)
- **4 module hệ thống** (config, audit log, notification, reports)

### Lợi ích sau khi hoàn thành
1. **Team nội dung tự quản trị 100%** — không cần dev support cho việc thêm/sửa từ vựng, ngữ pháp, bài tập
2. **Đội vận hành thấy ngay vấn đề** — biểu đồ real-time, top-N user/content
3. **Customer support nhanh** — mở user detail là thấy ngay lịch sử + có thể reset/grant XP
4. **Marketing chủ động** — gửi push notification, lên lịch word of day, cấu hình XP boost
5. **Bảo mật & compliance** — audit log đầy đủ, phân quyền rõ ràng
6. **Giảm risk deploy** — đổi config qua UI, không cần redeploy

### Bước kế tiếp đề xuất
1. Review tài liệu này, chọn ưu tiên P0/P1/P2/P3
2. Quyết định tech stack (JSP+Alpine+HTMX **hoặc** rewrite React)
3. Tạo migration V11-V15
4. Bắt đầu từ **Dashboard Analytics** và **Vocabulary CRUD** (tác động cao, effort vừa)

---

## 9. CHANGELOG TRIỂN KHAI

### 2026-05-17 — Module 1: Dashboard Analytics (P0) ✅

**Phạm vi hoàn thành (giai đoạn 1, không cần migration mới):**

#### A. KPI cards — hoàn thành
- ✅ Tổng số user, user mới hôm nay, DAU/WAU/MAU
- ✅ Retention 7d / 30d (DAU/WAU vs tổng user)
- ✅ Số session học hôm nay (cộng dồn study + exercise + test)
- ✅ Tổng XP cấp ra hôm nay (sum `xp_history.xp` theo ngày)
- ✅ Streak trung bình (AVG `users.current_streak` > 0)
- ✅ Active today (đã đổi từ "chỉ đếm pronunciation attempt" sang `xp_history` — coi bất kỳ hoạt động có XP là active)

#### B. Biểu đồ (Chart.js v4 qua CDN) — hoàn thành
- ✅ Line chart user mới theo ngày (14 ngày gần nhất)
- ✅ Line chart active users theo ngày (14 ngày, từ `xp_history`)
- ✅ Bar chart phân bố user theo CEFR (A1/A2/B1/B2/C1/C2 + Unknown)
- ✅ Doughnut chart phân bố nội dung học 30 ngày (Vocabulary/Exercise/Test/Pronunciation)
- ✅ Bar chart XP cấp theo nguồn trong 7 ngày (study/exercise/test)
- ✅ Heatmap hoạt động giờ × ngày-trong-tuần (30 ngày, study_session — render bằng HTML/CSS table, không dùng plugin ngoài)

#### C. Top-N tables — hoàn thành
- ✅ Top 10 user có streak cao nhất
- ✅ Top 10 user có XP cao nhất
- ✅ Top 10 từ phát âm sai nhiều nhất (từ `pronunciation_attempt`, GROUP BY reference_text, HAVING COUNT ≥ 3, ORDER BY AVG score ASC)
- ✅ Top 10 user inactive ≥ 7 ngày (sắp churn)
- ⚠️ Top 10 từ vựng học nhiều / top grammar truy cập nhiều — đang trả về danh sách placeholder; cần bảng `flashcard_study_count` / `grammar_view_count` ở giai đoạn sau

#### D. System Health — phần khung
- ✅ Khung UI hiển thị 6 chỉ số: Firebase / Pronunciation / Chat / DB size / DB connections / Audio disk
- ⚠️ Hiện trả về "OK" tĩnh + số 0 — cần wire vào health check thật sự (giai đoạn 2)

**Các file đã thêm/sửa:**

| File | Loại | Mô tả |
|------|------|-------|
| `src/main/java/com/kiovant/englishme/dto/DashboardAnalytics.java` | NEW | Record chứa KpiSummary, TimeSeries, NamedCount, TopUserRow, TopFlashcardRow, TopPronunciationMissRow, InactiveUserRow, SystemHealth |
| `src/main/java/com/kiovant/englishme/service/DashboardAnalyticsService.java` | NEW | Service tổng hợp dữ liệu cho dashboard từ 8 repository |
| `src/main/java/com/kiovant/englishme/repository/UserRepository.java` | MODIFIED | Thêm `countCreatedBetween`, `countNewUsersByDaySince`, `countByCefrLevel`, `averageCurrentStreak`, `findTopByStreak`, `findTopByXp`, `findInactiveUsers` |
| `src/main/java/com/kiovant/englishme/repository/PronunciationAttemptRepository.java` | MODIFIED | Thêm `countDistinctUsersSince`, `findTopMissedWords` |
| `src/main/java/com/kiovant/englishme/repository/StudySessionRepository.java` | MODIFIED | Thêm `countSince`, `countDistinctUsersSince`, `heatmapSince` (native query Postgres EXTRACT DOW/HOUR) |
| `src/main/java/com/kiovant/englishme/repository/ExerciseSessionRepository.java` | MODIFIED | Thêm `countSince`, `countDistinctUsersSince` |
| `src/main/java/com/kiovant/englishme/repository/UserTestSessionRepository.java` | MODIFIED | Thêm `countSince`, `countDistinctUsersSince` |
| `src/main/java/com/kiovant/englishme/repository/XpHistoryRepository.java` | MODIFIED | Thêm `sumXpOnDate`, `countActiveUsersBetween`, `activeUsersByDayBetween` |
| `src/main/java/com/kiovant/englishme/controller/AdminViewController.java` | MODIFIED | Inject `DashboardAnalyticsService` + truyền `analytics` vào model |
| `src/main/webapp/WEB-INF/views/admin/dashboard.jsp` | REWRITTEN | Layout mới: 2 hàng KPI (8 thẻ) + 2 hàng chart + heatmap + 4 bảng top-N + system health. Dùng Chart.js v4 CDN |

**Build status:** `./mvnw clean compile` → BUILD SUCCESS (143 source files, 7.5s).

**Phần còn nợ cho giai đoạn sau (không thuộc P0):**
- Lưu vết "lượt học flashcard" và "lượt xem bài grammar" vào DB để Top-N từ/grammar có dữ liệu thật.
- Wire System Health vào thật: ping Firebase, đo quota Google Pronunciation, ping DeepSeek, query `pg_database_size`, `pg_stat_activity`, đo disk.
- Bộ lọc khoảng thời gian (7d / 30d / 90d) cho các biểu đồ.
- Export CSV cho mỗi bảng top-N.

### 2026-05-17 — Module 2: Vocabulary Management (P0) ✅

**Phạm vi hoàn thành (giai đoạn 1, không cần migration mới — dùng schema V9 đã có):**

#### A. Topic CRUD — hoàn thành
- ✅ `GET  /admin/vocabulary` — list topics có filter theo CEFR + keyword (tìm trong `name` / `name_en`), hiển thị icon, màu, sort order, số từ trong topic.
- ✅ `POST /admin/vocabulary/topics` — tạo topic với validation: `name`, `name_en` bắt buộc; `level` phải thuộc A1–C2; `color_hex` phải dạng `#RRGGBB`; `sort_order` tự sinh = `MAX + 1` nếu để trống.
- ✅ `POST /admin/vocabulary/topics/{id}/update` — sửa topic (dùng POST + path `/update` để tương thích form HTML, không cần JS PUT).
- ✅ `POST /admin/vocabulary/topics/{id}/delete` — xóa topic + toàn bộ từ trong topic (có confirm dialog ở UI; DB cascade vẫn bảo vệ).

#### B. Word CRUD — hoàn thành
- ✅ `GET  /admin/vocabulary/topics/{id}` — chi tiết topic + list từ có search (`q` match `word` / `definitionVi` / `definitionEn` case-insensitive).
- ✅ `POST /admin/vocabulary/topics/{id}/words` — thêm từ; chặn duplicate trong cùng topic (case-insensitive); validate level A1–C2.
- ✅ `POST /admin/vocabulary/words/{id}/update` — sửa từ; nếu đổi `word` sang dạng đã có trong topic → trả 409.
- ✅ `POST /admin/vocabulary/words/{id}/delete` — xóa từ.
- ✅ Preview audio ngay trên list (HTML5 `<audio controls preload="none">`).
- ✅ Duplicate detection: query `GROUP BY word HAVING COUNT > 1` theo topic → đánh badge "Trùng" trên từng dòng.

#### C. Bulk import & export — hoàn thành
- ✅ `POST /admin/vocabulary/topics/{id}/import` — import từ JSON. Hỗ trợ 2 dạng payload: `[{...}, {...}]` hoặc `{"words": [...]}`. Mỗi item cho phép cả camelCase và snake_case (`definitionVi` / `definition_vi`, `partOfSpeech` / `part_of_speech`, `audioUrl` / `audio_url`, …). Nếu thiếu `level` thì fallback theo `topic.level`. Báo cáo: `totalRows`, `inserted`, `skipped`, list error (giới hạn 5 lỗi đầu trên UI).
- ✅ `GET  /admin/vocabulary/topics/{id}/export` — export CSV đầy đủ 9 cột (`word`, `pronunciation`, `part_of_speech`, `definition_vi`, `definition_en`, `example_sentence`, `example_translation`, `level`, `audio_url`) — kèm BOM UTF-8 để Excel mở không lỗi font.

#### D. UI/UX
- ✅ Sidebar: thêm entry "Vocabulary" với icon `translate`; đổi tên entry cũ thành "Desk / Flashcard" cho rõ nghĩa.
- ✅ Layout JSP đồng bộ style với các trang admin khác (Tailwind + Material Symbols, modal create/edit, banner success/error).
- ✅ Form modal cho create topic, edit topic, create word, edit word, import JSON — đều có ESC + click backdrop để đóng.

**Các file đã thêm/sửa:**

| File | Loại | Mô tả |
|------|------|-------|
| `src/main/java/com/kiovant/englishme/dto/AdminVocabularyTopicRow.java` | NEW | Record cho row topic trong admin list (kèm `wordCount`) |
| `src/main/java/com/kiovant/englishme/dto/AdminVocabularyWordRow.java` | NEW | Record cho row word (kèm flag `duplicate`) |
| `src/main/java/com/kiovant/englishme/dto/CreateVocabularyTopicRequest.java` | NEW | DTO request tạo topic |
| `src/main/java/com/kiovant/englishme/dto/UpdateVocabularyTopicRequest.java` | NEW | DTO request sửa topic |
| `src/main/java/com/kiovant/englishme/dto/CreateVocabularyWordRequest.java` | NEW | DTO request tạo word |
| `src/main/java/com/kiovant/englishme/dto/UpdateVocabularyWordRequest.java` | NEW | DTO request sửa word |
| `src/main/java/com/kiovant/englishme/dto/VocabularyImportResult.java` | NEW | DTO kết quả import (total/inserted/skipped/errors) |
| `src/main/java/com/kiovant/englishme/repository/VocabularyTopicRepository.java` | MODIFIED | Thêm `searchTopics(level, keyword)`, `maxSortOrder()` |
| `src/main/java/com/kiovant/englishme/repository/VocabularyWordRepository.java` | MODIFIED | Thêm `searchWordsByTopic`, `existsByTopic_IdAndWordIgnoreCase`, `findByTopicAndWordIgnoreCase`, `findDuplicateWordsByTopic`, `countByTopic_Id` |
| `src/main/java/com/kiovant/englishme/service/AdminVocabularyService.java` | NEW | Service CRUD đầy đủ + import JSON + export CSV + validation + duplicate detection |
| `src/main/java/com/kiovant/englishme/controller/AdminVocabularyController.java` | NEW | Controller MVC cho `/admin/vocabulary/**` (10 endpoint) |
| `src/main/webapp/WEB-INF/views/admin/vocabulary.jsp` | NEW | Trang list topics + modal create/edit topic |
| `src/main/webapp/WEB-INF/views/admin/vocabulary-topic-form-fields.jspf` | NEW | Fragment dùng chung cho create topic form |
| `src/main/webapp/WEB-INF/views/admin/vocabulary-topic.jsp` | NEW | Trang chi tiết topic + list words + modal create/edit word + modal import JSON |
| `src/main/webapp/WEB-INF/views/admin/vocabulary-word-form-fields.jspf` | NEW | Fragment dùng chung cho create word form |
| `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` | MODIFIED | Thêm menu entry "Vocabulary" + đổi tên entry desks thành "Desk / Flashcard" |

**Build status:** `./mvnw clean compile -DskipTests` → BUILD SUCCESS (152 source files, 8.4s).

**Phần còn nợ cho giai đoạn sau (không thuộc P0):**
- Bulk edit level / topic cho nhiều từ cùng lúc (multi-select + form batch update).
- Auto-generate IPA: tích hợp dictionary API (Free Dictionary API, Oxford API) — sinh `pronunciation` tự động khi tạo từ.
- Upload audio file: hiện chỉ nhận `audio_url` dạng string; cần upload thật → lưu vào storage (S3/MinIO/disk) → sinh URL.
- Import CSV (hiện mới import JSON); cần parser CSV với header mapping.
- Soft delete (hiện hard delete topic và word). Cần cột `deleted_at` ở V9 schema.
- Pagination cho list từ khi topic > 200 từ (hiện đang load all theo topic).

### 2026-05-17 — Module 3: Grammar Management UPGRADE (P0) ✅

**Phạm vi hoàn thành (giai đoạn 1, không cần migration mới — dùng schema V6 đã có):**

#### A. Topic CRUD — hoàn thành
- ✅ `GET  /admin/grammar` — list topics có filter theo CEFR + keyword (tìm trong `title` / `category` / `slug`), hiển thị slug, danh mục, CEFR, sort order, số bài học.
- ✅ `POST /admin/grammar/topics` — tạo topic với validation: `slug` (regex `[a-z0-9][a-z0-9_-]*`, unique), `category` bắt buộc, `level` thuộc A1–C2, `title` bắt buộc; chặn trùng cặp `(category, level)`; `sort_order` tự sinh = `MAX + 1` nếu để trống.
- ✅ `POST /admin/grammar/topics/{id}/update` — sửa topic (dùng POST + path `/update` cho tương thích form HTML, không cần JS PUT).
- ✅ `POST /admin/grammar/topics/{id}/delete` — xóa topic + cascade toàn bộ lesson + exercise bên trong (có confirm dialog ở UI; DB cascade `ON DELETE CASCADE` bảo vệ kép).

#### B. Lesson CRUD — hoàn thành
- ✅ `GET  /admin/grammar/topics/{id}` — chi tiết topic + list lesson (kèm `exerciseCount`/lesson).
- ✅ `POST /admin/grammar/topics/{id}/lessons` — thêm lesson với validation: `sourceId` bắt buộc và unique toàn hệ thống (ràng buộc DB), `title` bắt buộc; auto-fill `sort_order = MAX + 1` trong cùng topic.
- ✅ `POST /admin/grammar/lessons/{id}/update` — sửa lesson; nếu đổi `sourceId` sang dạng đã có → trả 409.
- ✅ `POST /admin/grammar/lessons/{id}/delete` — xóa lesson + cascade exercise.
- ✅ Form lesson hỗ trợ 4 trường JSONB: `formulas` (array of objects), `keyWords` (array of strings), `examples` (array of objects), `commonMistakes` (array of objects) — validate parse JSON ở server, lỗi parse trả 400 với tên trường cụ thể.

#### C. Exercise CRUD — hoàn thành
- ✅ `GET  /admin/grammar/lessons/{id}` — chi tiết lesson (đầy đủ 4 JSONB pretty-printed) + list exercise.
- ✅ `POST /admin/grammar/lessons/{id}/exercises` — thêm exercise; `content` (JSON object) bắt buộc; `exerciseType` dropdown 7 loại gợi ý (`multiple_choice`, `fill_blank`, `rearrange`, `translate`, `match`, `true_false`, `free_text`) — vẫn cho nhập tự do; auto-fill `exercise_order = MAX + 1` trong lesson.
- ✅ `POST /admin/grammar/exercises/{id}/update` — sửa exercise (form modal chia sẻ với form create, đổi action khi edit).
- ✅ `POST /admin/grammar/exercises/{id}/delete` — xóa exercise.

#### D. Bulk import JSON — hoàn thành
- ✅ `POST /admin/grammar/import` — import lồng nhau 3 cấp **topic → lesson → exercise** trong 1 lần. Hỗ trợ payload mảng `[{topic}, ...]` hoặc object `{"topics": [...]}`.
- ✅ Idempotent: topic đã tồn tại theo `slug` được tái sử dụng (không tạo lại nhưng vẫn import lesson con); lesson đã tồn tại theo `sourceId` thì skip toàn bộ lesson + exercise con để tránh trùng.
- ✅ Báo cáo chi tiết: `topicsInserted/totalTopics/topicsSkipped`, `lessonsInserted/totalLessons/lessonsSkipped`, `exercisesInserted/totalExercises`, kèm list error (giới hạn 5 lỗi đầu trên UI flash message).
- ✅ Trên giao diện list topic có nút **"Import JSON"** mở modal lớn (max-w-2xl) kèm hướng dẫn ngắn về cấu trúc payload.

#### E. UI/UX & bug fix
- ✅ JSP `admin/grammar.jsp`: viết lại từ trang chỉ-xem thành list CRUD đầy đủ với modal create/edit, nút import, filter, action menu (Xem / Sửa / Xóa). Đồng bộ style với `vocabulary.jsp`.
- ✅ JSP `admin/grammar-lessons.jsp`: thêm nút "Thêm bài học" + modal lớn (max-w-3xl, max-h-90vh + overflow-y) đủ chỗ 9 trường lesson; mỗi dòng có nút Xóa kèm confirm.
- ✅ JSP `admin/grammar-lesson-detail.jsp`: cho phép sửa lesson tại chỗ (modal), CRUD exercise inline. Sửa **bug cũ**: JSP cũ gọi `lesson.formulas()` như String trong khi entity trả về `List<Map<String, Object>>` — đã đổi sang dùng `*Json` (string đã được service pretty-print) để render đúng trong `<pre>`.
- ✅ Modal có ESC + click backdrop để đóng (script dùng pattern `bindModal` đồng bộ với các trang khác).
- ✅ Sidebar đã có sẵn entry "Grammar" — không cần đổi.

#### F. Refactor controller cũ
- ✅ Xóa 3 route grammar trong [AdminViewController.java](src/main/java/com/kiovant/englishme/controller/AdminViewController.java) (`GET /admin/grammar`, `GET /admin/grammar/topics/{id}`, `GET /admin/grammar/lessons/{id}`) — đã chuyển sang `AdminGrammarController` riêng biệt.
- ✅ Xóa dependency `GrammarService` không còn dùng khỏi `AdminViewController` (constructor + field + import). `GrammarService` vẫn được giữ để phục vụ API mobile `/api/grammar/**`.

**Các file đã thêm/sửa:**

| File | Loại | Mô tả |
|------|------|-------|
| [AdminGrammarTopicRow.java](src/main/java/com/kiovant/englishme/dto/AdminGrammarTopicRow.java) | NEW | Record cho row topic admin (kèm `lessonCount`) |
| [AdminGrammarLessonRow.java](src/main/java/com/kiovant/englishme/dto/AdminGrammarLessonRow.java) | NEW | Record cho row lesson (kèm `exerciseCount`) |
| [AdminGrammarExerciseRow.java](src/main/java/com/kiovant/englishme/dto/AdminGrammarExerciseRow.java) | NEW | Record cho row exercise (kèm `contentJson` pretty-printed) |
| [AdminGrammarLessonDetail.java](src/main/java/com/kiovant/englishme/dto/AdminGrammarLessonDetail.java) | NEW | DTO chi tiết lesson cho admin (4 trường JSONB dưới dạng pretty JSON string + danh sách exercise) |
| [CreateGrammarTopicRequest.java](src/main/java/com/kiovant/englishme/dto/CreateGrammarTopicRequest.java) | NEW | DTO tạo topic |
| [UpdateGrammarTopicRequest.java](src/main/java/com/kiovant/englishme/dto/UpdateGrammarTopicRequest.java) | NEW | DTO sửa topic |
| [CreateGrammarLessonRequest.java](src/main/java/com/kiovant/englishme/dto/CreateGrammarLessonRequest.java) | NEW | DTO tạo lesson |
| [UpdateGrammarLessonRequest.java](src/main/java/com/kiovant/englishme/dto/UpdateGrammarLessonRequest.java) | NEW | DTO sửa lesson |
| [CreateGrammarExerciseRequest.java](src/main/java/com/kiovant/englishme/dto/CreateGrammarExerciseRequest.java) | NEW | DTO tạo exercise |
| [UpdateGrammarExerciseRequest.java](src/main/java/com/kiovant/englishme/dto/UpdateGrammarExerciseRequest.java) | NEW | DTO sửa exercise |
| [GrammarImportResult.java](src/main/java/com/kiovant/englishme/dto/GrammarImportResult.java) | NEW | DTO kết quả import 3 cấp (totals/inserted/skipped + errors) |
| [GrammarTopicRepository.java](src/main/java/com/kiovant/englishme/repository/GrammarTopicRepository.java) | MODIFIED | Thêm `findBySlug`, `existsBySlug`, `existsByCategoryAndLevel`, `searchTopics(level, keyword)`, `maxSortOrder()` |
| [GrammarLessonRepository.java](src/main/java/com/kiovant/englishme/repository/GrammarLessonRepository.java) | MODIFIED | Thêm `existsBySourceId`, `maxSortOrderByTopic`, `countExercisesByLessonForTopic`, `countByTopic` |
| [GrammarExerciseRepository.java](src/main/java/com/kiovant/englishme/repository/GrammarExerciseRepository.java) | MODIFIED | Thêm `maxOrderByLesson`, `countByLesson` |
| [AdminGrammarService.java](src/main/java/com/kiovant/englishme/service/AdminGrammarService.java) | NEW | Service CRUD đầy đủ topic/lesson/exercise + parse/validate JSON + bulk import lồng nhau + helper Jackson |
| [AdminGrammarController.java](src/main/java/com/kiovant/englishme/controller/AdminGrammarController.java) | NEW | Controller MVC cho `/admin/grammar/**` (14 endpoint) |
| [AdminViewController.java](src/main/java/com/kiovant/englishme/controller/AdminViewController.java) | MODIFIED | Xóa 3 route grammar cũ + xóa dependency `GrammarService` |
| [grammar.jsp](src/main/webapp/WEB-INF/views/admin/grammar.jsp) | REWRITTEN | List topic + filter + modal create/edit + modal import JSON |
| [grammar-topic-form-fields.jspf](src/main/webapp/WEB-INF/views/admin/grammar-topic-form-fields.jspf) | NEW | Fragment dùng chung cho create topic form |
| [grammar-lessons.jsp](src/main/webapp/WEB-INF/views/admin/grammar-lessons.jsp) | REWRITTEN | List lesson trong topic + modal create lesson + delete inline |
| [grammar-lesson-form-fields.jspf](src/main/webapp/WEB-INF/views/admin/grammar-lesson-form-fields.jspf) | NEW | Fragment cho create lesson form (9 trường: sourceId, title, sort, explanation, whenToUse, tips, formulas, keyWords, examples, commonMistakes) |
| [grammar-lesson-detail.jsp](src/main/webapp/WEB-INF/views/admin/grammar-lesson-detail.jsp) | REWRITTEN | Chi tiết lesson + modal sửa lesson + modal create/edit exercise + xóa exercise; sửa bug render List/Map sai |

**Tổng endpoint mới của Module 3:** 14 (1 GET list topic, 3 POST topic CRUD, 1 GET topic detail, 3 POST lesson CRUD, 1 GET lesson detail, 3 POST exercise CRUD, 1 POST import, 1 chia sẻ với GET topic detail).

**Build status:** `./mvnw clean compile -DskipTests` → BUILD SUCCESS (165 source files, 8.0s).

**Phần còn nợ cho giai đoạn sau (không thuộc P0):**
- **Rich text editor** (TinyMCE / Quill / TipTap) cho 3 trường `explanationVi`, `whenToUseVi`, `tipsVi` — hiện đang dùng `<textarea>` thuần.
- **Markdown support** với preview real-time.
- **JSON editor** chuyên dụng (Monaco / CodeMirror) cho 4 trường JSONB + content exercise — hiện chỉ là `<textarea>` font mono, error parse báo về sau khi submit. Có UI builder kéo-thả là lý tưởng cho từng `exerciseType`.
- **Reorder lesson trong topic bằng drag-drop** (hiện chỉ có ô số `sort_order`).
- **Versioning lesson** — giữ lịch sử thay đổi (cần bảng `grammar_lesson_history`).
- **Export grammar ra JSON / CSV** — đối xứng với import (chưa làm).
- **Validate `exerciseType` enum** ở DB (hiện service chỉ gợi ý chuẩn, vẫn cho phép giá trị tự do).
- **Soft delete** topic / lesson (cần thêm cột `deleted_at`).

### 2026-05-17 — Module 4: Exercise Bank Management (P1) ✅

**Phạm vi hoàn thành (giai đoạn 1, không cần migration mới — dùng schema V10 đã có):**

#### A. Question CRUD — hoàn thành
- ✅ `GET  /admin/exercises` — list câu hỏi có 4 bộ lọc: `category` (vocabulary/grammar), `difficulty` (easy/medium/hard), `level` (A1–C2), `q` (tìm trong nội dung câu hỏi, case-insensitive).
- ✅ `POST /admin/exercises` — tạo câu hỏi với validation chặt: `category` ∈ {vocabulary, grammar}, `difficulty` ∈ {easy, medium, hard}, `level` (nếu có) thuộc A1–C2, `options` phải là mảng JSON ≥ 2 phần tử, `correctAnswer` **bắt buộc phải khớp 1 phần tử trong options** (tránh sai đáp án — đây là tính năng quan trọng đã đề cập trong yêu cầu).
- ✅ `POST /admin/exercises/{id}/update` — sửa câu hỏi (form modal chia sẻ schema validation với create).
- ✅ `POST /admin/exercises/{id}/delete` — xóa câu hỏi (DB cascade `ON DELETE`: vì `exercise_answer.question_id` không có cascade nên hiện chỉ delete trực tiếp; tương lai có thể cần soft-delete để bảo toàn lịch sử).

#### B. Bulk import JSON — hoàn thành
- ✅ `POST /admin/exercises/import` — import từ JSON. Hỗ trợ 2 dạng payload: `[{...}, {...}]` hoặc `{"questions": [...]}`. Mỗi item cho phép cả camelCase và snake_case (`correctAnswer` / `correct_answer`). Khử trùng lặp **trong cùng batch import** theo cặp `(category + question)` case-insensitive — bỏ qua các dòng trùng trong cùng request. Báo cáo: `totalRows`, `inserted`, `skipped`, `errors` (hiển thị 5 lỗi đầu trên flash message).

#### C. Export CSV — hoàn thành
- ✅ `GET  /admin/exercises/export?category=&difficulty=&level=&q=` — export CSV theo cùng bộ lọc của list (cho phép export "tất cả vocabulary easy" chẳng hạn). 8 cột: `category, difficulty, level, question, options, correct_answer, explanation, hint` — kèm BOM UTF-8 để Excel mở không lỗi font.

#### D. Session monitoring — hoàn thành
- ✅ `GET  /admin/exercises/sessions` — list session học viên có phân trang (mặc định 20/trang, max 100), filter `category` / `status` (active|completed) / `userId` (UUID). Mỗi dòng hiển thị: user (full name + email), category, status, tổng câu, đã trả lời, đúng, thời gian bắt đầu, thời gian hoàn thành.
- ✅ `GET  /admin/exercises/sessions/{id}` — chi tiết session: 5 KPI cards (category, status, tổng câu, đã trả lời, đúng + % accuracy), thời lượng (giây giữa `createdAt` và `completedAt`), bảng đầy đủ từng câu trả lời với 4 thông tin/câu (badge Đúng/Sai, level + difficulty, options, học viên chọn vs đáp án đúng). Câu trả lời sai bôi nền hồng nhạt, đúng bôi nền xanh nhạt để dễ scan.

#### E. Analytics per-question — hoàn thành
- ✅ Trang list câu hỏi tự động tính `attempts` và `correctCount` cho mỗi câu (group by `question_id` trên `exercise_answer`).
- ✅ Cột "Đúng %" hiển thị `avgAccuracy = correct / attempts × 100`, làm tròn 2 chữ số thập phân.
- ✅ Color-coded badge: `bg-rose` nếu < 30% (câu quá khó hoặc sai đáp án — flag để admin review), `bg-amber` nếu > 95% (quá dễ), `bg-emerald` nếu trong khoảng tốt 30%–95%. Câu chưa từng được làm hiển thị "—" với badge xám.

#### F. UI/UX
- ✅ Sidebar: thêm entry "Exercise Bank" với icon `quiz`, nằm giữa Grammar và Placement Test.
- ✅ Layout JSP đồng bộ style với các trang admin khác (Tailwind + Material Symbols, modal create/edit/import, banner success/error). Modal create + edit + import đều có ESC + click backdrop để đóng.
- ✅ Trang list có 4 nút action trên header: **Sessions** (xem lịch sử), **Import JSON**, **Export CSV** (preserve filter hiện tại qua query string), **Thêm câu hỏi**.
- ✅ Trang list câu hỏi: cột difficulty cũng color-coded (easy=xanh, medium=vàng, hard=đỏ) để admin scan nhanh.

#### G. Refactor controller cũ
- ✅ `ExerciseSessionRepository`: thêm method `searchSessions(category, status, userId, pageable)` cho admin; method `findByIdAndUser_FirebaseUid` cũ vẫn giữ cho API mobile.
- ✅ `ExerciseQuestionRepository`: thêm method `searchQuestions(category, difficulty, level, keyword)`; 2 method `findRandomByCategory` cũ vẫn giữ cho gameplay mobile.
- ✅ `ExerciseAnswerRepository`: thêm 4 method query — `findBySessionId`, `countBySessionId`, `countCorrectBySessionId`, `aggregateStatsByQuestionIds` (cho tính accuracy hàng loạt).

**Các file đã thêm/sửa:**

| File | Loại | Mô tả |
|------|------|-------|
| [AdminExerciseQuestionRow.java](src/main/java/com/kiovant/englishme/dto/AdminExerciseQuestionRow.java) | NEW | Record cho row câu hỏi admin (kèm `attemptCount`, `correctCount`, `avgAccuracy`) |
| [AdminExerciseSessionRow.java](src/main/java/com/kiovant/englishme/dto/AdminExerciseSessionRow.java) | NEW | Record cho row session (kèm user info + tổng câu / đã trả lời / đúng) |
| [AdminExerciseSessionDetail.java](src/main/java/com/kiovant/englishme/dto/AdminExerciseSessionDetail.java) | NEW | DTO chi tiết session + inner record `AnswerRow` cho từng câu trả lời |
| [CreateExerciseQuestionRequest.java](src/main/java/com/kiovant/englishme/dto/CreateExerciseQuestionRequest.java) | NEW | DTO tạo câu hỏi |
| [UpdateExerciseQuestionRequest.java](src/main/java/com/kiovant/englishme/dto/UpdateExerciseQuestionRequest.java) | NEW | DTO sửa câu hỏi |
| [ExerciseImportResult.java](src/main/java/com/kiovant/englishme/dto/ExerciseImportResult.java) | NEW | DTO kết quả import (total/inserted/skipped/errors) |
| [ExerciseQuestionRepository.java](src/main/java/com/kiovant/englishme/repository/ExerciseQuestionRepository.java) | MODIFIED | Thêm `searchQuestions(category, difficulty, level, keyword)` |
| [ExerciseSessionRepository.java](src/main/java/com/kiovant/englishme/repository/ExerciseSessionRepository.java) | MODIFIED | Thêm `searchSessions(category, status, userId, pageable)` (Page) |
| [ExerciseAnswerRepository.java](src/main/java/com/kiovant/englishme/repository/ExerciseAnswerRepository.java) | MODIFIED | Thêm `findBySessionId`, `countBySessionId`, `countCorrectBySessionId`, `aggregateStatsByQuestionIds` |
| [AdminExerciseService.java](src/main/java/com/kiovant/englishme/service/AdminExerciseService.java) | NEW | Service CRUD + import JSON + export CSV + session listing + per-question analytics + validation đầy đủ |
| [AdminExerciseController.java](src/main/java/com/kiovant/englishme/controller/AdminExerciseController.java) | NEW | Controller MVC cho `/admin/exercises/**` (8 endpoint) |
| [exercises.jsp](src/main/webapp/WEB-INF/views/admin/exercises.jsp) | NEW | Trang list câu hỏi + 3 modal (create / edit / import) + 4 filter |
| [exercise-form-fields.jspf](src/main/webapp/WEB-INF/views/admin/exercise-form-fields.jspf) | NEW | Fragment dùng chung cho create question form |
| [exercise-sessions.jsp](src/main/webapp/WEB-INF/views/admin/exercise-sessions.jsp) | NEW | Trang list session + filter + phân trang |
| [exercise-session-detail.jsp](src/main/webapp/WEB-INF/views/admin/exercise-session-detail.jsp) | NEW | Chi tiết 1 session + 5 KPI cards + thời lượng + bảng đáp án từng câu (color-coded đúng/sai) |
| [sidebar.jspf](src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf) | MODIFIED | Thêm menu entry "Exercise Bank" với icon `quiz` + active state khi URI bắt đầu bằng `/admin/exercises` |

**Tổng endpoint mới của Module 4:** 8 (1 GET list, 1 POST create, 1 POST update, 1 POST delete, 1 POST import, 1 GET export, 1 GET sessions list, 1 GET session detail).

**Build status:** `./mvnw clean compile -DskipTests` → BUILD SUCCESS (173 source files, 7.5s).

**Phần còn nợ cho giai đoạn sau (không thuộc P1):**
- **Thời gian trung bình làm mỗi câu** — cần thêm cột `answered_at TIMESTAMP` (hoặc `time_taken_ms INT`) vào `exercise_answer` bằng migration V11; rồi tính `AVG(answered_at - prev_answered_at)`.
- **Skip rate** — kết hợp `exercise_session.question_ids` (toàn bộ câu được giao) với `exercise_answer.question_id` (câu đã trả lời) → tính `skipRate = 1 - answered/total` cho từng câu.
- **Soft delete câu hỏi** — hiện hard delete có thể vướng FK constraint nếu câu đã được dùng trong session (do `exercise_answer.question_id` REFERENCES exercise_question(id) không CASCADE). Cần thêm cột `deleted_at` ở V10 schema và filter trong query.
- **Pagination cho list câu hỏi** — hiện đang load all theo filter, có thể chậm khi > 1000 câu.
- **Import CSV** (hiện mới import JSON); cần parser CSV với header mapping.
- **Trang phân tích chuyên sâu** — biểu đồ histogram phân bố accuracy, top 10 câu hỏi sai nhiều nhất, heatmap accuracy theo CEFR × difficulty.
- **Validate đáp án trùng trong options** (hiện chỉ check `correctAnswer ∈ options`, chưa chặn 2 option trùng nhau).

---

## CHANGE LOG — Module 12 (System Configuration) — 2026-05-17

**Phạm vi triển khai:**
- Bảng `app_config` (key, value, type, description, is_secret, updated_at, updated_by_email) với 16 key seed sẵn
- In-memory cache (`ConcurrentHashMap`) trong `AppConfigService` — warm-up bằng `@PostConstruct`, invalidate khi update qua admin UI
- Validate theo `value_type`: boolean (`true|false`), integer (parse Int), json (start/end bằng `{}` hoặc `[]`), string (free-form)
- Mask secret value khi list (hiện 4 ký tự cuối) — toggle "Hiện secrets" để xem giá trị thật
- "Reload cache" thủ công khi DB bị thay đổi từ ngoài
- Reader API cho service khác: `getInt(key, fallback)`, `getBoolean(key, fallback)`, `getString(key, fallback)`, `getRaw(key)`

### Files thêm mới (NEW)

| File | Mục đích |
|------|----------|
| [V14__app_config.sql](src/main/resources/db/migration/V14__app_config.sql) | Migration: bảng `app_config` (key PK, value TEXT, value_type, description, is_secret, updated_at, updated_by_email) + seed 16 key (xp.*, streak.*, pronunciation.*, chat.*, feature.*, maintenance.*, 3 secret API key) |
| [AppConfig.java](src/main/java/com/kiovant/englishme/entity/AppConfig.java) | Entity, dùng `@UpdateTimestamp` cho `updated_at` |
| [AppConfigRepository.java](src/main/java/com/kiovant/englishme/repository/AppConfigRepository.java) | `findAllByOrderByConfigKeyAsc` |
| [AppConfigRow.java](src/main/java/com/kiovant/englishme/dto/AppConfigRow.java) | DTO render bảng — tách `configValue` (raw) khỏi `displayValue` (đã mask nếu secret) |
| [AppConfigService.java](src/main/java/com/kiovant/englishme/service/AppConfigService.java) | Cache `ConcurrentHashMap`, `@PostConstruct warmup`, validate theo type, mask secret 4 ký tự cuối, reader API typed |
| [AdminConfigController.java](src/main/java/com/kiovant/englishme/controller/AdminConfigController.java) | `GET /admin/config` (with `?revealSecrets=true`), `POST /admin/config/{key}` (form submit), `PUT /admin/config/{key}` (REST), `POST /admin/config/reload` |
| [config.jsp](src/main/webapp/WEB-INF/views/admin/config.jsp) | UI: bảng config với input theo type (boolean → select, integer → number, json → textarea, string → text), badge SECRET, toggle reveal, nút reload cache |

### Files đổi (MODIFIED)

| File | Thay đổi |
|------|----------|
| [sidebar.jspf](src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf) | Thêm entry "System Config" (icon `tune`) → `/admin/config`; thêm flag `configActive` |

### Endpoint thêm mới

```
GET    /admin/config                          → List configs (?revealSecrets=true để xem secret value)
POST   /admin/config/{key}                    → Update value (form submit từ JSP)
PUT    /admin/config/{key}                    → Update value (REST/API client)
POST   /admin/config/reload                   → Force reload cache từ DB
```

**Tổng endpoint mới của Module 12:** 4 (1 GET, 2 update, 1 reload).

### Quyết định thiết kế

- **In-memory cache thay vì Caffeine** — yêu cầu hiện tại đơn giản (16 key, đọc nhiều / ghi rất ít), `ConcurrentHashMap` đủ và không thêm dependency. Khi cần TTL hoặc size limit thì thay sau.
- **Không dùng `@ConfigurationPropertiesRefresh`** — đề xuất trong spec, nhưng cần Spring Cloud Config / Actuator refresh; quá nặng cho nhu cầu. Cache invalidation tay (cập nhật entry sau khi save) là đủ và predictable.
- **Cả `POST` lẫn `PUT` cho `/admin/config/{key}`** — HTML form trong browser không gửi PUT trực tiếp; giữ `POST` cho UI và `PUT` cho client REST/curl/API tester.
- **Validate JSON nông** (chỉ check ngoặc đầu/cuối) — Jackson không có trong dependency thiết yếu cho phép kiểm tra này nhẹ nhàng; nếu cần validate đầy đủ, inject `ObjectMapper` và `readTree`.
- **Mask secret hiển thị 4 ký tự cuối** — pattern phổ biến (giống Stripe/AWS console) để admin verify đúng key mà không lộ toàn bộ.
- **Service khác chưa được refactor để đọc từ AppConfigService** — đây là module nền; bước migration `@Value` → `appConfig.getInt(...)` sẽ làm riêng theo service (XP, streak, chat limit, maintenance gate) để giữ diff Module 12 sạch.

**Build status:** `./mvnw clean compile` → BUILD SUCCESS (241 source files, 10.8s).

### Phần còn nợ cho giai đoạn sau

- **Role-based SECRET edit** — hiện UI cho mọi admin sửa secret nếu đã reveal; nên chặn ở controller dựa trên `ADMIN_ROLE = SUPER_ADMIN` (làm chung với Module 13 role enforcement).
- **Migration `@Value` → AppConfigService** — refactor `XpService` / `StreakService` / `ChatService` / `PronunciationService` / maintenance interceptor để đọc runtime config; xóa các property hardcode tương ứng trong `application.yaml`.
- **`maintenance.mode` middleware** — khi `true`, interceptor cho `/api/**` (không phải `/admin/**`) trả 503 + `maintenance.message`.
- **Audit cho update config** — đã được Module 13 `AuditLogInterceptor` ghi sẵn (action=POST/PUT, request_uri=`/admin/config/{key}`, entity_type=`config`), nhưng chưa lưu before/after value. Sau khi enable `ContentCachingRequestWrapper` (đã ghi note trong Module 13) thì câu chuyện này cũng được giải.
- **Validate JSON sâu** với Jackson `readTree`.
- **History versioning của config** — bảng `app_config_history` để rollback.

---

## CHANGE LOG — Module 13 (Audit Log & Admin Management) — 2026-05-17

**Phạm vi triển khai:**
- Audit log tự động cho mọi POST/PUT/DELETE/PATCH dưới `/admin/**` (loại trừ `/admin/login`, `/admin/logout`)
- CRUD admin accounts DB-backed (ngoài static admin trong `application.yml`)
- Role: `SUPER_ADMIN | EDITOR | VIEWER` (lưu vào cột, chưa enforce phân quyền view-level — vì hiện admin auth còn dùng single static user; sẽ siết khi tích hợp DB-backed login)
- Reset password (cấp mật khẩu mới hoặc tự sinh ngẫu nhiên, hiển thị 1 lần)
- Disable/enable admin account
- Filter audit log theo email (LIKE), action (POST/PUT/DELETE/PATCH), date range

### Files thêm mới (NEW)

| File | Mục đích |
|------|----------|
| [V13__audit_log_admin_management.sql](src/main/resources/db/migration/V13__audit_log_admin_management.sql) | Migration: bảng `admin_account` (UUID PK, email UNIQUE, password_hash, password_salt, role, is_active, last_login_at) + bảng `admin_audit_log` (UUID PK, admin_email, action, request_uri, entity_type, entity_id, status_code, ip_address, user_agent, created_at) + 3 index |
| [AdminAccount.java](src/main/java/com/kiovant/englishme/entity/AdminAccount.java) | Entity admin_account |
| [AdminAuditLog.java](src/main/java/com/kiovant/englishme/entity/AdminAuditLog.java) | Entity admin_audit_log |
| [AdminAccountRepository.java](src/main/java/com/kiovant/englishme/repository/AdminAccountRepository.java) | `findByEmailIgnoreCase`, `existsByEmailIgnoreCase`, `findAllByOrderByCreatedAtDesc` |
| [AdminAuditLogRepository.java](src/main/java/com/kiovant/englishme/repository/AdminAuditLogRepository.java) | JPQL `search(email, action, from, to)` với null-safe filter |
| [AdminAccountRow.java](src/main/java/com/kiovant/englishme/dto/AdminAccountRow.java) | DTO render bảng admin |
| [AuditLogRow.java](src/main/java/com/kiovant/englishme/dto/AuditLogRow.java) | DTO render bảng audit log |
| [AdminManagementService.java](src/main/java/com/kiovant/englishme/service/AdminManagementService.java) | Service CRUD admin + SHA-256+salt password hashing + validate role/email/password |
| [AdminAuditLogService.java](src/main/java/com/kiovant/englishme/service/AdminAuditLogService.java) | Service tìm kiếm audit log (chuẩn hóa filter, convert LocalDate → LocalDateTime) |
| [AuditLogInterceptor.java](src/main/java/com/kiovant/englishme/interceptor/AuditLogInterceptor.java) | `HandlerInterceptor#afterCompletion` — chỉ ghi POST/PUT/DELETE/PATCH; extract entity_type từ segment đầu sau `/admin/`, entity_id từ UUID/số trong URI; lấy IP từ `X-Forwarded-For` rồi fallback `getRemoteAddr`; nuốt lỗi để không làm vỡ request |
| [AdminManagementController.java](src/main/java/com/kiovant/englishme/controller/AdminManagementController.java) | `/admin/admins`: list, create, update role, reset password, disable/enable |
| [AdminAuditController.java](src/main/java/com/kiovant/englishme/controller/AdminAuditController.java) | `/admin/audit-log` với 4 filter params (`email`, `action`, `from`, `to`) |
| [admin-accounts.jsp](src/main/webapp/WEB-INF/views/admin/admin-accounts.jsp) | UI quản lý admin: form tạo, bảng list, inline form đổi role, nút reset password / disable / enable |
| [audit-log.jsp](src/main/webapp/WEB-INF/views/admin/audit-log.jsp) | UI audit log: form filter (email/action/date range), bảng list với action badge màu và status code color-coded |

### Files đổi (MODIFIED)

| File | Thay đổi |
|------|----------|
| [WebMvcConfig.java](src/main/java/com/kiovant/englishme/config/WebMvcConfig.java) | Đăng ký `AuditLogInterceptor` cho `/admin/**` (exclude `/admin/login`, `/admin/logout`) |
| [sidebar.jspf](src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf) | Thêm 2 entry: "Admin Accounts" (icon `admin_panel_settings`) → `/admin/admins`, "Audit Log" (icon `history`) → `/admin/audit-log`; 2 flag active mới (`adminAccountsActive`, `auditLogActive`) |

### Endpoint thêm mới

```
GET    /admin/audit-log                      → Trang audit log + filter (email, action, from, to)
GET    /admin/admins                         → List admin accounts
POST   /admin/admins                         → Tạo admin (email, password, fullName, role)
POST   /admin/admins/{id}/role               → Đổi role (SUPER_ADMIN | EDITOR | VIEWER)
POST   /admin/admins/{id}/reset-password     → Reset password (newPassword optional → auto-gen)
POST   /admin/admins/{id}/disable            → Vô hiệu hóa (is_active = false)
POST   /admin/admins/{id}/enable             → Kích hoạt lại
```

**Tổng endpoint mới của Module 13:** 7 (1 GET audit log, 1 GET list, 1 POST create, 4 POST mutate).

### Quyết định thiết kế

- **Audit qua HandlerInterceptor**, không dùng AOP — phù hợp với pattern interceptor sẵn có (`AdminRoleInterceptor`); không phải thêm dependency `spring-boot-starter-aop`.
- **Không lưu `before_value` / `after_value`** ở giai đoạn này — request body có thể chứa file upload (multipart) hoặc trường lớn (JSON description); việc capture đáng giá sẽ phải bọc `ContentCachingRequestWrapper` qua filter. Tạm bỏ; thêm sau khi cần evidence cụ thể.
- **Password hashing SHA-256 + per-account salt** — `spring-security-crypto` không có trong dependency hiện tại; SHA-256+salt đủ tốt để khởi đầu, sẽ thay BCrypt khi tích hợp `spring-security` vào auth flow thực tế.
- **Static admin trong `application.yml` vẫn hoạt động độc lập** — table `admin_account` chỉ dùng cho admin DB-backed (bước tiếp theo: refactor `AdminAuthService` để fallback sang DB nếu static credential không khớp, cập nhật `last_login_at`).
- **Role chưa enforce ở interceptor level** — vì auth hiện chỉ có 1 role string trong session (`ADMIN_ROLE`). Cần làm sau cùng với DB-backed login.

**Build status:** `./mvnw clean compile` → BUILD SUCCESS (236 source files, 11.5s).

### Phần còn nợ cho giai đoạn sau

- **DB-backed login** — `AdminAuthService` cần thử `admin_account` trước khi rơi về static credential; set `ADMIN_ROLE` từ DB column.
- **Role-based view filtering** — ẩn menu `Admin Accounts` / `Audit Log` / `System Configuration` khi role không phải `SUPER_ADMIN`; chặn route bằng interceptor riêng `RequireRoleInterceptor`.
- **Capture before/after JSON** — wrap request bằng `ContentCachingRequestWrapper`; chỉ enable cho `application/json` để tránh nuốt file upload.
- **Pagination cho audit log** — hiện load all rows match filter; thêm `Pageable` + UI pagination khi log > 5000.
- **Export audit log** — CSV/Excel download (Module 14 sẽ thừa kế pattern này).
- **BCrypt password** — sau khi import `spring-security-crypto` (hoặc full `spring-boot-starter-security`).

---

*— Hết —*
