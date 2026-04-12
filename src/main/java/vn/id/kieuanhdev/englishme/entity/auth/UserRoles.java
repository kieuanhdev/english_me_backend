package vn.id.kieuanhdev.englishme.entity.auth;

import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/** Chuỗi roles trên {@link User#roles}; tách khỏi entity để Hibernate không map nhầm getter. */
public final class UserRoles {
	private UserRoles() {}

	public static Set<Role> parse(String roles) {
		if (roles == null || roles.isBlank()) return Set.of();
		return java.util.Arrays.stream(roles.split(","))
			.map(String::trim)
			.filter(s -> !s.isBlank())
			.map(Role::valueOf)
			.collect(Collectors.toUnmodifiableSet());
	}

	public static String format(Set<Role> roleSet) {
		if (roleSet == null || roleSet.isEmpty()) return "";
		return roleSet.stream()
			.filter(Objects::nonNull)
			.map(Enum::name)
			.sorted()
			.collect(Collectors.joining(","));
	}
}
