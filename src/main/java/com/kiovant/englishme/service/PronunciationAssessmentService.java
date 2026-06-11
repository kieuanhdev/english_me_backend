package com.kiovant.englishme.service;

import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.AdminPronunciationAttemptRow;
import com.kiovant.englishme.dto.PronunciationInsightResponse;
import com.kiovant.englishme.entity.PronunciationAttempt;
import com.kiovant.englishme.entity.PronunciationWordFeedback;
import com.kiovant.englishme.entity.User;
import com.kiovant.englishme.repository.PronunciationAttemptRepository;
import com.kiovant.englishme.repository.PronunciationWordFeedbackRepository;
import com.kiovant.englishme.repository.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class PronunciationAssessmentService {
    private static final Logger log = LoggerFactory.getLogger(PronunciationAssessmentService.class);

    private static final int MAX_REFERENCE_LENGTH = 300;

    private final UserRepository userRepository;
    private final PronunciationAttemptRepository attemptRepository;
    private final PronunciationWordFeedbackRepository wordFeedbackRepository;
    private final PronunciationRateLimiter pronunciationRateLimiter;
    private final LevenshteinPronunciationScorer levenshteinPronunciationScorer;
    private final GoogleSttService googleSttService;

    public PronunciationAssessmentService(
            UserRepository userRepository,
            PronunciationAttemptRepository attemptRepository,
            PronunciationWordFeedbackRepository wordFeedbackRepository,
            PronunciationRateLimiter pronunciationRateLimiter,
            LevenshteinPronunciationScorer levenshteinPronunciationScorer,
            GoogleSttService googleSttService
    ) {
        this.userRepository = userRepository;
        this.attemptRepository = attemptRepository;
        this.wordFeedbackRepository = wordFeedbackRepository;
        this.pronunciationRateLimiter = pronunciationRateLimiter;
        this.levenshteinPronunciationScorer = levenshteinPronunciationScorer;
        this.googleSttService = googleSttService;
    }

    /**
     * Chấm phát âm dựa trên transcript (text người dùng nói được từ STT trên mobile)
     * thay vì gửi audio. Dùng thuật toán Levenshtein Distance để so với câu mẫu.
     *
     * Đây là luồng fallback khi Cloud STT chưa bật / lỗi (mobile tự STT on-device).
     */
    @Transactional
    public PronunciationAssessResponse assessText(
            String firebaseUid,
            String referenceText,
            String spokenText,
            UUID exerciseId
    ) {
        String safeReference = validateReference(referenceText);
        if (spokenText == null || spokenText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "spokenText is required");
        }
        String safeSpoken = spokenText.trim();
        if (safeSpoken.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "spokenText is too long");
        }

        pronunciationRateLimiter.checkOrThrow(firebaseUid);
        User user = loadUser(firebaseUid);
        return scoreAndPersist(user, safeReference, safeSpoken, exerciseId, "levenshtein");
    }

    /**
     * Chấm phát âm từ AUDIO thật: nhận file audio -> Google Cloud Speech-to-Text ra
     * transcript -> Levenshtein chấm so câu mẫu (đáp ứng đề cương MT4).
     *
     * @return null nếu STT chưa bật hoặc không nhận ra tiếng nói (controller fallback
     *         báo client tự gửi transcript on-device qua assess-text).
     */
    @Transactional
    public PronunciationAssessResponse assessAudio(
            String firebaseUid,
            String referenceText,
            byte[] audioBytes,
            UUID exerciseId
    ) {
        String safeReference = validateReference(referenceText);
        if (!googleSttService.isConfigured()) {
            return null;
        }
        pronunciationRateLimiter.checkOrThrow(firebaseUid);
        User user = loadUser(firebaseUid);

        String transcript = googleSttService.transcribe(audioBytes).trim();
        if (transcript.isEmpty()) {
            log.warn("pronunciation_audio_stt_empty firebaseUid={} — fallback client transcript", firebaseUid);
            return null;
        }
        if (transcript.length() > MAX_REFERENCE_LENGTH) {
            transcript = transcript.substring(0, MAX_REFERENCE_LENGTH);
        }
        return scoreAndPersist(user, safeReference, transcript, exerciseId, "google-stt");
    }

    /** Chấm Levenshtein + lưu attempt + word feedback. Dùng chung cho text & audio. */
    private PronunciationAssessResponse scoreAndPersist(
            User user, String safeReference, String safeSpoken, UUID exerciseId, String provider) {
        PronunciationAssessResponse response = levenshteinPronunciationScorer.score(safeReference, safeSpoken);

        PronunciationAttempt attempt = new PronunciationAttempt();
        attempt.setUser(user);
        attempt.setExerciseId(exerciseId);
        attempt.setReferenceText(safeReference);
        attempt.setProvider(provider);
        attempt.setOverallScore((int) Math.round(response.score()));
        attempt.setAccuracyScore((int) Math.round(response.accuracy()));
        attempt.setFluencyScore((int) Math.round(response.fluency()));
        attempt.setCompletenessScore((int) Math.round(response.completeness()));
        attempt.setTranscription(response.transcription());
        attempt = attemptRepository.save(attempt);
        log.info("pronunciation_attempt_saved provider={} attemptId={} score={} accuracy={} completeness={}",
                provider, attempt.getId(), response.score(), response.accuracy(), response.completeness());

        List<PronunciationWordFeedback> feedbackEntities = new ArrayList<>();
        for (var err : response.errors()) {
            PronunciationWordFeedback item = new PronunciationWordFeedback();
            item.setAttempt(attempt);
            item.setWord(err.word());
            item.setScore(0);
            item.setStartMs(0);
            item.setEndMs(0);
            item.setIssueType("critical");
            item.setSuggestion(err.suggestion());
            feedbackEntities.add(item);
        }
        wordFeedbackRepository.saveAll(feedbackEntities);
        return response;
    }

    private String validateReference(String referenceText) {
        if (referenceText == null || referenceText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is required");
        }
        String safeReference = referenceText.trim();
        if (safeReference.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is too long");
        }
        return safeReference;
    }

    private User loadUser(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    /**
     * Insight cá nhân hóa: tổng hợp lịch sử phát âm của user thành điểm TB, các từ yếu nhất
     * (xếp theo mức lỗi nặng rồi điểm thấp), và phân bố mức độ lỗi.
     *
     * @param limit số từ yếu trả về (clamp [1, 50]).
     */
    @Transactional(readOnly = true)
    public PronunciationInsightResponse insights(String firebaseUid, int limit) {
        int safeLimit = Math.min(Math.max(limit, 1), 50);

        long totalAttempts = attemptRepository.countByUser_FirebaseUid(firebaseUid);
        Double avg = attemptRepository.averageOverallScore(firebaseUid);
        int averageScore = avg == null ? 0 : (int) Math.round(avg);

        List<PronunciationInsightResponse.WeakWord> weakWords = new ArrayList<>();
        for (Object[] row : wordFeedbackRepository.findWeakWords(firebaseUid, PageRequest.of(0, safeLimit))) {
            String word = (String) row[0];
            int avgScore = row[1] == null ? 0 : ((Number) row[1]).intValue();
            long attempts = row[2] == null ? 0 : ((Number) row[2]).longValue();
            int worstRank = row[3] == null ? 2 : ((Number) row[3]).intValue();
            String suggestion = (String) row[4];
            weakWords.add(new PronunciationInsightResponse.WeakWord(
                    word, avgScore, attempts, rankToIssueType(worstRank), suggestion));
        }

        long good = 0;
        long minor = 0;
        long critical = 0;
        for (Object[] row : wordFeedbackRepository.countByIssueType(firebaseUid)) {
            String issueType = (String) row[0];
            long count = row[1] == null ? 0 : ((Number) row[1]).longValue();
            switch (issueType == null ? "" : issueType) {
                case "good" -> good = count;
                case "minor" -> minor = count;
                case "critical" -> critical = count;
                default -> { /* bỏ qua issue_type lạ */ }
            }
        }

        return new PronunciationInsightResponse(
                totalAttempts,
                averageScore,
                weakWords,
                new PronunciationInsightResponse.IssueBreakdown(good, minor, critical)
        );
    }

    /** Đảo rank severity (0/1/2) về chuỗi issue_type. */
    private static String rankToIssueType(int rank) {
        return switch (rank) {
            case 0 -> "critical";
            case 1 -> "minor";
            default -> "good";
        };
    }


    @Transactional(readOnly = true)
    public Page<AdminPronunciationAttemptRow> adminList(String provider, int minScore, String keyword, int page, int size) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 100);
        int safeMinScore = Math.min(Math.max(minScore, 0), 100);
        String safeProvider = provider == null ? "" : provider.trim();
        String safeKeyword = keyword == null ? "" : keyword.trim();

        return attemptRepository.findForAdmin(safeProvider, safeMinScore, safeKeyword, PageRequest.of(safePage, safeSize))
                .map(item -> new AdminPronunciationAttemptRow(
                        item.getId(),
                        item.getUser().getEmail(),
                        item.getUser().getFullName(),
                        item.getUser().getFirebaseUid(),
                        item.getExerciseId(),
                        item.getReferenceText(),
                        item.getOverallScore(),
                        item.getAccuracyScore(),
                        item.getFluencyScore(),
                        item.getProvider(),
                        item.getCreatedAt()
                ));
    }
}
