package vn.id.kieuanhdev.englishme.dto.profile;

import jakarta.validation.constraints.Size;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;

/**
 * PATCH: trường null (không gửi hoặc JSON null) = giữ nguyên giá trị cũ.
 */
public record UpdateProfileRequest(
	@Size(max = 100) String fullName,
	@Size(max = 500) String avatarUrl,
	CefrLevel cefrLevel
) {}
