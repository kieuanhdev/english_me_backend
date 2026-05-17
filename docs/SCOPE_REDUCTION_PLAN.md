# KẾ HOẠCH THU GỌN PHẠM VI ĐỒ ÁN — EnglishMe

> **Ngày lập:** 2026-05-17
> **Bối cảnh:** Đồ án tốt nghiệp (luận văn) — 1 sinh viên — còn ~2 tuần code + sau đó cleanup & viết tài liệu.
> **Định hướng:** Cắt vừa (giữ ~60–70% scope hiện tại) — bỏ module phụ, đào sâu module lõi để đủ chiều sâu thuyết trình.

---

## 1. CHẨN ĐOÁN HIỆN TRẠNG

Dự án hiện đã có **quy mô của một MVP team 3–4 người**:

| Hạng mục | Số lượng |
|---|---|
| Module nghiệp vụ | 15 |
| Migration DB | 14 (V1–V14) |
| Entity | 32 |
| Controller (REST + MVC) | ~30 |
| Service | ~30 |
| API mobile endpoint | 32+ |
| Admin JSP page | ~40 |
| Tích hợp ngoài | Firebase Auth, FCM Push, Google Cloud Pronunciation, DeepSeek Chat AI |

**Vấn đề khi giữ nguyên scope cho luận văn 1 người:**

1. **Không đủ thời gian polish** — code rộng nhưng nông, dễ bị hỏi sâu vào module phụ mà chưa hoàn thiện (push, audit, home content scheduling…).
2. **Phụ thuộc dịch vụ trả phí / phức tạp setup** — DeepSeek API key, FCM service account, Google Cloud project — hội đồng demo có thể không chạy được.
3. **Quá tải khi viết tài liệu** — 15 module × (ERD + sequence + use case + giải thích) ≈ ngoài tầm 2 tuần cleanup.
4. **Luận văn cần "điểm nhấn kỹ thuật" hơn là bề rộng** — nên đào sâu 2–3 thuật toán/AI rồi thuyết trình kỹ.

---

## 2. NGUYÊN TẮC THU GỌN

1. **Giữ những gì có "chiều sâu thuật toán"** để luận văn có chương kỹ thuật rõ ràng.
2. **Bỏ module phụ thuộc API trả phí / cần setup phức tạp** (FCM, DeepSeek) — demo không phụ thuộc internet ngoài.
3. **Bỏ module chỉ có CRUD không có logic nghiệp vụ đặc biệt** — không tạo "chiều sâu" cho luận văn.
4. **Mobile sẵn sàng sửa theo backend** — không phải giữ contract API, được phép xóa endpoint cùng nút trên app.
5. **Hai trục đánh giá:** *Giá trị thuyết trình* × *Chi phí duy trì* — bỏ những module thấp × cao.

---

## 3. BA NHÓM CỐT LÕI ĐỀ XUẤT (3 ĐIỂM NHẤN LUẬN VĂN)

Đề xuất xây luận văn xoay quanh 3 trụ kỹ thuật này — giữ chúng nguyên vẹn và đào sâu:

### Trụ 1 — Học từ vựng với thuật toán **SM-2 (SuperMemo)**
- Flashcard + Desk + Study Session + SM-2 spaced repetition.
- Chương luận văn: lý thuyết SM-2 → công thức EF/interval/repetitions → trình bày `SM2Service` → demo lịch ôn tập.

### Trụ 2 — Đánh giá phát âm bằng AI (**Pronunciation Assessment**)
- Giữ Google Cloud Pronunciation hoặc fallback rule-based đơn giản.
- Chương luận văn: API Google trả về gì → cách map sang điểm/word feedback → cách lưu attempt + tổng hợp top-từ phát âm sai.

### Trụ 3 — **Placement Test thích ứng CEFR**
- Khởi tạo session → trả câu hỏi theo level → suy luận CEFR cuối.
- Chương luận văn: thuật toán chọn câu hỏi → cách tính `cefrSuggestion` → so sánh với CAT/IRT (paper).

Mọi module khác chỉ là **vệ tinh hỗ trợ** 3 trụ này.

---

## 4. BẢNG QUYẾT ĐỊNH: GIỮ / CẮT

### 4.1 GIỮ (core — bắt buộc cho 3 trụ)

| # | Module | Lý do giữ | Cần làm thêm |
|---|---|---|---|
| 1 | **Auth & User (Firebase + Profile)** | Mọi flow phụ thuộc | Giữ nguyên |
| 2 | **Desk & Flashcard CRUD** + API mobile | Trụ 1 — SM-2 cần data này | Giữ nguyên |
| 3 | **Study Session SM-2** + API mobile | **Trụ 1** | Viết test cho `SM2Service`; chuẩn hoá XP formula |
| 4 | **Vocabulary CRUD admin + API mobile** | Nội dung học cơ bản | Giữ nguyên (import JSON + export CSV đã đủ) |
| 5 | **Grammar CRUD admin + API mobile** | Nội dung học cơ bản | Bỏ "rich text editor / versioning / drag-drop" trong nợ — không cần |
| 6 | **Pronunciation Attempt** + API `/assess` | **Trụ 2** | Giữ Google Cloud, có fallback mock nếu không có API key (để demo offline) |
| 7 | **Placement Test** + API mobile | **Trụ 3** | Viết test cho `PlacementTestService`; vẽ flow chart trong luận văn |
| 8 | **Exercise Bank** (chỉ CRUD + API mobile cho gameplay) | Bài tập luyện tập | Bỏ trang `exercises/sessions` admin (Module 4 phần D) — giữ list câu hỏi đủ |
| 9 | **XP / Streak** | Gamification cơ bản | Giữ nguyên — đã wire vào `ProgressService` |
| 10 | **Dashboard Analytics** (KPI + 2 chart core) | Trang đầu admin | Cắt: heatmap, donut content distribution, system health (giữ static), top-N từ vựng/grammar placeholder |
| 11 | **User Management** (list/lock/unlock/detail) | Hỗ trợ vận hành cơ bản | Cắt: grant XP, award badge, reset progress (giữ lock/unlock + detail xem-only) |
| 12 | **Admin Auth (static)** | Đăng nhập admin | Giữ static credential trong `application.yml` — bỏ Module 13 admin DB management |

### 4.2 CẮT BỎ HOÀN TOÀN

