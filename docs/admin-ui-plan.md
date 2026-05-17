# Admin Dashboard & API UI Plan

## Completed Changes

### 1. Dashboard — Real Data ✅
- [x] Replaced hardcoded stats with real data from DB
- [x] Shows: total users, active today, total desks, total flashcards, pronunciation attempts
- [x] Added `DashboardStats` DTO
- [x] Added `countActiveSince()` to `UserRepository`
- [x] Added `countSince()` to `PronunciationAttemptRepository`
- [x] Dashboard now shows quick navigation links + system status

### 2. Fix Vietnamese Text ✅
- [x] `users.jsp`: All diacritics fixed (Quan ly → Quản lý, etc.)
- [x] `pronunciation.jsp`: All diacritics fixed
- [x] `login.jsp`: All diacritics fixed
- [x] `dashboard.jsp`: Updated Vietnamese text

### 3. Sidebar — Add Missing Links ✅
- [x] Added Grammar link (auto_stories icon)
- [x] Added Placement Test link (quiz icon)
- [x] Removed dead "Reports" link

### 4. Grammar Admin UI (NEW) ✅
- [x] `GET /admin/grammar` — Topics list with category, level, lesson count
- [x] `GET /admin/grammar/topics/{id}` — Lessons list per topic
- [x] `GET /admin/grammar/lessons/{id}` — Lesson detail with full content + exercises
- [x] Created 3 JSP views: `grammar.jsp`, `grammar-lessons.jsp`, `grammar-lesson-detail.jsp`

### 5. Placement Test Admin UI (NEW) ✅
- [x] `GET /admin/placement-test` — Sessions list with user, status, result, score
- [x] `GET /admin/placement-test/{id}` — Session detail with answer review
- [x] Shows correct/wrong/skipped answers with question options highlighted
- [x] Added `findAllWithUser()` and `findByIdWithUser()` to `TestSessionRepository`
- [x] Created 2 JSP views: `placement-test.jsp`, `placement-test-detail.jsp`

### 6. Desk Detail — Add Delete Flashcard ✅
- [x] Added delete button for each flashcard with confirmation dialog
- [x] Added `POST /admin/desks/{deskId}/flashcards/{flashcardId}/delete`
- [x] Added `deleteFlashcard()` method to `DeskFlashcardService`

### 7. Chat History Admin UI
- Skipped — Chat API is purely backend, no admin monitoring needed currently

## Files Created
- `src/main/java/com/kiovant/englishme/dto/DashboardStats.java`
- `src/main/webapp/WEB-INF/views/admin/grammar.jsp`
- `src/main/webapp/WEB-INF/views/admin/grammar-lessons.jsp`
- `src/main/webapp/WEB-INF/views/admin/grammar-lesson-detail.jsp`
- `src/main/webapp/WEB-INF/views/admin/placement-test.jsp`
- `src/main/webapp/WEB-INF/views/admin/placement-test-detail.jsp`

## Files Modified
- `src/main/java/com/kiovant/englishme/controller/AdminViewController.java` — Added GrammarService, repositories, dashboard stats, grammar/placement-test endpoints, delete flashcard
- `src/main/java/com/kiovant/englishme/service/DeskFlashcardService.java` — Added `deleteFlashcard()` method
- `src/main/java/com/kiovant/englishme/repository/UserRepository.java` — Added `countActiveSince()`
- `src/main/java/com/kiovant/englishme/repository/PronunciationAttemptRepository.java` — Added `countSince()`
- `src/main/java/com/kiovant/englishme/repository/TestSessionRepository.java` — Added `findAllWithUser()`, `findByIdWithUser()`
- `src/main/webapp/WEB-INF/views/admin/dashboard.jsp` — Rewritten with real data
- `src/main/webapp/WEB-INF/views/admin/users.jsp` — Fixed Vietnamese diacritics
- `src/main/webapp/WEB-INF/views/admin/pronunciation.jsp` — Fixed Vietnamese diacritics
- `src/main/webapp/WEB-INF/views/admin/login.jsp` — Fixed Vietnamese diacritics
- `src/main/webapp/WEB-INF/views/admin/layout/sidebar.jspf` — Added Grammar & Placement Test links
- `src/main/webapp/WEB-INF/views/admin/desk-detail.jsp` — Added delete flashcard button
