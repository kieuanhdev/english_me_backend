-- Module 13: Audit Log & Admin Management

-- ── Admin accounts (DB-backed admins ngoài static admin trong application.yml) ──
CREATE TABLE admin_account (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(64) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(20) NOT NULL DEFAULT 'VIEWER',     -- SUPER_ADMIN | EDITOR | VIEWER
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_admin_account_email UNIQUE (email)
);

CREATE INDEX idx_admin_account_role ON admin_account(role);

-- ── Audit log: ghi mọi POST/PUT/DELETE trong /admin/** ──────────────────────
CREATE TABLE admin_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_email VARCHAR(255),
    action VARCHAR(100) NOT NULL,                   -- HTTP method, vd: POST | PUT | DELETE
    request_uri VARCHAR(500) NOT NULL,              -- vd: /admin/users/123/lock
    entity_type VARCHAR(100),                       -- suy ra từ uri segment đầu sau /admin/
    entity_id VARCHAR(100),                         -- path-variable cuối nếu có
    status_code INTEGER,                            -- HTTP response status
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_admin ON admin_audit_log(admin_email, created_at DESC);
CREATE INDEX idx_audit_log_entity ON admin_audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_created ON admin_audit_log(created_at DESC);
