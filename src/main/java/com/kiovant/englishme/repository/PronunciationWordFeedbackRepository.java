package com.kiovant.englishme.repository;

import com.kiovant.englishme.entity.PronunciationWordFeedback;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface PronunciationWordFeedbackRepository extends JpaRepository<PronunciationWordFeedback, UUID> {

    /**
     * Gộp feedback theo từ (chuẩn hóa lowercase) cho 1 user, sắp xếp ưu tiên theo mức lỗi
     * nặng nhất rồi điểm thấp nhất.
     *
     * <p>Sắp xếp dùng severity rank để xử lý cả 2 provider:
     * <ul>
     *   <li>SpeechAce: score thật, issue_type suy từ score.</li>
     *   <li>DeepSeek: score luôn = 0, issue_type = 'critical' (chỉ lưu từ sai).</li>
     * </ul>
     * Rank: critical=0, minor=1, good=2 -> ORDER tăng dần đẩy 'critical' lên đầu.
     *
     * <p>Cột trả về (theo thứ tự projection):
     * word, avgScore, attempts, worstIssueType, suggestion.
     */
    @Query(value = """
            SELECT LOWER(f.word)                              AS word,
                   CAST(ROUND(AVG(f.score)) AS INT)           AS avg_score,
                   COUNT(*)                                   AS attempts,
                   MIN(CASE f.issue_type
                           WHEN 'critical' THEN 0
                           WHEN 'minor'    THEN 1
                           ELSE 2 END)                        AS worst_rank,
                   MAX(f.suggestion)                          AS suggestion
            FROM pronunciation_word_feedback f
            JOIN pronunciation_attempt a ON a.id = f.attempt_id
            JOIN users u ON u.id = a.user_id
            WHERE u.firebase_uid = :firebaseUid
            GROUP BY LOWER(f.word)
            ORDER BY worst_rank ASC, avg_score ASC, attempts DESC
            """, nativeQuery = true)
    List<Object[]> findWeakWords(@Param("firebaseUid") String firebaseUid, Pageable pageable);

    /** Đếm feedback theo issue_type cho 1 user. Trả về (issue_type, count). */
    @Query(value = """
            SELECT f.issue_type AS issue_type, COUNT(*) AS cnt
            FROM pronunciation_word_feedback f
            JOIN pronunciation_attempt a ON a.id = f.attempt_id
            JOIN users u ON u.id = a.user_id
            WHERE u.firebase_uid = :firebaseUid
            GROUP BY f.issue_type
            """, nativeQuery = true)
    List<Object[]> countByIssueType(@Param("firebaseUid") String firebaseUid);
}
