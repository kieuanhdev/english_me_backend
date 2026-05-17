# Kế hoạch Triển khai Backend — EnglishMe

> Phân tích ngày: 2026-05-17  
> So sánh: `BACKEND_API_REQUIREMENTS.md` ↔ mã nguồn thực tế  
> Base URL: `http://{host}:8080/api`

---

## Tổng quan trạng thái

| # | Module / Endpoint | Trạng thái | Ghi chú |
|---|-------------------|-----------|---------|
| 0 | `GET /api/home/dashboard` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 1 | `POST /api/auth/sync` | ✅ Hoàn chỉnh | |
| 2 | `GET/POST/PUT/DELETE /api/desks` | ✅ Hoàn chỉnh | |
| 3 | `GET/POST /api/desks/{id}/flashcards` | ✅ Hoàn chỉnh | |
| 4 | `PUT /api/desks/{id}/flashcards/{fid}` | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 5 | `DELETE /api/desks/{id}/flashcards/{fid}` | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 6 | `GET /api/grammar/topics` | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 7 | `GET /api/grammar/topics/{id}/lessons` | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 8 | `GET /api/grammar/lessons/{id}` | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 9 | `POST /api/placement-test/start` | ✅ Hoàn chỉnh | |
| 10 | `POST /api/placement-test/{sid}/answer` | ✅ Hoàn chỉnh | |
| 11 | `POST /api/placement-test/{sid}/complete` | ✅ Hoàn chỉnh | |
| 12 | `GET /api/pronunciation/exercises` | ✅ Hoàn chỉnh | |
| 13 | `POST /api/pronunciation/assess` | ✅ Hoàn chỉnh | |
| 14 | `POST /api/chat` | ✅ Hoàn chỉnh | |
| 15 | Error format nhất quán | ✅ Hoàn chỉnh | Fixed 2026-05-17 |
| 16 | `GET /api/home/dashboard` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 17 | `GET /api/vocabulary/topics` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 18 | `GET /api/vocabulary/topics/{id}/words` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 19 | `GET /api/exercises/sessions` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 20 | `POST /api/exercises/sessions/{sid}/complete` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 21 | `POST /api/tests/sessions` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 22 | `POST /api/tests/sessions/{sid}/submit` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 23 | `GET /api/tests/history` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 24 | `GET /api/users/me` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 25 | `PUT /api/users/me` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 26 | `GET /api/users/me/progress` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 27 | `GET /api/users/me/xp-history` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 28 | `GET /api/users/me/streak-calendar` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 29 | `GET /api/study-sessions/due-cards` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 30 | `POST /api/study-sessions/start` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 31 | `POST /api/study-sessions/{sid}/review` | ✅ Hoàn chỉnh | Done 2026-05-17 |
| 32 | `GET /api/study-sessions/{sid}/summary` | ✅ Hoàn chỉnh | Done 2026-05-17 |

**Tóm tắt:** 29 endpoints hoàn chỉnh · ~~3 sai URL~~ đã fix · ~~2 thiếu trong controller~~ đã fix · ~~1 thiếu error handler~~ đã fix · Migration V10 Done 2026-05-17 · Phase 4 (Study Session SM-2) Done 2026-05-17 · Phase 6 (Exercise) Done 2026-05-17 · Phase 7 (Test) Done 2026-05-17 · Phase 8 (Home Dashboard) Done 2026-05-17

---

## PHASE 1 — Sửa lỗi API hiện có

> Ưu tiên cao nhất. Sửa trước khi build mới vì mobile đang dùng.

### 1.1 Fix Grammar URL prefix

**File cần sửa:** `GrammarController.java`

```java
// TRƯỚC (sai)
@RequestMapping("/grammar")

// SAU (đúng)
@RequestMapping("/api/grammar")
```

**Lý do:** Mobile gọi `/api/grammar/topics` nhưng backend mapping là `/grammar/topics` — 404 hoàn toàn.  
**Kiểm tra:** Không ảnh hưởng admin views vì admin dùng `/admin/grammar/...` riêng.

---

### 1.2 Thêm PUT và DELETE flashcard

**File cần sửa:** `DeskApiController.java` và `DeskFlashcardService.java`

