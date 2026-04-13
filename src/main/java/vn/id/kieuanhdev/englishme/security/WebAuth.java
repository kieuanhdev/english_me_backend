package vn.id.kieuanhdev.englishme.security;

import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.server.ResponseStatusException;

public final class WebAuth {
	private WebAuth() {
	}

	public static UUID requireUserId(Authentication authentication) {
		if (authentication == null || authentication.getPrincipal() == null) {
			throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized");
		}
		return (UUID) authentication.getPrincipal();
	}
}
