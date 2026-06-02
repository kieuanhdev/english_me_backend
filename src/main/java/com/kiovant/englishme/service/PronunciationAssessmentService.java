package com.kiovant.englishme.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.kiovant.englishme.dto.PronunciationAssessResponse;
import com.kiovant.englishme.dto.AdminPronunciationAttemptRow;
import com.kiovant.englishme.dto.PronunciationAttemptHistoryItemResponse;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class PronunciationAssessmentService {
    private static final Logger log = LoggerFactory.getLogger(PronunciationAssessmentService.class);

    private static final int MAX_AUDIO_BYTES = 3 * 1024 * 1024;
    private static final int MAX_REFERENCE_LENGTH = 300;

    private final UserRepository userRepository;
    private final PronunciationAttemptRepository attemptRepository;
    private final PronunciationWordFeedbackRepository wordFeedbackRepository;
    private final CloudPronunciationClient cloudPronunciationClient;
    private final PronunciationScoringMapper pronunciationScoringMapper;
    private final PronunciationRateLimiter pronunciationRateLimiter;
    private final DeepSeekPronunciationScorer deepSeekPronunciationScorer;

    public PronunciationAssessmentService(
            UserRepository userRepository,
            PronunciationAttemptRepository attemptRepository,
            PronunciationWordFeedbackRepository wordFeedbackRepository,
            CloudPronunciationClient cloudPronunciationClient,
            PronunciationScoringMapper pronunciationScoringMapper,
            PronunciationRateLimiter pronunciationRateLimiter,
            DeepSeekPronunciationScorer deepSeekPronunciationScorer
    ) {
        this.userRepository = userRepository;
        this.attemptRepository = attemptRepository;
        this.wordFeedbackRepository = wordFeedbackRepository;
        this.cloudPronunciationClient = cloudPronunciationClient;
        this.pronunciationScoringMapper = pronunciationScoringMapper;
        this.pronunciationRateLimiter = pronunciationRateLimiter;
        this.deepSeekPronunciationScorer = deepSeekPronunciationScorer;
    }

    @Transactional
    public PronunciationAssessResponse assess(
            String firebaseUid,
            MultipartFile audio,
            String referenceText,
            String language,
            UUID exerciseId
    ) {
        if (audio == null || audio.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "audio is required");
        }
        if (audio.getSize() > MAX_AUDIO_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "audio is too large (max 3MB)");
        }
        String contentType = audio.getContentType();
        if (contentType == null || (!contentType.contains("audio") && !contentType.contains("octet-stream"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "unsupported audio content type");
        }
        if (referenceText == null || referenceText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is required");
        }
        String safeReference = referenceText.trim();
        if (safeReference.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is too long");
        }

        pronunciationRateLimiter.checkOrThrow(firebaseUid);
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        byte[] bytes;
        try {
            bytes = audio.getBytes();
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cannot read audio payload");
        }

        JsonNode providerResult = cloudPronunciationClient.assess(bytes, safeReference, language);
        PronunciationAssessResponse response = pronunciationScoringMapper.mapSpeechace(providerResult, safeReference);

        PronunciationAttempt attempt = new PronunciationAttempt();
        attempt.setUser(user);
        attempt.setExerciseId(exerciseId);
        attempt.setReferenceText(safeReference);
        attempt.setProvider(cloudPronunciationClient.providerName());
        attempt.setOverallScore((int) Math.round(response.score()));
        attempt.setAccuracyScore((int) Math.round(response.accuracy()));
        attempt.setFluencyScore((int) Math.round(response.fluency()));
        attempt.setCompletenessScore((int) Math.round(response.completeness()));
        attempt.setTranscription(response.transcription());
        attempt = attemptRepository.save(attempt);
        log.info("pronunciation_attempt_saved attemptId={} score={} accuracy={} fluency={} completeness={}",
                attempt.getId(), response.score(), response.accuracy(), response.fluency(), response.completeness());

        JsonNode textScore = providerResult.path("text_score");
        List<PronunciationWordFeedback> feedbackEntities = new ArrayList<>();
        for (JsonNode word : textScore.path("word_score_list")) {
            String token = word.path("word").asText("").trim();
            if (token.isEmpty()) {
                continue;
            }
            int wordScore = clampScore(word.path("quality_score").asInt(0));
            int startMs = (int) Math.round(word.path("start").asDouble(0) * 1000);
            int endMs = (int) Math.round(word.path("end").asDouble(0) * 1000);
            String issueType = wordScore >= 80 ? "good" : (wordScore >= 60 ? "minor" : "critical");
            PronunciationWordFeedback item = new PronunciationWordFeedback();
            item.setAttempt(attempt);
            item.setWord(token);
            item.setScore(wordScore);
            item.setStartMs(startMs);
            item.setEndMs(endMs);
            item.setIssueType(issueType);
            item.setSuggestion(null);
            feedbackEntities.add(item);
        }
        wordFeedbackRepository.saveAll(feedbackEntities);
        return response;
    }

    /**
     * Chấm phát âm dựa trên transcript (text người dùng nói được từ STT trên mobile)
     * thay vì gửi audio. Dùng DeepSeek (fallback Levenshtein) để so với câu mẫu.
     */
    @Transactional
    public PronunciationAssessResponse assessText(
            String firebaseUid,
            String referenceText,
            String spokenText,
            UUID exerciseId
    ) {
        if (referenceText == null || referenceText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is required");
        }
        if (spokenText == null || spokenText.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "spokenText is required");
        }
        String safeReference = referenceText.trim();
        if (safeReference.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "referenceText is too long");
        }
        String safeSpoken = spokenText.trim();
        if (safeSpoken.length() > MAX_REFERENCE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "spokenText is too long");
        }

        pronunciationRateLimiter.checkOrThrow(firebaseUid);
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        PronunciationAssessResponse response = deepSeekPronunciationScorer.score(safeReference, safeSpoken);

        PronunciationAttempt attempt = new PronunciationAttempt();
        attempt.setUser(user);
        attempt.setExerciseId(exerciseId);
        attempt.setReferenceText(safeReference);
        attempt.setProvider("deepseek");
        attempt.setOverallScore((int) Math.round(response.score()));
        attempt.setAccuracyScore((int) Math.round(response.accuracy()));
        attempt.setFluencyScore((int) Math.round(response.fluency()));
        attempt.setCompletenessScore((int) Math.round(response.completeness()));
        attempt.setTranscription(response.transcription());
        attempt = attemptRepository.save(attempt);
        log.info("pronunciation_text_attempt_saved attemptId={} score={} accuracy={} completeness={}",
                attempt.getId(), response.score(), response.accuracy(), response.completeness());

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

    @Transactional(readOnly = true)
    public List<PronunciationAttemptHistoryItemResponse> history(String firebaseUid, UUID exerciseId, int limit) {
        int safeLimit = Math.min(Math.max(limit, 1), 50);
        List<PronunciationAttempt> attempts = exerciseId == null
                ? attemptRepository.findByUser_FirebaseUidOrderByCreatedAtDesc(firebaseUid, PageRequest.of(0, safeLimit))
                : attemptRepository.findByUser_FirebaseUidAndExerciseIdOrderByCreatedAtDesc(firebaseUid, exerciseId, PageRequest.of(0, safeLimit));

        return attempts.stream().map(item -> new PronunciationAttemptHistoryItemResponse(
                item.getId(),
                item.getExerciseId(),
                item.getReferenceText(),
                item.getOverallScore(),
                item.getAccuracyScore(),
                item.getFluencyScore(),
                item.getProvider(),
                item.getCreatedAt()
        )).toList();
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

    private static int clampScore(int score) {
        return Math.min(Math.max(score, 0), 100);
    }
}