| # | Module / Tính năng | Lý do cắt | Cách bỏ |
|---|---|---|---|
| C1 | **Chat AI (DeepSeek)** — endpoint `/api/chat`, `ChatApiController`, `DeepSeekChatService` | Phụ thuộc API key trả phí, không phải core học tập, dễ hỏng demo | Xóa controller + service + entity + nút Chat ở mobile |
| C2 | **FCM Push Notification** (Module 11 phần push) | Phụ thuộc service account + thiết bị thật, không demo được trên web | Xóa `FcmPushService`, `AdminNotificationController`, `DeviceTokenApiController`, bảng `user_device_token` + `admin_notification` |
| C3 | **App Announcement** (Module 11 phần announcement) | Đi kèm push, không có giá trị độc lập | Xóa `AnnouncementApiController`, `AdminAnnouncementController` (nếu tách riêng), bảng `app_announcement` |
| C4 | **Home Dashboard Content** (Module 10 — Word of Day, Recommendation, Banner) | Chưa wire vào mobile, hard-code recommendation hiện đã đủ cho demo | Xóa `AdminHomeContentController`, 3 entity + 3 JSP, bảng `home_word_of_day` / `home_recommendation` / `home_banner`. `HomeDashboardService` giữ logic hard-code hiện tại. |
| C5 | **Pronunciation Exercise CRUD admin + Analytics** (Module 8) | Admin có thể seed bằng SQL, attempt list đã đủ thuyết trình Trụ 2 | Xóa `AdminPronunciationExerciseController`, `AdminPronunciationExerciseService`, 2 JSP, giữ entity `PronunciationExercise` (seed bằng V7) |
| C6 | **Test Bank admin CRUD + Stats** (Module 5) | Đã có placement test seed từ `dauvaotest.json` — không cần CRUD UI | Xóa `AdminTestBankController` + service + 2 JSP. Giữ `Question` + seed JSON. |
| C7 | **Badge Management UI nâng cao** (Module 7 — re-evaluate, icon upload, user-detail badge management) | Giữ list badge + auto-award qua `ProgressService.evaluateBadges` là đủ | Xóa `AdminBadgeController` (giữ `Badge` entity + auto-award), xóa `badges.jsp` + `badge-users.jsp` |
| C8 | **Study Session Monitoring** (Module 9 — read-only admin) | Read-only, ít giá trị thuyết trình | Xóa `AdminStudySessionController` + service + 2 JSP |
| C9 | **System Configuration** (Module 12 — app_config UI) | Demo dùng `application.yml` là đủ; chưa wire service nào đọc từ DB | Xóa `AdminConfigController` + service + entity + JSP. Drop bảng `app_config` (Flyway V14 → đánh dấu "rollback in V15"). |
| C10 | **Audit Log + Admin DB Management** (Module 13 nâng cao) | Auth static đã đủ; audit không có before/after không có giá trị | Xóa `AdminManagementController`, `AdminAuditController`, interceptor `AuditLogInterceptor`. Drop bảng `admin_account` + `admin_audit_log`. |
| C11 | **Exercise Sessions admin page** (Module 4 phần D, E) | Giữ list câu hỏi đủ; session monitoring trùng Module 9 đã bỏ | Xóa `exercise-sessions.jsp` + `exercise-session-detail.jsp` + endpoint tương ứng |
| C12 | **Dashboard heatmap + donut + content-usage placeholder** | Placeholder không có data thật → mất uy tín khi demo | Đơn giản hoá `dashboard.jsp` còn 6 KPI + 2 chart (user mới 14d + XP cấp 7d) |
| C13 | **User Detail — grant XP / award badge / reset progress** | Risky, ít dùng demo | Giữ trang detail xem-only (profile + stats + badges + biểu đồ XP) — xóa 3 action POST |
| C14 | **API mobile thuộc các module đã bỏ** | Mobile sẽ sửa theo backend | Xóa endpoint: `/api/chat`, `/api/users/me/devices`, `/api/announcements/active`. Mobile cập nhật theo. |

### 4.3 GIỮ Ở MỨC TỐI THIỂU (không đầu tư thêm)

| Module | Trạng thái sau khi thu gọn |
|---|---|
| Migration V1–V10 | Giữ nguyên (đã có data) |
| Migration V11–V14 | Tạo migration `V15__drop_optional_tables.sql` để DROP các bảng không dùng nữa (xem mục 6) |
| `WebMvcConfig` | Bỏ `AuditLogInterceptor`, giữ `AdminRoleInterceptor` |
| `OpenApiConfig` | Giữ — có Swagger là điểm cộng luận văn |
| `Dockerfile` + `docker-compose.yml` | Giữ — minh chứng triển khai |

---

## 5. CẦN BỔ SUNG (cho hệ thống hoàn chỉnh & luận văn)

Đây là phần **thêm vào** sau khi cắt — không phải tính năng mới mà là *chất lượng kỹ thuật* mà luận văn yêu cầu:

### 5.1 Code & chất lượng

| # | Hạng mục | Mô tả | Effort |
|---|---|---|---|
| A1 | **Unit test cho `SM2Service`** | Cover công thức EF/interval theo paper SuperMemo. 8–10 test case. | 0.5 ngày |
| A2 | **Unit test cho `PlacementTestService`** | Cover start → answer → complete → cefr suggestion. 5–6 test case. | 0.5 ngày |
| A3 | **Unit test cho `PronunciationScoringMapper`** | Cover mapping Google response → DTO. 3–4 test case. | 0.3 ngày |
| A4 | **Integration test 1 flow end-to-end** | `@SpringBootTest` cho placement test: start → answer 5 câu → complete. Dùng `@DataJpaTest` + H2 hoặc Testcontainers. | 0.7 ngày |
| A5 | **Seed data demo đầy đủ** | 5 user demo (mỗi CEFR 1 user), 5 vocabulary topic × 10 từ, 5 grammar topic × 3 lesson, 30 exercise question, 10 pronunciation exercise, 30 placement question. Viết Flyway `V16__demo_seed.sql`. | 1 ngày |
| A6 | **Fallback mock cho Pronunciation API** | Nếu `google.application.credentials` không set → trả điểm random nhưng hợp lý (60–95). Tránh demo bị 500. | 0.3 ngày |
| A7 | **Cleanup dead code** | Xóa import, file, JSP, route của module đã cắt. Build pass. | 0.5 ngày |
| A8 | **Migration rollback `V15__drop_optional_tables.sql`** | DROP các bảng module đã cắt | 0.2 ngày |

### 5.2 Tài liệu (cho luận văn — làm sau giai đoạn code)

| # | Tài liệu | Mô tả |
|---|---|---|
| D1 | **README.md** | Project description, prerequisites, setup steps (PostgreSQL + Firebase optional), how to run dev + Docker, screenshots. |
| D2 | **`docs/architecture.md`** | Architecture diagram (PlantUML hoặc draw.io PNG): mobile ↔ Spring Boot ↔ Postgres + Firebase + Google Cloud. |
| D3 | **`docs/erd.png`** | ERD render từ `dbdiagram.io` hoặc PlantUML, chỉ các bảng còn lại sau cắt. |
| D4 | **`docs/sequence-sm2.png`** | Sequence diagram: mobile gọi `/study-sessions/{id}/review` → service → SM2Service → repository. |
| D5 | **`docs/sequence-pronunciation.png`** | Sequence diagram: upload audio → Google API → mapping → save attempt. |
| D6 | **`docs/sequence-placement-test.png`** | Sequence diagram cho test thích ứng. |
| D7 | **`docs/api-reference.md`** | Export Swagger JSON sang Markdown (hoặc link Swagger UI). |
| D8 | **`docs/admin-user-guide.md`** | Hướng dẫn dùng admin panel: login, CRUD vocab/grammar, xem dashboard. |
| D9 | **`docs/demo-script.md`** | Kịch bản 10 phút thuyết trình: login → tạo topic vocab → user mobile học SM-2 → đánh giá phát âm → placement test → xem dashboard. |
| D10 | **`docs/thesis-outline.md`** | Đề cương luận văn theo chuẩn trường (Mở đầu, Cơ sở lý thuyết, Phân tích thiết kế, Cài đặt, Kết quả thực nghiệm, Kết luận). |