Thêm vào controller:
```java
@PutMapping("/{deskId}/flashcards/{flashcardId}")
public FlashcardResponse updateFlashcard(
    @RequestHeader("Authorization") String auth,
    @PathVariable UUID deskId,
    @PathVariable UUID flashcardId,
    @RequestBody CreateFlashcardRequest body   // reuse existing DTO
) { ... }

@DeleteMapping("/{deskId}/flashcards/{flashcardId}")
@ResponseStatus(HttpStatus.NO_CONTENT)
public void deleteFlashcard(
    @RequestHeader("Authorization") String auth,
    @PathVariable UUID deskId,
    @PathVariable UUID flashcardId
) { ... }
```

Thêm vào service:
```java
FlashcardResponse updateFlashcard(String firebaseUid, UUID deskId, UUID flashcardId, CreateFlashcardRequest req);
void deleteFlashcard(String firebaseUid, UUID deskId, UUID flashcardId);
```

Repository cần thêm:
```java
Optional<Flashcard> findByIdAndDesk_Id(UUID id, UUID deskId);
```

---

### 1.3 Thêm GlobalExceptionHandler

**File cần tạo:** `exception/GlobalExceptionHandler.java`

Mobile parse `response.data['message']` — cần format nhất quán:
```json
{ "status": 400, "message": "Mô tả lỗi", "error": "BAD_REQUEST" }
```

Xử lý các exception:
- `IllegalArgumentException` → 400
- `EntityNotFoundException` / `NoSuchElementException` → 404
- `AccessDeniedException` → 403
- `FirebaseAuthException` → 401
- `Exception` (fallback) → 500

**File cần tạo:** `exception/AppException.java` — Custom exception với HTTP status

---

## PHASE 2 — Database Migration mới

> Cần chạy trước khi implement các module mới.

### Migration V8 — User fields cho XP & Streak

```sql
-- Thêm vào bảng users
ALTER TABLE users ADD COLUMN total_xp INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN current_streak INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN longest_streak INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN last_active_date DATE;

-- Lịch sử XP theo ngày (cho chart)
CREATE TABLE xp_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    xp INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT uq_xp_history_user_date UNIQUE (user_id, activity_date)
);
CREATE INDEX idx_xp_history_user_date ON xp_history(user_id, activity_date DESC);

-- Badges
CREATE TABLE badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    condition_type VARCHAR(50) NOT NULL  -- 'streak_7', 'xp_1000', etc.
);

CREATE TABLE user_badge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badge(id),
    earned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_badge UNIQUE (user_id, badge_id)
);

-- Seed badges cơ bản
INSERT INTO badge (name, description, icon_url, condition_type) VALUES
    ('First Step', 'Hoàn thành bài học đầu tiên', null, 'first_lesson'),
    ('Week Streak', '7 ngày liên tiếp học', null, 'streak_7'),
    ('Month Streak', '30 ngày liên tiếp học', null, 'streak_30'),
    ('XP Milestone', 'Đạt 1000 XP', null, 'xp_1000'),
    ('Grammar Pro', 'Hoàn thành 10 bài ngữ pháp', null, 'grammar_10');
```

### Migration V9 — Vocabulary module

```sql
CREATE TABLE vocabulary_topic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,          -- Tên tiếng Việt
    name_en VARCHAR(100) NOT NULL,        -- Tên tiếng Anh
    icon VARCHAR(50),                     -- emoji hoặc icon name
    level VARCHAR(10),                    -- A1-C2 (nullable = all levels)
    color_hex VARCHAR(7),                 -- #RRGGBB
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE vocabulary_word (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES vocabulary_topic(id) ON DELETE CASCADE,
    word VARCHAR(200) NOT NULL,
    pronunciation VARCHAR(200),           -- IPA
    part_of_speech VARCHAR(50),
    definition_vi TEXT,
    definition_en TEXT,
    example_sentence TEXT,
    example_translation TEXT,
    level VARCHAR(10) NOT NULL,           -- a1|a2|b1|b2|c1|c2 (lowercase)
    audio_url TEXT
);

CREATE INDEX idx_vocabulary_word_topic ON vocabulary_word(topic_id);
CREATE INDEX idx_vocabulary_word_level ON vocabulary_word(level);

-- Seed data: ít nhất 3-5 topic, mỗi topic 10+ từ
```

### Migration V10 — Exercise & Test modules + Study Session

