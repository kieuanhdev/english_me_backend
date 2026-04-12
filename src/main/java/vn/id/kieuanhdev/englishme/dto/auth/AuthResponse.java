package vn.id.kieuanhdev.englishme.dto.auth;

public record AuthResponse(
	String accessToken,
	String refreshToken,
	long accessTokenExpiresInSeconds
) {}