---

## 6. CHI TIẾT KỸ THUẬT THU GỌN

### 6.1 Files / packages cần XÓA

```
src/main/java/com/kiovant/englishme/
├── controller/
│   ├── ChatApiController.java                       ❌ (C1)
│   ├── DeviceTokenApiController.java                ❌ (C2)
│   ├── AnnouncementApiController.java               ❌ (C3)
│   ├── AdminHomeContentController.java              ❌ (C4)
│   ├── AdminPronunciationExerciseController.java    ❌ (C5)
│   ├── AdminTestBankController.java                 ❌ (C6)
│   ├── AdminBadgeController.java                    ❌ (C7)
│   ├── AdminStudySessionController.java             ❌ (C8)
│   ├── AdminConfigController.java                   ❌ (C9)
│   ├── AdminManagementController.java               ❌ (C10)
│   ├── AdminAuditController.java                    ❌ (C10)
│   └── AdminNotificationController.java             ❌ (C2)
├── service/
│   ├── DeepSeekChatService.java                     ❌ (C1)
│   ├── FcmPushService.java                          ❌ (C2)
│   ├── AdminHomeContentService.java                 ❌ (C4)
│   ├── AdminPronunciationExerciseService.java       ❌ (C5)
│   ├── AdminTestBankService.java                    ❌ (C6)
│   ├── AdminBadgeService.java                       ❌ (C7)
│   ├── AdminStudySessionService.java                ❌ (C8)
│   ├── AppConfigService.java                        ❌ (C9)
│   ├── AdminManagementService.java                  ❌ (C10)
│   ├── AdminAuditLogService.java                    ❌ (C10)
│   └── AdminNotificationService.java                ❌ (C2)
├── interceptor/
│   └── AuditLogInterceptor.java                     ❌ (C10)
├── entity/
│   ├── UserDeviceToken.java, AdminNotification.java ❌ (C2)
│   ├── AppAnnouncement.java                         ❌ (C3)
│   ├── HomeWordOfDay.java, HomeRecommendation.java,
│   │   HomeBanner.java                              ❌ (C4)
│   ├── AppConfig.java                               ❌ (C9)
│   └── AdminAccount.java, AdminAuditLog.java        ❌ (C10)
├── repository/
│   └── (các repository tương ứng entity bị xóa)     ❌
├── dto/
│   └── (DTO chỉ phục vụ module đã cắt)              ❌
└── (giữ nguyên các package khác)

src/main/webapp/WEB-INF/views/admin/
├── notifications.jsp                                ❌ (C2)
├── notification-stats.jsp                           ❌ (C2)
├── announcements.jsp                                ❌ (C3)
├── home-banners.jsp, home-recommendations.jsp,
│   home-word-of-day.jsp                             ❌ (C4)
├── pronunciation-exercises.jsp                       ❌ (C5)
├── pronunciation-analytics.jsp                      ❌ (C5)
├── test-bank.jsp, test-bank-stats.jsp               ❌ (C6)
├── badges.jsp, badge-users.jsp                      ❌ (C7)
├── study-sessions.jsp, study-session-detail.jsp     ❌ (C8)
├── exercise-sessions.jsp,
│   exercise-session-detail.jsp                      ❌ (C11)
├── config.jsp                                       ❌ (C9)
├── admin-accounts.jsp, audit-log.jsp                ❌ (C10)
└── layout/sidebar.jspf                              🔧 cập nhật chỉ giữ entry còn lại
```

### 6.2 Migration mới

```sql
-- src/main/resources/db/migration/V15__drop_optional_tables.sql

DROP TABLE IF EXISTS admin_audit_log;
DROP TABLE IF EXISTS admin_account;
DROP TABLE IF EXISTS app_config;
DROP TABLE IF EXISTS app_announcement;
DROP TABLE IF EXISTS admin_notification;
DROP TABLE IF EXISTS user_device_token;
DROP TABLE IF EXISTS home_banner;
DROP TABLE IF EXISTS home_recommendation;
DROP TABLE IF EXISTS home_word_of_day;
```

```sql
-- src/main/resources/db/migration/V16__demo_seed.sql
-- 5 users, 5 vocab topics × 10 từ, 5 grammar topic × 3 lesson, 30 exercise question,
-- 10 pronunciation exercise, 30 placement question. Đảm bảo demo chạy ngay sau migrate.
```

### 6.3 Cấu hình bỏ phụ thuộc

`application.yml` cần làm:
- Xóa block `deepseek.*`.
- Xóa block `firebase.fcm.*` (nếu có) — giữ Firebase Auth.
- Đặt `google.application.credentials` thành **optional** — nếu thiếu, `PronunciationAssessmentService` rơi vào fallback mock (A6).

### 6.4 Sidebar còn lại

```
Admin
├── 📊 Dashboard
├── 👥 Users         (list + lock/unlock + detail xem-only)
├── 📚 Vocabulary    (topic CRUD + word CRUD + import/export)
├── 📖 Grammar       (topic + lesson + exercise CRUD)
├── 📑 Desks         (admin xem desk người dùng — giữ nguyên)
├── 🎯 Exercises     (question CRUD)
├── 🗣 Pronunciation (attempt list — giữ nguyên)
└── 🧪 Placement Test (read-only)
```

8 menu thay vì 18 menu — gọn, dễ thuyết trình.

---

## 7. LỘ TRÌNH 2 TUẦN CODE + 1–2 TUẦN DOCS

### Tuần 1 — Cắt + ổn định build

| Ngày | Việc | Output |
|---|---|---|
| T2 | Xóa Module C1, C2, C3 (Chat, FCM, Announcement) + cleanup mobile gọi `/api/chat` & `/api/users/me/devices` | Build pass; mobile bỏ nút Chat/notification |
| T3 | Xóa Module C4, C5 (Home Content, Pronunciation Exercise CRUD) | Build pass |
| T4 | Xóa Module C6, C7, C8 (Test Bank, Badge UI, Study Monitor) | Build pass |
| T5 | Xóa Module C9, C10, C11 (Config, Audit, Admin DB, Exercise sessions admin) | Build pass; chỉ còn 8 menu |
| T6 | Viết `V15__drop_optional_tables.sql` + chạy migrate sạch; rà sidebar | DB sạch |
| T7 | A6 (Pronunciation mock fallback) + thử demo offline | Demo offline chạy được |

