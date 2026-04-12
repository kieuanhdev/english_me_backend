package vn.id.kieuanhdev.englishme.service.auth;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.id.kieuanhdev.englishme.config.AppSecurityProperties;
import vn.id.kieuanhdev.englishme.dto.auth.AuthResponse;
import vn.id.kieuanhdev.englishme.dto.auth.LoginRequest;
import vn.id.kieuanhdev.englishme.dto.auth.RegisterRequest;
import vn.id.kieuanhdev.englishme.entity.auth.RefreshToken;
import vn.id.kieuanhdev.englishme.entity.auth.Role;
import vn.id.kieuanhdev.englishme.entity.auth.User;
import vn.id.kieuanhdev.englishme.repository.auth.RefreshTokenRepository;
import vn.id.kieuanhdev.englishme.repository.auth.UserRepository;

@Service
@RequiredArgsConstructor
public class AuthService {
	private final UserRepository userRepository;
	private final RefreshTokenRepository refreshTokenRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final AppSecurityProperties props;

	@Transactional
	public AuthResponse register(RegisterRequest req) {
		var email = normalizeEmail(req.email());
		if (userRepository.existsByEmail(email)) {
			throw new IllegalArgumentException("Email already in use");
		}

		User user = new User();
		user.setEmail(email);
		user.setFullName(req.fullName());
		user.setPasswordHash(passwordEncoder.encode(req.password()));
		user.setRoleSet(Set.of(Role.USER));

		user = userRepository.save(user);
		return issueTokens(user);
	}

	@Transactional
	public AuthResponse login(LoginRequest req) {
		var email = normalizeEmail(req.email());
		var user = userRepository.findByEmail(email)
			.orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

		if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
			throw new BadCredentialsException("Invalid credentials");
		}
		return issueTokens(user);
	}

	@Transactional
	public AuthResponse refresh(String refreshToken) {
		var now = Instant.now();
		var rt = refreshTokenRepository.findByToken(refreshToken)
			.orElseThrow(() -> new BadCredentialsException("Invalid refresh token"));

		if (rt.isRevoked() || rt.isExpired(now)) {
			throw new BadCredentialsException("Invalid refresh token");
		}

		var user = rt.getUser();

		// rotate refresh token
		rt.setRevokedAt(now);
		refreshTokenRepository.save(rt);

		return issueTokens(user);
	}

	@Transactional
	public void logout(String refreshToken) {
		refreshTokenRepository.findByToken(refreshToken).ifPresent(rt -> {
			if (!rt.isRevoked()) {
				rt.setRevokedAt(Instant.now());
				refreshTokenRepository.save(rt);
			}
		});
	}

	private AuthResponse issueTokens(User user) {
		var accessToken = jwtService.createAccessToken(user.getId(), user.getEmail(), user.getRoleSet());

		var refresh = new RefreshToken();
		refresh.setUser(user);
		refresh.setToken(UUID.randomUUID().toString());
		refresh.setExpiresAt(Instant.now().plus(props.refreshTtl()));
		refreshTokenRepository.save(refresh);

		return new AuthResponse(accessToken, refresh.getToken(), props.accessTokenTtlSeconds());
	}

	private static String normalizeEmail(String email) {
		if (email == null) return null;
		return email.trim().toLowerCase();
	}
}
