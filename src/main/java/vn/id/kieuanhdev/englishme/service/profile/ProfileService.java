package vn.id.kieuanhdev.englishme.service.profile;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.id.kieuanhdev.englishme.dto.profile.UpdateProfileRequest;
import vn.id.kieuanhdev.englishme.dto.profile.UserProfileResponse;
import vn.id.kieuanhdev.englishme.repository.auth.UserRepository;

@Service
@RequiredArgsConstructor
public class ProfileService {
	private final UserRepository userRepository;

	public UserProfileResponse getProfile(UUID userId) {
		var user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
		return UserProfileResponse.fromEntity(user);
	}

	@Transactional
	public UserProfileResponse updateProfile(UUID userId, UpdateProfileRequest req) {
		var user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

		if (req.fullName() != null) {
			var name = req.fullName().trim();
			if (name.isEmpty()) {
				throw new IllegalArgumentException("fullName cannot be empty");
			}
			user.setFullName(name);
		}
		if (req.avatarUrl() != null) {
			var url = req.avatarUrl().trim();
			user.setAvatarUrl(url.isEmpty() ? null : url);
		}
		if (req.cefrLevel() != null) {
			user.setCefrLevel(req.cefrLevel());
		}

		userRepository.save(user);
		return UserProfileResponse.fromEntity(user);
	}
}
