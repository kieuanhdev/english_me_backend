package vn.id.kieuanhdev.englishme.repository.placement;

import org.springframework.data.jpa.domain.Specification;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.placement.CefrQuestion;
import vn.id.kieuanhdev.englishme.entity.placement.PlacementSkillType;

public final class CefrQuestionSpecs {
	private CefrQuestionSpecs() {
	}

	public static Specification<CefrQuestion> filter(CefrLevel cefrBand, PlacementSkillType skillType, boolean includeDeleted) {
		return (root, query, cb) -> {
			var p = cb.conjunction();
			if (!includeDeleted) {
				p = cb.and(p, cb.isNull(root.get("deletedAt")));
			}
			if (cefrBand != null) {
				p = cb.and(p, cb.equal(root.get("cefrBand"), cefrBand));
			}
			if (skillType != null) {
				p = cb.and(p, cb.equal(root.get("skillType"), skillType));
			}
			return p;
		};
	}
}
