package vn.id.kieuanhdev.englishme.dto.profile;

import java.time.Instant;
import java.util.UUID;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.auth.Role;
import vn.id.kieuanhdev.englishme.entity.auth.User;
import vn.id.kieuanhdev.englishme.entity.auth.UserStatus;

public record UserProfileResponse(
	UUID id,
	String email,
	String fullName,
	String avatarUrl,
	Role role,
	UserStatus status,
	CefrLevel cefrLevel,
	String googleId,
	Instant createdAt,
	Instant updatedAt
) {
	public static UserProfileResponse fromEntity(User u) {
		return new UserProfileResponse(
			u.getId(),
			u.getEmail(),
			u.getFullName(),
			u.getAvatarUrl(),
			u.getRole(),
			u.getStatus(),
			u.getCefrLevel(),
			u.getGoogleId(),
			u.getCreatedAt(),
			u.getUpdatedAt()
		);
	}
}
