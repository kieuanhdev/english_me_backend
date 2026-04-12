package vn.id.kieuanhdev.englishme.controller.profile;

import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.id.kieuanhdev.englishme.dto.profile.UpdateProfileRequest;
import vn.id.kieuanhdev.englishme.dto.profile.UserProfileResponse;
import vn.id.kieuanhdev.englishme.service.profile.ProfileService;

@RestController
@RequestMapping("/api/users/me")
@RequiredArgsConstructor
public class UserProfileController {
	private final ProfileService profileService;

	@GetMapping
	public UserProfileResponse getMyProfile(Authentication authentication) {
		var userId = requireUserId(authentication);
		return profileService.getProfile(userId);
	}

	@PatchMapping
	public UserProfileResponse updateMyProfile(
		Authentication authentication,
		@Valid @RequestBody UpdateProfileRequest req
	) {
		var userId = requireUserId(authentication);
		return profileService.updateProfile(userId, req);
	}

	private static UUID requireUserId(Authentication authentication) {
		if (authentication == null || authentication.getPrincipal() == null) {
			throw new IllegalArgumentException("Unauthorized");
		}
		return (UUID) authentication.getPrincipal();
	}
}
