package vn.id.kieuanhdev.englishme.dto.auth;

import java.util.Set;
import java.util.UUID;
import vn.id.kieuanhdev.englishme.entity.auth.Role;

public record MeResponse(
	UUID id,
	String email,
	String fullName,
	Set<Role> roles
) {}
