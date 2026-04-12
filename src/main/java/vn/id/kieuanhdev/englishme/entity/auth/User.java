package vn.id.kieuanhdev.englishme.entity.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "app_user")
public class User {
	@Id
	private UUID id;

	@Column(nullable = false, unique = true, length = 320)
	private String email;

	@Column(name = "full_name", length = 200)
	private String fullName;

	@Column(name = "password_hash", nullable = false, length = 200)
	private String passwordHash;

	/**
	 * Stored as a comma-separated string in DB. Example: "USER,ADMIN"
	 */
	@Column(nullable = false, columnDefinition = "text")
	private String roles;

	@Column(name = "created_at", nullable = false)
	private Instant createdAt;

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	@PrePersist
	void prePersist() {
		if (id == null) id = UUID.randomUUID();
		var now = Instant.now();
		createdAt = now;
		updatedAt = now;
	}

	@PreUpdate
	void preUpdate() {
		updatedAt = Instant.now();
	}

	public Set<Role> getRoleSet() {
		if (roles == null || roles.isBlank()) return Set.of();
		return java.util.Arrays.stream(roles.split(","))
			.map(String::trim)
			.filter(s -> !s.isBlank())
			.map(Role::valueOf)
			.collect(java.util.stream.Collectors.toUnmodifiableSet());
	}

	public void setRoleSet(Set<Role> roleSet) {
		if (roleSet == null || roleSet.isEmpty()) {
			this.roles = "";
			return;
		}
		this.roles = roleSet.stream()
			.filter(Objects::nonNull)
			.map(Enum::name)
			.sorted()
			.collect(java.util.stream.Collectors.joining(","));
	}
}
