# CHANGELOG

Lịch sử thay đổi backend EnglishMe trong giai đoạn thu gọn phạm vi đồ án.

## [scope-reduction] — 2026-05-17 → 2026-05-18

### Mục tiêu
Cắt phạm vi từ MVP team 3–4 người về scope phù hợp cho luận văn 1 sinh viên,
tập trung 3 trụ kỹ thuật: **SM-2 spaced repetition**, **Pronunciation
Assessment AI**, **Placement Test thích ứng CEFR**.

---

### Phase 0 — Chuẩn bị (Step 0.1 – 0.3)
- Tạo branch `scope-reduction`, snapshot routes hiện tại.
- Đổi `spring.jpa.hibernate.ddl-auto` từ `update` sang `validate`.

### Phase 1 — Xoá module (Step 1.1 – 1.17)
Đã xoá 11 module thứ cấp; sidebar admin từ 18 menu còn 8 menu.

| Step | Module bị xoá |
|---|---|
| 1.1  | Chat AI (DeepSeek) — controller, service, DTO, block `deepseek:` trong config |
| 1.2  | FCM Push Notification — `FcmPushService`, `AdminNotificationController`, `DeviceTokenApiController`, 2 entity, 2 JSP |
| 1.3  | App Announcement — controller, entity, JSP |
| 1.4  | Home Dashboard Content (Word of Day / Recommendation / Banner) — controller, 3 entity, 3 JSP |
| 1.5  | Pronunciation Exercise CRUD admin + Analytics — controller, service, 2 JSP (giữ entity + mobile API) |
| 1.6  | Test Bank admin — controller, service, 2 JSP (giữ `Question` + placement API) |
| 1.7  | Badge admin UI — controller, service, 2 JSP (giữ entity + auto-award qua `ProgressService`) |
| 1.8  | Study Session Monitoring admin — controller, service, 2 JSP |
| 1.9  | System Configuration UI — controller, service, entity, JSP, drop `app_config` |
| 1.10 | Audit Log + Admin DB Management — `AuditLogInterceptor`, 2 controller, 2 entity, 2 JSP |
| 1.11 | Exercise Sessions admin pages — 2 endpoint, 2 JSP, method service liên quan |
| 1.12 | Dashboard heatmap + donut + content placeholder → còn KPI + 2 chart core |
| 1.13 | User Detail — bỏ 4 action POST risky (reset progress, grant XP, award badge, change level), giữ lock/unlock/delete soft |
| 1.14 | Migration `V15__drop_optional_tables.sql` — DROP 9 bảng đã bị xoá entity |
| 1.15 | Cấu hình `application.yaml` / `application.properties` — bỏ block không dùng |
| 1.16 | Sidebar còn 8 menu: Dashboard, Users, Vocabulary, Grammar, Desks, Exercises, Pronunciation, Placement Test |
| 1.17 | Smoke test toàn bộ admin + API mobile |

### Phase 2 — Bổ sung chất lượng (Step 2.1 – 2.9)
- **2.1** `SM2ServiceTest` — 10 unit test cover công thức EF/interval/lapse + xpForQuality.
- **2.2** `PlacementTestServiceTest` — 8 unit test cover start/answer/complete + suy luận CEFR + edge case (duplicate answer, session đã completed, câu ngoài session).
- **2.3** `PronunciationScoringMapperTest` — bổ sung 4 test (empty word list, clamp score, ordering theo start, skip empty tokens). Tổng 6 test.
- **2.4** `PlacementTestFlowIT` — 3 integration test end-to-end với H2 in-memory (Hibernate `create-drop`, tắt Flyway), bao gồm full flow start → answer x N → complete và 2 case lỗi.
- **2.5** Refactor `CloudPronunciationClient` thành interface + 2 implementation `SpeechacePronunciationClient` / `MockPronunciationClient`, chọn qua property `englishme.ai.pronunciation.provider = speechace|mock`. Khi `speechace` nhưng thiếu API key, fallback tự động sang mock. Bổ sung `MockPronunciationClientTest` (4 test).
- **2.6** Migration `V16__demo_seed.sql` — 5 demo user (A1..C1) + 14 dòng XP history + 30 placement test question (5/CEFR × 6 mức). Idempotent ở các bảng có unique key.
- **2.7** Skip cleanup sâu — Phase 1 đã cleanup từng step, build sạch không có orphan rõ.
- **2.8** CHANGELOG (file này).
- **2.9** `mvn clean verify` toàn bộ test xanh.

### Tổng kết test
- **Trước Phase 2:** 1 test (`EnglishmeApplicationTests.contextLoads`) + 2 test pronunciation cũ.
- **Sau Phase 2:** ~31 unit/integration test xanh:
  - SM2ServiceTest: 10
  - PlacementTestServiceTest: 8
  - PronunciationScoringMapperTest: 6
  - PronunciationAssessmentServiceTest: 3 (giữ nguyên)
  - MockPronunciationClientTest: 4
  - PlacementTestFlowIT: 3
  - EnglishmeApplicationTests: 1

### Tổng kết schema
- Migration đã chạy: V1 → V16.
- V15 drop: `admin_audit_log`, `admin_account`, `app_config`, `app_announcement`, `admin_notification`, `user_device_token`, `home_banner`, `home_recommendation`, `home_word_of_day`.
- V16 seed: 5 demo user + 30 placement test question.

### Cấu hình tối thiểu để chạy
- PostgreSQL 14+ (development) — port 5432, DB `englishme_db`.
- Firebase Auth credentials (`serviceAccountKey.json` ở classpath).
- Pronunciation: không bắt buộc Speechace API key — không có key sẽ fallback mock.

### Sidebar admin (8 menu sau khi cắt)
1. Dashboard
2. Users (list + lock/unlock + detail xem-only)
3. Vocabulary (topic + word CRUD + import/export)
4. Grammar (topic + lesson + exercise CRUD)
5. Desks (admin view)
6. Exercises (question CRUD)
7. Pronunciation (attempt list)
8. Placement Test (read-only)