### Tuần 2 — Bổ sung chất lượng & seed

| Ngày | Việc | Output |
|---|---|---|
| T2 | A1 (test `SM2Service`) | 8 unit test green |
| T3 | A2 + A3 (test `PlacementTestService`, `PronunciationScoringMapper`) | Thêm test green |
| T4 | A4 (integration test placement test) | 1 integration test green |
| T5 | A5 (seed demo `V16__demo_seed.sql`) | Demo data đầy đủ |
| T6 | A7 (cleanup dead code, format, lint) + chạy `mvn clean install` | Build success, không warning thừa |
| T7 | Sửa mobile theo backend (xóa Chat tab, FCM init, announcement card), test smoke với 1 user demo | Mobile + backend chạy chung |

### Tuần 3–4 — Cleanup + tài liệu

| Ngày | Việc |
|---|---|
| W3 T2 | D1 (README.md) + screenshot |
| W3 T3 | D2 + D3 (architecture + ERD) |
| W3 T4 | D4 + D5 + D6 (3 sequence diagrams) |
| W3 T5 | D7 (API reference) + D8 (admin user guide) |
| W3 T6 | D9 (demo script) |
| W3 T7 | D10 (thesis outline) + soát commit log → CHANGELOG.md |
| W4 | Đọc luận văn nháp, đối chiếu code, fix mâu thuẫn |

---

## 8. RỦI RO & GIẢM THIỂU

| Rủi ro | Tác động | Cách giảm thiểu |
|---|---|---|
| Mobile vẫn gọi endpoint đã xóa → 404 | Demo lỗi | Liệt kê chính xác endpoint xóa (mục 4.2 C14); commit mobile cùng PR backend. |
| Pronunciation API thiếu key khi demo | Demo trắng | A6 — fallback mock điểm hợp lý. |
| Hibernate `ddl-auto: update` tự tạo lại bảng đã DROP | DB rác | Đổi sang `ddl-auto: validate` ở `application.yml`, chỉ dựa Flyway. |
| Xoá nhầm code module còn dùng | Build fail | Mỗi ngày commit nhỏ, build sau mỗi lần xóa, dùng `mvn dependency:analyze` hoặc IDE find-usage. |
| Mất dữ liệu khi DROP TABLE | Mất demo data cũ | Backup `pg_dump` trước khi chạy V15; demo chạy lại từ V16 seed. |
| Hội đồng hỏi sâu module đã bỏ | Mất điểm | Trong báo cáo có 1 mục "Scope decision" giải thích lý do bỏ, hướng mở rộng tương lai. |

---

## 9. ĐIỀU NÊN VIẾT VÀO LUẬN VĂN (tận dụng phần đã cắt)

Phần "Scope & Limitations" trong luận văn nên ghi rõ:

> "Hệ thống có thiết kế mở rộng cho push notification (FCM), audit log đa người dùng, system configuration runtime và content scheduling. Trong phạm vi đồ án 1 sinh viên, các module này được loại trừ để tập trung chiều sâu vào 3 trụ kỹ thuật chính: thuật toán SM-2, đánh giá phát âm AI và bài thi xếp lớp CEFR. Hướng phát triển tương lai trình bày tại chương kết luận."

→ Vừa giải thích, vừa cho thấy hiểu trade-off — điểm cộng với hội đồng.

---

## 10. CHECKLIST GỌN

**Code (tuần 1–2):**
- [ ] Xóa 12 controller / 11 service / 12 entity / 14 JSP (theo mục 6.1)
- [ ] `V15__drop_optional_tables.sql` chạy clean
- [ ] `V16__demo_seed.sql` có data đủ demo
- [ ] Pronunciation fallback mock hoạt động khi không có key
- [ ] Sidebar còn 8 menu
- [ ] `mvn clean verify` pass
- [ ] Test: SM2 + Placement + ScoringMapper xanh
- [ ] Mobile cập nhật xóa Chat tab, FCM, announcement

**Tài liệu (tuần 3–4):**
- [ ] README.md
- [ ] architecture.md + ERD
- [ ] 3 sequence diagram PNG
- [ ] API reference / Swagger export
- [ ] Admin user guide
- [ ] Demo script 10 phút
- [ ] Thesis outline

---

## 11. BACKEND EXECUTION PLAN — TỪNG BƯỚC CHI TIẾT

> Phần này chỉ tập trung **backend Spring Boot**. Mobile không nằm trong scope. Mỗi step là 1 đơn vị commit độc lập — build pass sau mỗi step.

### Quy ước

- 🎯 = Mục tiêu của step
- 📂 = Files cần xóa / sửa
- ✅ = Verify (lệnh kiểm tra sau khi xong)
- ⏱ = Thời lượng ước lượng
- 🔗 = Phụ thuộc step nào trước đó

---

### PHASE 0 — CHUẨN BỊ (1 buổi)

#### Step 0.1 — Tạo branch + backup DB
🎯 Có thể rollback nếu sai. <br>
📂 — <br>
✅ Lệnh:
```bash
git checkout -b scope-reduction
pg_dump -U postgres -d englishme > backup_before_trim.sql
```
⏱ 15 phút

#### Step 0.2 — Đổi `ddl-auto: update` → `validate`
🎯 Chặn Hibernate tự tạo lại bảng khi xóa entity. <br>
📂 `src/main/resources/application.yaml` (hoặc `application.yml`) <br>
✅ Lệnh:
```bash
./mvnw spring-boot:run
# log "Hibernate: validate" — không thấy "create" "alter table"
```
⏱ 10 phút

#### Step 0.3 — Snapshot routes hiện có
🎯 Có danh sách trước/sau để báo cáo cuối. <br>
📂 Tạo `docs/_routes-before.txt` chứa output của `grep -r "@GetMapping\|@PostMapping\|@RequestMapping" src/main/java/.../controller/` <br>
✅ File tồn tại, ~80–90 dòng. <br>
⏱ 10 phút

---

### PHASE 1 — XÓA MODULE (Tuần 1)

> Quy tắc: 1 step = 1 commit. Sau mỗi step chạy `./mvnw clean compile -DskipTests` — phải xanh.

#### Step 1.1 — Xóa Chat AI (C1)
🎯 Bỏ phụ thuộc DeepSeek API key. <br>
🔗 Step 0.* <br>
📂 Xóa:
- `controller/ChatApiController.java`
- `service/DeepSeekChatService.java`
- `dto/ChatRequest.java`, `dto/ChatResponse.java`, `dto/ChatMessageDto.java`

📂 Sửa `application.yaml` — xóa block `deepseek:`. <br>
📂 Sửa `pom.xml` nếu có dependency riêng cho DeepSeek (kiểm tra `groupId` có chứa "deepseek" — thường không có, dùng `WebClient` thuần). <br>
✅ `./mvnw clean compile` xanh. `grep -ri "deepseek" src/` — không kết quả. <br>
⏱ 30 phút

