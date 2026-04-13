package vn.id.kieuanhdev.englishme.repository.placement;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import vn.id.kieuanhdev.englishme.entity.auth.CefrLevel;
import vn.id.kieuanhdev.englishme.entity.placement.CefrQuestion;

public interface CefrQuestionRepository extends JpaRepository<CefrQuestion, UUID>, JpaSpecificationExecutor<CefrQuestion> {
	long countByCefrBandAndDeletedAtIsNullAndActiveTrue(CefrLevel cefrBand);
}