```sql
-- Exercise Questions (khác với placement test questions)
CREATE TABLE exercise_question (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(50) NOT NULL,        -- vocabulary | grammar
    difficulty VARCHAR(20) NOT NULL,      -- easy | medium | hard
    question TEXT NOT NULL,
    options JSONB NOT NULL,               -- ["A", "B", "C", "D"]
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    hint TEXT,
    level VARCHAR(10)                     -- A1-C2 optional filter
);

-- Exercise Sessions (tạm thời, in-memory style)
CREATE TABLE exercise_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active | completed
    question_ids JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Exercise Answers
CREATE TABLE exercise_answer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES exercise_session(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES exercise_question(id),
    selected_answer TEXT,
    is_correct BOOLEAN
);

-- User Test Sessions (khác PlacementTest: user chủ động tạo)
CREATE TABLE user_test_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic VARCHAR(50) NOT NULL,           -- grammar | vocabulary
    level VARCHAR(10) NOT NULL,           -- a1|a2|b1|b2|c1|c2
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    question_ids JSONB NOT NULL,
    duration_seconds INTEGER NOT NULL DEFAULT 900,
    correct INTEGER,
    total INTEGER,
    xp_earned INTEGER,
    time_taken_seconds INTEGER,
    cefr_suggestion VARCHAR(10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_user_test_session_user ON user_test_session(user_id, created_at DESC);

-- Study Sessions (SM-2 — dùng flashcard_progress table đã có)
CREATE TABLE study_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    desk_id UUID NOT NULL REFERENCES desk(id),
    status VARCHAR(20) NOT NULL DEFAULT 'active',  -- active | completed
    card_ids JSONB NOT NULL,
    total_cards INTEGER NOT NULL,
    mastered_cards INTEGER DEFAULT 0,
    again_cards INTEGER DEFAULT 0,
    hard_cards INTEGER DEFAULT 0,
    xp_earned INTEGER DEFAULT 0,
    new_words_learned INTEGER DEFAULT 0,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);
```

---

## PHASE 3 — Profile & Progress

### 3.1 Entities cần cập nhật/tạo

- **`User.java`**: Thêm fields `totalXp`, `currentStreak`, `longestStreak`, `lastActiveDate`
- **Tạo mới `XpHistory.java`**: entity map bảng `xp_history`
- **Tạo mới `Badge.java`**, **`UserBadge.java`**
- **Tạo mới `XpHistoryRepository.java`**
- **Tạo mới `BadgeRepository.java`**, **`UserBadgeRepository.java`**

### 3.2 ProfileService (mới)

```java
UserProfileResponse getProfile(String firebaseUid);
UserProfileResponse updateProfile(String firebaseUid, UpdateProfileRequest req);
```

### 3.3 ProgressService (mới)

```java
ProgressResponse getProgress(String firebaseUid);
List<XpHistoryItem> getXpHistory(String firebaseUid, int days);
StreakCalendarResponse getStreakCalendar(String firebaseUid, String month); // "2026-05"
```

Logic cần implement:
- `recordActivity(userId, xpEarned)` — gọi sau mỗi action (study, exercise, test). Cập nhật `xp_history`, `current_streak`, `longest_streak`, `last_active_date`
- Streak logic: tăng streak nếu `last_active_date = yesterday`, reset nếu > 1 ngày bỏ qua

### 3.4 DTOs cần tạo

- `UserProfileResponse` — full profile với badges
- `UpdateProfileRequest` — `{ displayName, cefrLevel }`  
- `ProgressResponse` — skills, weekSummary
- `XpHistoryItem` — `{ date, xp }`
- `StreakCalendarResponse` — `{ streakDays: ["2026-05-01", ...] }`

### 3.5 Controller

**Tạo mới `UserApiController.java`** mapping `/api/users/me`:

```
GET  /api/users/me
PUT  /api/users/me
GET  /api/users/me/progress
GET  /api/users/me/xp-history?days=14
GET  /api/users/me/streak-calendar?month=2026-05
```

---

## PHASE 4 — Study Session (SM-2) — Core Feature

> Bảng `flashcard_progress` đã có từ V2. Cần tạo service/controller.

### 4.1 Entity cần tạo

- **`FlashcardProgress.java`** — map bảng `flashcard_progress` (hiện chưa có entity!)
- **`StudySession.java`** — map bảng `study_session` (sẽ tạo trong V10)

### 4.2 Repository cần tạo

