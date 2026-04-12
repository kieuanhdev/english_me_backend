package vn.id.kieuanhdev.englishme.entity.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User {
	@Id
	private UUID id;

	@Column(nullable = false, unique = true, length = 255)
	private String email;

	@Column(name = "password_hash", length = 255)
	private String passwordHash;

	@Column(name = "full_name", nullable = false, length = 100)
	private String fullName;

	@Column(name = "avatar_url", length = 500)
	private String avatarUrl;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(nullable = false, length = 20)
	private Role role = Role.USER;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(nullable = false, length = 20)
	private UserStatus status = UserStatus.ACTIVE;

	@Enumerated(EnumType.STRING)
	@JdbcTypeCode(SqlTypes.VARCHAR)
	@Column(name = "cefr_level", length = 2)
	private CefrLevel cefrLevel;

	@Column(name = "google_id", unique = true, length = 255)
	private String googleId;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt;

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	@PrePersist
	void prePersist() {
		if (id == null) {
			id = UUID.randomUUID();
		}
		var now = Instant.now();
		createdAt = now;
		updatedAt = now;
		if (role == null) {
			role = Role.USER;
		}
		if (status == null) {
			status = UserStatus.ACTIVE;
		}
	}

	@PreUpdate
	void preUpdate() {
		updatedAt = Instant.now();
	}
}
