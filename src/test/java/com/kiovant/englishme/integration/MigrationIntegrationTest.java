package com.kiovant.englishme.integration;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Chạy ĐỦ bộ Flyway migration trên Postgres THẬT (Testcontainers) + Hibernate
 * ddl-auto=validate đối chiếu entity với schema.
 *
 * Context load thành công = (1) mọi migration apply sạch theo thứ tự,
 * (2) entity mapping khớp schema — bắt nguyên lớp lỗi
 * "Schema-validation: missing column/table" TRƯỚC khi chạy app thật.
 *
 * KHÔNG dùng profile "test" (profile đó tắt Flyway + dùng H2 — vô nghĩa ở đây).
 * Cần Docker — gắn @Tag("docker") để skip được ở máy không có Docker:
 *   ./mvnw test -Dgroups=!docker
 */
@SpringBootTest
@Testcontainers
@Tag("docker")
class MigrationIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("englishme_migration_test");

    @DynamicPropertySource
    static void props(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.flyway.enabled", () -> "true");
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "validate");
        // Các placeholder bắt buộc của môi trường thật — test tự cấp giá trị.
        registry.add("englishme.firebase.enabled", () -> "false");
        registry.add("admin.auth.password", () -> "test-admin-password");
    }

    @Test
    @DisplayName("Flyway migrations apply sạch + entity khớp schema (validate)")
    void flywayMigrationsApplyCleanlyAndEntitiesValidate() {
        // Đến được đây nghĩa là Spring context đã load: Flyway chạy hết migration
        // và Hibernate validate pass. Assert container cho rõ ràng.
        assertTrue(postgres.isRunning());
    }
}
