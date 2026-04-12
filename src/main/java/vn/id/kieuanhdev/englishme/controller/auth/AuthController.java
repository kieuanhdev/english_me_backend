package vn.id.kieuanhdev.englishme.controller.auth;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.id.kieuanhdev.englishme.dto.auth.AuthResponse;
import vn.id.kieuanhdev.englishme.dto.auth.LoginRequest;
import vn.id.kieuanhdev.englishme.dto.auth.RefreshRequest;
import vn.id.kieuanhdev.englishme.dto.auth.RegisterRequest;
import vn.id.kieuanhdev.englishme.service.auth.AuthService;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
	private final AuthService authService;

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
}
