package vn.id.kieuanhdev.englishme.repository.vocabulary;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.data.jpa.domain.Specification;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;

public final class VocabularySpecs {
	private VocabularySpecs() {
	}

	public static Specification<Vocabulary> adminList(String q, boolean includeDeleted) {
		return (root, query, cb) -> {
			List<Predicate> parts = new ArrayList<>();
			if (!includeDeleted) {
				parts.add(cb.isNull(root.get("deletedAt")));
			}
			if (q != null && !q.isBlank()) {
				String like = "%" + q.trim().toLowerCase(Locale.ROOT) + "%";
				parts.add(cb.or(
					cb.like(cb.lower(root.get("word")), like),
					cb.like(cb.lower(root.get("meaningVi")), like)
				));
			}
			return cb.and(parts.toArray(Predicate[]::new));
		};
	}
}