#### Step 1.2 — Xóa FCM Push (C2)
🎯 Bỏ phụ thuộc Firebase service account cho push. <br>
🔗 Step 1.1 <br>
📂 Xóa:
- `controller/AdminNotificationController.java`
- `controller/DeviceTokenApiController.java`
- `service/FcmPushService.java`
- `service/AdminNotificationService.java`
- `entity/UserDeviceToken.java`, `entity/AdminNotification.java`
- `repository/UserDeviceTokenRepository.java`, `repository/AdminNotificationRepository.java`
- `dto/DeviceTokenRequest.java`, `dto/PushSendResult.java`, `dto/AdminNotificationRow.java`
- `webapp/WEB-INF/views/admin/notifications.jsp`
- `webapp/WEB-INF/views/admin/notification-stats.jsp`

📂 Sửa `webapp/WEB-INF/views/admin/layout/sidebar.jspf`:
- Xóa entry "Push Notifications"
- Xóa flag `notificationsActive`

📂 Kiểm tra `FirebaseConfig.java` — nếu chỉ còn Firebase Auth thì giữ; nếu có khởi tạo `FirebaseMessaging` thì gỡ phần đó. <br>
✅ `./mvnw clean compile` xanh. `grep -ri "FcmPushService\|FirebaseMessaging" src/` — không kết quả ngoài file đã giữ. <br>
⏱ 1 giờ

#### Step 1.3 — Xóa Announcement (C3)
🎯 Bỏ banner in-app (đi kèm push). <br>
🔗 Step 1.2 <br>
📂 Xóa:
- `controller/AnnouncementApiController.java`
- (Nếu có) `controller/AdminAnnouncementController.java` — nếu chưa tách thì xem trong `AdminNotificationController` đã xóa
- `entity/AppAnnouncement.java`
- `repository/AppAnnouncementRepository.java`
- `dto/AdminAnnouncementRow.java`
- `webapp/WEB-INF/views/admin/announcements.jsp`

📂 Sửa `sidebar.jspf` — xóa entry "Announcements" + flag. <br>
✅ `./mvnw clean compile` xanh. <br>
⏱ 30 phút

#### Step 1.4 — Xóa Home Dashboard Content (C4)
🎯 Bỏ Word of Day / Banner / Recommendation admin (mobile chưa wire). <br>
🔗 Step 1.3 <br>
📂 Xóa:
- `controller/AdminHomeContentController.java`
- `service/AdminHomeContentService.java`
- `entity/HomeWordOfDay.java`, `entity/HomeRecommendation.java`, `entity/HomeBanner.java`
- `repository/HomeWordOfDayRepository.java`, `repository/HomeRecommendationRepository.java`, `repository/HomeBannerRepository.java`
- `dto/AdminWordOfDayRow.java`, `dto/AdminRecommendationRow.java`, `dto/AdminBannerRow.java`
- 3 JSP `admin/home-word-of-day.jsp`, `home-recommendations.jsp`, `home-banners.jsp`

📂 Sửa `service/HomeDashboardService.java` — đảm bảo **không** đọc 3 bảng đã xóa (logic hard-code hiện tại đã đủ; nếu có inject 3 repo trên thì gỡ). <br>
📂 Sửa `sidebar.jspf` — xóa entry "Home Content". <br>
✅ `./mvnw clean compile` xanh. `/api/home/dashboard` vẫn trả 200 với data hard-code. <br>
⏱ 1 giờ

#### Step 1.5 — Xóa Pronunciation Exercise CRUD admin (C5)
🎯 Giữ attempt list, bỏ trang CRUD bài tập + analytics. <br>
🔗 Step 1.4 <br>
📂 Xóa:
- `controller/AdminPronunciationExerciseController.java`
- `service/AdminPronunciationExerciseService.java`
- `dto/AdminPronunciationExerciseRow.java`, `dto/CreatePronunciationExerciseRequest.java`, `dto/UpdatePronunciationExerciseRequest.java`, `dto/PronunciationAnalytics.java`
- `webapp/WEB-INF/views/admin/pronunciation-exercises.jsp`
- `webapp/WEB-INF/views/admin/pronunciation-analytics.jsp`

📂 **KHÔNG xóa**: `PronunciationExercise` entity, `PronunciationExerciseRepository`, `PronunciationApiController` (mobile `/api/pronunciation/exercises` vẫn dùng). <br>
📂 `PronunciationAttemptRepository`: kiểm tra method `aggregateStatsByExercise`, `scoreDistributionBuckets`, `providerComparison`, `findTopMissedWords` — nếu chỉ controller analytics đã xóa dùng thì xóa cùng; nếu `DashboardAnalyticsService` còn dùng `findTopMissedWords` thì giữ. <br>
📂 `PronunciationWordFeedbackRepository`: tương tự — xóa `findWeakestWords`, `countByIssueType` nếu không còn caller. <br>
📂 Sửa `sidebar.jspf` — xóa entry "Pronunciation Exercises" + "Pronunciation Analytics" (giữ "Pronunciation" attempt list). <br>
✅ `./mvnw clean compile` xanh. Trang `/admin/pronunciation` (attempt list) vẫn hoạt động. <br>
⏱ 1 giờ

#### Step 1.6 — Xóa Test Bank admin (C6)
🎯 Bỏ CRUD placement question (seed JSON đủ). <br>
🔗 Step 1.5 <br>
📂 Xóa:
- `controller/AdminTestBankController.java`
- `service/AdminTestBankService.java`
- `dto/AdminTestBankQuestionRow.java`, `dto/CreateTestBankQuestionRequest.java`, `dto/UpdateTestBankQuestionRequest.java`, `dto/TestBankImportResult.java`, `dto/TestBankStats.java`
- `webapp/WEB-INF/views/admin/test-bank.jsp`
- `webapp/WEB-INF/views/admin/test-bank-stats.jsp`

📂 **KHÔNG xóa**: `Question` entity, `QuestionRepository`, `PlacementTestController` (mobile API), `TestAnswerRepository`. <br>
📂 `QuestionRepository`: nếu method `searchQuestions`, `countByCefrLevel`, `countBySkillCategory` chỉ admin dùng → xóa; nếu mobile/placement dùng → giữ. <br>
📂 `TestAnswerRepository`: tương tự với `aggregateStatsByQuestionIds`, `aggregateStatsByCefrLevel`. <br>
📂 Sửa `sidebar.jspf` — xóa entry "Test Bank". <br>
✅ `./mvnw clean compile` xanh. <br>
⏱ 45 phút

#### Step 1.7 — Xóa Badge UI admin (C7)
🎯 Giữ Badge entity + auto-award, bỏ admin CRUD. <br>
🔗 Step 1.6 <br>
📂 Xóa:
- `controller/AdminBadgeController.java`
- `service/AdminBadgeService.java`
- `dto/AdminBadgeRow.java`, `dto/AdminBadgeUserRow.java`, `dto/CreateBadgeRequest.java`, `dto/UpdateBadgeRequest.java`
- `webapp/WEB-INF/views/admin/badges.jsp`
- `webapp/WEB-INF/views/admin/badge-users.jsp`