- **`FlashcardProgressRepository.java`**:
  ```java
  List<FlashcardProgress> findByUserIdAndDeskIdAndNextReviewAtBefore(UUID userId, UUID deskId, LocalDateTime now, Pageable pageable);
  Optional<FlashcardProgress> findByUserIdAndFlashcardId(UUID userId, UUID flashcardId);
  ```
- **`StudySessionRepository.java`**

### 4.3 SM2Service (mới)

```java
// SM-2 algorithm
FlashcardProgress applyReview(FlashcardProgress progress, int quality);
```

Công thức SM-2:
- Nếu quality < 3: interval = 1, repetitions = 0
- Nếu quality >= 3: interval theo repetitions (1→1, 2→6, n→interval*EF)
- EF mới = EF + (0.1 - (5-q) * (0.08 + (5-q)*0.02))
- EF min = 1.3

### 4.4 StudySessionService (mới)

```java
List<DueCardResponse> getDueCards(String firebaseUid, UUID deskId, int limit);
StudySessionStartResponse startSession(String firebaseUid, UUID deskId);
ReviewResponse review(String firebaseUid, UUID sessionId, UUID flashcardId, int quality, int responseTimeMs);
StudySessionSummaryResponse getSummary(String firebaseUid, UUID sessionId);
```

### 4.5 StudySessionApiController (mới)

```
GET  /api/study-sessions/due-cards?deskId={id}&limit=20
POST /api/study-sessions/start              { deskId }
POST /api/study-sessions/{sid}/review       { flashcardId, quality, responseTimeMs }
GET  /api/study-sessions/{sid}/summary
```

XP formula đơn giản: mỗi card quality>=3 = 2 XP, quality==5 = 3 XP.

---

## PHASE 5 — Vocabulary Module

### 5.1 Entities

- **`VocabularyTopic.java`** — map `vocabulary_topic`
- **`VocabularyWord.java`** — map `vocabulary_word`

### 5.2 Service & Controller

**`VocabularyService.java`**:
```java
List<VocabularyTopicResponse> getTopics();
List<VocabularyWordResponse> getWordsByTopic(UUID topicId);
```

**`VocabularyController.java`** mapping `/api/vocabulary`:
```
GET /api/vocabulary/topics
GET /api/vocabulary/topics/{topicId}/words
```

### 5.3 DTOs

- `VocabularyTopicResponse`: `{ id, name, nameEn, icon, wordCount, level, colorHex }`
- `VocabularyWordResponse`: `{ id, topicId, word, pronunciation, partOfSpeech, definitionVi, definitionEn, exampleSentence, exampleTranslation, level }`

### 5.4 Seed Data

Thêm vào V9 migration ít nhất 5 topic + 50 từ chia đều. Ví dụ topics:
- Greetings (A1) — 10 từ
- Food & Drinks (A1) — 10 từ
- Family (A1) — 10 từ
- Travel (A2) — 10 từ
- Business (B1) — 10 từ

---

## PHASE 6 — Exercise Module

### 6.1 Entities

- **`ExerciseQuestion.java`** — map `exercise_question`
- **`ExerciseSession.java`** — map `exercise_session`
- **`ExerciseAnswer.java`** — map `exercise_answer`

### 6.2 Service

**`ExerciseService.java`**:
```java
ExerciseSessionResponse createSession(String firebaseUid, String category, int size);
ExerciseCompleteResponse completeSession(String firebaseUid, UUID sessionId, List<AnswerSubmit> answers);
```

Logic `createSession`: Random pick `size` questions từ `exercise_question` theo `category`. Lưu session. XP tính theo % đúng.

### 6.3 Controller

**`ExerciseApiController.java`** mapping `/api/exercises`:
```
GET  /api/exercises/sessions?category={vocabulary|grammar}&size=10
POST /api/exercises/sessions/{sessionId}/complete  { answers: [{questionId, selectedAnswer}] }
```

### 6.4 Seed Data

Thêm vào V10 migration 20+ exercise questions cho vocabulary + grammar (easy/medium).

---

## PHASE 7 — Test Module (có tính giờ)

### 7.1 Entities

- **`UserTestSession.java`** — map `user_test_session`

### 7.2 Service

**`UserTestService.java`**:
```java
UserTestStartResponse createSession(String firebaseUid, String topic, String level);
UserTestSubmitResponse submit(String firebaseUid, UUID sessionId, List<AnswerSubmit> answers, int timeTakenSeconds);
List<TestHistoryItem> getHistory(String firebaseUid);
```

