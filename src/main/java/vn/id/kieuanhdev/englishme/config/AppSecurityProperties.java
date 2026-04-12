package vn.id.kieuanhdev.englishme.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security.jwt")
public record AppSecurityProperties(
	String issuer,
	String secret,
	long accessTokenTtlSeconds,
	long refreshTokenTtlSeconds
) {
	public Duration accessTtl() {
		return Duration.ofSeconds(accessTokenTtlSeconds);
	}

	public Duration refreshTtl() {
		return Duration.ofSeconds(refreshTokenTtlSeconds);
	}
}
