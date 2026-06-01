package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.VocabularyWord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface VocabularyWordRepository extends JpaRepository<VocabularyWord, UUID> {

    List<VocabularyWord> findByTopic_IdOrderByWordAsc(UUID topicId);

    List<VocabularyWord> findByLevelIgnoreCaseOrderByWordAsc(String level);

    @Query("""
            SELECT w FROM VocabularyWord w
            WHERE w.topic.id = :topicId
              AND (:keyword IS NULL OR :keyword = ''
                   OR LOWER(w.word) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(COALESCE(w.definitionVi, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(COALESCE(w.definitionEn, '')) LIKE LOWER(CONCAT('%', :keyword, '%')))
            ORDER BY w.word ASC
            """)
    List<VocabularyWord> searchWordsByTopic(@Param("topicId") UUID topicId, @Param("keyword") String keyword);

    boolean existsByTopic_IdAndWordIgnoreCase(UUID topicId, String word);

    @Query("""
            SELECT w.word, COUNT(w) FROM VocabularyWord w
            WHERE w.topic.id = :topicId
            GROUP BY w.word
            HAVING COUNT(w) > 1
            """)
    List<Object[]> findDuplicateWordsByTopic(@Param("topicId") UUID topicId);
}
