package vn.id.kieuanhdev.englishme.repository.vocabulary;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;

public interface VocabularyRepository extends JpaRepository<Vocabulary, UUID> {
}
