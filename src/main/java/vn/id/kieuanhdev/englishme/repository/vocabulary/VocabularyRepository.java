package vn.id.kieuanhdev.englishme.repository.vocabulary;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.id.kieuanhdev.englishme.entity.vocabulary.Vocabulary;

public interface VocabularyRepository extends JpaRepository<Vocabulary, UUID>, JpaSpecificationExecutor<Vocabulary> {
	Optional<Vocabulary> findByIdAndDeletedAtIsNull(UUID id);

	boolean existsByWordIgnoreCaseAndDeletedAtIsNull(String word);

	boolean existsByWordIgnoreCaseAndDeletedAtIsNullAndIdNot(String word, UUID id);

	@Query(
		"""
		select lower(trim(v.word)) from Vocabulary v
		where v.deletedAt is null and lower(trim(v.word)) in :words
		"""
	)
	List<String> findActiveWordsLowerTrimmedIn(@Param("words") Collection<String> words);
}
