package vn.id.kieuanhdev.englishme.service.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Service;
import vn.id.kieuanhdev.englishme.config.AppSecurityProperties;
import vn.id.kieuanhdev.englishme.entity.auth.Role;

@Service
public class JwtService {
	private final AppSecurityProperties props;
	private final SecretKey key;

	public JwtService(AppSecurityProperties props) {
		this.props = props;
		this.key = decodeSecret(props.secret());
	}

	public String createAccessToken(UUID userId, String email, Role role) {
		var now = Instant.now();
		var exp = now.plus(props.accessTtl());
		return Jwts.builder()
			.issuer(props.issuer())
			.subject(userId.toString())
			.issuedAt(Date.from(now))
			.expiration(Date.from(exp))
			.claims(Map.of(
				"email", email,
				"roles", List.of(role.name())
			))
			.signWith(key, Jwts.SIG.HS256)
			.compact();
	}

	public Claims parseAndValidate(String jwt) {
		return Jwts.parser()
			.verifyWith(key)
			.requireIssuer(props.issuer())
			.build()
			.parseSignedClaims(jwt)
			.getPayload();
	}

	private static SecretKey decodeSecret(String secret) {
		if (secret == null || secret.isBlank()) {
			throw new IllegalArgumentException("JWT secret is missing");
		}
		byte[] raw;
		try {
			raw = Base64.getDecoder().decode(secret);
		} catch (IllegalArgumentException ignored) {
			raw = secret.getBytes(StandardCharsets.UTF_8);
		}
		if (raw.length < 32) {
			throw new IllegalArgumentException("JWT secret must be at least 256-bit (32 bytes)");
		}
		return Keys.hmacShaKeyFor(raw);
	}
}
