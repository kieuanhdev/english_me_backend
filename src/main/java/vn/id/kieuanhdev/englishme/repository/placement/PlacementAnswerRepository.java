package vn.id.kieuanhdev.englishme.repository.placement;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.id.kieuanhdev.englishme.entity.placement.PlacementAnswer;

public interface PlacementAnswerRepository extends JpaRepository<PlacementAnswer, UUID> {
	long countByQuestion_Id(UUID questionId);
}
