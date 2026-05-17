package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationWordFeedback;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface PronunciationWordFeedbackRepository extends JpaRepository<PronunciationWordFeedback, UUID> {

    /**
     * Trả về [word, count, avgScore] cho top word có điểm thấp nhất (chỉ tính word xuất hiện ≥ 3 lần).
     */
    @Query("""
            SELECT LOWER(w.word), COUNT(w), AVG(w.score)
            FROM PronunciationWordFeedback w
            GROUP BY LOWER(w.word)
            HAVING COUNT(w) >= 3
            ORDER BY AVG(w.score) ASC, COUNT(w) DESC
            """)
    List<Object[]> findWeakestWords(Pageable pageable);

    /** Top issue_type theo tần suất. */
    @Query("""
            SELECT w.issueType, COUNT(w)
            FROM PronunciationWordFeedback w
            GROUP BY w.issueType
            ORDER BY COUNT(w) DESC
            """)
    List<Object[]> countByIssueType();
}
