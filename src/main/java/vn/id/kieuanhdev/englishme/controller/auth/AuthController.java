package vn.id.kieuanhdev.englishme.controller.auth;

import jakarta.validation.Valid;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.id.kieuanhdev.englishme.dto.auth.AuthResponse;
import vn.id.kieuanhdev.englishme.dto.auth.LoginRequest;
import vn.id.kieuanhdev.englishme.dto.auth.MeResponse;
import vn.id.kieuanhdev.englishme.dto.auth.RefreshRequest;
import vn.id.kieuanhdev.englishme.dto.auth.RegisterRequest;
import vn.id.kieuanhdev.englishme.repository.auth.UserRepository;
import vn.id.kieuanhdev.englishme.service.auth.AuthService;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
	private final AuthService authService;
	private final UserRepository userRepository;

	@PostMapping("/register")
	public AuthResponse register(@Valid @RequestBody RegisterRequest req) {
		return authService.register(req);
	}

	@PostMapping("/login")
	public AuthResponse login(@Valid @RequestBody LoginRequest req) {
		return authService.login(req);
	}

	@PostMapping("/refresh")
	public AuthResponse refresh(@Valid @RequestBody RefreshRequest req) {
		return authService.refresh(req.refreshToken());
	}

	@PostMapping("/logout")
	public void logout(@Valid @RequestBody RefreshRequest req) {
		authService.logout(req.refreshToken());
	}

	@GetMapping("/me")
	public MeResponse me(Authentication authentication) {
		if (authentication == null || authentication.getPrincipal() == null) {
			throw new IllegalArgumentException("Unauthorized");
		}
		var userId = (UUID) authentication.getPrincipal();
		var user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
		return new MeResponse(
			user.getId(),
			user.getEmail(),
			user.getFullName(),
			user.getRole(),
			user.getStatus(),
			user.getAvatarUrl(),
			user.getCefrLevel()
		);
	}
}