📂 **KHÔNG xóa**: `Badge`, `UserBadge` entity, `BadgeRepository`, `UserBadgeRepository`, `ProgressService.evaluateBadges()`. <br>
📂 `BadgeRepository`: xóa method admin-only (`findAllByOrderByCreatedAtDesc`, `existsByNameIgnoreCase`, `countAwardedGroupByBadge`) nếu không còn caller. <br>
📂 `UserBadgeRepository`: xóa `findByBadge_IdOrderByEarnedAtDesc`, `countByBadge_Id`, `deleteByBadge_Id` nếu không còn caller. <br>
📂 Sửa `sidebar.jspf` — xóa entry "Badges". <br>
✅ `./mvnw clean compile` xanh. Tạo user mới + đủ XP → `ProgressService` vẫn award badge tự động. <br>
⏱ 45 phút

#### Step 1.8 — Xóa Study Session Monitoring admin (C8)
🎯 Bỏ trang read-only quan sát SM-2 session. <br>
🔗 Step 1.7 <br>
📂 Xóa:
- `controller/AdminStudySessionController.java`
- `service/AdminStudySessionService.java`
- `dto/AdminStudySessionRow.java`, `dto/AdminStudySessionDetail.java`
- `webapp/WEB-INF/views/admin/study-sessions.jsp`
- `webapp/WEB-INF/views/admin/study-session-detail.jsp`

📂 **KHÔNG xóa**: `StudySession` entity, `StudySessionRepository` (mobile + dashboard dùng). <br>
📂 `StudySessionRepository`: gỡ `searchForAdmin`, `findWithUserAndDeskById` nếu không còn caller. **Giữ** `heatmapSince`, `countSince`, `countDistinctUsersSince` (DashboardAnalyticsService dùng). <br>
📂 Sửa `sidebar.jspf` — xóa entry "Study Sessions". <br>
✅ `./mvnw clean compile` xanh. <br>
⏱ 45 phút

#### Step 1.9 — Xóa System Configuration (C9)
🎯 Bỏ UI quản lý `app_config`, dùng `application.yaml`. <br>
🔗 Step 1.8 <br>
📂 Xóa:
- `controller/AdminConfigController.java`
- `service/AppConfigService.java`
- `entity/AppConfig.java`
- `repository/AppConfigRepository.java`
- `dto/AppConfigRow.java`
- `webapp/WEB-INF/views/admin/config.jsp`

📂 Kiểm tra service nào đang `@Autowired AppConfigService` — phải có 0 caller (vì spec ghi "Service khác chưa được refactor để đọc từ AppConfigService"). Nếu có thì revert sang `@Value`. <br>
📂 Sửa `sidebar.jspf` — xóa entry "System Config". <br>
✅ `./mvnw clean compile` xanh. <br>
⏱ 30 phút

#### Step 1.10 — Xóa Audit + Admin Management (C10)
🎯 Bỏ DB admin account, dùng static `application.yml`. <br>
🔗 Step 1.9 <br>
📂 Xóa:
- `controller/AdminManagementController.java`
- `controller/AdminAuditController.java`
- `service/AdminManagementService.java`
- `service/AdminAuditLogService.java`
- `interceptor/AuditLogInterceptor.java`
- `entity/AdminAccount.java`, `entity/AdminAuditLog.java`
- `repository/AdminAccountRepository.java`, `repository/AdminAuditLogRepository.java`
- `dto/AdminAccountRow.java`, `dto/AuditLogRow.java`
- `webapp/WEB-INF/views/admin/admin-accounts.jsp`
- `webapp/WEB-INF/views/admin/audit-log.jsp`

📂 Sửa `config/WebMvcConfig.java`:
- Gỡ `addInterceptor(auditLogInterceptor)` (chỉ giữ `adminRoleInterceptor`).
- Gỡ import + field.

📂 Sửa `sidebar.jspf` — xóa 2 entry "Admin Accounts", "Audit Log". <br>
✅ `./mvnw clean compile` xanh. Đăng nhập admin bằng static credential vẫn ok. <br>
⏱ 1 giờ

#### Step 1.11 — Bỏ Exercise sessions admin pages (C11)
🎯 Giữ admin CRUD câu hỏi, bỏ trang monitor session. <br>
🔗 Step 1.10 <br>
📂 Xóa:
- `webapp/WEB-INF/views/admin/exercise-sessions.jsp`
- `webapp/WEB-INF/views/admin/exercise-session-detail.jsp`

📂 Sửa `controller/AdminExerciseController.java` — xóa 2 endpoint:
- `GET /admin/exercises/sessions`
- `GET /admin/exercises/sessions/{id}`

📂 Sửa `service/AdminExerciseService.java` — xóa method liên quan (`listSessions`, `getSessionDetail`). <br>
📂 Xóa `dto/AdminExerciseSessionRow.java`, `dto/AdminExerciseSessionDetail.java`. <br>
📂 `ExerciseSessionRepository`: gỡ `searchSessions` (admin-only). **Giữ** method mobile dùng (`findByIdAndUser_FirebaseUid`) + dashboard (`countSince`, `countDistinctUsersSince`). <br>
📂 `ExerciseAnswerRepository`: gỡ `findBySessionId`, `countBySessionId`, `countCorrectBySessionId` nếu không còn caller. **Giữ** `aggregateStatsByQuestionIds` (admin list question accuracy vẫn dùng). <br>
✅ `./mvnw clean compile` xanh. Trang `/admin/exercises` (list question) vẫn hoạt động. <br>
⏱ 45 phút

#### Step 1.12 — Đơn giản hóa Dashboard (C12)
🎯 Bỏ placeholder không có data thật. <br>
🔗 Step 1.11 <br>
📂 Sửa `service/DashboardAnalyticsService.java` — chỉ trả:
- KPI: totalUsers, newUsersToday, DAU, WAU, MAU, retention7d, xpGrantedToday
- TimeSeries: newUsersByDay (14d), xpBySourceLast7Days
- Cefr distribution bar

Xóa: heatmap, contentDonut, systemHealth, topFlashcards (placeholder), topGrammar (placeholder). <br>
📂 Sửa `controller/AdminViewController.java` — model bớt key. <br>
📂 Sửa `webapp/WEB-INF/views/admin/dashboard.jsp` — xóa block heatmap, donut, system health, 2 bảng top-N placeholder. <br>
📂 Xóa các field tương ứng trong `dto/DashboardAnalytics.java`. <br>
📂 Repository — gỡ method không còn dùng:
- `StudySessionRepository.heatmapSince` (nếu dashboard không cần)

✅ `./mvnw clean compile` xanh. Mở `/admin` thấy gọn, không có chỗ trống. <br>
⏱ 1 giờ