Logic `createSession`: Chọn random 10-15 câu từ bảng `question` (dùng lại PlacementTest questions) theo topic và level.
Logic `submit`: Tính điểm, lưu kết quả, award XP, gọi `recordActivity()`.

**Note:** Reuse bảng `question` hiện có — chỉ cần filter theo `cefr_level` và `skill_category`.

### 7.3 Controller

**`UserTestApiController.java`** mapping `/api/tests`:
```
POST /api/tests/sessions              { topic, level }
POST /api/tests/sessions/{sid}/submit { answers: [{questionId, selectedAnswer}], timeTakenSeconds }
GET  /api/tests/history
```

---

## PHASE 8 — Home Dashboard

> Triển khai cuối vì phụ thuộc vào tất cả module trên.

### 8.1 Service

**`HomeDashboardService.java`**:
```java
HomeDashboardResponse getDashboard(String firebaseUid);
```

Tổng hợp từ các service đã có:
- User info: từ `UserService`
- Daily stats: từ `ProgressService` (XP hôm nay từ `xp_history`)
- Word of day: Random từ `vocabulary_word` seed cứng theo CEFR của user, rotate theo ngày
- Continue learning: Grammar topic có sort_order thấp nhất user chưa hoàn thành (tạm thời hardcode nếu chưa có tracking)
- Recommendations: Hardcode 3 gợi ý đơn giản theo CEFR

### 8.2 Controller

**`HomeApiController.java`** mapping `/api/home`:
```
GET /api/home/dashboard
```

---

## Thứ tự thực hiện (Priority Order)

| Thứ tự | Phase | Công việc | Độ quan trọng |
|--------|-------|-----------|---------------|
| 1 | Fix 1.1 | Sửa Grammar URL prefix | ✅ Done (2026-05-17) |
| 2 | Fix 1.2 | Thêm PUT/DELETE flashcard | ✅ Done (2026-05-17) |
| 3 | Fix 1.3 | GlobalExceptionHandler | ✅ Done (2026-05-17) |
| 4 | DB V8 | Migration user XP/streak/badges | ✅ Done (2026-05-17) |
| 5 | Phase 3 | Profile & Progress endpoints | ✅ Done (2026-05-17) |
| 6 | DB V9 | Migration vocabulary | ✅ Done (2026-05-17) |
| 7 | Phase 5 | Vocabulary module | ✅ Done (2026-05-17) |
| 8 | Phase 4 | Study Session SM-2 | ✅ Done (2026-05-17) |
| 9 | DB V10 | Migration exercise/test/study_session | ✅ Done (2026-05-17) |
| 10 | Phase 6 | Exercise module | ✅ Done (2026-05-17) |
| 11 | Phase 7 | Test module | ✅ Done (2026-05-17) |
| 12 | Phase 8 | Home Dashboard | ✅ Done (2026-05-17) |

---

## Những gì cần XÓA / Làm sạch

1. **Không có gì cần xóa bắt buộc** — code hiện tại không có dead code rõ ràng.
2. **`GroqChatService`** đã được đổi sang `DeepSeekChatService` trong git history — kiểm tra xem còn file nào cũ không (nếu có thì xóa).
3. **`AdminShortcutController`** — chỉ redirect, giữ lại.
4. **`PronunciationViewController`** — serve trang practice view, giữ lại cho admin testing.

---

## Những gì cần CẢI THIỆN (không bắt buộc)

1. **CEFR level validation** — hiện tại là free-form string. Nên dùng `enum` để tránh typo (`A1`/`a1`/`A1 ` đều khác nhau). Ít nhất thêm `@Pattern` validation.
2. **Pagination mặc định** — các list endpoint vocabulary/exercise nên có page/size params sẵn.
3. **`/api/pronunciation/history`** — endpoint này đã có trong backend nhưng không có trong requirements doc. Cần kiểm tra với frontend để đồng bộ.
4. **Security — CORS** — kiểm tra `WebMvcConfig.java` xem CORS đã config đúng cho mobile (không cần CORS cho mobile native, nhưng cần nếu có web client).
5. **XP event system** — thay vì gọi `recordActivity()` thủ công sau mỗi action, có thể dùng Spring Events (`@EventListener`) để tách logic XP ra khỏi business logic. Tuy nhiên không cần thiết cho MVP.

---

## Files cần tạo mới (tóm tắt)

