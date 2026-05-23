# Dev Setup — EnglishMe Backend

Hướng dẫn cấu hình môi trường local để chạy `./mvnw spring-boot:run` không lỗi.

## 1. Yêu cầu

- JDK 21
- PostgreSQL 14+ (database `englishme_db`, user `admin`)
- Maven Wrapper đi kèm repo (không cần cài mvn global)

## 2. Cấu hình JVM Timezone (Windows VN locale)

Trên Windows với timezone hệ thống `(UTC+07:00) Bangkok, Hanoi, Jakarta`,
JDK báo cáo `SE Asia Standard Time` và Postgres JDBC driver dịch về
`Asia/Saigon` — một alias mà Postgres server không công nhận, gây lỗi:

```
FATAL: invalid value for parameter "TimeZone": "Asia/Saigon"
```

**Cách xử lý:** ép JVM dùng UTC trước khi chạy app. Chọn 1 trong 2:

### Một lần / phiên terminal

```powershell
# PowerShell
$env:JAVA_TOOL_OPTIONS = "-Duser.timezone=UTC"
./mvnw spring-boot:run
```

```bash
# Git Bash / WSL
export JAVA_TOOL_OPTIONS="-Duser.timezone=UTC"
./mvnw spring-boot:run
```

### Vĩnh viễn (Windows User Environment Variables)

1. Win + R → `sysdm.cpl` → Advanced → Environment Variables.
2. New variable: `JAVA_TOOL_OPTIONS` = `-Duser.timezone=UTC`.
3. Restart terminal.

Lưu ý: production deploy (Linux container) thường không gặp lỗi này vì
timezone container là `Etc/UTC`. Setting này chỉ cần cho dev Windows VN.

## 3. Database

```sql
CREATE DATABASE englishme_db;
CREATE USER admin WITH PASSWORD '2004';
GRANT ALL PRIVILEGES ON DATABASE englishme_db TO admin;
```

Flyway tự chạy migrations khi app khởi động — không cần seed thủ công.
`spring.jpa.hibernate.ddl-auto=validate` đảm bảo Flyway là nguồn schema
duy nhất; nếu Hibernate báo `Schema-validation: missing column ...`,
thêm migration mới, không sửa entity để né.

## 4. Chạy

```powershell
$env:JAVA_TOOL_OPTIONS = "-Duser.timezone=UTC"
./mvnw spring-boot:run
```

App lắng nghe `http://localhost:8080`. Admin login: `/admin/login`
(credentials trong `application.properties` qua `ADMIN_EMAIL` /
`ADMIN_PASSWORD` env, mặc định `admin@englishme.vn` / `admin123456`).
