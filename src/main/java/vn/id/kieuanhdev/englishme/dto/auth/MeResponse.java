package vn.id.kieuanhdev.englishme.dto.auth;

import java.util.UUID;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.auth.Role;
import vn.id.kieuanhdev.englishme.entity.auth.UserStatus;

public record MeResponse(
	UUID id,
	String email,
	String fullName,
	Role role,
	UserStatus status,
	String avatarUrl,
	CefrLevel cefrLevel
) {}