```
src/main/java/com/kiovant/englishme/
├── exception/
│   ├── AppException.java              [Phase 1.3]
│   └── GlobalExceptionHandler.java    [Phase 1.3]
├── entity/
│   ├── FlashcardProgress.java         [Phase 4.1]
│   ├── StudySession.java              [Phase 4.1]
│   ├── XpHistory.java                 [Phase 3.1]
│   ├── Badge.java                     [Phase 3.1]
│   ├── UserBadge.java                 [Phase 3.1]
│   ├── VocabularyTopic.java           [Phase 5.1]
│   ├── VocabularyWord.java            [Phase 5.1]
│   ├── ExerciseQuestion.java          [Phase 6.1]
│   ├── ExerciseSession.java           [Phase 6.1]
│   ├── ExerciseAnswer.java            [Phase 6.1]
│   └── UserTestSession.java           [Phase 7.1]
├── repository/
│   ├── FlashcardProgressRepository.java  [Phase 4.2]
│   ├── StudySessionRepository.java       [Phase 4.2]
│   ├── XpHistoryRepository.java          [Phase 3.2]
│   ├── BadgeRepository.java              [Phase 3.2]
│   ├── UserBadgeRepository.java          [Phase 3.2]
│   ├── VocabularyTopicRepository.java    [Phase 5.2]
│   ├── VocabularyWordRepository.java     [Phase 5.2]
│   ├── ExerciseQuestionRepository.java   [Phase 6.2]
│   ├── ExerciseSessionRepository.java    [Phase 6.2]
│   └── UserTestSessionRepository.java    [Phase 7.2]
├── service/
│   ├── SM2Service.java                [Phase 4.3]
│   ├── StudySessionService.java       [Phase 4.4]
│   ├── ProfileService.java            [Phase 3.3]
│   ├── ProgressService.java           [Phase 3.3]
│   ├── VocabularyService.java         [Phase 5.2]
│   ├── ExerciseService.java           [Phase 6.2]
│   └── UserTestService.java           [Phase 7.2]
├── controller/
│   ├── UserApiController.java         [Phase 3.5]
│   ├── StudySessionApiController.java [Phase 4.5]
│   ├── VocabularyController.java      [Phase 5.2]
│   ├── ExerciseApiController.java     [Phase 6.3]
│   ├── UserTestApiController.java     [Phase 7.3]
│   └── HomeApiController.java         [Phase 8.2]
└── dto/
    ├── UserProfileResponse.java       [Phase 3.4]
    ├── UpdateProfileRequest.java      [Phase 3.4]
    ├── ProgressResponse.java          [Phase 3.4]
    ├── XpHistoryItem.java             [Phase 3.4]
    ├── StreakCalendarResponse.java     [Phase 3.4]
    ├── DueCardResponse.java           [Phase 4.5]
    ├── StudySessionStartResponse.java [Phase 4.5]
    ├── ReviewResponse.java            [Phase 4.5]
    ├── StudySessionSummaryResponse.java [Phase 4.5]
    ├── VocabularyTopicResponse.java   [Phase 5.3]
    ├── VocabularyWordResponse.java    [Phase 5.3]
    ├── ExerciseSessionResponse.java   [Phase 6.3]
    ├── ExerciseCompleteResponse.java  [Phase 6.3]
    ├── UserTestStartResponse.java     [Phase 7.3]
    ├── UserTestSubmitResponse.java    [Phase 7.3]
    ├── TestHistoryItem.java           [Phase 7.3]
    └── HomeDashboardResponse.java     [Phase 8.1]

src/main/resources/db/migration/
    ├── V8__user_xp_streak_badges.sql  [Phase 2 / Phase 3]
    ├── V9__vocabulary_module.sql      [Phase 2 / Phase 5]
    └── V10__exercise_test_study.sql   [Phase 2 / Phase 6-7] ✅ Done 2026-05-17
```

---

## Files cần SỬA

| File | Thay đổi |
|------|---------|
| `GrammarController.java` | Đổi `/grammar` → `/api/grammar` |
| `DeskApiController.java` | Thêm PUT + DELETE flashcard endpoints |
| `DeskFlashcardService.java` | Thêm `updateFlashcard()` + `deleteFlashcard()` |
| `FlashcardRepository.java` | Thêm `findByIdAndDesk_Id()` |
| `User.java` | Thêm fields: `totalXp`, `currentStreak`, `longestStreak`, `lastActiveDate` |
