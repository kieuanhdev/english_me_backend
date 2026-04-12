package vn.id.kieuanhdev.englishme.security.auth;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import vn.id.kieuanhdev.englishme.service.auth.JwtService;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {
	private final JwtService jwtService;

	public JwtAuthFilter(JwtService jwtService) {
		this.jwtService = jwtService;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
		throws ServletException, IOException {
		var auth = request.getHeader("Authorization");
		if (auth == null || !auth.startsWith("Bearer ")) {
			filterChain.doFilter(request, response);
			return;
		}

		var token = auth.substring("Bearer ".length()).trim();
		if (token.isBlank()) {
			filterChain.doFilter(request, response);
			return;
		}

		try {
			Claims claims = jwtService.parseAndValidate(token);
			var userId = UUID.fromString(claims.getSubject());
			@SuppressWarnings("unchecked")
			var roles = (List<String>) claims.get("roles", List.class);
			Collection<? extends GrantedAuthority> authorities = roles == null
				? List.of()
				: roles.stream().map(r -> new SimpleGrantedAuthority("ROLE_" + r)).toList();

			var authentication = new UsernamePasswordAuthenticationToken(userId, null, authorities);
			SecurityContextHolder.getContext().setAuthentication(authentication);
		} catch (Exception ignored) {
			// ignore invalid token and continue; Security will block protected endpoints
		}

		filterChain.doFilter(request, response);
	}
}
