package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.DictationSentence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface DictationSentenceRepository extends JpaRepository<DictationSentence, UUID> {

    /** Câu dictation theo level (CEFR user), ngẫu nhiên. */
    @Query(value = """
            SELECT * FROM dictation_sentence
            WHERE UPPER(cefr_level) = :levelUpper
            ORDER BY random() LIMIT :size
            """, nativeQuery = true)
    List<DictationSentence> findRandomByLevel(String levelUpper, int size);

    /** Fallback: bỏ lọc level khi kho câu đúng level không đủ. */
    @Query(value = "SELECT * FROM dictation_sentence ORDER BY random() LIMIT :size", nativeQuery = true)
    List<DictationSentence> findRandom(int size);
}
