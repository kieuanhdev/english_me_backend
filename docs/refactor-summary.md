# EnglishMe Refactor Summary (2026-05-07)

## Done

### 1. AuthController.sync() returns DTO
- Created `dto/UserSyncResponse` record — exposes only safe fields (`id`, `email`, `fullName`, `avatarUrl`, `cefrLevel`, `isOnboarded`, `createdAt`)
- `AuthController.sync()` no longer leaks `firebaseUid` and `accountLocked` to client

### 2. Replace @Data on entities with lazy relationships (7 entities)
- Replaced `@Data` → `@Getter`/`@Setter` + `@EqualsAndHashCode(onlyExplicitlyIncluded = true)` + `@ToString(exclude = {...})`
- Added `@EqualsAndHashCode.Include` on each `id` field
- Files: `Desk` (exclude `owner`), `Flashcard` (exclude `desk`), `TestSession` (exclude `user`, `answers`), `TestAnswer` (exclude `testSession`, `question`), `GrammarTopic`, `GrammarLesson` (exclude `topic`), `GrammarExercise` (exclude `lesson`)
- Prevents `LazyInitializationException` from accidental `toString()`/`equals()`/`hashCode()` calls on lazy proxies

### 3. Consistent GenerationType
- Changed 7 entities from `GenerationType.AUTO` → `GenerationType.UUID` to match the rest
- All 11 entities now consistently use `UUID` strategy

### 4. Consistent DTO style — @Data → records
- Converted 15 `@Data` DTOs to Java records (excludes `DeskResponse` + `FlashcardResponse` — kept as `@Data` because JSP EL needs `getXxx()` accessors)
- Request DTOs: `AnswerQuestionRequest`, `ChatRequest`, `CreateDeskRequest`, `CreateFlashcardRequest`, `SubmitTestRequest`, `UpdateDeskRequest`
- Response DTOs: `AnswerQuestionResponse`, `ChatMessageDto`, `GrammarExerciseResponse`, `GrammarLessonListItemResponse`, `GrammarLessonDetailResponse`, `GrammarTopicResponse`, `QuestionDto`, `StartTestResponse`, `TestResultResponse`
- Updated all construction sites and getter calls across `GrammarService`, `PlacementTestService`, `DeskFlashcardService`, `AdminViewController`, `GroqChatService`

### 5. DB query instead of in-memory filtering
- **`UserService.findUsersByFilter()`**: replaced `findAll()` + stream filter with JPA `Specification` — filters `cefrLevel`, `accountLocked`, and keyword (LIKE on `fullName`, `email`, `firebaseUid`) now run in DB.
- **`DeskFlashcardService.listDesks(String)`**: replaced `findAll()` + in-memory filter/sort with `findAllAccessibleByOwner()` query.
- **`DeskFlashcardService.listDesks()` (legacy)**: replaced `findAll()` + in-memory filter/sort with `findAllByOwnerIsNullOrderBySortOrderAsc()`.
- **`DeskFlashcardService.createDesk()` (legacy)**: replaced `listDesks().stream().map(DeskResponse::getSortOrder).max(...)` with direct `findMaxSortOrderWhereOwnerIsNull()` DB query.
- **`UserRepository`**: extended with `JpaSpecificationExecutor<User>`.

### 6. Fix N+1 query in `toDeskResponse()`
- Replaced per-desk `countByDesk_Id()` with single batch `countByDeskIds()` grouped query.
- Added `countByDeskIdsAsMap(Set<UUID>)` default method on `FlashcardRepository` for convenient lookup.
- Changed `toDeskResponse(Desk)` → `toDeskResponses(List<Desk>)` to batch all counts before mapping.

### 7. Remove dead code
- Deleted `entity/FlashcardProgress.java` — unused SM-2 entity
- Deleted `repository/FlashcardProgressRepository.java` — never injected

### 8. @Autowired → constructor injection (8 files)
| File | Fields |
|------|--------|
| `controller/AuthController.java` | `UserService` |
| `controller/AdminAuthViewController.java` | `AdminAuthService` |
| `controller/AdminViewController.java` | `UserService`, `DeskFlashcardService`, `PronunciationAssessmentService` |
| `controller/PlacementTestController.java` | `PlacementTestService` |
| `service/UserService.java` | `UserRepository` |
| `service/PlacementTestService.java` | 5 repos + UserService |
| `config/QuestionDataInitializer.java` | `QuestionRepository`, `ObjectMapper` |
| `config/WebMvcConfig.java` | `AdminRoleInterceptor` |

### 9. Extract Firebase token verification
- Created `service/FirebaseAuthHelper.java` — shared `verifyBearer(String)` → `FirebaseToken`
- Replaced 5 inline copies in: `AuthController`, `ChatApiController`, `DeskApiController`, `PronunciationApiController`, `PlacementTestController`
- Removed ~50 lines of duplicated code

### 10. Code style fixes
- `GrammarExerciseRepository`: removed unused `existsByLesson()`
- `GrammarService`: `.collect(Collectors.toList())` → `.toList()`, `java.util.UUID` → `UUID`
- `PlacementTestService`: `.collect(Collectors.toList())` → `.toList()`
- `FirebaseConfig`: `javax.annotation.PostConstruct` → `jakarta.annotation.PostConstruct`
- `GrammarDataInitializer`: `System.out.printf` → SLF4J `log.info`
- `QuestionDataInitializer`: `System.out.printf` → SLF4J `log.info`
- Cleaned unused imports across all modified files

### 11. DeskFlashcardService dedup
- Extracted `buildAndSaveFlashcard()` — shared flashcard creation logic (~25 lines saved)
- Extracted `listFlashcardsForDesk()` — shared query/mapping for flashcard listing
- Extracted `buildAndSaveDesk()` — shared desk creation field-setting
- Extracted `requireCefrLevel()` + `requireNonNegativeSortOrder()` — shared validation

### 12. PronunciationAssessmentService single save
- Eliminated double-save in `assess()`: pre-generate `attemptId`, call cloud API, create attempt with real scores → save once

### 13. Minor fixes
- **`PronunciationRateLimiter`**: moved `userWindowMap.remove()` inside synchronized block — fixes benign race
- **`WebMvcConfig`**: added `/admin/logout` to interceptor exclude patterns
- **`QuestionDataInitializer`**: replaced unchecked cast `(Map<String, String>) raw.get("options")` with type-safe `objectMapper.convertValue(..., new TypeReference<>() {})`
- **`FirebaseConfig`**: added null check for `serviceAccountKey.json` with clear error message

---

**Status: ALL DONE**