#### Step 1.13 — Đơn giản hóa User Detail (C13)
🎯 Giữ xem-only, bỏ action rủi ro. <br>
🔗 Step 1.12 <br>
📂 Sửa `controller/AdminUserController.java` — xóa 4 endpoint:
- `POST /admin/users/{id}/reset-progress`
- `POST /admin/users/{id}/grant-xp`
- `POST /admin/users/{id}/award-badge`
- `POST /admin/users/{id}/change-level`

(Giữ `lock`, `unlock`, `delete` soft, `export`.) <br>
📂 Sửa `service/AdminUserService.java` — xóa method tương ứng. <br>
📂 Sửa `webapp/WEB-INF/views/admin/user-detail.jsp` — xóa 4 form tương ứng. <br>
📂 Repository — gỡ method orphan (vd `deleteByUser_Id` của một số repo nếu không còn `resetProgress` gọi). <br>
  - **Lưu ý**: `deleteByUser_Id` vẫn cần cho soft delete (xóa session data khi soft delete user). Kiểm tra trước khi xóa. <br>
✅ `./mvnw clean compile` xanh. Trang user detail hiện đủ profile + stats + biểu đồ XP. <br>
⏱ 45 phút

#### Step 1.14 — Migration V15 drop tables
🎯 DB phản ánh code sạch. <br>
🔗 Tất cả step 1.* <br>
📂 Tạo `src/main/resources/db/migration/V15__drop_optional_tables.sql`:

```sql
-- Module 13 (Audit + Admin DB Management)
DROP TABLE IF EXISTS admin_audit_log;
DROP TABLE IF EXISTS admin_account;

-- Module 12 (System Configuration)
DROP TABLE IF EXISTS app_config;

-- Module 11 (Push + Announcement)
DROP TABLE IF EXISTS app_announcement;
DROP TABLE IF EXISTS admin_notification;
DROP TABLE IF EXISTS user_device_token;

-- Module 10 (Home Content)
DROP TABLE IF EXISTS home_banner;
DROP TABLE IF EXISTS home_recommendation;
DROP TABLE IF EXISTS home_word_of_day;
```

✅ Lệnh:
```bash
./mvnw spring-boot:run
# log Flyway: "Migrating schema to version 15"
psql -d englishme -c "\dt" | grep -E "admin_account|app_config|home_"
# → trống
```
⏱ 30 phút

#### Step 1.15 — Cập nhật `application.yaml`
🎯 Cấu hình tối giản, không phụ thuộc service ngoài. <br>
🔗 Step 1.14 <br>
📂 Sửa `src/main/resources/application.yaml`:
- Xóa block `deepseek:`
- (Nếu có) Xóa block `firebase.fcm:`
- Đảm bảo `google.application.credentials` cho phép null (Pronunciation fallback ở Phase 2)
- `spring.jpa.hibernate.ddl-auto: validate` (đã đặt ở 0.2)

📂 Sửa `pom.xml` nếu có dependency không còn dùng:
- Firebase Admin SDK — giữ (vẫn cần Auth)
- Google Cloud Speech / Pronunciation — giữ

✅ `./mvnw clean package` xanh. <br>
⏱ 20 phút

#### Step 1.16 — Soát sidebar còn 8 menu
🎯 Sidebar khớp với code. <br>
🔗 Step 1.15 <br>
📂 Sửa `webapp/WEB-INF/views/admin/layout/sidebar.jspf` — chỉ giữ:

```
Dashboard          → /admin
Users              → /admin/users
Vocabulary         → /admin/vocabulary
Grammar            → /admin/grammar
Desks              → /admin/desks
Exercises          → /admin/exercises
Pronunciation      → /admin/pronunciation
Placement Test     → /admin/placement-test
```

✅ Đăng nhập, đi qua từng menu, không thấy 404. <br>
⏱ 20 phút

#### Step 1.17 — Smoke test toàn bộ admin + API mobile
🎯 Verify cuối Phase 1. <br>
🔗 Tất cả step 1.* <br>
✅ Manual:
- Login `/admin/login`
- Dashboard load không lỗi
- Tạo 1 vocab topic + 1 từ
- Tạo 1 grammar topic + lesson + exercise
- Tạo 1 exercise question
- Mở 1 user detail
- Mở 1 pronunciation attempt

✅ API mobile:
```bash
curl http://localhost:8080/api/vocabulary/topics
curl http://localhost:8080/api/grammar/topics
# ... mỗi endpoint trả 200 hoặc 401 (cần auth) — không 500
```

✅ `./mvnw clean verify` xanh. <br>
⏱ 1 giờ

---

### PHASE 2 — BỔ SUNG CHẤT LƯỢNG (Tuần 2)

#### Step 2.1 — Test `SM2Service`
🎯 Cover thuật toán SM-2 — phần lõi luận văn Trụ 1. <br>
🔗 Phase 1 xong <br>
📂 Tạo `src/test/java/com/kiovant/englishme/service/SM2ServiceTest.java`:

Test cases:
1. `quality < 3` → interval = 1, repetitions = 0
2. `quality = 3, repetitions = 0` → interval = 1, repetitions = 1
3. `quality = 4, repetitions = 1` → interval = 6, repetitions = 2
4. `quality = 5, repetitions = 2, EF = 2.5` → interval ≈ 15
5. EF không nhỏ hơn 1.3
6. EF công thức `EF + (0.1 - (5-q) * (0.08 + (5-q)*0.02))` chính xác cho q = 3, 4, 5
7. `nextReviewAt = now + interval days` chính xác
8. Chuyển trạng thái card mới (`repetitions = 0`) → sau review = `repetitions = 1`

📂 Dùng `@ExtendWith(MockitoExtension.class)` hoặc test thuần (SM2 không cần DB). <br>
✅ `./mvnw test -Dtest=SM2ServiceTest` — 8 test xanh. <br>
⏱ 4 giờ

#### Step 2.2 — Test `PlacementTestService`
🎯 Cover flow start → answer → complete + suy luận CEFR — Trụ 3. <br>
🔗 Step 2.1 <br>
📂 Tạo `src/test/java/com/kiovant/englishme/service/PlacementTestServiceTest.java`:

Test cases:
1. `startTest` tạo session với N câu hỏi, status `active`
2. `answerQuestion` lưu đáp án, cập nhật `correctCount`
3. `completeTest` tính score, suy luận CEFR (A1 nếu < 30%, A2 nếu 30-50%, …)
4. Không cho phép answer khi session đã `completed`
5. Không cho phép answer câu đã trả lời
6. CEFR suggestion theo phân vùng % đúng — match bảng trong service

📂 Dùng `@MockBean` cho repository. <br>
✅ `./mvnw test -Dtest=PlacementTestServiceTest` — xanh. <br>
⏱ 4 giờ

#### Step 2.3 — Test `PronunciationScoringMapper`
🎯 Cover mapping Google response → DTO — Trụ 2. <br>
🔗 Step 2.2 <br>
📂 Tạo `src/test/java/com/kiovant/englishme/service/PronunciationScoringMapperTest.java`:

Test cases:
1. Map full response → DTO đủ field `overallScore`, `accuracyScore`, `fluencyScore`, `completenessScore`
2. Map word-level → list `PronunciationWordFeedbackDto`
3. Response thiếu word feedback → list rỗng, không NPE
4. `errorType` map đúng (Mispronunciation, Omission, Insertion)

📂 Dùng JSON fixture `src/test/resources/fixtures/google-pronunciation-response.json`. <br>
✅ `./mvnw test -Dtest=PronunciationScoringMapperTest` — xanh. <br>
⏱ 2 giờ

#### Step 2.4 — Integration test placement test
🎯 1 flow end-to-end qua HTTP. <br>
🔗 Step 2.3 <br>
📂 Tạo `src/test/java/com/kiovant/englishme/integration/PlacementTestFlowIT.java`:

Test scenario:
1. `@SpringBootTest(webEnvironment = RANDOM_PORT)` + Testcontainers Postgres (hoặc H2)
2. Mock Firebase Auth — inject `firebaseUid` trực tiếp
3. Seed 5 câu hỏi qua `@Sql`
4. POST `/api/placement-test/start` → 200, có sessionId
5. POST `/api/placement-test/{sid}/answer` × 5 lần
6. POST `/api/placement-test/{sid}/complete` → 200, có `cefrSuggestion`

📂 Tạo `src/test/resources/application-test.yaml` với Postgres test profile. <br>
📂 Pom.xml: thêm `testcontainers-postgresql` nếu chưa có (hoặc dùng H2 đơn giản hơn). <br>
✅ `./mvnw verify -Dtest=PlacementTestFlowIT` — xanh. <br>
⏱ 6 giờ (setup Testcontainers tốn thời gian lần đầu)

#### Step 2.5 — Pronunciation fallback mock
🎯 Demo offline không cần Google Cloud key. <br>
🔗 Step 2.4 <br>
📂 Sửa `service/PronunciationAssessmentService.java`:
- Nếu `cloudPronunciationClient` chưa init / key null → gọi `MockPronunciationClient`
- Mock trả điểm random trong khoảng [60, 95] cho overall, [55, 95] cho từng word
- Sinh 2–3 word feedback giả lập với `errorType` random

📂 Tạo `service/MockPronunciationClient.java` implement cùng interface `CloudPronunciationClient`. <br>
📂 Sửa config bean để chọn mock/real qua property `pronunciation.provider: mock|google`. <br>
✅ Khởi động không có credentials → upload audio → nhận response hợp lý, không 500. <br>
⏱ 3 giờ

#### Step 2.6 — Seed data demo `V16__demo_seed.sql`
🎯 Demo chạy ngay sau migrate sạch. <br>
🔗 Step 1.14 <br>
📂 Tạo `src/main/resources/db/migration/V16__demo_seed.sql`:

Nội dung:
- 5 user demo (mỗi CEFR A1/A2/B1/B2/C1 — firebaseUid giả `demo_a1`, …)
- 5 vocabulary topic × 10 từ (Greetings, Food, Family, Travel, Business)
- 5 grammar topic × 3 lesson × 2 exercise
- 30 exercise question (vocab + grammar mix)
- 10 pronunciation exercise
- 30 placement question (5/CEFR)
- Mỗi user demo có 1 desk + 5 flashcard
- 2 user có streak 7, 1 user có 1000 XP để trigger badge

📂 Đảm bảo idempotent: dùng `INSERT … ON CONFLICT DO NOTHING` (hoặc check `WHERE NOT EXISTS`). <br>
✅ Drop DB → migrate → mở `/admin` thấy dashboard có số > 0. Login mobile bằng demo user → có data. <br>
⏱ 6 giờ

#### Step 2.7 — Cleanup dead code
🎯 Repository / DTO orphan sau cắt. <br>
🔗 Step 2.6 <br>
📂 Quét từng repository — bất kỳ method nào không còn caller thì xóa. <br>
📂 Quét `dto/` — DTO không còn import nào tham chiếu → xóa. <br>
📂 Format toàn bộ: `./mvnw spotless:apply` (nếu có plugin) hoặc IDE reformat. <br>
✅ `./mvnw clean verify` xanh, 0 warning về unused. <br>
⏱ 3 giờ

#### Step 2.8 — Soát commit + tạo CHANGELOG
🎯 Có dấu vết cho hội đồng. <br>
🔗 Step 2.7 <br>
📂 Tạo `docs/CHANGELOG.md` ghi lại: phiên bản trước cắt — phiên bản sau cắt — danh sách module bỏ — danh sách test thêm. <br>
📂 Squash các commit nhỏ trong cùng module thành 1 commit nếu cần (vd 14 step trong Phase 1 → 14 commit message rõ ràng). <br>
✅ `git log --oneline | head -30` — commit message rõ ràng, không có "wip", "fix", "xxx". <br>
⏱ 2 giờ

#### Step 2.9 — Smoke test final
🎯 Tất cả flow hoạt động sau khi seed sạch. <br>
🔗 Step 2.8 <br>
✅ Quy trình:
```bash
# Drop & recreate DB
dropdb englishme && createdb englishme
./mvnw spring-boot:run  # Flyway V1..V16 chạy hết
```

- Login admin → đi qua 8 menu, mỗi menu phải có ít nhất 1 row data demo
- Run `./mvnw test` — toàn bộ test xanh
- Build Docker: `docker compose up` (nếu plan dùng) — chạy được

⏱ 2 giờ

---

### TỔNG KẾT EFFORT BACKEND

| Phase | Step | Effort |
|---|---|---|
| Phase 0 — Chuẩn bị | 3 step | ~35 phút |
| Phase 1 — Xóa module | 17 step | ~11 giờ (≈ 1.5 ngày) |
| Phase 2 — Bổ sung chất lượng | 9 step | ~32 giờ (≈ 4 ngày) |
| **Tổng** | **29 step** | **~6 ngày làm việc** |

Vừa khít với 2 tuần code (10 ngày), còn dư ~4 ngày cho buffer + sửa mobile theo backend.

---

### LƯU Ý KHI THỰC THI

1. **Commit từng step** — đừng gộp. Mỗi commit message: `chore: remove [module] (step 1.X)` hoặc `test: add SM2Service tests (step 2.1)`.
2. **Sau mỗi step chạy `./mvnw clean compile`** — không skip. Bug do reference cũ phát hiện sớm dễ fix.
3. **Step 1.x trước Step 2.x** — đừng viết test khi code chưa ổn định.
4. **Backup DB trước Step 1.14** — `pg_dump` lần nữa trước khi DROP.
5. **Không commit `application.yaml` có secret thật** — kiểm tra `.gitignore`.
6. **`ddl-auto: validate`** sẽ báo lỗi khởi động nếu entity còn map vào bảng đã DROP — đó là tín hiệu tốt, fix bằng xóa entity.

---

*— Hết —*
